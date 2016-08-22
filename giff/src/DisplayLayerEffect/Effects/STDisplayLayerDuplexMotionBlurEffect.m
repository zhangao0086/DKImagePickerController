//
// Created by BLACKGENE on 8/22/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STDisplayLayerDuplexMotionBlurEffect.h"
#import "GPUImageMotionBlurFilter.h"
#import "STGPUImageOutputComposeItem.h"
#import "NYXImagesKit.h"
#import "STGIFFDisplayLayerCrossFadeGradientMaskEffect.h"


@implementation STDisplayLayerDuplexMotionBlurEffect {

}

- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    UIImage * firstImage = sourceImages[0];

    UIImage * flippedSourceImage = [firstImage horizontalFlip];
    STGPUImageOutputComposeItem * composeItem = [STGPUImageOutputComposeItem itemWithSourceImage:flippedSourceImage];
    GPUImageMotionBlurFilter * motionBlurFilter = [[GPUImageMotionBlurFilter alloc] init];
    motionBlurFilter.blurSize = 30;
    composeItem.filters = @[
            motionBlurFilter
    ];

    STGIFFDisplayLayerCrossFadeGradientMaskEffect * crossFadeGradientMaskEffect = [[STGIFFDisplayLayerCrossFadeGradientMaskEffect alloc] init];
    crossFadeGradientMaskEffect.style = CrossFadeGradientMaskEffectStyleLinearHorizontal;
    crossFadeGradientMaskEffect.automaticallyMatchUpColors = NO;

    return [crossFadeGradientMaskEffect processImages:@[[self processComposers:@[composeItem]], firstImage]];
}


@end