//
// Created by BLACKGENE on 8/22/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STDisplayLayerDuplexMotionBlurEffect.h"
#import "GPUImageMotionBlurFilter.h"
#import "STGPUImageOutputComposeItem.h"
#import "STGIFFDisplayLayerCrossFadeGradientMaskEffect.h"
#import "GPUImageBrightnessFilter.h"
#import "GPUImageBrightnessFilter+STGPUImageFilter.h"
#import "GPUImageContrastFilter.h"
#import "GPUImageContrastFilter+STGPUImageFilter.h"
#import "GPUImageTransformFilter.h"
#import "GPUImageTransformFilter+STGPUImageFilter.h"
#import "GPUImageZoomBlurFilter.h"


@implementation STDisplayLayerDuplexMotionBlurEffect {

}

- (NSArray *)composersToProcessSingle:(UIImage * __nullable)sourceImage {
    STGPUImageOutputComposeItem * composeItem = [STGPUImageOutputComposeItem itemWithSourceImage:sourceImage];

    GPUImageZoomBlurFilter * motionBlurFilter = [[GPUImageZoomBlurFilter alloc] init];
    motionBlurFilter.blurSize = 8;
    composeItem.filters = @[
            motionBlurFilter
            ,[GPUImageBrightnessFilter brightness:-0.16f]
            ,[GPUImageContrastFilter contrast:1.05f]
            ,[GPUImageTransformFilter scale:-1 y:1]
    ];
    UIImage * bluredImage = [self processComposers:@[composeItem]];

    STGIFFDisplayLayerCrossFadeGradientMaskEffect * crossFadeGradientMaskEffect = [[STGIFFDisplayLayerCrossFadeGradientMaskEffect alloc] init];
    crossFadeGradientMaskEffect.style = CrossFadeGradientMaskEffectStyleLinearHorizontal;
    crossFadeGradientMaskEffect.automaticallyMatchUpColors = NO;
    crossFadeGradientMaskEffect.locations = @[@.45, @.85];

    return [crossFadeGradientMaskEffect composersToProcess:@[bluredImage, sourceImage]];
}


- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
    UIImage * backgroundImage = sourceImages[0];
    UIImage * blurringTargetImage = sourceImages.count>1 ? sourceImages[1] : backgroundImage;

    STGPUImageOutputComposeItem * composeItem = [STGPUImageOutputComposeItem itemWithSourceImage:blurringTargetImage];

    GPUImageZoomBlurFilter * motionBlurFilter = [[GPUImageZoomBlurFilter alloc] init];
    motionBlurFilter.blurSize = 8;
    composeItem.filters = @[
            motionBlurFilter
            ,[GPUImageBrightnessFilter brightness:-0.05f]
            ,[GPUImageContrastFilter contrast:1.1f]
//            ,[GPUImageTransformFilter scale:-1 y:1]
    ];
    UIImage * bluredImage = [self processComposers:@[composeItem]];

    STGIFFDisplayLayerCrossFadeGradientMaskEffect * crossFadeGradientMaskEffect = [[STGIFFDisplayLayerCrossFadeGradientMaskEffect alloc] init];
    crossFadeGradientMaskEffect.style = CrossFadeGradientMaskEffectStyleRadial;
    crossFadeGradientMaskEffect.automaticallyMatchUpColors = NO;
    crossFadeGradientMaskEffect.locations = @[@.35,@1];

    return [crossFadeGradientMaskEffect composersToProcess:@[backgroundImage, bluredImage]];
}


@end