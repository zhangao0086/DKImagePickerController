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


@implementation STCapturedImageSetDisplayProcessor {
    NSArray<NSArray *> * _resourcesFromTargetLayerSet;
}

- (instancetype)initWithLayerSet:(STCapturedImageSetDisplayLayerSet *)targetLayer {
    self = [super init];
    if (self) {
        _layerSet = targetLayer;
    }
    return self;
}

+ (instancetype)processorWithLayerSet:(STCapturedImageSetDisplayLayerSet *)targetLayer {
    return [[self alloc] initWithLayerSet:targetLayer];
}

- (NSArray<NSURL *> *)processForImageUrls:(BOOL)forceReprocess {
    NSAssert(_layerSet.layers.count,@"_targetLayer.layers is empty.");

    Weaks
    NSArray * processedResources = nil;
    if(_layerSet.effect){

        processedResources = [self.sourceSetOfImagesForLayerSetApplyingRangeIfNeeded mapWithIndex:^id(NSArray *resourceSet, NSInteger indexOfResourceItemSet) {
            NSAssert([[resourceSet firstObject] isKindOfClass:NSURL.class], @"only NSURL was allowed.");
#if DEBUG
            [resourceSet eachWithIndex:^(NSURL * object, NSUInteger index) {
                oo([object path]);
            }];
#endif
            @autoreleasepool {
                NSURL * tempURLToApplyEffect = [[NSString stringWithFormat:@"l_%@_e_%@_f_%d",
                                                                           Wself.layerSet.uuid,
                                                                           Wself.layerSet.effect.uuid,
                                                                           indexOfResourceItemSet
                ] URLForTemp:@"filter_applied_after_image" extension:self.loselessImageEncoding ? @"png" : @"jpg"];

                if(!forceReprocess && [[NSFileManager defaultManager] fileExistsAtPath:tempURLToApplyEffect.path]){
                    //cached
                    oo([@"Cached Processing" st_add:tempURLToApplyEffect.path]);
                    return tempURLToApplyEffect;

                }else{
                    //newly create
                    NSArray<UIImage *> * imagesToProcessEffect = [self loadImagesFromSourceSet:resourceSet];
                    UIImage * processedImage = [Wself.layerSet.effect processImages:imagesToProcessEffect];

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
                return nil;
            }
        }];

    }else{
        //TODO: effect가 없으면서.layers이 2이상 (즉 이미지 레벨에서 겹치길 원한다는 의미)일때는 기본 알파 블렌딩?
        processedResources = [self sourceOfImagesForLayer:[_layerSet.layers firstObject]];
    }

    NSAssert(processedResources.count, @"processedResources is empty");
    NSAssert([processedResources containsNull]==0, @"processedResources contained null");
    return processedResources;
}

- (NSArray<id> *)sourceOfImagesForLayer:(STCapturedImageSetDisplayLayer *)layer{
    NSAssert(layer.imageSet.images.count, @"imageSet's count of SourceImageSets is must be higer than 0 ");
    if(layer.imageSet.images.count){
        STCapturedImage * anyImage = [layer.imageSet.images firstObject];
        NSAssert(anyImage.imageUrl, @"STCapturedImage's imageUrl does not exist.");
        return [layer.imageSet.images mapWithItemsKeyPath:@keypath(anyImage.fullScreenUrl) orDefaultKeypath:@keypath(anyImage.imageUrl)];
    }
    return nil;
}

- (NSArray<UIImage *> *)loadImagesFromSourceSet:(NSArray *)sourceSetOfImages{
    NSArray<UIImage *> * images = [sourceSetOfImages mapWithIndex:^id(NSURL * imageUrl, NSInteger index) {
        @autoreleasepool {
            NSAssert([imageUrl isKindOfClass:NSURL.class],@"resource type was supported only as NSURL");
            NSAssert([[NSFileManager defaultManager] fileExistsAtPath:imageUrl.path], @"file does not exists.");
            return [UIImage imageWithContentsOfFile:imageUrl.path];
        }
    }];

    BOOL containsNullInImages = [images containsNull]>0;
    if(containsNullInImages){
        NSAssert(NO, @"imagesToProcessEffect contains null. check fileExistsAtPath.");
        return nil;
    }

    BOOL invailedLayerNumbers = images.count==0;// || images.count > [self.layerSet.effect supportedNumberOfSourceImages];
    if(invailedLayerNumbers){
//        NSAssert(NO, ([NSString stringWithFormat:@"%@ - Only %d source image sets supported",NSStringFromClass(self.layerSet.effect.class), [self.layerSet.effect supportedNumberOfSourceImages]]));
        NSAssert(NO, ([NSString stringWithFormat:@"%@ - sourceSetOfImages is empty. Only %d source image sets supported",NSStringFromClass(self.layerSet.effect.class), [self.layerSet.effect maxSupportedNumberOfSourceImages]]));
        return nil;
    }

    return images;
}

- (NSArray<NSArray *> *)sourceSetOfImagesForLayerSet{
    if(_resourcesFromTargetLayerSet){
        return _resourcesFromTargetLayerSet;
    }

    NSArray * results = [_layerSet.layers mapWithIndex:^id(STCapturedImageSetDisplayLayer * layer, NSInteger index) {
        return [self sourceOfImagesForLayer:layer];
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
    return (_resourcesFromTargetLayerSet = rejoinResults);
}

- (NSArray<NSArray *> *)sourceSetOfImagesForLayerSetApplyingRangeIfNeeded{
    return isNSRangeNull(_preferredRangeOfSourceSet) ?
            self.sourceSetOfImagesForLayerSet : [self.sourceSetOfImagesForLayerSet subarrayWithRange:_preferredRangeOfSourceSet];
}

@end