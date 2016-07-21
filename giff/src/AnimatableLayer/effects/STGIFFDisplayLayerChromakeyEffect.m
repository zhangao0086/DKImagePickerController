//
// Created by BLACKGENE on 7/14/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <GPUImage/GPUImageChromaKeyBlendFilter.h>
#import <GPUImage/GPUImagePicture.h>
#import "STGIFFDisplayLayerChromakeyEffect.h"
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

/*
GPUImagePicture : addTargets -> useNextFrameForImageCapture -> processImage
GPUImageFilter : addTargets-> forceProcessingAtSize -> useNextFrameForImageCapture -> imageFromCurrentFramebufferWithOrientation
 */

@implementation STGIFFDisplayLayerChromakeyEffect {

}

- (NSUInteger)supportedNumberOfSourceImages {
    return 2;
}

- (UIImage *)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    if(sourceImages.count<2){
        return [super processImages:sourceImages];
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

        GPUImagePicture * sourceImagePicture = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:YES];
        [sourceImagePicture addTarget:overlayBlendFilter];


//        GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
//        blendFilter.mix = 1.0;
//        [sourcePicture addTarget:blendFilter];
//        [overlayBlendFilter addTarget:blendFilter];

        if(self.fitOutputSizeToSourceImage){
            [overlayBlendFilter forceProcessingAtSize:sourceImage.size];
        }

        [chromakeyPicture processImage];
        [chromakeyPicture useNextFrameForImageCapture];

        [sourceImagePicture processImage];
        [sourceImagePicture useNextFrameForImageCapture];

        [overlayBlendFilter useNextFrameForImageCapture];
        return [overlayBlendFilter imageFromCurrentFramebufferWithOrientation:[[sourceImages firstObject] imageOrientation]];
    }
}


@end