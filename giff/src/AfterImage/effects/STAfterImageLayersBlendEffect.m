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

- (UIImage *)processEffect:(NSArray<UIImage *> *__nullable)sourceImages {
    if(sourceImages.count<2){
        return [super processEffect:sourceImages];
    }

    NSAssert(sourceImages.count==2, @"Max 2 sourceImage supported");

    @autoreleasepool {
        GPUImageChromaKeyBlendFilter * overlayBlendFilter = [[GPUImageChromaKeyBlendFilter alloc] init];
        overlayBlendFilter.thresholdSensitivity = .47;
        overlayBlendFilter.smoothing = .1;
        [overlayBlendFilter setColorToReplaceRed:0 green:1 blue:0];

        UIImage * sourceImage = sourceImages[0];
        //source
        GPUImagePicture * chromakeyPicture = [[GPUImagePicture alloc] initWithImage:sourceImages[1] smoothlyScaleOutput:YES];
        [chromakeyPicture addTarget:overlayBlendFilter];
        [chromakeyPicture processImage];

        GPUImagePicture * sourceImagePicture = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:YES];
        [sourceImagePicture addTarget:overlayBlendFilter];
        [sourceImagePicture processImage];

//        GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
//        blendFilter.mix = 1.0;
//        [sourcePicture addTarget:blendFilter];
//        [overlayBlendFilter addTarget:blendFilter];

        if(self.fitOutputSizeToSourceImage){
            [overlayBlendFilter forceProcessingAtSize:sourceImage.size];
        }

        [overlayBlendFilter useNextFrameForImageCapture];

        return [overlayBlendFilter imageFromCurrentFramebufferWithOrientation:[[sourceImages firstObject] imageOrientation]];
    }
}


@end