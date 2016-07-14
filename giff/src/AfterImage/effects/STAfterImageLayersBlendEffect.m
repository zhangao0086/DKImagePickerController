//
// Created by BLACKGENE on 7/14/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageLayersBlendEffect.h"
#import "UIImage+STUtil.h"


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