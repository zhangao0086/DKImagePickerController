//
// Created by BLACKGENE on 2014. 10. 23..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <objc/runtime.h>
#import "CAShapeLayer+STUtil.h"
#import "NSObject+STPopAnimatableProperty.h"
#import "CALayer+STUtil.h"
#import "MTGeometry.h"

@implementation CAShapeLayer (STUtil)

+ (CAShapeLayer *)rectWidth:(CGFloat)width color:(UIColor *)color{
    return [self.class rect:CGSizeMakeValue(width) color:[UIColor whiteColor]];
}

+ (CAShapeLayer *)rect:(CGSize)size{
    return [self.class rect:size color:[UIColor whiteColor]];
}

+ (CAShapeLayer *)rect:(CGSize)size color:(UIColor *)color {
    CAShapeLayer * layer = [CAShapeLayer layer];
    [layer setColorToAll:color];
    layer.lineWidth = 0;
    layer.path = [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)] CGPath];
    layer.frame = layer.bounds = layer.pathBound;
    return layer;
}

+ (CAShapeLayer *)roundRect:(CGSize)size cornerRadius:(CGFloat)radius color:(UIColor *)color {
    CAShapeLayer * layer = [CAShapeLayer layer];
    [layer setColorToAll:color];
    layer.lineWidth = 0;
    layer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:radius].CGPath;
    layer.anchorPoint = CGPointZero;
    layer.frame = layer.bounds = layer.pathBound;
    return layer;
}

+ (CAShapeLayer *)roundRect:(CGSize)size {
    return [self roundRect:size cornerRadius:size.height/2 color:nil];
}

+ (CAShapeLayer *)roundRect:(CGSize)size color:(UIColor *)color {
    return [self roundRect:size cornerRadius:size.height/2 color:color];
}

+ (CAShapeLayer *)circle:(CGFloat)diameter {
    return [self circle:diameter inset:CGPointZero color:[UIColor blackColor]];
}

+ (CAShapeLayer *)circle:(CGFloat)diameter color:(UIColor *)color {
    return [self circle:diameter inset:CGPointZero color:color];
}

+ (CAShapeLayer *)circle:(CGFloat)diameter color:(UIColor *)color name:(NSString *)name {
    CAShapeLayer * layer = [self circle:diameter inset:CGPointZero color:color];
    layer.name = name;
    return layer;
}

+ (CAShapeLayer *)circle:(CGFloat)diameter inset:(CGPoint)point color:(UIColor *)color {
    CAShapeLayer * layer = [CAShapeLayer layer];
    [layer setColorToAll:color];
    layer.lineWidth = 0;
    layer.bounds = CGRectMakeWithSize_AGK(CGSizeMake(diameter, diameter));
    layer.anchorPoint = CGPointZero;
    layer.path = [[UIBezierPath bezierPathWithOvalInRect:CGRectInset(layer.bounds, point.x, point.y)] CGPath];
//    layer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(layer.bounds, point.x, point.y) cornerRadius:diameter*.5f].CGPath;
//    [layer addSublayer:[CALayer circleRaster:diameter inset:point color:color name:nil]];
    return layer;
}

+ (CAShapeLayer *)circleInvertFilled:(CGRect)bounds diameter:(CGFloat)diameter color:(UIColor *)color{
    color?:(color=[UIColor whiteColor]);

    CAShapeLayer * layer = [CAShapeLayer layer];
    layer.bounds = bounds;
    layer.anchorPoint = CGPointZero;
    layer.lineWidth = 0;
    [layer circleInvertFill:bounds diameter:diameter color:color];
    return layer;
}

