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

// chroma key black / white -> add

@implementation STGIFFDisplayLayerJanneEffect {

}

- (UIImage *)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    @autoreleasepool {
        GPUImagePicture * sourcePicture = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:YES];

        GPUImagePicture * overlayPicture = [[GPUImagePicture alloc] initWithImage:[UIImage imageBundled:@"input.jpg"] smoothlyScaleOutput:YES];

        GPUImageLightenBlendFilter *blendFilter = [[GPUImageLightenBlendFilter alloc] init];

        //color
        GPUImageRGBFilter * colorFilter_add = [[GPUImageRGBFilter alloc] init];
        NSArray* colors_add = [UIColorFromRGB(0xff0000) rgbaArray];
        colorFilter_add.red = 1;
        colorFilter_add.green = 0;
        colorFilter_add.blue = 0;

//    [colorFilter_add setColorRed:[colors_add[0] floatValue]
//                           green:[colors_add[1] floatValue]
//                            blue:[colors_add[2] floatValue]];

        GPUImageSobelEdgeDetectionFilter * edgeDetectionFilter = [[GPUImageSobelEdgeDetectionFilter alloc] init];
        edgeDetectionFilter.edgeStrength = 4;

        [overlayPicture addTarget:edgeDetectionFilter];
        [edgeDetectionFilter addTarget:colorFilter_add];
        [colorFilter_add addTarget:blendFilter];

        GPUImageBrightnessFilter * brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
        brightnessFilter.brightness = -.5f;

        [sourcePicture addTarget:brightnessFilter];
        [brightnessFilter addTarget:blendFilter];

        [blendFilter useNextFrameForImageCapture];

        [overlayPicture useNextFrameForImageCapture];
        [overlayPicture processImage];

        [sourcePicture useNextFrameForImageCapture];
        [sourcePicture processImage];

        return [blendFilter imageFromCurrentFramebuffer];
    }
}

@end