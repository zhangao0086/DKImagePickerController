//
// Created by BLACKGENE on 8/16/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerInvertMaskEffect.h"
#import "GPUImageChromaKeyBlendFilter.h"
#import "GPUImagePicture.h"
#import "STFilter.h"
#import "STFilterManager.h"
#import "STGPUImageOutputComposeItem.h"
#import "SVGKImage.h"
#import "SVGKImage+STUtil.h"
#import "NSString+STUtil.h"
#import "UIImage+STUtil.h"
#import "GPUImageTransformFilter+STGPUImageFilter.h"

@implementation STGIFFDisplayLayerInvertMaskEffect {

}

- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {


    NSMutableArray * composers = [NSMutableArray array];

    /*
     * masking image
     */
//    UIImage * sourceImageForMask = sourceImages[0];

//    //patt
//    STGPUImageOutputComposeItem * composeItem0 = [STGPUImageOutputComposeItem new];
//    composeItem0.source = [[GPUImagePicture alloc] initWithImage:sourceImageForMask smoothlyScaleOutput:NO];
//    composeItem0.composer = GPUImageMaskFilter.new;
//    [composers addObject:composeItem0];

    //image
    STGPUImageOutputComposeItem * composeItem1 = [STGPUImageOutputComposeItem new];
    composeItem1.source = [[GPUImagePicture alloc] initWithImage:sourceImages[0] smoothlyScaleOutput:NO];
    composeItem1.composer = GPUImageMaskFilter.new;
    composeItem1.filters = @[
            GPUImageColorInvertFilter.new
    ];
    [composers addObject:composeItem1];

//    UIImage * maskedImage = [[[STFilterManager sharedManager] buildTerminalOutputToComposeMultiSource:[composers reverse] forInput:nil] imageFromCurrentFramebuffer];
//    composers = [NSMutableArray array];

    /*
     * source[1] + masked
     */
//    STGPUImageOutputComposeItem * composeItemA = [STGPUImageOutputComposeItem new];
//    composeItemA.source = [[GPUImagePicture alloc] initWithImage:maskedImage smoothlyScaleOutput:NO];
//    composeItemA.composer = GPUImageNormalBlendFilter.new;
//    [composers addObject:composeItemA];

    STGPUImageOutputComposeItem * composeItemB = [STGPUImageOutputComposeItem new];
    composeItemB.source = [[GPUImagePicture alloc] initWithImage:sourceImages[1] smoothlyScaleOutput:NO];
//    if(_scaleOfFadingImage!=1){
//        composeItemB.filters = @[
//                [GPUImageTransformFilter.new addScaleScalar:_scaleOfFadingImage]
//        ];
//    }
    [composers addObject:composeItemB];

    return [composers reverse];
}


@end