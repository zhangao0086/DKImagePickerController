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
#import "STRasterizingImageSourceItem.h"
#import "GPUImageNormalBlendFilter.h"
#import "UIImage+STUtil.h"
#import "CALayer+STUtil.h"
#import "STGIFFDisplayLayerCrossFadeMaskEffect.h"


@implementation STGIFFDisplayLayerLeifEffect {
    //Standard method of multi blending : https://github.com/BradLarson/GPUImage/issues/269
    //http://leifpodhajsky.bigcartel.com/
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _minScaleOfCircle = .4f;
        _maxScaleOfCircle = 1;
    }
    return self;
}


- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {

    NSArray *processedImages = @[
            //FIXME: 너무 헤비 하진 않을까..
            [self processComposers:[self composersToProcessSingle:sourceImages[0]]]
            ,[self processComposers:[self composersToProcessSingle:sourceImages[1]]]
    ];

    UIImage * sourceImage = sourceImages.firstObject;
    CAShapeLayer * layer = [CAShapeLayer layerWithSize:sourceImage.size];
    layer.path = [[UIBezierPath bezierPathWithRect:(CGRect) {CGPointZero, CGSizeMake(sourceImage.size.width / 2, sourceImage.size.height)}] CGPath];
    layer.fillColor = [UIColor whiteColor].CGColor;

    STGIFFDisplayLayerCrossFadeMaskEffect * crossFadeMaskEffect = [[STGIFFDisplayLayerCrossFadeMaskEffect alloc] init];
    crossFadeMaskEffect.maskImageSource = [STRasterizingImageSourceItem itemWithLayer:layer];
    return [crossFadeMaskEffect composersToProcessMultiple:processedImages];
}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    NSUInteger count = 8;

    UIImage * circluarClippedImage = [sourceImage clipAsCircle:sourceImage.size.width scale:sourceImage.scale];
    CGFloat minScale = self.minScaleOfCircle;
    CGFloat maxScale = self.maxScaleOfCircle;

    NSArray * composers = [[[@(count) st_intArray] reverse] mapWithIndex:^id(id object, NSInteger index) {
        @autoreleasepool {
            CGFloat offset = [object floatValue];
            CGFloat scaleValue = AGKRemap(offset, 0, count - 1, minScale, maxScale);
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