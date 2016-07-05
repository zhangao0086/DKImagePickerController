//
// Created by BLACKGENE on 2015. 2. 9..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "NSArray+BlocksKit.h"
#import "STExportManager.h"
#import "STGIFFAppSetting.h"
#import "STExporter+Config.h"
#import "NSObject+BNRTimeBlock.h"
#import "NSSet+STUtil.h"
#import "NSString+STUtil.h"
#import "STExporter+URL.h"
#import "NSObject+STUtil.h"
#import "STSLComposeViewExporter.h"
#import "STQueueManager.h"
#import "STExporter+View.h"
#import "STExporter+ConfigGIF.h"

#define INTERVAL_TIMEOUT_AFTER_EXPORT 10
#define ID_INTERVAL_TIMEOUT_AFTER_EXPORT @"ExportManager.timeout"

@implementation STExportManager {
    NSMutableDictionary *_createdExporters;
    NSArray *_targetPhotoItems;
}

+ (STExportManager *)sharedManager {
    static STExportManager *_instance = nil;
    BlockOnce(^{
        _instance = [[self alloc] init];
        _instance->_createdExporters = [NSMutableDictionary dictionaryWithCapacity:STExportType_count];
    });
    return _instance;
}

#pragma mark Publics
static NSArray *_avaliableExporterTypes;
- (void)setup{
    BlockOnce(^{
        _avaliableExporterTypes = [[STGIFFAppSetting valuesExportType] bk_select:^BOOL(id obj) {
            //gain class
            Class exporterClass = [STExporter exporterClassWithType:(STExportType) [obj integerValue]];

            //check unhandled export type
            if([exporterClass isKindOfClass:NSNull.class]){
                return NO;
            }

            //caching can open url
            dispatch_async([STQueueManager sharedQueue].starting, ^{
                [exporterClass canOpenApp];
            });

            //check setup succeed
            return [exporterClass setup];
        }];

        [STSLComposeViewExporter precheckSLServiceAvailables];
    });
}

- (NSArray *)acquire:(NSArray *)photoItems{
    NSParameterAssert(photoItems.count>0);

    //return over count
    if(photoItems.count > MAX_ALLOWED_EXPORT_COUNT){
        return _acquiredTypes;
    }

    //finish previous
    [self finish];

    //(GIF) extensible resources are required
    BOOL shouldGIFsExporting = [STExporter shouldExportGIF:photoItems];

    Weaks
    // prepare
    NSArray *targetExporterTypes = [_avaliableExporterTypes bk_select:^BOOL(id obj) {
        STExportType type = (STExportType) [obj integerValue];

        Strongs
        //check application state
        if ([STExporter isAllowedByCurrentApplicationState:type]
                //check needed extensible content
                && (!shouldGIFsExporting || [STExporter isAllowedToExportGIF:type])
                //check allowed item count
                && photoItems.count <= [STExporter allowedCount:type]) {

            STExporter *exporter = [self st_cachedObject:[@"exporter" st_add:[@(type) stringValue]] init:^id {
                return [STExporter exporterWithType:type];
            }];
//            STExporter *exporter = [STExporter exporterWithType:type];
            exporter.photoItems = photoItems;

            BOOL prepared;
            if (STGIFFApp.isDebugMode) {
                __block BOOL _prepared;
                [Sself ckTime:^{
                    _prepared = [exporter prepare];
                }      symbol:[@"^ prepared : " st_add:exporter.serviceName]];
                prepared = _prepared;

            } else {
                prepared = [exporter prepare];
            }

            if (prepared) {
                Sself->_createdExporters[@(type)] = exporter;
                return YES;

            }else{
                [exporter finish];
                exporter = nil;
            }
        }
        return NO;
    }];

    // sorting
    targetExporterTypes = [targetExporterTypes sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Strongs
        STExporter *exporter1 = Sself->_createdExporters[obj1];
        STExporter *exporter2 = Sself->_createdExporters[obj2];
        BOOL orderDescending = NO;

        NSSet *locSet1 = [[exporter1 class] primarySupportedLocaleCodes];
        NSSet *locSet2 = [[exporter2 class] primarySupportedLocaleCodes];
        NSSet *locCodes = [NSSet setWithArray:[STGIFFApp localeCodes]];

        //language + locales
        BOOL primarySet1 = locSet1 && [locSet1 intersectsSet:locCodes];
        BOOL primarySet2 = locSet2 && [locSet2 intersectsSet:locCodes];
        orderDescending |= !primarySet1 && primarySet2; //supported?
        orderDescending |= (primarySet1 && primarySet2) && [locSet2 st_intersectsSet:locCodes].count > [locSet1 st_intersectsSet:locCodes].count; //more wide if both supported?

        //fallback
        orderDescending |= exporter1.shouldFallback && !exporter2.shouldFallback;

        return orderDescending ? NSOrderedDescending : NSOrderedSame;
    }];

    _targetPhotoItems = targetExporterTypes.count ? photoItems : nil;
    _acquiredTypes = targetExporterTypes;
    return targetExporterTypes;
}

