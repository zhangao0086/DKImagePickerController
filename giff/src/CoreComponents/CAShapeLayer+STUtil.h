//
// Created by BLACKGENE on 2014. 10. 23..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface CAShapeLayer (STUtil)
+ (CAShapeLayer *)rectWidth:(CGFloat)width color:(UIColor *)color;

+ (CAShapeLayer *)rect:(CGSize)size;

+ (CAShapeLayer *)rect:(CGSize)size color:(UIColor *)color;

+ (instancetype)rectWithFillingRect:(CGSize)size fillRect:(CGRect)fillRect;

+ (instancetype)rectWithFilledRect:(CGSize)size inRect:(CGRect)fillRect color:(UIColor *)fillColor bgColor:(UIColor *)bgColor;

- (instancetype)fillRect:(CGRect)rect color:(UIColor *)fillColor;

+ (CAShapeLayer *)roundRect:(CGSize)size cornerRadius:(CGFloat)radius color:(UIColor *)color;

+ (CAShapeLayer *)roundRect:(CGSize)size;

+ (CAShapeLayer *)roundRect:(CGSize)size color:(UIColor *)color;

+ (CAShapeLayer *)circle:(CGFloat)diameter;

+ (CAShapeLayer *)circle:(CGFloat)diameter color:(UIColor *)color;

+ (CAShapeLayer *)circle:(CGFloat)diameter color:(UIColor *)color name:(NSString *)name;

+ (CAShapeLayer *)circle:(CGFloat)diameter inset:(CGPoint)point color:(UIColor *)color;

+ (CAShapeLayer *)circleInvertFilled:(CGRect)bounds diameter:(CGFloat)diameter color:(UIColor *)color;

- (void)circleInvertFill:(CGRect)bounds diameter:(CGFloat)diameter color:(UIColor *)color;

- (void)setColorToAll:(UIColor *)color;

- (void)animateCircleRadiusWithPadding:(CGRect)rect from:(CGFloat)from to:(CGFloat)to completion:(void (^)(POPAnimation *anim, BOOL finished))block;

- (void)animateCircleWithPadding:(CGFloat)radius to:(CGFloat)to;

- (void)animateCircleRadiusWithPadding:(CGFloat)to;

- (void)animateCircleSizeToZero;

- (void)animateCircleRadiusWithPadding:(CGRect)rect to:(CGFloat)to completion:(void (^)(POPAnimation *anim, BOOL finished))block;

- (void)circleRadiusWithPadding:(CGRect)rect padding:(CGFloat)padding;

- (void)circleRadius:(CGFloat)radius;

- (CGRect)pathBound;

- (CGSize)pathSize;

- (CGFloat)pathWidth;

- (CGFloat)pathHeight;

- (CGFloat)pathWidthHalf;

- (CGFloat)pathHeightHalf;

- (CAShapeLayer *)clearLineWidth;

- (CAShapeLayer *)clearLineWidthAndRasterizeDoubleScaled;

- (CAShapeLayer *)invertFill;

- (void)animateCircleRadiusWithPadding:(CGRect)rect from:(CGFloat)from to:(CGFloat)to;
@end