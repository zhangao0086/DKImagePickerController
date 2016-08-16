//
// Created by BLACKGENE on 8/16/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerDoubleExposureEffect.h"
#import "GPUImageChromaKeyBlendFilter.h"
#import "GPUImagePicture.h"
#import "STFilter.h"
#import "STGPUImageOutputComposeItem.h"

@implementation STGIFFDisplayLayerDoubleExposureEffect {

}

- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
    NSMutableArray * composers = [NSMutableArray array];

    //soure image
    STGPUImageOutputComposeItem * composeItemB = [STGPUImageOutputComposeItem new];
    composeItemB.source = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO];
    composeItemB.composer = [GPUImageLightenBlendFilter new];
//    GPUImageSaturationFilter * saturationFilter = GPUImageSaturationFilter.new;
//    saturationFilter.saturation = 1.2f;
//    composeItemB.filters = @[
//            saturationFilter
//    ];
    [composers addObject:composeItemB];

    //mask image
    STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem new];
    composeItem1.source = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO];
    composeItem1.composer = GPUImageMaskFilter.new;

    GPUImageContrastFilter * contrastFilter = GPUImageContrastFilter.new;
    contrastFilter.contrast = 3.f;

    composeItem1.filters = @[
            GPUImageColorInvertFilter.new
            ,contrastFilter
    ];
    [composers addObject:composeItem1];

    //background image
    STGPUImageOutputComposeItem * composeItemA = [STGPUImageOutputComposeItem new];
    composeItemA.source = [[GPUImagePicture alloc] initWithImage:sourceImages[1] smoothlyScaleOutput:NO];
    [composers addObject:composeItemA];

    return [composers reverse];
}


@end