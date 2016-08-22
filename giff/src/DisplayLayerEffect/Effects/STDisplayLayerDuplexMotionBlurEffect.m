//
// Created by BLACKGENE on 8/22/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STDisplayLayerDuplexMotionBlurEffect.h"
#import "GPUImageMotionBlurFilter.h"
#import "STGPUImageOutputComposeItem.h"
#import "NYXImagesKit.h"
#import "STGIFFDisplayLayerCrossFadeGradientMaskEffect.h"
#import "GPUImageSoftLightBlendFilter.h"
#import "GPUImageBrightnessFilter.h"
#import "GPUImageBrightnessFilter+STGPUImageFilter.h"
#import "GPUImageContrastFilter.h"
#import "GPUImageContrastFilter+STGPUImageFilter.h"
#import "GPUImageTransformFilter.h"
#import "GPUImageTransformFilter+STGPUImageFilter.h"


@implementation STDisplayLayerDuplexMotionBlurEffect {

}

- (NSArray *)composersToProcess:(NSArray<UIImage *> *__nullable)sourceImages {
    UIImage * backgroundImage = sourceImages[0];
    UIImage * blurringTargetImage = sourceImages.count>1 ? sourceImages[1] : backgroundImage;

    STGPUImageOutputComposeItem * composeItem = [STGPUImageOutputComposeItem itemWithSourceImage:blurringTargetImage];
    GPUImageMotionBlurFilter * motionBlurFilter = [[GPUImageMotionBlurFilter alloc] init];
    motionBlurFilter.blurSize = 30;
    composeItem.filters = @[
            motionBlurFilter
            ,[GPUImageBrightnessFilter brightness:-0.05f]
            ,[GPUImageContrastFilter contrast:1.4f]
            ,[GPUImageTransformFilter scale:-1 y:1]
    ];
    UIImage * bluredImage = [self processComposers:@[composeItem]];

    STGIFFDisplayLayerCrossFadeGradientMaskEffect * crossFadeGradientMaskEffect = [[STGIFFDisplayLayerCrossFadeGradientMaskEffect alloc] init];
    crossFadeGradientMaskEffect.style = CrossFadeGradientMaskEffectStyleLinearHorizontal;
    crossFadeGradientMaskEffect.automaticallyMatchUpColors = NO;

    return [crossFadeGradientMaskEffect composersToProcess:@[bluredImage, backgroundImage]];
}

//
//- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
//    UIImage * firstImage = sourceImages[0];
//
//    UIImage * flippedSourceImage = [firstImage horizontalFlip];
//    STGPUImageOutputComposeItem * composeItem = [STGPUImageOutputComposeItem itemWithSourceImage:flippedSourceImage];
//    GPUImageMotionBlurFilter * motionBlurFilter = [[GPUImageMotionBlurFilter alloc] init];
//    motionBlurFilter.blurSize = 30;
//    composeItem.filters = @[
//            motionBlurFilter
//    ];
//
//    STGIFFDisplayLayerCrossFadeGradientMaskEffect * crossFadeGradientMaskEffect = [[STGIFFDisplayLayerCrossFadeGradientMaskEffect alloc] init];
//    crossFadeGradientMaskEffect.style = CrossFadeGradientMaskEffectStyleLinearHorizontal;
//    crossFadeGradientMaskEffect.automaticallyMatchUpColors = NO;
//
//    return [crossFadeGradientMaskEffect processImages:@[[self processComposers:@[composeItem]], firstImage]];
//}


@end