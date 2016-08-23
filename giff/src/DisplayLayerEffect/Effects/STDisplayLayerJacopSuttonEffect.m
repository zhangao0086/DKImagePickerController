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
#import "GPUImageGrayscaleFilter.h"
#import "NSArray+STGPUImageOutputComposeItem.h"

@implementation STDisplayLayerJacopSuttonEffect {

}

+ (NSUInteger)maxSupportedNumberOfSourceImages {
    return 1;
}

- (NSArray *)composersToProcessSingle:(UIImage *__nullable)sourceImage {

//    sourceImage = [[sourceImage grayscale] brightenWithValue:-20];

    UIImage * bluredImage = [sourceImage blurredImageWithRadius:120 iterations:2 tintColor:nil];

//    bluredImage = [bluredImage contrastAdjustmentWithValue:30];

    STGIFFDisplayLayerCrossFadeGradientMaskEffect * crossFadeGradientMaskEffect = [[STGIFFDisplayLayerCrossFadeGradientMaskEffect alloc] init];
    crossFadeGradientMaskEffect.style = CrossFadeGradientMaskEffectStyleRadial;
    crossFadeGradientMaskEffect.automaticallyMatchUpColors = NO;
    crossFadeGradientMaskEffect.locations = @[@0.15,@.7];

    NSArray * composers = [crossFadeGradientMaskEffect composersToProcess:@[sourceImage, bluredImage]];

    [[composers composeItemsByCategory:STGPUImageOutputComposeItemCategorySourceImage] eachWithIndex:^(STGPUImageOutputComposeItem * sourceImageComposeItem, NSUInteger index) {
        [sourceImageComposeItem addFilters:@[
                [GPUImageContrastFilter contrast:1]
                ,[GPUImageBrightnessFilter brightness:-.2f]
                , [[GPUImageGrayscaleFilter alloc] init]
        ]];
    }];

    return composers;


//    crossFadeGradientMaskEffect.locations = @[@0,@.6];
//    return [crossFadeGradientMaskEffect composersToProcess:@[processedImage, bluredImage]];
}


@end