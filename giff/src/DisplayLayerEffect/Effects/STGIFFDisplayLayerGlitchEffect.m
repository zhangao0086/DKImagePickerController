//
// Created by BLACKGENE on 8/10/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerGlitchEffect.h"
#import "GPUImageChromaKeyBlendFilter.h"
#import "GPUImagePicture.h"
#import "UIColor+BFPaperColors.h"
#import "GPUImageTransformFilter.h"
#import "STFilter.h"
#import "STGPUImageOutputComposeItem.h"
#import "GPUImageRGBFilter+STGPUImageFilter.h"
#import "STGIFFDisplayLayerCrossFadeMaskEffect.h"
#import "STRasterizingImageSourceItem.h"
#import "NSArray+STGPUImageOutputComposeItem.h"

@implementation STGIFFDisplayLayerGlitchEffect {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.primaryColor = UIColorFromRGB(0xff46c0);
        self.secondaryColor = UIColorFromRGB(0x83F5F8);
        self.screenShaking = YES;
    }

    return self;
}

- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
//    STGIFFDisplayLayerDarkenMaskEffect * darkenMaskEffect = [[STGIFFDisplayLayerDarkenMaskEffect alloc] init];
//    UIImage * preprocessedImage = [darkenMaskEffect processImages:sourceImages];

//    STGIFFDisplayLayerColoredDoubleExposureEffect * coloredDoubleExposureEffect = [[STGIFFDisplayLayerColoredDoubleExposureEffect alloc] init];
//    coloredDoubleExposureEffect.style = ColoredDoubleExposureEffectBlendingStyleSolid;

//    UIImage * preprocessedImage = [coloredDoubleExposureEffect processImages:sourceImages];

//    return [self composersToProcessSingle:preprocessedImage];


//    STGIFFDisplayLayerCrossFadeMaskEffect * crossFadeMaskEffect = [[STGIFFDisplayLayerCrossFadeMaskEffect alloc] init];
//    crossFadeMaskEffect.maskImageSource = [STRasterizingImageSourceItem itemWithBundleFileName:@"STGIFFDisplayLayerGlitchEffect_default.svg"];
//    crossFadeMaskEffect.transformFadingImage = CGAffineTransformMakeScale(1.04,1);

    return [[self composersToProcessSingle:sourceImages[0]]
            concatOtherComposers:[self composersToProcessSingle:sourceImages[1]]
                         blender:GPUImageLightenBlendFilter.new
                      orderByMix:YES];
//    return [crossFadeMaskEffect composersToProcess:@[glichedImage,glichedImage]];

}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    //TODO:stripe를 alpha mix로 하나 깔아주는 게 좋을듯
    //TODO:stripe가 좀 더 실감나게

    NSMutableArray * composers = [NSMutableArray array];
    //1
    STGPUImageOutputComposeItem * composeItem0 = [STGPUImageOutputComposeItem new];
    composeItem0.source = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:NO];
    GPUImageSaturationFilter * saturationFilter0 = GPUImageSaturationFilter.new;
    saturationFilter0.saturation = 1.2;
    GPUImageTransformFilter * transformFilter1 = [[GPUImageTransformFilter alloc] init];
    transformFilter1.affineTransform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(.02f,0),CGAffineTransformMakeScale(1.04,1.04));

    //[GPUImageMonochromeFilter filterWithColor:[self colors][0]]
    composeItem0.filters = @[
            [GPUImageRGBFilter rgbColor:self.primaryColor]
            , saturationFilter0
            ,transformFilter1
    ];
    composeItem0.composer = [[GPUImageOverlayBlendFilter alloc] init];
    [composers addObject:composeItem0];

    //3
    STGPUImageOutputComposeItem * composeItem3 = [STGPUImageOutputComposeItem new];
    composeItem3.source = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:NO];
    composeItem3.composer = [[GPUImageScreenBlendFilter alloc] init];
    [composers addObject:composeItem3];

    //4
    STGPUImageOutputComposeItem * composeItem4 = [STGPUImageOutputComposeItem new];
    composeItem4.source = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:NO];
    GPUImageSaturationFilter * saturationFilter4 = GPUImageSaturationFilter.new;
    saturationFilter4.saturation = 1.2;
    GPUImageTransformFilter * transformFilter4 = [[GPUImageTransformFilter alloc] init];
    transformFilter4.affineTransform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-.015f,0),CGAffineTransformMakeScale(1.04,1.04));
    composeItem4.filters = @[
            [GPUImageRGBFilter rgbColor:self.secondaryColor]
            , saturationFilter4
            ,transformFilter4
    ];

    [composers addObject:composeItem4];

    NSArray * resultComposers = [composers reverse];

    if(self.screenShaking){
        UIImage * glichedImage = [self processComposers:resultComposers];

        STGIFFDisplayLayerCrossFadeMaskEffect * crossFadeMaskEffect = [[STGIFFDisplayLayerCrossFadeMaskEffect alloc] init];
        crossFadeMaskEffect.maskImageSource = [STRasterizingImageSourceItem itemWithBundleFileName:@"STGIFFDisplayLayerGlitchEffect_default.svg"];
        crossFadeMaskEffect.transformFadingImage = CGAffineTransformMakeScale(1.03,1);
        return [crossFadeMaskEffect composersToProcess:@[glichedImage,glichedImage]];

    } else{
        return resultComposers;
    }
}

@end