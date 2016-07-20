//
// Created by BLACKGENE on 7/20/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerLeifEffect.h"
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


@implementation STGIFFDisplayLayerLeifEffect {
    //Standard method of multi blending : https://github.com/BradLarson/GPUImage/issues/269
}

- (UIImage *)processEffect:(NSArray<UIImage *> *__nullable)sourceImages {
    @autoreleasepool {

        //TODO: 이걸 Array를 넣든지 거의 무한대로 되게 구조를 변경
        //TODO: PepVentosa + Leif Podhajsky 스타일 모두와 관련된 효과
        GPUImagePicture *inputPicture = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO];

//pass1
        GPUImagePicture *pass1Texture = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO];
        GPUImageSoftLightBlendFilter *pass1 = [[GPUImageSoftLightBlendFilter alloc] init];

        GPUImageTransformFilter * scaleFilter_1 = [[GPUImageTransformFilter alloc] init];
        scaleFilter_1.affineTransform = CGAffineTransformMakeScale(.7,.7);

        [inputPicture addTarget:scaleFilter_1];

        [scaleFilter_1 addTarget:pass1];
        [pass1Texture addTarget:pass1];

//pass2
        GPUImagePicture *pass2Texture = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO];
        GPUImageSoftLightBlendFilter *pass2 = [[GPUImageSoftLightBlendFilter alloc] init];

        GPUImageTransformFilter * scaleFilter_2 = [[GPUImageTransformFilter alloc] init];
        scaleFilter_2.affineTransform = CGAffineTransformMakeScale(.4,.4);

        [pass1 addTarget:pass2];

        [pass2Texture addTarget:scaleFilter_2];
        [scaleFilter_2 addTarget:pass2];

//process
        [pass2 useNextFrameForImageCapture];

        [pass2Texture processImage];
        [pass2Texture useNextFrameForImageCapture];

        [pass1Texture processImage];
        [pass1Texture useNextFrameForImageCapture];

        [inputPicture processImage];
        [inputPicture useNextFrameForImageCapture];

        return [pass2 imageFromCurrentFramebuffer];

//        GPUImageSoftLightBlendFilter * blendFilter = [[GPUImageSoftLightBlendFilter alloc] init];
////        GPUImageDarkenBlendFilter * blendFilter = [[GPUImageDarkenBlendFilter alloc] init];
//
//        //target
//        GPUImagePicture * effectPicture = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:YES];
//
//        GPUImageTransformFilter * scaleFilter_1 = [[GPUImageTransformFilter alloc] init];
//        scaleFilter_1.affineTransform = CGAffineTransformMakeScale(.7,.7);
//
////        colorFilter_add.intensity = 1;
////        NSArray* colors_add = [UIColorFromRGB(0xff0000) rgbaArray];
////        [colorFilter_add setColorRed:[colors_add[0] floatValue]
////                               green:[colors_add[1] floatValue]
////                                blue:[colors_add[2] floatValue]];
//        [effectPicture addTarget:scaleFilter_1];
//        [scaleFilter_1 addTarget:blendFilter];
//
//        //source
//        GPUImagePicture * sourcePicture = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:YES];
//
////        GPUImageMonochromeFilter * colorFilter_src = [[GPUImageMonochromeFilter alloc] init];
////        colorFilter_src.intensity = .6;
////        NSArray* colors_src = [UIColorFromRGB(0x0000ff) rgbaArray];
////        [colorFilter_src setColorRed:[colors_src[0] floatValue]
////                               green:[colors_src[1] floatValue]
////                                blue:[colors_src[2] floatValue]];
////
////        [sourcePicture addTarget:colorFilter_src];
////        [colorFilter_src addTarget:blendFilter];
//
//
//        [sourcePicture addTarget:blendFilter];
//
//        [blendFilter useNextFrameForImageCapture];
//
//        [effectPicture useNextFrameForImageCapture];
//        [effectPicture processImage];
//
//        [sourcePicture useNextFrameForImageCapture];
//        [sourcePicture processImage];
//        return [blendFilter imageFromCurrentFramebufferWithOrientation:[[sourceImages firstObject] imageOrientation]];
    }
}

//
//- (GPUImageTwoInputFilter *)addScale:(CGFloat)scale sourceImage:(UIImage *)sourceImage inputFrom:(GPUImageOutput <GPUImageInput> *)inputTarget{
//
//
//
//
//    return blendFilter;
//}

@end