//
// Created by BLACKGENE on 8/23/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STDisplayLayerJacopSuttonEffect.h"
#import "STGPUImageOutputComposeItem.h"
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
#import "GPUImageGaussianBlurFilter.h"
#import "GPUImageBoxBlurFilter.h"
#import "NYXImagesKit.h"
#import "UIImage+ImageEffects.h"
#import "FXBlurView.h"

@implementation STDisplayLayerJacopSuttonEffect {

}

+ (NSUInteger)maxSupportedNumberOfSourceImages {
    return 1;
}

- (NSArray *)composersToProcessSingle:(UIImage *__nullable)sourceImage {

    UIImage * bluredImage = [sourceImage blurredImageWithRadius:200 iterations:2 tintColor:nil];

    STGIFFDisplayLayerCrossFadeGradientMaskEffect * crossFadeGradientMaskEffect = [[STGIFFDisplayLayerCrossFadeGradientMaskEffect alloc] init];
    crossFadeGradientMaskEffect.style = CrossFadeGradientMaskEffectStyleRadial;
    crossFadeGradientMaskEffect.automaticallyMatchUpColors = NO;
    crossFadeGradientMaskEffect.locations = @[@.2,@1];

    return [crossFadeGradientMaskEffect composersToProcess:@[sourceImage, bluredImage]];
}


@end