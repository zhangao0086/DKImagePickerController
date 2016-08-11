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
#import "GPUImageMonochromeFilter+STGPUImage.h"

@implementation STGIFFDisplayLayerAfterImagePopStarEffect {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.colors = @[UIColorFromRGB(0x00B6AD), UIColorFromRGB(0x24A7AC)];
    }

    return self;
}

- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    NSMutableArray * composers = [NSMutableArray array];

    //1
    STGPUImageOutputComposeItem * composeItem0 = [STGPUImageOutputComposeItem new];
    composeItem0.source = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO];
    composeItem0.filters = @[
            [GPUImageMonochromeFilter filterWithColor:[self colors][0]]
    ];
    composeItem0.composer = [[GPUImageOverlayBlendFilter alloc] init];
    [composers addObject:composeItem0];

//    //2
//    if(sourceImages.count>1){
//        STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem new];
//        composeItem1.source = [[GPUImagePicture alloc] initWithImage:sourceImages[1] smoothlyScaleOutput:YES];
//        composeItem1.composer = [[GPUImageLightenBlendFilter alloc] init];
//        [composers addObject:composeItem1];
//    }
//
//    //3
//    STGPUImageOutputComposeItem * composeItem3 = [STGPUImageOutputComposeItem new];
//    composeItem3.source = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO];
//    composeItem3.composer = [[GPUImageDarkenBlendFilter alloc] init];
//    composeItem3.filters = @[
//            GPUImageFilter.new
//    ];
//    [composers addObject:composeItem3];
//
//    //4
//    STGPUImageOutputComposeItem * composeItem4 = [STGPUImageOutputComposeItem new];
//    composeItem4.source = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO];
//    composeItem4.composer = [[GPUImageDarkenBlendFilter alloc] init];
//    composeItem4.filters = @[
//            [GPUImageMonochromeFilter filterWithColor:[self colors][1]]
//    ];
//    [composers addObject:composeItem4];

    return [[[STFilterManager sharedManager] buildTerminalOutputToComposeMultiSource:composers forInput:nil] imageFromCurrentFramebuffer];
}

@end