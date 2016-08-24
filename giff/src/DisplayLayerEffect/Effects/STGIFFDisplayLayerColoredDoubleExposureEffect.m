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
        self.primaryColor = UIColorFromRGB(0xff46c0);
        self.secondaryColor = UIColorFromRGB(0x83F5F8);

        self.primaryColor = UIColorFromRGB(0xF60800);
        self.secondaryColor = UIColorFromRGB(0x1DFCFE);
    }

    return self;
}

- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
    NSMutableArray * composers = [NSMutableArray array];
    //1
    STGPUImageOutputComposeItem * composeItem0 = [STGPUImageOutputComposeItem new];
    composeItem0.source = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO];
    GPUImageTransformFilter * transformFilter1 = [[GPUImageTransformFilter alloc] init];
    transformFilter1.affineTransform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(.015f,0),CGAffineTransformMakeScale(1.04,1.04));
    composeItem0.filters = @[
            [GPUImageRGBFilter rgbColor:self.primaryColor]
            ,transformFilter1
    ];
    composeItem0.composer = [[GPUImageLightenBlendFilter alloc] init];
    [composers addObject:composeItem0];

    //2
//    STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem new];
//    composeItem1.source = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:YES];
//    composeItem1.composer = GPUImageSoftLightBlendFilter.new;
//    [composers addObject:composeItem1];
//
//    //3
//    STGPUImageOutputComposeItem * composeItem3 = [STGPUImageOutputComposeItem new];
//    composeItem3.source = [[GPUImagePicture alloc] initWithImage:sourceImages[1] smoothlyScaleOutput:NO];
//    composeItem3.composer = GPUImageDarkenBlendFilter .new;
//    [composers addObject:composeItem3];

    //4
    STGPUImageOutputComposeItem * composeItem4 = [STGPUImageOutputComposeItem new];
    composeItem4.source = [[GPUImagePicture alloc] initWithImage:sourceImages[1] smoothlyScaleOutput:NO];
    GPUImageSaturationFilter * saturationFilter4 = GPUImageSaturationFilter.new;
    saturationFilter4.saturation = 1.2;
    GPUImageTransformFilter * transformFilter4 = [[GPUImageTransformFilter alloc] init];
    transformFilter4.affineTransform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-.015f,0),CGAffineTransformMakeScale(1.04,1.04));
    composeItem4.filters = @[
            [GPUImageRGBFilter rgbColor:self.secondaryColor]
//            , saturationFilter4
            ,transformFilter4
    ];

    [composers addObject:composeItem4];

    return [composers reverse];
}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    NSMutableArray * composers = [NSMutableArray array];

    [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:sourceImage
                                                                  composer:[[GPUImageLightenBlendFilter alloc] init]] addFilters:@[
            [[GPUImageGrayscaleFilter alloc] init]
    ]]];

    [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:sourceImage
                                                                  composer:[[GPUImageSoftLightBlendFilter alloc] init]] addFilters:@[
            [[GPUImageGrayscaleFilter alloc] init]
            , [[GPUImageTransformFilter translate:.2f y:0] scaleScalar:1.3]
            , [GPUImageFalseColorFilter colors:@[UIColorFromRGB(0xEC3CA3),UIColorFromRGB(0xA0C2D0)]]
//            ,[GPUImageSaturationFilter saturation:2]
    ]]];

//    sourceImage = [sourceImage blurredImageWithRadius:100 iterations:2 tintColor:nil];
    [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:sourceImage] addFilters:@[
            [[GPUImageGrayscaleFilter alloc] init]
            , [GPUImageFalseColorFilter colors:@[self.primaryColor, self.secondaryColor]]
//            ,[GPUImageSaturationFilter saturation:2]
            , [[GPUImageTransformFilter translate:-.15f y:0] scaleScalar:1.2]
//            ,[GPUImageRGBFilter rgbColor:self.primaryColor]
    ]]];

    return [composers reverse];
}

@end