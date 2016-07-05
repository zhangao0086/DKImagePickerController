//
// Created by BLACKGENE on 2014. 10. 30..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import "CALayer+STUtil.h"
#import "NSArray+BlocksKit.h"
#import "CAShapeLayer+STUtil.h"
#import "NSObject+STUtil.h"
#import "UIColor+STColorUtil.h"
#import "NSArray+STUtil.h"


@implementation CALayer (STUtil)

@dynamic rasterizationEnabled, scaleXYValue;

#pragma mark Image
- (UIImage *)UIImage{
    return [self UIImage:NO];
}

- (UIImage *)UIImage:(BOOL)opaque{
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, opaque, [UIScreen mainScreen].scale);
        [self renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}

#pragma mark initialize with
+ (instancetype)layerWithSize:(CGSize)size{
    CALayer * layer = [[self alloc] init];
    layer.frame = (CGRect){CGPointZero, size};
    [layer setNeedsDisplay];
    return layer;
}

+ (CALayer *)layerWithMaskedImage:(UIImage *)image size:(CGSize)size color:(UIColor *)color{
    CAShapeLayer *iconLayer = [CAShapeLayer circle:size.width color:color];
    CALayer *iconMaskLayer = [CALayer layerWithImage:image centerInSizeAndFitScaleIfOversized:size];
    iconLayer.mask = iconMaskLayer;
    return iconLayer;
}

+ (CALayer *)layerWithColorMaskWrapped:(CALayer *)targetLayer color:(UIColor *)color{
    NSAssert(!CGRectIsNull(targetLayer.frame) && !CGRectIsEmpty(targetLayer.frame), @"must fill layer's frame");

    CALayer * container = [CALayer layer];
    container.frame = targetLayer.bounds;
    CAShapeLayer * maskLayer = [CAShapeLayer rect:targetLayer.bounds.size color:color];
    maskLayer.mask = targetLayer;

    [container addSublayer:maskLayer];
    return container;
}

+ (CALayer *)layerWithImage:(UIImage *)image centerInSize:(CGSize)size {
    CALayer * imageLayer = [self layerWithImage:image];
    imageLayer.frame = CGRectModified_AGK(imageLayer.frame, ^CGRect(CGRect rect) {
        CGSize maxSizeHalf = CGSizeHalf_AGK(size);
        CGSize imageSizeHalf = CGSizeHalf_AGK(image.size);
        rect.origin = CGPointMake(maxSizeHalf.width-imageSizeHalf.width, maxSizeHalf.height-imageSizeHalf.height);
        return rect;
    });

    return imageLayer;
}

+ (CALayer *)layerWithImage:(UIImage *)image centerInSizeAndFitScaleIfOversized:(CGSize)size{
    CALayer * imageLayer = [self layerWithImage:image centerInSize:size];
    imageLayer.scaleX = size.width>=image.size.width?:size.width/image.size.width;
    imageLayer.scaleY = size.height>=image.size.height?:size.height/image.size.height;
    return imageLayer;
}

+ (CALayer *)layerWithImage:(UIImage *)image{
    CALayer * layer = [CALayer layer];
    return [layer setImage:image];
}

- (CALayer *)setImage:(UIImage *)image{
    self.rasterizationScale = [[UIScreen mainScreen] scale];
    self.contents = (id) image.CGImage;
    self.frame = (CGRect){CGPointZero, image.size};
    return self;
}

#pragma mark Property
- (CGFloat)scaleXYValue; {
    return MAX(self.scaleXY.x, self.scaleXY.y);
}

- (void)setScaleXYValue:(CGFloat)scaleXYValue; {
    self.scaleXY = CGPointMake(scaleXYValue, scaleXYValue);
}

- (void)setVisible:(BOOL)visible; {
    self.hidden = !visible;
}

- (BOOL)isVisible; {
    return !self.hidden;
}

- (CALayer *)layerWithName:(NSString *)name{
    return [self.sublayers bk_match:^BOOL(id obj) {
        return [name isEqualToString:((CALayer *)obj).name];
    }];
}

- (void)setRasterizationEnabled:(BOOL)rasterizationEnabled; {
    self.rasterizationScale = [[UIScreen mainScreen] scale];
    self.shouldRasterize = rasterizationEnabled;
}

- (BOOL)rasterizationEnabled:(BOOL)rasterizationEnabled; {
    return self.shouldRasterize;
}

- (CALayer *)setRasterize {
    self.rasterizationEnabled = YES;
    return self;
}

- (CALayer *)setRasterizeDoubleScaled {
    self.rasterizationScale = [[UIScreen mainScreen] scale]*2;
    self.shouldRasterize = YES;
    return self;
}

- (void)centerToParent{
    self.anchorPoint = CGPointHalf;
    self.position = self.superlayer.boundsCenter;
}

- (void)centerToSize:(CGSize)size{
    self.anchorPoint = CGPointHalf;
    self.positionX = size.width/2;
    self.positionY = size.height/2;
}

#pragma mark Make Circle
+ (CALayer *)circleRaster:(CGFloat)diameter {
    return [self circleRaster:diameter inset:CGPointZero color:[UIColor blackColor]];
}

+ (CALayer *)circleRaster:(CGFloat)diameter inset:(CGPoint)inset color:(UIColor *)color {
    return [self circleRaster:diameter inset:inset color:color name:nil];
}

+ (CALayer *)circleRaster:(CGFloat)diameter inset:(CGPoint)point color:(UIColor *)color name:(NSString *)name {
    return [self.class layerWithImage:[self st_cachedImage:name ? name : [NSString stringWithFormat:@"circleraster%f%f%f%@",diameter, point.x, point.y,[color hexValue]] init:^UIImage * {
        CAShapeLayer * layer = [CAShapeLayer layer];
        [layer setColorToAll:color];
        layer.lineWidth = 0;
        layer.bounds = CGRectMakeWithSize_AGK(CGSizeMake(diameter, diameter));
//        layer.anchorPoint = CGPointZero;
        layer.path = [[UIBezierPath bezierPathWithOvalInRect:CGRectInset(layer.bounds, point.x, point.y)] CGPath];
        return layer.UIImage;
    }]];
}

#pragma mark Hirechy
- (void)st_removeAllSublayers {
    [[self sublayers] eachLayersWithIndex:^(CALayer *layer, NSUInteger index) {
        [layer removeFromSuperlayer];
    }];
}

- (void)st_removeAllSublayersRecursively {
    [[self st_allSublayersRecursively] eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        [view removeFromSuperview];
    }];
}

- (NSArray *)st_allSublayersRecursively{
    NSMutableArray * array = [NSMutableArray array];
    for (CALayer *l in self.sublayers){
        [array addObject:l];
        if(l.sublayers.count){
            array = (NSMutableArray *) [[[l st_allSublayersRecursively] arrayByAddingObjectsFromArray:array] mutableCopy];
        }
    }
    return array;
}
@end