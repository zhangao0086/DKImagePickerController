//
// Created by BLACKGENE on 8/16/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerDarkenMaskEffect.h"
#import "GPUImageChromaKeyBlendFilter.h"
#import "GPUImagePicture.h"
#import "STFilter.h"
#import "STGPUImageOutputComposeItem.h"
#import "GPUImageTransformFilter+STGPUImageFilter.h"
#import "GPUImageFalseColorFilter+STGPUImageFilter.h"
#import "STGIFFDisplayLayerPepVentosaEffect.h"
#import "LEColorPicker.h"
#import "NSObject+STUtil.h"

@implementation STGIFFDisplayLayerDarkenMaskEffect {
}

- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
    NSMutableArray * composers = [NSMutableArray array];

    //soure image
    STGPUImageOutputComposeItem * composeItemB = [STGPUImageOutputComposeItem new];
    composeItemB.source = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO];
    composeItemB.composer = [GPUImageLightenBlendFilter new];
//    GPUImageSaturationFilter * saturationFilter = GPUImageSaturationFilter.new;
//    saturationFilter.saturation = 1.2f;
//    composeItemB.filters = @[
//            saturationFilter
//    ];
    [composers addObject:composeItemB];

    //mask image
    STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem new];
    composeItem1.source = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO];
    composeItem1.composer = GPUImageMaskFilter.new;

    GPUImageContrastFilter * contrastFilter = GPUImageContrastFilter.new;
    contrastFilter.contrast = 3;

    composeItem1.filters = @[
            GPUImageColorInvertFilter.new
            ,contrastFilter
    ];
    [composers addObject:composeItem1];

    //background image
    STGPUImageOutputComposeItem * composeItemA = [STGPUImageOutputComposeItem new];
    composeItemA.source = [[GPUImagePicture alloc] initWithImage:sourceImages[1] smoothlyScaleOutput:NO];
    [composers addObject:composeItemA];

    return [composers reverse];
}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    NSMutableArray * composers = [NSMutableArray array];

    //soure image
    STGPUImageOutputComposeItem * composeItemPrimary = [STGPUImageOutputComposeItem new];
    composeItemPrimary.source = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:NO];
    composeItemPrimary.composer = [GPUImageLightenBlendFilter new];
//    composeItemPrimary.composer = [GPUImageNormalBlendFilter new];
    composeItemPrimary.filters = @[
//            [GPUImageFalseColorFilter filterWithColors:@[
//                    UIColorFromRGB(0xDA3DEF), UIColorFromRGB(0x50ECF0)
//            ]]
    ];

    [composers addObject:composeItemPrimary];

    //mask image
    STGPUImageOutputComposeItem * composeItemInvertingMask = [STGPUImageOutputComposeItem new];
    composeItemInvertingMask.source = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:NO];
    composeItemInvertingMask.composer = GPUImageMaskFilter.new;

    GPUImageContrastFilter * contrastFilter = GPUImageContrastFilter.new;
    contrastFilter.contrast = 3;

    composeItemInvertingMask.filters = @[
            GPUImageColorInvertFilter.new
            ,contrastFilter
    ];
    [composers addObject:composeItemInvertingMask];

    //background image
    STGIFFDisplayLayerPepVentosaEffect * effect = STGIFFDisplayLayerPepVentosaEffect.new;
    UIImage * effectImage = [effect processImages:@[sourceImage]];

    STGPUImageOutputComposeItem * composeItemA = [STGPUImageOutputComposeItem new];
    composeItemA.source = [[GPUImagePicture alloc] initWithImage:effectImage smoothlyScaleOutput:NO];

    //https://github.com/metasmile/DominantColor (import)
    LEColorScheme * colorScheme = [self st_cachedObject:sourceImage.st_uid init:^id {
        return [LEColorPicker.new colorSchemeFromImage:sourceImage];
    }];

    composeItemA.filters = @[
            [GPUImageFalseColorFilter filterWithColors:@[
                    colorScheme.primaryTextColor, colorScheme.backgroundColor
//    UIColorFromRGB(0x5E21CF), UIColorFromRGB(0x50ECF0)
            ]]
//            , [GPUImageContrastFilter contrast:2]
//            ,[GPUImageSaturationFilter saturation:1.3f]
            , [[GPUImageTransformFilter filterByTransform:CGAffineTransformMakeRotation(AGKDegreesToRadians(180/*90 * randomir(1, 3)*/))] addScaleScalar:1.2]
    ];

    [composers addObject:composeItemA];

    return [composers reverse];
}


@end