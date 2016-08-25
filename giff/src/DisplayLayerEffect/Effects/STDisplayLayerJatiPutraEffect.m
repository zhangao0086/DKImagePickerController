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
#import "NSArray+STGPUImageOutputComposeItem.h"
#import "GPUImageLightenBlendFilter.h"
#import "GPUImageTransformFilter+STGPUImageFilter.h"


@implementation STDisplayLayerJatiPutraEffect {

}

- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {

    NSArray * firstComposers = [self composersToProcessSingle:sourceImages[0]];
    NSArray * secondComposers = [self composersToProcessSingle:sourceImages[1]];

    CGSize sourceImageSize = sourceImages[0].size;
    CAShapeLayer * triangle = [CAShapeLayer rect:sourceImageSize];
    UIBezierPath* trianglePath = [UIBezierPath bezierPath];
    //TL
//    [trianglePath moveToPoint:CGPointMake(0, 0)];
//    [trianglePath addLineToPoint:CGPointMake(sourceImageSize.width,0)];
//    [trianglePath addLineToPoint:CGPointMake(0,sourceImageSize.height)];
    //BR
//    [trianglePath moveToPoint:CGPointMake(sourceImageSize.width,0)];
//    [trianglePath addLineToPoint:CGPointMake(sourceImageSize.width,sourceImageSize.height)];
//    [trianglePath addLineToPoint:CGPointMake(0,sourceImageSize.height)];
    //BL
//    [trianglePath moveToPoint:CGPointMake(0,0)];
//    [trianglePath addLineToPoint:CGPointMake(0,sourceImageSize.height)];
//    [trianglePath addLineToPoint:CGPointMake(sourceImageSize.width,sourceImageSize.height)];
    //TR
    [trianglePath moveToPoint:CGPointMake(0,0)];
    [trianglePath addLineToPoint:CGPointMake(sourceImageSize.width,sourceImageSize.height)];
    [trianglePath addLineToPoint:CGPointMake(sourceImageSize.width,0)];

    [trianglePath closePath];
    triangle.path = trianglePath.CGPath;
    triangle.fillColor = [UIColor whiteColor].CGColor;


    STGIFFDisplayLayerCrossFadeMaskEffect * crossFadeMaskEffect = [[STGIFFDisplayLayerCrossFadeMaskEffect alloc] init];
    crossFadeMaskEffect.maskImageSource = [STRasterizingImageSourceItem itemWithLayer:triangle];
    crossFadeMaskEffect.transformFadingImage = CGAffineTransformMakeRotation(AGKDegreesToRadians(180));

//    crossFadeMaskEffect.transformFadingImage = CGAffineTransformConcat(CGAffineTransformMakeScale(-1,-1), CGAffineTransformMakeRotation(AGKDegreesToRadians(90)));

    return [crossFadeMaskEffect composersToProcess:@[[self processComposers:secondComposers],[self processComposers:firstComposers]]];

    return [super composersToProcessMultiple:sourceImages];
}

- (NSArray *)composersToProcessSingle:(UIImage *__nullable)sourceImage {
    CAShapeLayer * triangle = [CAShapeLayer rect:sourceImage.size];
    UIBezierPath* trianglePath = [UIBezierPath bezierPath];
    //TL
//    [trianglePath moveToPoint:CGPointMake(0, 0)];
//    [trianglePath addLineToPoint:CGPointMake(sourceImage.size.width,0)];
//    [trianglePath addLineToPoint:CGPointMake(0,sourceImage.size.height)];
    //BR
    [trianglePath moveToPoint:CGPointMake(sourceImage.size.width,0)];
    [trianglePath addLineToPoint:CGPointMake(sourceImage.size.width,sourceImage.size.height)];
    [trianglePath addLineToPoint:CGPointMake(0,sourceImage.size.height)];

    [trianglePath closePath];
    triangle.path = trianglePath.CGPath;
    triangle.fillColor = [UIColor whiteColor].CGColor;


    STGIFFDisplayLayerCrossFadeMaskEffect * crossFadeMaskEffect = [[STGIFFDisplayLayerCrossFadeMaskEffect alloc] init];
    crossFadeMaskEffect.maskImageSource = [STRasterizingImageSourceItem itemWithLayer:triangle];
    crossFadeMaskEffect.transformFadingImage = CGAffineTransformConcat(CGAffineTransformMakeScale(-1,1), CGAffineTransformMakeRotation(AGKDegreesToRadians(90)));

    return [crossFadeMaskEffect composersToProcess:@[sourceImage, sourceImage]];

}


@end