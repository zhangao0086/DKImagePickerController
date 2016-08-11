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
#import "GPUImageMonochromeFilter+STGPUImageFilter.h"
#import "GPUImageMotionBlurFilter+STGPUImageFilter.h"

@implementation STGIFFDisplayLayerAfterImagePopStarEffect {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.colors = @[UIColorFromRGB(0xf944b1), UIColorFromRGB(0x00BAED)];
    }

    return self;
}

- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    NSMutableArray * composers = [NSMutableArray array];

    //1
    STGPUImageOutputComposeItem * composeItem0 = [STGPUImageOutputComposeItem new];
    composeItem0.source = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO];
    GPUImageSaturationFilter * saturationFilter0 = GPUImageSaturationFilter.new;
    saturationFilter0.saturation = 1.6;
    composeItem0.filters = [@[
            [GPUImageMonochromeFilter filterWithColor:[self colors][0]]
            , saturationFilter0
    ] arrayByAddingObjectsFromArray:[GPUImageMotionBlurFilter filtersWithBlurSize:16 countToDivide360Degree:4]];
    composeItem0.composer = [[GPUImageOverlayBlendFilter alloc] init];
    [composers addObject:composeItem0];

//    //2
//    if(sourceImages.count>1){
//        STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem new];
//        composeItem1.source = [[GPUImagePicture alloc] initWithImage:sourceImages[1] smoothlyScaleOutput:YES];
//        composeItem1.composer = [[GPUImageLightenBlendFilter alloc] init];
//        [composers addObject:composeItem1];
//    }

    //3
    STGPUImageOutputComposeItem * composeItem3 = [STGPUImageOutputComposeItem new];
    composeItem3.source = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO];
    composeItem3.composer = [[GPUImageDarkenBlendFilter alloc] init];
    [composers addObject:composeItem3];

    //4
    STGPUImageOutputComposeItem * composeItem4 = [STGPUImageOutputComposeItem new];
    composeItem4.source = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO];
    GPUImageSaturationFilter * saturationFilter4 = GPUImageSaturationFilter.new;
    saturationFilter4.saturation = 1.6;
    composeItem4.filters = @[
            [GPUImageMonochromeFilter filterWithColor:[self colors][1]]
            ,saturationFilter4
    ];
    [composers addObject:composeItem4];

    return [[[STFilterManager sharedManager] buildTerminalOutputToComposeMultiSource:[composers reverse] forInput:nil] imageFromCurrentFramebuffer];
}

@end