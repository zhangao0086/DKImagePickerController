//
// Created by BLACKGENE on 8/17/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerColoredHalfToneEffect.h"
#import "GPUImageHalftoneFilter.h"
#import "GPUImageMosaicFilter.h"
#import "STGPUImageOutputComposeItem.h"
#import "GPUImageFalseColorFilter.h"
#import "GPUImageFalseColorFilter+STGPUImageFilter.h"
#import "UIColor+BFPaperColors.h"
#import "GPUImageNormalBlendFilter.h"
#import "GPUImageTransformFilter.h"
#import "GPUImageTransformFilter+STGPUImageFilter.h"
#import "GPUImageDifferenceBlendFilter.h"
#import "GPUImageColorBurnBlendFilter.h"
#import "GPUImageBrightnessFilter.h"
#import "GPUImageSaturationFilter+STGPUImageFilter.h"
#import "GPUImageBrightnessFilter+STGPUImageFilter.h"
#import "GPUImageOverlayBlendFilter.h"
#import "STGPUImageHalftoneFilter.h"
#import "GPUImageClosingFilter.h"
#import "GPUImageLightenBlendFilter.h"
#import "GPUImageDarkenBlendFilter.h"
#import "GPUImageMultiplyBlendFilter.h"
#import "GPUImageMaskFilter.h"
#import "GPUImageScreenBlendFilter.h"
#import "GPUImageColorInvertFilter.h"
#import "GPUImageAlphaBlendFilter.h"
#import "GPUImageAddBlendFilter.h"
#import "GPUImageSoftLightBlendFilter.h"
#import "STGIFFDisplayLayerCrossFadeMaskEffect.h"
#import "GPUImageHardLightBlendFilter.h"


@implementation STGIFFDisplayLayerColoredHalfToneEffect {

}

- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
    return [self composersToProcessSingle:sourceImages[0]];
}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    NSMutableArray * composers = NSMutableArray.array;

    STGPUImageHalftoneFilter * halftoneFilter = STGPUImageHalftoneFilter.new;
    halftoneFilter.fractionalWidthOfAPixel = 0.01f;

    STGPUImageOutputComposeItem * composeItem0 = [STGPUImageOutputComposeItem new];
    [[composeItem0 setSourceAsImage:sourceImage] setFilters:@[
            [GPUImageBrightnessFilter brightness:-.1f]
            ,
//            halftoneFilter,
            [GPUImageFalseColorFilter filterWithColors:@[
                    UIColorFromRGB(0xEC0000)
                    , UIColorFromRGB(0xADFBFB)
            ]]

    ]];
    [composers addObject:composeItem0];

////    UIImage * image1 = [self processImagesAsComposers:[composers reverse]];
//

    composeItem0.composer = GPUImageSoftLightBlendFilter.new;

    GPUImageMosaicFilter * mosaicFilter = GPUImageMosaicFilter.new;
    mosaicFilter.inputTileSize = CGSizeMakeValue(0.015);
    mosaicFilter.tileSet = @"GPUImageMosaicFilter_square.png";
    composeItem0.composer = mosaicFilter;


    GPUImageHalftoneFilter * halftoneFilterBig = GPUImageHalftoneFilter.new;
    halftoneFilterBig.fractionalWidthOfAPixel = halftoneFilter.fractionalWidthOfAPixel;

    STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem new];
    [[composeItem1 setSourceAsImage:sourceImage] setFilters:@[
//            [GPUImageSaturationFilter saturation:0]
//           halftoneFilterBig ,
//            [GPUImageTransformFilter.new scale:CGPointMake(-1,1)]
//            ,
            [GPUImageFalseColorFilter filterWithColors:@[
                    UIColorFromRGB(0xF43C2B)
                    , UIColorFromRGB(0xAFCC34)
            ]]
//            ,[GPUImageTransformFilter.new rotate:AGKDegreesToRadians(90)]

//            [GPUImageTransformFilter.new addScaleScalar:1.1],
//            ,[GPUImageTransformFilter transform:CGAffineTransformMakeTranslation(halftoneFilter.fractionalWidthOfAPixel,halftoneFilter.fractionalWidthOfAPixel)]
    ]];
    [composers addObject:composeItem1];


//    STGIFFDisplayLayerPatternizedCrossFadeEffect * effect = STGIFFDisplayLayerPatternizedCrossFadeEffect.new;
//    effect.maskImageName = @"STGIFFDisplayLayerCrossFadeEffect_PatternStar.svg";
//    [effect processImages:@[image1]];

    return [composers reverse];
}

@end