//
// Created by BLACKGENE on 8/19/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerJulieCockburnEffect.h"
#import "CALayer+STUtil.h"
#import "CAShapeLayer+STUtil.h"
#import "STGPUImageOutputComposeItem.h"
#import "NYXImagesKit.h"


@implementation STGIFFDisplayLayerJulieCockburnEffect {

}

- (NSArray *)composersToProcess:(NSArray<UIImage *> *__nullable)sourceImages {

    CGSize size = [sourceImages[0] size];
    size.height *= .3f;
    CAShapeLayer * layer = [CAShapeLayer layerWithSize:size];
    layer.fillColor = [UIColor whiteColor].CGColor;
    layer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMakeWithSize_AGK(size)].CGPath;
    UIImage * maskImage = [layer UIImage:YES];

    [maskImage maskWithImage:sourceImages[0]];

    STGPUImageOutputComposeItem * composeItem0 = STGPUImageOutputComposeItem.new;
    [composeItem0 setSourceAsImage:sourceImages[0]];

    return [super composersToProcess:sourceImages];
}

- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {

    CGSize size = [sourceImages[0] size];
    size.height *= .3f;
    CAShapeLayer * layer = [CAShapeLayer layerWithSize:size];
    layer.fillColor = [UIColor whiteColor].CGColor;
    layer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMakeWithSize_AGK(size)].CGPath;
    UIImage * maskImage = [layer UIImage:YES];

    return [sourceImages[0] maskWithImage:maskImage];

    return [super processImages:sourceImages];
}

@end