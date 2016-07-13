//
// Created by BLACKGENE on 7/13/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageLayerView.h"
#import "STAfterImageLayerItem.h"
#import "NSString+STUtil.h"
#import "GPUImageContext.h"
#import "STQueueManager.h"
#import "STFilter.h"
#import "STFilterManager.h"
#import "NSArray+STUtil.h"


@implementation STAfterImageLayerView {
    NSArray<NSURL *>* _preheatedImageUrlsAfterEffectsApplied;
}

- (void)dealloc {
    _layerItem = nil;
    _preheatedImageUrlsAfterEffectsApplied = nil;
}

- (void)setViews:(NSArray *)presentableObjects {
    NSAssert(_layerItem, @"set _layerItem first");

    if(_layerItem.filterId){

        if(_preheatedImageUrlsAfterEffectsApplied){
            [super setViews:_preheatedImageUrlsAfterEffectsApplied];

        }else{
            Weaks
            dispatch_async([STQueueManager sharedQueue].uiProcessing,^{
                NSArray <NSURL *> * preheatedImageUrls = [presentableObjects mapWithIndex:^id(NSURL *imageUrl, NSInteger index) {
                    NSAssert([imageUrl isKindOfClass:NSURL.class], @"only NSURL was allowed.");

                    @autoreleasepool {
                        NSURL * tempURLToApplyEffect = [[NSString stringWithFormat:@"%@_%@_f%d",
                                        Wself.layerItem.uuid,
                                        Wself.layerItem.filterId,
                                        index] URLForTemp:@"filter_applied_after_image" extension:@"jpg"];

                        if([[NSFileManager defaultManager] fileExistsAtPath:tempURLToApplyEffect.path]){
                            //cached
                            return tempURLToApplyEffect;

                        }else{
                            //newly create

                            GPUImageFilter * sourceFilter = nil;
                            if([@"falsecolor" isEqualToString:Wself.layerItem.filterId]){
                                sourceFilter = [[GPUImageFalseColorFilter alloc] init];
                            }else if([@"monochrome" isEqualToString:Wself.layerItem.filterId]){
                                sourceFilter = [[GPUImageMonochromeFilter alloc] init];
                            }

                            STFilter * filter = [[STFilter alloc] initWithFilters:@[sourceFilter]];
                            UIImage * targetImage = [UIImage imageWithContentsOfFile:imageUrl.path];
                            UIImage * resultImage = [[STFilterManager sharedManager]
                                    buildOutputImage:targetImage
                                             enhance:NO
                                              filter:filter
                                    extendingFilters:nil
                                        rotationMode:kGPUImageNoRotation
                                         outputScale:1
                               useCurrentFrameBuffer:YES
                                  lockFrameRendering:NO];

                            if([UIImageJPEGRepresentation(resultImage, 1) writeToURL:tempURLToApplyEffect atomically:NO]){
                                return tempURLToApplyEffect;
                            }
                        }
                        return nil;
                    }
                }];

                if(preheatedImageUrls.count){
                    dispatch_async(dispatch_get_main_queue(),^{
                        _preheatedImageUrlsAfterEffectsApplied = preheatedImageUrls;
                        [super setViews:_preheatedImageUrlsAfterEffectsApplied];
                    });
                }

            });
        }
    }else{
        _preheatedImageUrlsAfterEffectsApplied = nil;
        [super setViews:presentableObjects];
    }
}
@end