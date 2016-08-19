//
// Created by BLACKGENE on 8/19/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerJulieCockburnEffect.h"
#import "CALayer+STUtil.h"
#import "CAShapeLayer+STUtil.h"
#import "STGPUImageOutputComposeItem.h"
#import "NYXImagesKit.h"
#import "UIImage+STUtil.h"
#import "GPUImageMaskFilter.h"
#import "GPUImageTransformFilter.h"
#import "GPUImageTransformFilter+STGPUImageFilter.h"


@implementation STGIFFDisplayLayerJulieCockburnEffect {

}

- (NSArray *)composersToProcess:(NSArray<UIImage *> *__nullable)sourceImages {

    CGSize size = [sourceImages[0] size];
    CAShapeLayer * layer = [CAShapeLayer layerWithSize:size];
    layer.fillColor = [UIColor whiteColor].CGColor;

    layer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(CGRectMakeWithSize_AGK(size), 0, size.height*.3f)].CGPath;
    UIImage * maskImage = [layer UIImage:YES];

    NSMutableArray * composers = NSMutableArray.array;

    [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:maskImage composer:GPUImageMaskFilter.new] addFilters:@[
            [GPUImageTransformFilter transform:CGAffineTransformMakeRotation(AGKDegreesToRadians(30))]
    ]]];
    [composers addObject:[[STGPUImageOutputComposeItem itemWithSourceImage:sourceImages[0]] addFilters:@[
            [GPUImageTransformFilter transform:CGAffineTransformMakeRotation(AGKDegreesToRadians(30))]
    ]]];


    return [composers reverse];
}

- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    return [super processImages:sourceImages];
}

@end