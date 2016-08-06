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
#import "STGPUImageOutputComposeItem.h"


@implementation STGIFFDisplayLayerLeifEffect {
    //Standard method of multi blending : https://github.com/BradLarson/GPUImage/issues/269
}

- (UIImage *)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    @autoreleasepool {

        UIImage *firstSourceImage = sourceImages[0];
        GPUImagePicture *inputPicture = [[GPUImagePicture alloc] initWithImage:firstSourceImage smoothlyScaleOutput:NO];


        STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem itemWithSource:[[GPUImagePicture alloc] initWithImage:sourceImages.count==2 ? sourceImages[1] : firstSourceImage smoothlyScaleOutput:NO]
                                           composer:[[GPUImageSoftLightBlendFilter alloc] init]];
        GPUImageTransformFilter * scaleFilter1 = [[GPUImageTransformFilter alloc] init];
        scaleFilter1.affineTransform = CGAffineTransformMakeScale(.7,.7);
        composeItem1.filters = @[
                scaleFilter1
        ];

        STGPUImageOutputComposeItem * composeItem2 = [STGPUImageOutputComposeItem itemWithSource:[[GPUImagePicture alloc] initWithImage:firstSourceImage smoothlyScaleOutput:NO]
                                                                                        composer:[[GPUImageSoftLightBlendFilter alloc] init]];
        GPUImageTransformFilter * scaleFilter2 = [[GPUImageTransformFilter alloc] init];
        scaleFilter2.affineTransform = CGAffineTransformMakeScale(.4,.4);
        composeItem2.filters = @[
                scaleFilter2
        ];

        return [[[STFilterManager sharedManager] buildTerminalOutputToComposeMultiSource:@[
                [STGPUImageOutputComposeItem itemWithSource:inputPicture],
                composeItem1,
                composeItem2
        ] forInput:nil] imageFromCurrentFramebuffer];

    }
}

@end