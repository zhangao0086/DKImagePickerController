//
// Created by BLACKGENE on 7/20/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerJanneEffect.h"
#import "GPUImageChromaKeyBlendFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageDifferenceBlendFilter.h"
#import "GPUImageSourceOverBlendFilter.h"
#import "GPUImageOverlayBlendFilter.h"
#import "GPUImageAlphaBlendFilter.h"
#import "GPUImageMonochromeFilter.h"
#import "UIColor+BFPaperColors.h"
#import "Colours.h"
#import "GPUImageColorBlendFilter.h"
#import "GPUImageFalseColorFilter.h"
#import "GPUImageHardLightBlendFilter.h"
#import "GPUImageSubtractBlendFilter.h"
#import "GPUImageDarkenBlendFilter.h"
#import "GPUImageSoftLightBlendFilter.h"
#import "GPUImageTransformFilter.h"
#import "GPUImageZoomBlurFilter.h"
#import "STGPUImageOffsetScalingFilter.h"
#import "STFilter.h"
#import "STFilterManager.h"
#import "UIImage+STUtil.h"
#import "STGPUImageOutputComposeItem.h"

// chroma key black / white -> add

@implementation STGIFFDisplayLayerJanneEffect {

}

- (UIImage *)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    @autoreleasepool {
        UIImage *inputImage = sourceImages[0];

        //0
        STGPUImageOutputComposeItem * composeItem0 = [STGPUImageOutputComposeItem new];
        composeItem0.source = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:NO];

        GPUImageBrightnessFilter * brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
        brightnessFilter.brightness = -.5f;
        composeItem0.filters = @[
                brightnessFilter
        ];

        //1
        STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem new];
        composeItem1.source = [[GPUImagePicture alloc] initWithImage:[UIImage imageBundled:@"input.jpg"] smoothlyScaleOutput:YES];
        composeItem1.composer = [[GPUImageLightenBlendFilter alloc] init];

        GPUImageSobelEdgeDetectionFilter * edgeDetectionFilter = [[GPUImageSobelEdgeDetectionFilter alloc] init];
        edgeDetectionFilter.edgeStrength = 4;

        GPUImageRGBFilter * colorFilter_add = [[GPUImageRGBFilter alloc] init];
        NSArray* colors_add = [UIColorFromRGB(0xff0000) rgbaArray];
        colorFilter_add.red = 1;
        colorFilter_add.green = 0;
        colorFilter_add.blue = 0;

        composeItem1.filters = @[
                edgeDetectionFilter,
                colorFilter_add
        ];

        //2
        STGPUImageOutputComposeItem * composeItem2 = [STGPUImageOutputComposeItem itemWithSource:[[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:NO]
                                                                                        composer:[[GPUImageSoftLightBlendFilter alloc] init]];
        GPUImageTransformFilter * scaleFilter2 = [[GPUImageTransformFilter alloc] init];
        scaleFilter2.affineTransform = CGAffineTransformMakeScale(.4,.4);
        composeItem2.filters = @[
                scaleFilter2
        ];

        return [[[STFilterManager sharedManager] buildTerminalOutputToComposeMultiSource:@[
                composeItem0
                ,composeItem1
//                ,composeItem2
        ] processForImage:YES] imageFromCurrentFramebuffer];

//        GPUImagePicture * sourcePicture = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:YES];
//
//        GPUImagePicture * overlayPicture = [[GPUImagePicture alloc] initWithImage:[UIImage imageBundled:@"input.jpg"] smoothlyScaleOutput:YES];
//
//        GPUImageLightenBlendFilter *blendFilter = [[GPUImageLightenBlendFilter alloc] init];
//
//        //color
//        GPUImageRGBFilter * colorFilter_add = [[GPUImageRGBFilter alloc] init];
//        NSArray* colors_add = [UIColorFromRGB(0xff0000) rgbaArray];
//        colorFilter_add.red = 1;
//        colorFilter_add.green = 0;
//        colorFilter_add.blue = 0;
//
////    [colorFilter_add setColorRed:[colors_add[0] floatValue]
////                           green:[colors_add[1] floatValue]
////                            blue:[colors_add[2] floatValue]];
//
//        GPUImageSobelEdgeDetectionFilter * edgeDetectionFilter = [[GPUImageSobelEdgeDetectionFilter alloc] init];
//        edgeDetectionFilter.edgeStrength = 4;
//
//        [overlayPicture addTarget:edgeDetectionFilter];
//        [edgeDetectionFilter addTarget:colorFilter_add];
//        [colorFilter_add addTarget:blendFilter];
//
//        GPUImageBrightnessFilter * brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
//        brightnessFilter.brightness = -.5f;
//
//        [sourcePicture addTarget:brightnessFilter];
//        [brightnessFilter addTarget:blendFilter];
//
//        [blendFilter useNextFrameForImageCapture];
//
//        [overlayPicture useNextFrameForImageCapture];
//        [overlayPicture processImage];
//
//        [sourcePicture useNextFrameForImageCapture];
//        [sourcePicture processImage];
//
//        return [blendFilter imageFromCurrentFramebuffer];
    }
}

@end