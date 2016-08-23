//
// Created by BLACKGENE on 8/23/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STDisplayLayerJacopSuttonEffect.h"
#import "STGPUImageOutputComposeItem.h"
#import "GPUImageMotionBlurFilter.h"
#import "STGIFFDisplayLayerCrossFadeGradientMaskEffect.h"
#import "GPUImageBrightnessFilter.h"
#import "GPUImageBrightnessFilter+STGPUImageFilter.h"
#import "GPUImageContrastFilter.h"
#import "GPUImageContrastFilter+STGPUImageFilter.h"
#import "FXBlurView.h"
#import "GPUImageGrayscaleFilter.h"

@implementation STDisplayLayerJacopSuttonEffect {

}

+ (NSUInteger)maxSupportedNumberOfSourceImages {
    return 1;
}

- (NSArray *)composersToProcessSingle:(UIImage *__nullable)sourceImage {

    UIImage * bluredImagePhase0 = [sourceImage blurredImageWithRadius:70 iterations:2 tintColor:nil];

    STGIFFDisplayLayerCrossFadeGradientMaskEffect * crossFadeGradientMaskEffect = [[STGIFFDisplayLayerCrossFadeGradientMaskEffect alloc] init];
    crossFadeGradientMaskEffect.style = CrossFadeGradientMaskEffectStyleRadial;
    crossFadeGradientMaskEffect.automaticallyMatchUpColors = NO;
    crossFadeGradientMaskEffect.locations = @[@0,@.8];
    NSArray * composers = [crossFadeGradientMaskEffect composersToProcess:@[sourceImage, bluredImagePhase0]];
    UIImage * phase0 = [crossFadeGradientMaskEffect processComposers:composers];

    //실기기(6S Plus) 기준 프로세스 하나당 약 0.4Xs걸림
    UIImage * bluredImagePhase1 = [sourceImage blurredImageWithRadius:130 iterations:2 tintColor:nil];
    crossFadeGradientMaskEffect.locations = @[@.5,@1];
    composers = [crossFadeGradientMaskEffect composersToProcess:@[phase0, bluredImagePhase1]];

    [composers eachWithIndex:^(STGPUImageOutputComposeItem * sourceImageComposeItem, NSUInteger index) {
        [sourceImageComposeItem addFilters:@[
                [GPUImageContrastFilter contrast:1]
                ,[GPUImageBrightnessFilter brightness:-.2f]
                , [[GPUImageGrayscaleFilter alloc] init]
        ]];
    }];

    return composers;
}


@end