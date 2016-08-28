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


@implementation STDisplayLayerJatiPutraEffect {

}

- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {

    CGSize imageSize= sourceImages[0].size;
    CGFloat imageTargetSize = imageSize.height;
    CGFloat cornerRadious = imageTargetSize/8;

    CAShapeLayer * layer = [CAShapeLayer roundRect:imageSize andBlankedInnerRect:CGSizeMakeValue(imageTargetSize/8) cornerRadius:cornerRadious color:[UIColor yellowColor]];
//
//    CAShapeLayer * layer = [CAShapeLayer roundRect:imageSize cornerRadius:cornerRadious color:[UIColor yellowColor]];
//    UIBezierPath * path = [UIBezierPath bezierPathWithCGPath:layer.path];
//    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectInset(CGRectMakeSize(imageSize),imageTargetSize/8,imageTargetSize/8)]];
//    layer.fillRule = kCAFillRuleEvenOdd;
//    layer.fillColor = [UIColor blackColor].CGColor;
//    layer.path = path.CGPath;

    return [layer UIImage];
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