- (void)circleInvertFill:(CGRect)bounds diameter:(CGFloat)diameter color:(UIColor *)color{
    color?:([self fillColor] ? (color=[UIColor colorWithCGColor:[self fillColor]]):(color=[UIColor whiteColor]));

    UIBezierPath *newpath = [UIBezierPath bezierPathWithRect:bounds];
    [newpath appendPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(CGRectCenterPoint(bounds).x-diameter*.5f, CGRectCenterPoint(bounds).y-diameter*.5f, diameter, diameter)]];
    self.path = newpath.CGPath;

    self.fillRule = kCAFillRuleEvenOdd;
    self.fillColor = [color CGColor];
}

- (void)setColorToAll:(UIColor *)color{
    if(!color){
        color = [UIColor blackColor];
    }
    self.strokeColor = self.fillColor = [color CGColor];
}

- (void)animateCircleRadiusWithPadding:(CGRect)rect from:(CGFloat)from to:(CGFloat)to; {
    [self animateCircleRadiusWithPadding:rect from:from to:to completion:nil];
}

- (void)animateCircleRadiusWithPadding:(CGRect)rect from:(CGFloat)from to:(CGFloat)to completion:(void (^)(POPAnimation *anim, BOOL finished))block{
    WeakSelf weakSelf = self;
    [self st_spring:@(from) to:@(to) withBlock:^(id target, CGFloat const values[]) {
        [weakSelf circleRadiusWithPadding:rect padding:values[0]];
    }   speedOffset:0 completion:block];
}

- (void)animateCircleWithPadding:(CGFloat)radius to:(CGFloat)to; {
    [self animateCircleRadiusWithPadding:(CGRect) {CGPointZero, radius, radius} to:to completion:nil];
}

- (void)animateCircleRadiusWithPadding:(CGFloat)to; {
    [self animateCircleRadiusWithPadding:self.pathBound to:to completion:nil];
}

- (void)animateCircleSizeToZero {
    [self animateCircleRadiusWithPadding:self.pathBound to:self.pathWidthHalf completion:nil];
}

- (void)animateCircleRadiusWithPadding:(CGRect)rect to:(CGFloat)to completion:(void (^)(POPAnimation *anim, BOOL finished))block{
    [self animateCircleRadiusWithPadding:rect from:(rect.size.width - [self pathBound].size.width) / 2 to:to completion:block];
}

- (void)circleRadiusWithPadding:(CGRect)rect padding:(CGFloat)padding {
    CGRect _rect = CGRectInset(rect, padding, padding);
    if (!CGRectIsEmpty(_rect)) {
        self.path = [UIBezierPath bezierPathWithRoundedRect:_rect cornerRadius:_rect.size.width / 2].CGPath;
    }
}

- (void)circleRadius:(CGFloat)radius {
    [self circleRadiusWithPadding:(CGRect) {CGPointZero, radius, radius} padding:0];
}

- (CGRect)pathBound{
    CGRect bound = CGPathGetPathBoundingBox(self.path);
    return CGRectIsNull(bound) ? CGRectZero : bound;
}

- (CGSize)pathSize{
    return self.pathBound.size;
}

- (CGFloat)pathWidth{
    return self.pathBound.size.width;
}

- (CGFloat)pathHeight{
    return self.pathBound.size.height;
}

- (CGFloat)pathWidthHalf {
    return self.pathWidth/2;
}

- (CGFloat)pathHeightHalf {
    return self.pathHeight/2;
}

#pragma mark Macro
- (CAShapeLayer *)clearLineWidth{
    self.lineWidth = 0;
    return self;
}

- (CAShapeLayer *)clearLineWidthAndRasterizeDoubleScaled {
    self.lineWidth = 0;
    return (CAShapeLayer *) [self setRasterizeDoubleScaled];
}

- (CAShapeLayer *)invertFill {
    self.fillRule = kCAFillRuleEvenOdd;
    self.fillColor = [[UIColor blueColor] CGColor];
    CGPathRef path = self.path;

    UIBezierPath *newpath = [UIBezierPath bezierPathWithRect:self.bounds];
    [newpath appendPath:[UIBezierPath bezierPathWithCGPath:path]];
    self.path = newpath.CGPath;
    return self;
}

@end