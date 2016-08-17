//
// Created by BLACKGENE on 8/17/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerColoredHalfToneEffect.h"
#import "GPUImageHalftoneFilter.h"
#import "GPUImageMosaicFilter.h"
#import "STGPUImageOutputComposeItem.h"
#import "GPUImageFalseColorFilter.h"
#import "GPUImageFalseColorFilter+STGPUImageFilter.h"
#import "UIColor+BFPaperColors.h"
#import "GPUImageNormalBlendFilter.h"
#import "GPUImageTransformFilter.h"


@implementation STGIFFDisplayLayerColoredHalfToneEffect {

}

- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
    return [self composersToProcessSingle:sourceImages[0]];
}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    NSMutableArray * composers = NSMutableArray.array;

    GPUImageHalftoneFilter * halftoneFilter = GPUImageHalftoneFilter.new;
    halftoneFilter.fractionalWidthOfAPixel = 0.015f;

    STGPUImageOutputComposeItem * composeItem0 = [STGPUImageOutputComposeItem new];
    composeItem0.composer = GPUImageNormalBlendFilter.new;
    [[composeItem0 setSourceAsImage:sourceImage] setFilters:@[
            halftoneFilter
            ,[GPUImageFalseColorFilter filterWithColors:@[
                    UIColorFromRGB(0xEC0000)
                    , UIColorFromRGB(0xADFBFB)
            ]]
    ]];
    [composers addObject:composeItem0];


    GPUImageHalftoneFilter * halftoneFilterBig = GPUImageHalftoneFilter.new;
    halftoneFilterBig.fractionalWidthOfAPixel = 0.0415f;

    STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem new];
    [[composeItem1 setSourceAsImage:sourceImage] setFilters:@[
            halftoneFilterBig
            ,[GPUImageFalseColorFilter filterWithColors:@[
                    UIColorFromRGB(0xEC0000)
                    , UIColorFromRGB(0xADFBFB)
            ]]
    ]];
    [composers addObject:composeItem1];


    return [composers reverse];
}

@end