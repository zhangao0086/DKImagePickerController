//
// Created by BLACKGENE on 2014. 9. 30..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import "UIColor+STColorUtil.h"


@implementation UIColor (STColorUtil)
+ (UIColor *)colorWithRGBHex:(NSUInteger)rgbHex
{
    return [UIColor colorWithRed:((CGFloat)((rgbHex & 0xFF0000) >> 16))/255.0 green:((CGFloat)((rgbHex & 0xFF00) >> 8))/255.0 blue:((CGFloat)(rgbHex & 0xFF))/255.0 alpha:1.0];
}

+ (UIColor *)colorWithRGBAHex:(NSUInteger)rgbaHex
{
    return [UIColor colorWithRed:((CGFloat)((rgbaHex & 0xFF000000) >> 24))/255.0 green:((CGFloat)((rgbaHex & 0xFF0000) >> 16))/255.0 blue:((CGFloat)((rgbaHex & 0xFF00) >> 8 ))/255.0 alpha:((CGFloat)((rgbaHex & 0xFF))/255.0)];
}

+ (UIColor *)colorWithRGBHexString:(NSString *)hexString
{
    NSUInteger rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];

    return [UIColor colorWithRGBHex:rgbValue];
}

+ (UIColor *)colorWithRGBAHexString:(NSString *)hexString
{
    NSUInteger rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];

    return [UIColor colorWithRGBAHex:rgbValue];
}

- (UIColor *)multiplyColorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
    CGFloat h, s, v, a;
    [self getHue:&h saturation:&s brightness:&v alpha:&a];

    h = fminf(1.f, h * hue);
    s = fminf(1.f, s * saturation);
    v = fminf(1.f, v * brightness);
    a = fminf(1.f, a * alpha);

    return [UIColor colorWithHue:h saturation:s brightness:v alpha:a];
}

- (UIColor *)colorByInterpolatingWith:(UIColor *)color factor:(CGFloat)factor {
    factor = MIN(MAX(factor, 0.0), 1.0);

    const CGFloat *startComponent = CGColorGetComponents(self.CGColor);
    const CGFloat *endComponent = CGColorGetComponents(color.CGColor);

    float startAlpha = CGColorGetAlpha(self.CGColor);
    float endAlpha = CGColorGetAlpha(color.CGColor);

    float r = startComponent[0] + (endComponent[0] - startComponent[0]) * factor;
    float g = startComponent[1] + (endComponent[1] - startComponent[1]) * factor;
    float b = startComponent[2] + (endComponent[2] - startComponent[2]) * factor;
    float a = startAlpha + (endAlpha - startAlpha) * factor;

    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

- (NSString *)hexValue
{
    if (self == [UIColor whiteColor]) {
        // Special case, as white doesn't fall into the RGB color space
        return @"ffffff";
    }

    CGFloat red;
    CGFloat blue;
    CGFloat green;
    CGFloat alpha;

    [self getRed:&red green:&green blue:&blue alpha:&alpha];

    int redDec = (int)(red * 255);
    int greenDec = (int)(green * 255);
    int blueDec = (int)(blue * 255);

    NSString *returnString = [NSString stringWithFormat:@"%02x%02x%02x", (unsigned int)redDec, (unsigned int)greenDec, (unsigned int)blueDec];

    return returnString;
}


@end