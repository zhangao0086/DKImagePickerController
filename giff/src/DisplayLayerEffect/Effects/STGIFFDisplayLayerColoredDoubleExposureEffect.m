//
// Created by BLACKGENE on 8/10/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <FXBlurView/FXBlurView.h>
#import "STGIFFDisplayLayerColoredDoubleExposureEffect.h"
#import "STGIFFDisplayLayerFluorEffect.h"
#import "GPUImageChromaKeyBlendFilter.h"
#import "GPUImagePicture.h"
#import "UIColor+BFPaperColors.h"
#import "Colours.h"
#import "GPUImageSoftLightBlendFilter.h"
#import "GPUImageTransformFilter.h"
#import "STFilter.h"
#import "STFilterManager.h"
#import "UIImage+STUtil.h"
#import "STGPUImageOutputComposeItem.h"
#import "GPUImageBrightnessFilter.h"
#import "GPUImageLightenBlendFilter.h"
#import "GPUImageRGBFilter.h"
#import "GPUImageSobelEdgeDetectionFilter.h"
#import "GPUImageMonochromeFilter+STGPUImageFilter.h"
#import "GPUImageMotionBlurFilter+STGPUImageFilter.h"
#import "GPUImageRGBFilter+STGPUImageFilter.h"
#import "GPUImageTransformFilter+STGPUImageFilter.h"
#import "GPUImageFalseColorFilter+STGPUImageFilter.h"
#import "GPUImageSaturationFilter+STGPUImageFilter.h"
#import "GPUImageBrightnessFilter+STGPUImageFilter.h"
#import "STGIFFDisplayLayerDarkenMaskEffect.h"
#import "GPUImageContrastFilter+STGPUImageFilter.h"

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


    [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:sourceImages[0]
                                                                  composer:[[GPUImageSoftLightBlendFilter alloc] init]] addFilters:@[
                    [GPUImageFalseColorFilter colors:self.primary2ColorSet]
//                    ,[[GPUImageTransformFilter translate:.015f y:0] scaleScalar:1.04]
    ]]];

//    [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:sourceImages[1]
//                                                                  composer:[[GPUImageMaskFilter alloc] init]] addFilters:@[
//            [[GPUImageGrayscaleFilter alloc] init]
//            , [GPUImageBrightnessFilter brightness:.2]
//            , [GPUImageContrastFilter contrast:.2]
////            [GPUImageFalseColorFilter colors:self.primary2ColorSet]
//            ,[GPUImageTransformFilter scale:-1 y:1]
//    ]]];

    [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:sourceImages[1]] addFilters:@[
            [GPUImageFalseColorFilter colors:self.secondary2ColorSet]
//            ,[GPUImageBrightnessFilter brightness:-.1f]
//            ,[GPUImageSaturationFilter saturation:.9]
//            ,[[GPUImageTransformFilter translate:-.015f y:0] scaleScalar:1.04]
    ]]];

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