//
// Created by BLACKGENE on 7/20/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerLeifEffect.h"
#import "GPUImageChromaKeyBlendFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageTransformFilter.h"
#import "STGPUImageOutputComposeItem.h"
#import "NSNumber+STUtil.h"
#import "NSArray+STUtil.h"
#import "GPUImageTransformFilter+STGPUImageFilter.h"
#import "GPUImageNormalBlendFilter.h"
#import "UIImage+STUtil.h"


@implementation STGIFFDisplayLayerLeifEffect {
    //Standard method of multi blending : https://github.com/BradLarson/GPUImage/issues/269
}

- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {

    return [self composersToProcessSingle:sourceImages[0]];
}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    NSUInteger count = 8;
    UIImage * circluarClippedImage = [sourceImage clipAsCircle:sourceImage.size.width scale:sourceImage.scale];
    NSArray * composers = [[[@(count) st_intArray] reverse] mapWithIndex:^id(id object, NSInteger index) {
        @autoreleasepool {
            CGFloat offset = [object floatValue];
            CGFloat minScale = .4f;
            CGFloat scaleValue = AGKRemap(offset, 0, count - 1, minScale, 1);
//            scaleValue *= AGKEaseOutWithOverShoot([object floatValue]/count, 1.8f);

            STGPUImageOutputComposeItem *composeItem1 = STGPUImageOutputComposeItem.new;

            if (offset == count-1) { //background biggest image
                composeItem1.source = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:NO];
                composeItem1.filters = @[
                        [GPUImageTransformFilter rotateDegree:90]
                ];

            } else {
                composeItem1.source = [[GPUImagePicture alloc] initWithImage:circluarClippedImage smoothlyScaleOutput:NO];
                composeItem1.composer = GPUImageNormalBlendFilter.new;
                composeItem1.filters = @[
                        [[GPUImageTransformFilter scaleScalar:scaleValue] rotate:AGKDegreesToRadians(AGKRemap(offset, 0, count - 1, 0, 90))]
                ];
            }

            return composeItem1;
        }
    }];

    return composers;
}

@end