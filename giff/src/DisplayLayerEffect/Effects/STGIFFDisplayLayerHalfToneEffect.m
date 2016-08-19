//
// Created by BLACKGENE on 8/19/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerHalfToneEffect.h"
#import "STGPUImageHalftoneFilter.h"
#import "STGPUImageOutputComposeItem.h"
#import "GPUImageBrightnessFilter.h"
#import "GPUImageBrightnessFilter+STGPUImageFilter.h"
#import "GPUImageFalseColorFilter.h"
#import "UIColor+BFPaperColors.h"
#import "GPUImageFalseColorFilter+STGPUImageFilter.h"
#import "GPUImageColorInvertFilter.h"
#import "UIImage+STUtil.h"
#import "GPUImageMaskFilter.h"
#import "GPUImageTransformFilter.h"
#import "GPUImageTransformFilter+STGPUImageFilter.h"


@implementation STGIFFDisplayLayerHalfToneEffect {

}

- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    NSMutableArray * composers = NSMutableArray.array;

    STGPUImageHalftoneFilter * halftoneFilter = STGPUImageHalftoneFilter.new;
    halftoneFilter.fractionalWidthOfAPixel = 0.01f;
    STGPUImageOutputComposeItem * composeItem0 = [STGPUImageOutputComposeItem new];
    [[composeItem0 setSourceAsImage:sourceImages[0]] setFilters:@[
//            [GPUImageBrightnessFilter brightness:-.2f]
//            ,
            halftoneFilter
//            [GPUImageFalseColorFilter filterWithColors:@[
//                    UIColorFromRGB(0xEC0000)
//                    , UIColorFromRGB(0xADFBFB)
//            ]]
    ]];
    [composers addObject:composeItem0];

    UIImage * halfToneB = [self processComposers:[composers reverse]];

    [composers removeAllObjects];

    STGPUImageOutputComposeItem * maskItem = STGPUImageOutputComposeItem.new;
    [maskItem setSourceAsImage:halfToneB];
    maskItem.composer = GPUImageMaskFilter.new;
    [composers addObject:maskItem];

    STGPUImageHalftoneFilter * halftoneFilter1 = STGPUImageHalftoneFilter.new;
    halftoneFilter1.fractionalWidthOfAPixel = 0.005f;
    STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem new];
    [[composeItem1 setSourceAsImage:sourceImages[0]] setFilters:@[
//             [GPUImageBrightnessFilter brightness:-.2f]
//            ,
            halftoneFilter1
//    ,GPUImageColorInvertFilter.new
//            , [GPUImageFalseColorFilter filterWithColors:@[
//                    UIColorFromRGB(0xEC0000)
//                    , UIColorFromRGB(0xADFBFB)
//            ]]
            ,[GPUImageTransformFilter transform:CGAffineTransformMakeTranslation(
                    halftoneFilter1.fractionalWidthOfAPixel,
                    halftoneFilter1.fractionalWidthOfAPixel
            )]
//            ,[GPUImageTransformFilter.new scaleScalar:1.2f]
    ]];

    [composers addObject:composeItem1];

    UIImage * halfToneF = [self processComposers:[composers reverse]];

    //https://www.yumpu.com/en/document/view/11401079/blending/7
    UIImage * resultImage = [halfToneB drawOver:halfToneF atPosition:CGPointZero alpha:1 blend:kCGBlendModeSourceIn];

    return resultImage;
}


@end