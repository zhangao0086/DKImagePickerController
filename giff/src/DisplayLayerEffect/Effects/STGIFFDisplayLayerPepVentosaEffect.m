//
// Created by BLACKGENE on 8/12/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerPepVentosaEffect.h"
#import "NSNumber+STUtil.h"
#import "STGPUImageOutputComposeItem.h"
#import "GPUImagePicture.h"
#import "GPUImageSoftLightBlendFilter.h"
#import "GPUImageTransformFilter.h"
#import "NSArray+STUtil.h"
#import "GPUImageLightenBlendFilter.h"
#import "GPUImageAlphaBlendFilter.h"
#import "GPUImageOverlayBlendFilter.h"
#import "GPUImageDarkenBlendFilter.h"
#import "GPUImageDivideBlendFilter.h"
#import "GPUImageExclusionBlendFilter.h"
#import "GPUImageContrastFilter.h"


@implementation STGIFFDisplayLayerPepVentosaEffect {

}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    NSUInteger composeCount = 12;

    NSArray * composeIndexes = [@(composeCount) st_intArray];
//    composeIndexes = [composeIndexes reverse];

    return [composeIndexes mapWithIndex:^id(id object, NSInteger index) {
        @autoreleasepool {
            STGPUImageOutputComposeItem * composeItem1 = STGPUImageOutputComposeItem.new;
            composeItem1.source = [[GPUImagePicture alloc] initWithImage: sourceImage smoothlyScaleOutput:NO];

            if(index>0){
                GPUImageAlphaBlendFilter * alphaBlendFilter = GPUImageAlphaBlendFilter.new;
                alphaBlendFilter.mix = .1f;// * (CGFloat) randomdzto();
                composeItem1.composer = alphaBlendFilter;
//                composeItem1.composer = GPUImageExclusionBlendFilter.new;

                CGFloat randomDegree = (CGFloat) (((CGFloat) randomir(1, 5)+ randomdzto()) * (randomdzto()>=.5 ? 1 : -1));
                CGFloat radianValue = AGKDegreesToRadians(randomDegree);

                CGFloat randomScale = 1 + (CGFloat)randomir(1, 16)*.01f;

                CGFloat randomTx = ((CGFloat)randomir(1, 5)*.01f)*(randomdzto()>=.5 ? 1 : -1);
                CGFloat randomTy = ((CGFloat)randomir(1, 5)*.01f)*(randomdzto()>=.5 ? 1 : -1);

                GPUImageTransformFilter * scaleFilter1 = [[GPUImageTransformFilter alloc] init];
                scaleFilter1.affineTransform = CGAffineTransformScale(scaleFilter1.affineTransform, randomScale,randomScale);
                scaleFilter1.affineTransform = CGAffineTransformRotate(scaleFilter1.affineTransform, radianValue);
                scaleFilter1.affineTransform = CGAffineTransformTranslate(scaleFilter1.affineTransform, randomTx,randomTy);

                GPUImageContrastFilter * contrastFilter = GPUImageContrastFilter.new;
                contrastFilter.contrast = 3.f;

                composeItem1.filters = @[
                        contrastFilter,
                        scaleFilter1
                ];
            }

            return composeItem1;
        }
    }];
}

@end