- (void)finish{
    //clear timeout when only (STExporter.shouldWaitUsersInteraction == NO)
    [self st_clearPerformOnceAfterDelay:ID_INTERVAL_TIMEOUT_AFTER_EXPORT];

    //clear stored exporter instances.
    if(!_createdExporters.count){
        return;
    }
    for(id type in [_createdExporters keyEnumerator]){
        [_createdExporters[type] finish];
    }
    [_createdExporters removeAllObjects];

    //clear global properties
    _acquiredTypes = nil;

    _targetPhotoItems = nil;

    [_currentExporter whenValueOf:@keypath(_currentExporter.processing) id:@keypath(_currentExporter.processing) changed:nil];
    _currentExporter = nil;
}

#pragma mark Export
- (BOOL)ready:(STExportType)type;{
    return [[_createdExporters allKeys] containsObject:@(type)];
}

- (BOOL)export:(STExportType)type; {
    return [self export:type finished:nil];
}

- (BOOL)export:(STExportType)type finished:(void (^)(STExportResult))block{
   return [self export:type processing:nil finished:block];
}

- (BOOL)export:(STExportType)type processing:(void (^)(BOOL processing))processingBlock finished:(void (^)(STExportResult))block{
    return [self export:type will:nil processing:processingBlock finished:block];
}

- (BOOL)export:(STExportType)type will:(void (^)(STExporter * exporter))willBlock processing:(void (^)(BOOL processing))processingBlock finished:(void (^)(STExportResult))block{
    @synchronized (@(type)) {
        NSAssert(!_currentExporter, @"aleady finished.");
        NSAssert([self ready:type], ([NSString stringWithFormat:@"can't export because didn't prepared yet. STExportType type : %d", type]));
        NSAssert(_targetPhotoItems.count, ([NSString stringWithFormat:@"can't fine _preparedPhotos : %d", type]));

        Weaks

        //setup
        _currentExporter = _createdExporters[@(type)];

        !willBlock?:willBlock(_currentExporter);

        [_currentExporter whenFinished:^(STExporter * __weak exporter, STExportResult result) {
            !block?:block(result);
            [Wself finish];
        }];

        [_currentExporter whenValueOf:@keypath(_currentExporter.processing) id:@keypath(_currentExporter.processing) changed:!processingBlock ? nil : ^(id value, id _weakSelf) {
            processingBlock([value boolValue]);
        }];

        //check timeout
        if(!_currentExporter.shouldWaitUsersInteraction){
            [self st_performOnceAfterDelay:ID_INTERVAL_TIMEOUT_AFTER_EXPORT interval:INTERVAL_TIMEOUT_AFTER_EXPORT block:^{
                Strongs
                [Sself->_currentExporter whenFinished:nil];
                !block?:block(STExportResultFailed);
                [Wself finish];
            }];
        }else{
            [self st_clearPerformOnceAfterDelay:ID_INTERVAL_TIMEOUT_AFTER_EXPORT];
        }

        //check fallback
        if(_currentExporter.shouldFallback){
            [_currentExporter fallback];
            return NO;
        }

        //export
        if(_currentExporter.shouldNeedViewWhenExport){
            [_currentExporter openExporterView:^{
                [self exportCurrent];
            }];
            return YES;

        }else{
            return [self exportCurrent];
        }
    }
}

- (BOOL)exportCurrent{
    //export
    if([_currentExporter export]){
        return YES;
    }else{
        [_currentExporter dispatchFinshed:STExportResultImpossible];
        return NO;
    }
}

- (BOOL)handle:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation; {
    return [self.currentExporter handleOpenURL:application url:url sourceApplication:sourceApplication annotation:annotation];
}

@end