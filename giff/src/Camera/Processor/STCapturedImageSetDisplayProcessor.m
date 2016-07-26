//
// Created by BLACKGENE on 7/21/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageSetDisplayProcessor.h"
#import "STMultiSourcingImageProcessor.h"
#import "NSString+STUtil.h"
#import "NSArray+STUtil.h"
#import "STCapturedImageSet.h"
#import "STCapturedImageSetDisplayLayerSet.h"
#import "STCapturedImage.h"
#import "STCapturedImageSetDisplayLayer.h"

@interface STCapturedImageSetDisplayProcessor()
@property(nonatomic, readwrite) STCapturedImageSetDisplayLayerSet * targetLayerSet;
@end

@implementation STCapturedImageSetDisplayProcessor {
}
- (instancetype)initWithTargetLayer:(STCapturedImageSetDisplayLayerSet *)targetLayer {
    self = [super init];
    if (self) {
        _targetLayerSet = targetLayer;
    }
    return self;
}

+ (instancetype)processorWithTargetLayerSet:(STCapturedImageSetDisplayLayerSet *)targetLayer {
    return [[self alloc] initWithTargetLayer:targetLayer];
}

- (NSArray *)processResources {
    NSAssert(_targetLayerSet.layers.count,@"_targetLayer.layers is empty.");

    Weaks
    NSArray * processedResources = nil;
    if(_targetLayerSet.effect){
        processedResources = [self.resourcesSetToProcessFromSourceLayers mapWithIndex:^id(NSArray *resourceItemSet, NSInteger indexOfResourceItemSet) {
            NSAssert([[resourceItemSet firstObject] isKindOfClass:NSURL.class], @"only NSURL was allowed.");
#if DEBUG
            [resourceItemSet eachWithIndex:^(NSURL * object, NSUInteger index) {
                oo([object path]);
            }];
#endif
            @autoreleasepool {
                NSURL * tempURLToApplyEffect = [[NSString stringWithFormat:@"l_%@_e_%@_f_%d",
                                                                           Wself.targetLayerSet.uuid,
                                                                           Wself.targetLayerSet.effect.uuid,
                                                                           indexOfResourceItemSet
                ] URLForTemp:@"filter_applied_after_image" extension:@"jpg"];

                if([[NSFileManager defaultManager] fileExistsAtPath:tempURLToApplyEffect.path]){
                    //cached
                    return tempURLToApplyEffect;

                }else{
                    //newly create
                    NSArray * imagesToProcessEffect = [resourceItemSet mapWithIndex:^id(NSURL * imageUrl, NSInteger index) {
                        @autoreleasepool {
                            NSAssert([imageUrl isKindOfClass:NSURL.class],@"resource type was supported only as NSURL");
                            NSAssert([[NSFileManager defaultManager] fileExistsAtPath:imageUrl.path], @"file does not exists.");
                            return [UIImage imageWithContentsOfFile:imageUrl.path];
                        }
                    }];

                    BOOL containsNullInImages = [imagesToProcessEffect containsNull]>0;
                    NSAssert(!containsNullInImages, @"imagesToProcessEffect contains null. check fileExistsAtPath.");
                    if(!containsNullInImages){
                        BOOL vailedLayerNumbers = imagesToProcessEffect.count== [Wself.targetLayerSet.effect supportedNumberOfSourceImages];
                        NSAssert(vailedLayerNumbers, ([NSString stringWithFormat:@"%@ - Only %d source image sets supported",NSStringFromClass(Wself.targetLayerSet.effect.class), [Wself.targetLayerSet.effect supportedNumberOfSourceImages]]));

                        UIImage * processedImage = vailedLayerNumbers ?
                                [Wself.targetLayerSet.effect processImages:imagesToProcessEffect] : [imagesToProcessEffect firstObject];

                        NSAssert(processedImage, ([@"Processed Image is nil: " st_add:tempURLToApplyEffect.path]));

                        if([(self.loselessImageEncoding ?
                                UIImagePNGRepresentation(processedImage) : UIImageJPEGRepresentation(processedImage, 1))
                                writeToURL:tempURLToApplyEffect
                                atomically:YES]){
                            return tempURLToApplyEffect;
                        }else{
                            NSAssert(NO, ([@"Write failed : " st_add:tempURLToApplyEffect.path]));
                        }
                    }
                }
                return nil;
            }
        }];

    }else{
        //TODO: effect가 없으면서.layers이 2이상 (즉 이미지 레벨에서 겹치길 원한다는 의미)일때는 기본 알파 블렌딩?
        processedResources = [self resourcesToProcessFromSourceLayer:[_targetLayerSet.layers firstObject]];
    }

    NSAssert(processedResources.count, @"processedResources is empty");
    NSAssert([processedResources containsNull]==0, @"processedResources contained null");
    return processedResources;
}

- (NSArray<id> *)resourcesToProcessFromSourceLayer:(STCapturedImageSetDisplayLayer *)layer{
    NSAssert(layer.imageSet.images.count, @"imageSet's count of SourceImageSets is must be higer than 0 ");
    if(layer.imageSet.images.count){
        STCapturedImage * anyImage = [layer.imageSet.images firstObject];
        NSAssert(anyImage.imageUrl, @"STCapturedImage's imageUrl does not exist.");
        return [layer.imageSet.images mapWithItemsKeyPath:@keypath(anyImage.fullScreenUrl) orDefaultKeypath:@keypath(anyImage.imageUrl)];
    }
    return nil;
}

- (NSArray<NSArray *> *)resourcesSetToProcessFromSourceLayers{
    NSArray * results = [_targetLayerSet.layers mapWithIndex:^id(STCapturedImageSetDisplayLayer * layer, NSInteger index) {
        return [self resourcesToProcessFromSourceLayer:layer];
    }];

    BOOL containsNull = [results containsNull]>0;
    NSAssert(!containsNull, @"result resource array contains NSNull.");
    if(containsNull){
        return nil;
    }

    //[[resource....],[resource....]] -> [ [resources_item0,resources_item1], ...]
    NSArray * resourceSets0 = [results firstObject];
    NSMutableArray * rejoinResults = [NSMutableArray arrayWithCapacity:resourceSets0.count];
    [results eachWithIndex:^(NSArray * resourceSets, NSUInteger index) {
        [resourceSets eachWithIndex:^(id object, NSUInteger subindex) {
            if(![rejoinResults st_objectOrNilAtIndex:subindex]) {
                [rejoinResults addObject:[NSMutableArray arrayWithCapacity:resourceSets.count]];
            }

            if(![rejoinResults[subindex] st_objectOrNilAtIndex:index]){
                [rejoinResults[subindex] addObject:[NSMutableArray arrayWithCapacity:results.count]];
            }
            rejoinResults[subindex][index] = object;
        }];
    }];
    return rejoinResults;
}
@end