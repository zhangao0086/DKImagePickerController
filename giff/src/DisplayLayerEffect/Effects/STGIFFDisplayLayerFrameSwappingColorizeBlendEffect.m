//
// Created by BLACKGENE on 7/19/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerFrameSwappingColorizeBlendEffect.h"
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


//GPUImagePicture : addTargets -> useNextFrameForImageCapture -> processImage
//GPUImageFilter : addTargets-> forceProcessingAtSize -> useNextFrameForImageCapture -> imageFromCurrentFramebufferWithOrientation
@implementation STGIFFDisplayLayerFrameSwappingColorizeBlendEffect {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        _alpha = 1;
    }

    return self;
}

- (UIImage *)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    @autoreleasepool {

        GPUImageSoftLightBlendFilter * blendFilter = [[GPUImageSoftLightBlendFilter alloc] init];
//        GPUImageDarkenBlendFilter * blendFilter = [[GPUImageDarkenBlendFilter alloc] init];

        UIImage * sourceImage = sourceImages[0];

        //TODO: 알파 구현은 GPUImageOpacityFilter *opacityFilter = [[GPUImageOpacityFilter alloc] init];

        //target
        GPUImagePicture * effectPicture = [[GPUImagePicture alloc] initWithImage:sourceImages[1] smoothlyScaleOutput:YES];

        GPUImageFalseColorFilter * colorFilter_add = [[GPUImageFalseColorFilter alloc] init];
//        colorFilter_add.intensity = 1;
//        NSArray* colors_add = [UIColorFromRGB(0xff0000) rgbaArray];
//        [colorFilter_add setColorRed:[colors_add[0] floatValue]
//                               green:[colors_add[1] floatValue]
//                                blue:[colors_add[2] floatValue]];
        [effectPicture addTarget:colorFilter_add];
        [colorFilter_add addTarget:blendFilter];


        //source
        GPUImagePicture * sourcePicture = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:YES];

        GPUImageMonochromeFilter * colorFilter_src = [[GPUImageMonochromeFilter alloc] init];
        colorFilter_src.intensity = .6;
        NSArray* colors_src = [UIColorFromRGB(0x0000ff) rgbaArray];
        [colorFilter_src setColorRed:[colors_src[0] floatValue]
                               green:[colors_src[1] floatValue]
                                blue:[colors_src[2] floatValue]];

        [sourcePicture addTarget:colorFilter_src];
        [colorFilter_src addTarget:blendFilter];

        if(self.fitOutputSizeToSourceImage){
            [blendFilter forceProcessingAtSize:sourceImage.size];
        }

        [blendFilter useNextFrameForImageCapture];

        [effectPicture useNextFrameForImageCapture];
        [effectPicture processImage];

        [sourcePicture useNextFrameForImageCapture];
        [sourcePicture processImage];

        return [blendFilter imageFromCurrentFramebufferWithOrientation:[[sourceImages firstObject] imageOrientation]];
    }
}

@end