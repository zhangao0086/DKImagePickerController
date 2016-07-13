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
#import "NSArray+BlocksKit.h"


@implementation STAfterImageLayerView {
    NSArray<NSURL *>* _preheatedImageUrlsAfterEffectsApplied;
}

- (void)setViews:(NSArray *)presentableObjects {
    NSAssert(_layerItem, @"set _layerItem first");

    if(_layerItem.filterId){

        if(_preheatedImageUrlsAfterEffectsApplied){
            [super setViews:_preheatedImageUrlsAfterEffectsApplied];

        }else{
            Weaks
            dispatch_async([STQueueManager sharedQueue].uiProcessing,^{
                NSArray * preheatedImageUrls = [presentableObjects bk_map:^id(NSURL * imageUrl) {
                    NSAssert([imageUrl isKindOfClass:NSURL.class], @"only NSURL was allowed.");

                    @autoreleasepool {
                        STFilter * filter = [[STFilter alloc] initWithFilters:@[[[GPUImageFalseColorFilter alloc] init]]];
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

                        NSURL * tempURLToApplyEffect = [@"STAfterImageLayerView_filtered_image" URLForTemp:Wself.layerItem.filterId extension:@"jpg"];
                        if([UIImageJPEGRepresentation(resultImage, 1) writeToURL:tempURLToApplyEffect atomically:NO]){
                            return tempURLToApplyEffect;
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