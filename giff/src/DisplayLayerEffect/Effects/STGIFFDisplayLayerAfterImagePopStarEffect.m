//
// Created by BLACKGENE on 8/10/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerAfterImagePopStarEffect.h"
#import "STGIFFDisplayLayerJanneEffect.h"
#import "GPUImageChromaKeyBlendFilter.h"
#import "GPUImagePicture.h"
#import "UIColor+BFPaperColors.h"
#import "Colours.h"
#import "GPUImageSoftLightBlendFilter.h"
#import "GPUImageTransformFilter.h"
#import "STFilter.h"
#import "STFilterManager.h"
#import "UIImage+STUtil.h"
#import "STGPUImageOutputComposeItem.h"
#import "GPUImageBrightnessFilter.h"
#import "GPUImageLightenBlendFilter.h"
#import "GPUImageRGBFilter.h"
#import "GPUImageSobelEdgeDetectionFilter.h"

@implementation STGIFFDisplayLayerAfterImagePopStarEffect {

}

- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    UIImage *inputImage = sourceImages[0];

    //original
    STGPUImageOutputComposeItem * composeItem0 = [STGPUImageOutputComposeItem new];
    composeItem0.source = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:NO];

    GPUImageBrightnessFilter * brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
//    brightnessFilter.brightness = -.5f;
    composeItem0.filters = @[
//            brightnessFilter
    ];

    //1
    STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem new];
    //TODO: 한개 들어올떼 대체 처리
    composeItem1.source = [[GPUImagePicture alloc] initWithImage:sourceImages.count>1 ? sourceImages[1] : sourceImages[0] smoothlyScaleOutput:YES];
    composeItem1.composer = [[GPUImageLightenBlendFilter alloc] init];

    if(self.colors.count){
//        GPUImageMonochromeFilter * colorizeFilter = [[GPUImageMonochromeFilter alloc] init];
//        colorizeFilter.intensity = 1;
//        NSArray* colors = [UIColorFromRGB(0x00B6AD) rgbaArray];
//        [colorizeFilter setColorRed:[colors[0] floatValue] green:[colors[1] floatValue] blue:[colors[2] floatValue]];
    }

    GPUImageSobelEdgeDetectionFilter * edgeDetectionFilter = [[GPUImageSobelEdgeDetectionFilter alloc] init];
    edgeDetectionFilter.edgeStrength = 4;

    GPUImageRGBFilter * colorFilter_add = [[GPUImageRGBFilter alloc] init];
    NSArray* colors_add = [UIColorFromRGB(0xff0000) rgbaArray];
    colorFilter_add.red = 1;
    colorFilter_add.green = 0;
    colorFilter_add.blue = 0;

    composeItem1.filters = @[
            edgeDetectionFilter,
            colorFilter_add
    ];

    //2
    STGPUImageOutputComposeItem * composeItem2 = [STGPUImageOutputComposeItem itemWithSource:[[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:NO]
                                                                                    composer:[[GPUImageSoftLightBlendFilter alloc] init]];
    GPUImageTransformFilter * scaleFilter2 = [[GPUImageTransformFilter alloc] init];
    scaleFilter2.affineTransform = CGAffineTransformMakeScale(.4,.4);
    composeItem2.filters = @[
            scaleFilter2
    ];

    return [[[STFilterManager sharedManager] buildTerminalOutputToComposeMultiSource:@[
            composeItem0
            , composeItem1

    ] forInput:nil] imageFromCurrentFramebuffer];
}

@end