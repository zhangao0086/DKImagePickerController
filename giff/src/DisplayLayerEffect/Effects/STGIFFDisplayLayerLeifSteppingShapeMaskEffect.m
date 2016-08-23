//
// Created by BLACKGENE on 7/20/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerLeifSteppingShapeMaskEffect.h"
#import "GPUImageChromaKeyBlendFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageTransformFilter.h"
#import "STGPUImageOutputComposeItem.h"
#import "NSNumber+STUtil.h"
#import "NSArray+STUtil.h"
#import "GPUImageTransformFilter+STGPUImageFilter.h"
#import "STRasterizingImageSourceItem.h"
#import "GPUImageNormalBlendFilter.h"
#import "CALayer+STUtil.h"
#import "STGIFFDisplayLayerCrossFadeMaskEffect.h"
#import "NYXImagesKit.h"
#import "NSObject+STUtil.h"
#import "NSString+STUtil.h"


@implementation STGIFFDisplayLayerLeifSteppingShapeMaskEffect {
    //Standard method of multi blending : https://github.com/BradLarson/GPUImage/issues/269
    //http://leifpodhajsky.bigcartel.com/
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _minScaleOfShape = .2f;
        _maxScaleOfShape = 1.2f;
        _countOfShape = 4;
    }
    return self;
}


- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {

    NSArray *processedImages = @[
            //FIXME: 너무 헤비 하진 않을까.. //실기기 0.9s ~ 0.6s
            [self processComposers:[self composersToProcessSingle:sourceImages[0]]]
            ,[self processComposers:[self composersToProcessSingle:sourceImages[1]]]
    ];

    if(self.maskImageForShape){
        UIImage * sourceImage = sourceImages.firstObject;
        CAShapeLayer * layer = [CAShapeLayer layerWithSize:sourceImage.size];
        layer.path = [[UIBezierPath bezierPathWithRect:(CGRect) {CGPointZero, CGSizeMake(sourceImage.size.width, sourceImage.size.height/2)}] CGPath];
        layer.fillColor = [UIColor whiteColor].CGColor;
        self.maskImageForShape = [STRasterizingImageSourceItem itemWithLayer:layer];
    }

    STGIFFDisplayLayerCrossFadeMaskEffect * crossFadeMaskEffect = [[STGIFFDisplayLayerCrossFadeMaskEffect alloc] init];
    crossFadeMaskEffect.maskImageSource = self.maskImageForShape;
    return [crossFadeMaskEffect composersToProcessMultiple:processedImages];
}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    NSUInteger count = self.countOfShape + 1;

    Weaks
    //set default maskImageForSteppingShape
    if(!self.maskImageForShape){
        self.maskImageForShape = [STRasterizingImageSourceItem itemWithBundleFileName:@"STGIFFDisplayLayerLeifSteppingShapeMaskEffect_default.svg"];
    }

    NSString * cacheKeyToGenMask = [NSString stringWithFormat:@"%@_%@_%@", NSStringFromClass(self.class), NSStringFromCGSize(sourceImage.size), self.maskImageForShape.uuid];
    UIImage * clipedImageForShapeMask = [self st_cachedImage:cacheKeyToGenMask init:^UIImage * {
        return [sourceImage maskWithImage:[Wself.maskImageForShape rasterize:sourceImage.size]];
    }];

    UIImage * clipedImageForShapeMaskInvert = [self st_cachedImage:[cacheKeyToGenMask st_add:@"invert"] init:^UIImage * {
        return [clipedImageForShapeMask invert];
    }];


    CGFloat minScale = self.minScaleOfShape;
    CGFloat maxScale = self.maxScaleOfShape;

    NSArray * composers = [[[@(count) st_intArray] reverse] mapWithIndex:^id(id object, NSInteger index) {
        @autoreleasepool {
            CGFloat offset = [object floatValue];

            STGPUImageOutputComposeItem *composeItem1 = STGPUImageOutputComposeItem.new;
            if (offset == count-1) { //background biggest image
                composeItem1.source = [[GPUImagePicture alloc] initWithImage:sourceImage smoothlyScaleOutput:NO];

            } else {
                CGFloat scaleValue = AGKRemap(offset+1, 0, count-1, minScale, maxScale);
//            scaleValue *= AGKEaseOutWithOverShoot([object floatValue]/(count-1), 1.8f);

                composeItem1.source = [[GPUImagePicture alloc] initWithImage:index % 2 ? clipedImageForShapeMaskInvert : clipedImageForShapeMask smoothlyScaleOutput:NO];
                composeItem1.composer = GPUImageNormalBlendFilter.new;
                composeItem1.filters = @[
                        [GPUImageTransformFilter scaleScalar:scaleValue]
//                        [[GPUImageTransformFilter scaleScalar:scaleValue] rotate:AGKDegreesToRadians(AGKRemap(offset, 0, count - 1, 0, 90))]
                ];
            }
            return composeItem1;
        }
    }];
    return composers;
}

@end