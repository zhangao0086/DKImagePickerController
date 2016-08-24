//
// Created by BLACKGENE on 8/10/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <FXBlurView/FXBlurView.h>
#import "STGIFFDisplayLayerColoredDoubleExposureEffect.h"
#import "GPUImageChromaKeyBlendFilter.h"
#import "UIColor+BFPaperColors.h"
#import "GPUImageSoftLightBlendFilter.h"
#import "GPUImageTransformFilter.h"
#import "STFilter.h"
#import "STGPUImageOutputComposeItem.h"
#import "GPUImageRGBFilter+STGPUImageFilter.h"
#import "GPUImageTransformFilter+STGPUImageFilter.h"
#import "GPUImageFalseColorFilter+STGPUImageFilter.h"

@implementation STGIFFDisplayLayerColoredDoubleExposureEffect {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.primary2ColorSet = @[UIColorFromRGB(0xF60800), UIColorFromRGB(0x1DFCFE)];
        self.secondary2ColorSet = @[UIColorFromRGB(0x4223F1),UIColorFromRGB(0xFDCDD4)];
    }
    return self;
}

- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
    NSMutableArray * composers = [NSMutableArray array];

    if(self.style==ColoredDoubleExposureEffectBlendingStyleSolid){

        [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:sourceImages[0]
                                                                      composer:[[GPUImageLightenBlendFilter alloc] init]] addFilters:@[
            [GPUImageRGBFilter rgbColor:self.primary2ColorSet.firstObject]
        ]]];
        [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:sourceImages[1]] addFilters:@[
            [GPUImageRGBFilter rgbColor:self.secondary2ColorSet.firstObject]
        ]]];

    }else if(self.style==ColoredDoubleExposureEffectBlendingStyleTwoColors){

        [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:sourceImages[0]
                                                                      composer:[[GPUImageSoftLightBlendFilter alloc] init]] addFilters:@[
                [GPUImageFalseColorFilter colors:self.primary2ColorSet]
        ]]];
        [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:sourceImages[1]] addFilters:@[
                [GPUImageFalseColorFilter colors:self.secondary2ColorSet]
        ]]];
    }

    return [composers reverse];
}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    NSMutableArray * composers = [NSMutableArray array];

    [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:sourceImage
                                                                  composer:[[GPUImageLightenBlendFilter alloc] init]] addFilters:@[
            [[GPUImageGrayscaleFilter alloc] init]
//            ,[GPUImageContrastFilter contrast:.2]

    ]]];

    [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:sourceImage
                                                                  composer:[[GPUImageSoftLightBlendFilter alloc] init]] addFilters:@[
            [[GPUImageGrayscaleFilter alloc] init]
            , [GPUImageFalseColorFilter colors:self.secondary2ColorSet]
            , [[GPUImageTransformFilter translate:.1f y:0] scaleScalar:1.2]
//            ,[GPUImageSaturationFilter saturation:2]
    ]]];

//    sourceImage = [sourceImage blurredImageWithRadius:100 iterations:2 tintColor:nil];
    [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:sourceImage] addFilters:@[
            [[GPUImageGrayscaleFilter alloc] init]
            , [GPUImageFalseColorFilter colors:self.primary2ColorSet]
//            ,[GPUImageSaturationFilter saturation:2]
//            , [[[GPUImageTransformFilter translate:-.2f y:0] scaleScalar:1.32] scale:CGPointMake(-1,1)]
            , [[GPUImageTransformFilter translate:-.2f y:0] scaleScalar:1.32]
    ]]];

    return [composers reverse];
}

@end