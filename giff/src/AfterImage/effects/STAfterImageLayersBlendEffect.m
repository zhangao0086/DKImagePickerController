//
// Created by BLACKGENE on 7/14/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageLayersBlendEffect.h"
#import "UIImage+STUtil.h"

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
        GPUImageOverlayBlendFilter * overlayBlendFilter = [[GPUImageOverlayBlendFilter alloc] init];

        GPUImagePicture * sourcePicture = [[GPUImagePicture alloc] initWithImage:[UIImage imageBundled:@"blend.JPG"] smoothlyScaleOutput:YES];
        [sourcePicture addTarget:overlayBlendFilter];
        [sourcePicture processImage];

        GPUImagePicture * originalPicture = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:YES];
        [originalPicture addTarget:overlayBlendFilter];
        [originalPicture processImage];

        [overlayBlendFilter useNextFrameForImageCapture];

        return [overlayBlendFilter imageFromCurrentFramebufferWithOrientation:sourceImage.imageOrientation];
    }
}
@end