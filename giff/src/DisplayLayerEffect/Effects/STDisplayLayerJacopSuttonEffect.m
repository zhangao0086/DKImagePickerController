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

- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {

    return [sourceImages[0] blurredImageWithRadius:200 iterations:2 tintColor:nil];;

    return [sourceImages[0] gaussianBlurWithBias:100];

    STGPUImageOutputComposeItem * composeItem = [STGPUImageOutputComposeItem itemWithSourceImage:sourceImages[0]];

    GPUImageGaussianBlurFilter * blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    blurFilter.blurRadiusInPixels = 10;
    composeItem.filters = @[
            blurFilter
            ,[GPUImageBrightnessFilter brightness:-0.05f]
            ,[GPUImageContrastFilter contrast:1.1f]
            ,[GPUImageTransformFilter scale:-1 y:1]
    ];
    UIImage * bluredImage = [self processComposers:@[composeItem]];
    return bluredImage;
}

//- (NSArray *)composersToProcessSingle:(UIImage *__nullable)sourceImage {
//    STGPUImageOutputComposeItem * composeItem = [STGPUImageOutputComposeItem itemWithSourceImage:sourceImage];
//
//    GPUImageGaussianBlurFilter * blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
//    blurFilter.blurRadiusInPixels = 20;
//    composeItem.filters = @[
//            blurFilter
//            ,[GPUImageBrightnessFilter brightness:-0.05f]
//            ,[GPUImageContrastFilter contrast:1.1f]
//            ,[GPUImageTransformFilter scale:-1 y:1]
//    ];
//    UIImage * bluredImage = [self processComposers:@[composeItem]];
//
//    STGIFFDisplayLayerCrossFadeGradientMaskEffect * crossFadeGradientMaskEffect = [[STGIFFDisplayLayerCrossFadeGradientMaskEffect alloc] init];
//    crossFadeGradientMaskEffect.style = CrossFadeGradientMaskEffectStyleRadial;
//    crossFadeGradientMaskEffect.automaticallyMatchUpColors = NO;
//    crossFadeGradientMaskEffect.locations = @[@.32,@1];
//
//    return [crossFadeGradientMaskEffect composersToProcess:@[sourceImage, bluredImage]];
//}


@end