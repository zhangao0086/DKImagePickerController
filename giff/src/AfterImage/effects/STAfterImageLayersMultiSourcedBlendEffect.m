//
// Created by BLACKGENE on 7/19/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageLayersMultiSourcedBlendEffect.h"
#import "GPUImageChromaKeyBlendFilter.h"
#import "GPUImagePicture.h"


@implementation STAfterImageLayersMultiSourcedBlendEffect {

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