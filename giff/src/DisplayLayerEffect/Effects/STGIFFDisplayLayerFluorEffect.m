//
// Created by BLACKGENE on 7/20/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerFluorEffect.h"
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
#import "GPUImageRGBFilter+STGPUImageFilter.h"

// chroma key black / white -> add

@implementation STGIFFDisplayLayerFluorEffect {

}

- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    @autoreleasepool {
        NSMutableArray * composers = [NSMutableArray array];

        //0
        STGPUImageOutputComposeItem * composeItem0 = [STGPUImageOutputComposeItem new];
        composeItem0.source = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO];

//        GPUImageBrightnessFilter * brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
//        brightnessFilter.brightness = -.5f;
//        composeItem0.filters = @[
//                brightnessFilter
//        ];
        [composers addObject:composeItem0];

        //1
        STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem new];
        composeItem1.source = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:YES];
        composeItem1.composer = [[GPUImageLightenBlendFilter alloc] init];

        GPUImageSobelEdgeDetectionFilter * edgeDetectionFilter = [[GPUImageSobelEdgeDetectionFilter alloc] init];
        edgeDetectionFilter.edgeStrength = 3;

        composeItem1.filters = @[
                edgeDetectionFilter,
                [GPUImageRGBFilter filterWithColor:UIColorFromRGB(0xff0000)]
        ];
        [composers addObject:composeItem1];

        //2
        STGPUImageOutputComposeItem * composeItem2 = [STGPUImageOutputComposeItem itemWithSource:[[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO]
                                                                                        composer:[[GPUImageSoftLightBlendFilter alloc] init]];
        GPUImageTransformFilter * scaleFilter2 = [[GPUImageTransformFilter alloc] init];
        scaleFilter2.affineTransform = CGAffineTransformMakeScale(.4,.4);
        composeItem2.filters = @[
                scaleFilter2
        ];
        [composers addObject:composeItem2];


        return [[[STFilterManager sharedManager] buildTerminalOutputToComposeMultiSource:composers forInput:nil] imageFromCurrentFramebuffer];
    }
}

 
@end