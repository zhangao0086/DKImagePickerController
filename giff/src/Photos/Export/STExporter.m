//
// Created by BLACKGENE on 2014. 11. 1..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import "STExporter.h"
#import "STExporter+Config.h"
#import "STExporter+Handle.h"
#import "STExporter+URL.h"
#import "NSURL+STUtil.h"
#import "STExporter+IO.h"
#import "STExportView.h"
#import "STExporter+View.h"

NSString * const STExporterAuthorizationInputDataAccountKey = @"STExporterAuthorizationInputDataAccountKey";
NSString * const STExporterAuthorizationInputDataPasswordKey = @"STExporterAuthorizationInputDataAccountPassword";

//ref : https://github.com/ShareKit/ShareKit/tree/master/Classes/ShareKit/Sharers
@implementation STExporter {
    void (^_whenFinished)(STExporter *,STExportResult);
    STExporterViewOption * _viewOption;
}

#pragma mark instance

- (instancetype)initWithType:(STExportType)type; {
    self = [super init];
    if (self) {
        self.type = type;
        _allowedCount = [self.class allowedCount:type];
        _allowedFullResolution = [self.class isAllowedFullResolution:type];
        _shouldWaitUsersInteraction = [self.class isShouldWaitUsersInteraction:type];
    }
    return self;
}

+ (BOOL)setup; {
    return YES;
}

//http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
//http://www.ibabbleon.com/iOS-Language-Codes-ISO-639.html
+ (NSSet *)primarySupportedLocaleCodes {
    return nil;
}

- (void)dealloc; {
    NSLog(@"! dealloc %@", self.serviceName);
    [self finish];
}

- (void)setType:(STExportType)type; {
    _type = type;
}

- (NSString *)serviceName; {
    return [[NSStringFromClass(self.class) stringByReplacingOccurrencesOfString:NSStringFromClass(STExporter.class) withString:@""] capitalizedString];
}

- (void)setPhotoItems:(NSArray *)photoItems {
    NSAssert(photoItems,  @"photoItems is must be available.");
    NSAssert(photoItems.count <= self.allowedCount,  @"prepare : not allowed count");
    _photoItems = photoItems;
}

- (BOOL)prepare {
    return YES;
}

- (void)authorize:(NSDictionary *)inputData result:(void (^)(BOOL succeed, id data))block {
    NSAssert(self.shouldNeedAuthorize, @"self.shouldNeedAuthorize must be YES before authorize.");
    NSAssert(self.authorizationType!=STExporterAuthorizationTypeUndefined, @"self.authorizationType must not be STExporterAuthorizationTypeUndefined.");
}

- (BOOL)export{
    return NO;
}

- (void)fallback; {
    NSAssert(_shouldFallback,  @"fallback : self.shouldFallback. must be YES");

    if(self.fallbackAppStoreId || self.fallbackAppStoreURL){
        if([[UIApplication sharedApplication] openURL:self.fallbackAppStoreURL?:[NSURL URLForAppstoreApp:self.fallbackAppStoreId]]){
            [self dispatchFinshed:STExportResultFailedAndTriedFallback];
        }else{
            [self dispatchFinshed:STExportResultImpossible];
        }
    }else{
        [self dispatchFinshed:STExportResultImpossible];
    }
}

- (void)finish{
    @synchronized (self) {
        [self cancelAllExportJobs];
        [self cleanAllExportedResults];
        [self unregistDispatchSuccessWhenEnterBackground];
        _photoItems = nil;
        _viewOption = nil;
    }
}

- (void)whenFinished:(void (^)(STExporter * __weak, STExportResult))block; {
    _whenFinished = block;
}

- (void)dispatchFinshed:(STExportResult)result{
    [self dispatchStopProcessing];

    Weaks
    if(STExportView.view){
        [STExportView close:YES finshed:^ {
            !_whenFinished?:_whenFinished(Wself, result);
            _whenFinished = nil;
        }];

    }else{
        !_whenFinished?:_whenFinished(Wself, result);
        _whenFinished = nil;
    }
}

- (void)setShouldSucceesWhenEnterBackground:(BOOL)shouldSucceesWhenEnterBackground; {
    _shouldSucceesWhenEnterBackground = shouldSucceesWhenEnterBackground;

    if(shouldSucceesWhenEnterBackground){
        [self registDispatchSuccessWhenEnterBackground];
    }else{
        [self unregistDispatchSuccessWhenEnterBackground];
    }
}

- (STExporterViewOption *)viewOption {
    if(!_viewOption){
        _viewOption = [[STExporterViewOption alloc] init];
    }
    return _viewOption;
}

- (BOOL)shouldNeedViewWhenExport {
    return [STExporter allowedCount:self.type]>1 && self.photoItems.count>1;
}
@end