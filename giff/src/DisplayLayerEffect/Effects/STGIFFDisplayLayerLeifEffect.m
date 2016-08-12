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
#import "NSNumber+STUtil.h"
#import "NSArray+STUtil.h"


@implementation STGIFFDisplayLayerLeifEffect {
    //Standard method of multi blending : https://github.com/BradLarson/GPUImage/issues/269
}

- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
    NSUInteger composeCount = 6;

    return [[@(composeCount) st_intArray] mapWithIndex:^id(id object, NSInteger index) {
        CGFloat scaleValue = AGKRemap([object floatValue],0,composeCount-1,.2,1);

        scaleValue *= AGKEaseOutWithOverShoot([object floatValue]/composeCount, 1.5f);

        STGPUImageOutputComposeItem * composeItem1 = STGPUImageOutputComposeItem.new;
        composeItem1.source = [[GPUImagePicture alloc] initWithImage:index== 2 /*|| [object integerValue]==composeCount-1 */ ? sourceImages[1] : sourceImages[0] smoothlyScaleOutput:NO];

        if(index>0){
            composeItem1.composer = GPUImageSoftLightBlendFilter.new;
        }

        if(scaleValue!=1){
            GPUImageTransformFilter * scaleFilter1 = [[GPUImageTransformFilter alloc] init];
            scaleFilter1.affineTransform = CGAffineTransformMakeScale(scaleValue,scaleValue);
            composeItem1.filters = @[
                    scaleFilter1
            ];
        }
        return composeItem1;
    }];
}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    NSUInteger composeCount = 6;

    NSArray * composeIndexes = [@(composeCount) st_intArray];
//    composeIndexes = [composeIndexes reverse];

    return [composeIndexes mapWithIndex:^id(id object, NSInteger index) {

        CGFloat scaleValue = AGKRemap(index,0,composeCount-1,.2,1);

        scaleValue *= AGKEaseOutWithOverShoot([object floatValue]/composeCount, 1.8f);

        STGPUImageOutputComposeItem * composeItem1 = STGPUImageOutputComposeItem.new;
        composeItem1.source = [[GPUImagePicture alloc] initWithImage: sourceImage smoothlyScaleOutput:NO];

        if(index>0){
            composeItem1.composer = GPUImageSoftLightBlendFilter.new;
        }

        if(scaleValue!=1){
            GPUImageTransformFilter * scaleFilter1 = [[GPUImageTransformFilter alloc] init];
            scaleFilter1.affineTransform = CGAffineTransformMakeScale(scaleValue,scaleValue);
            composeItem1.filters = @[
                    scaleFilter1
            ];
        }

        return composeItem1;
    }];
}

@end