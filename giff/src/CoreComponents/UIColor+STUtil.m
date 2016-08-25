//
// Created by BLACKGENE on 2015. 7. 1..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <UIColor+BFPaperColors/UIColor+BFPaperColors.h>
#import "UIColor+STUtil.h"
#import "CAShapeLayer+STUtil.h"
#import "CALayer+STUtil.h"


@implementation UIColor (STUtil)

- (UIColor *) negative{
    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    return [UIColor colorWithRed:1-red green:1-green blue:1-blue alpha:alpha];
}

+ (UIColor *)colorIf:(UIColor *)color or:(UIColor *)defaultColor{
    return (color && ![color isEqual:[NSNull null]]) && ![UIColor isColorClear:color] ? color : defaultColor;
}

+ (UIColor *)colorPatternRect:(CGSize)size rect:(CGRect)fillRect {
    return [self colorPatternRect:size rect:fillRect color:nil bgColor:nil];
}

+ (UIColor *)colorPatternRect:(CGSize)size rect:(CGRect)fillRect opaque:(BOOL)opaque {
    return [self colorPatternRect:size rect:fillRect color:nil bgColor:nil opaque:opaque];
}

+ (UIColor *)colorPatternRect:(CGSize)size rect:(CGRect)fillRect color:(UIColor *)color bgColor:(UIColor *)bgColor {
    return [self colorPatternRect:size rect:fillRect color:nil bgColor:nil opaque:YES];
}

+ (UIColor *)colorPatternRect:(CGSize)size rect:(CGRect)fillRect color:(UIColor *)color bgColor:(UIColor *)bgColor opaque:(BOOL)opaque{
    return [UIColor colorWithPatternImage:[[CAShapeLayer rectWithFilledRect:size inRect:fillRect color:color bgColor:bgColor] UIImage:opaque]];
}
@end