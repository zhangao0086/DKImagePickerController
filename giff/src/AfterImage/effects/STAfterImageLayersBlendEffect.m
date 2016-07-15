//
// Created by BLACKGENE on 7/14/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageLayersBlendEffect.h"
#import "UIImage+STUtil.h"
#import "UIColor+BFPaperColors.h"
#import "Colours.h"

/*
 * GPUImagePicture *inputPicture = [[GPUImagePicture alloc] initWithImage:self.inputImage smoothlyScaleOutput:NO];

//pass1 Overlay -> texture1
GPUImagePicture *pass1Texture = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"texture1.png"] smoothlyScaleOutput:NO];
GPUImageOverlayBlendFilter *pass1Filter = [[GPUImageOverlayBlendFilter alloc] init];

[inputPicture addTarget:pass1Filter];
[pass1Texture addTarget:pass1Filter];
[pass1Texture processImage];


//pass2 SoftLight -> texture2
GPUImagePicture *pass2Texture = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"texture2.png"] smoothlyScaleOutput:NO];
GPUImageSoftLightBlendFilter *pass2Filter = [[GPUImageSoftLightBlendFilter alloc] init];

[pass1Filter addTarget:pass2Filter];
[pass2Texture addTarget:pass2Filter];
[pass2Texture processImage];

//process
[inputPicture processImage];
UIImage *outputImage = [pass2Filter imageFromCurrentlyProcessedOutput];
 */

@implementation STAfterImageLayersBlendEffect {

}

- (UIImage *)processEffect:(UIImage *__nullable)sourceImage {
    @autoreleasepool {

        GPUImageChromaKeyBlendFilter * overlayBlendFilter = [[GPUImageChromaKeyBlendFilter alloc] init];
        overlayBlendFilter.thresholdSensitivity = .4;
//        overlayBlendFilter.smoothing = .6;

//        NSArray* colors = [UIColorFromRGB(0x4470c0) rgbaArray];
//        oo(colors);
//        [overlayBlendFilter setColorToReplaceRed:[colors[0] floatValue] green:[colors[1] floatValue] blue:[colors[2] floatValue]];
        [overlayBlendFilter setColorToReplaceRed:0 green:1 blue:0];

        //source
        GPUImagePicture * pictureChromakey = [[GPUImagePicture alloc] initWithImage:[UIImage imageBundled:@"chro0.png"] smoothlyScaleOutput:YES];
        [pictureChromakey addTarget:overlayBlendFilter];
        [pictureChromakey processImage];

        GPUImagePicture * pictureToInsert = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:YES];
        [pictureToInsert addTarget:overlayBlendFilter];
        [pictureToInsert processImage];

//        GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
//        blendFilter.mix = 1.0;
//        [sourcePicture addTarget:blendFilter];
//        [overlayBlendFilter addTarget:blendFilter];

        [overlayBlendFilter useNextFrameForImageCapture];

        return [overlayBlendFilter imageFromCurrentFramebufferWithOrientation:sourceImage.imageOrientation];
    }
}
@end