//
// Created by BLACKGENE on 8/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STDisplayLayerJatiPutraEffect.h"
#import "CAShapeLayer+STUtil.h"
#import "GPUImageTransformFilter.h"
#import "GPUImageMaskFilter.h"
#import "STGIFFDisplayLayerCrossFadeMaskEffect.h"
#import "STRasterizingImageSourceItem.h"
#import "CALayer+STUtil.h"
#import "UIView+STUtil.h"
#import "SVGKImageView.h"
#import "SVGKImage+STUtil.h"
#import "R.h"
#import "UIColor+BFPaperColors.h"


@implementation STDisplayLayerJatiPutraEffect {

}


- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
    NSArray * firstComposers = [self composersToProcessSingle:sourceImages[0]];
    NSArray * secondComposers = [self composersToProcessSingle:sourceImages[1]];

    CGSize sourceImageSize = sourceImages[0].size;

    STGIFFDisplayLayerCrossFadeMaskEffect * crossFadeMaskEffect = [[STGIFFDisplayLayerCrossFadeMaskEffect alloc] init];
    crossFadeMaskEffect.maskImageSource = [STRasterizingImageSourceItem itemWithLayer:[CAShapeLayer corneredTriangle:sourceImageSize type:ShapeLayerCorneredTriangleTopRight]];
    crossFadeMaskEffect.transformFadingImage = CGAffineTransformMakeRotation(AGKDegreesToRadians(180));

    return [crossFadeMaskEffect composersToProcess:@[[self processComposers:secondComposers],[self processComposers:firstComposers]]];
}

- (NSArray *)composersToProcessSingle:(UIImage *__nullable)sourceImage {
    STGIFFDisplayLayerCrossFadeMaskEffect * crossFadeMaskEffect = [[STGIFFDisplayLayerCrossFadeMaskEffect alloc] init];
    crossFadeMaskEffect.maskImageSource = [STRasterizingImageSourceItem itemWithLayer:[CAShapeLayer corneredTriangle:sourceImage.size type:ShapeLayerCorneredTriangleBottomRight]];
    crossFadeMaskEffect.transformFadingImage = CGAffineTransformConcat(CGAffineTransformMakeScale(-1,1), CGAffineTransformMakeRotation(AGKDegreesToRadians(90)));

    return [crossFadeMaskEffect composersToProcess:@[sourceImage, sourceImage]];
}


@end