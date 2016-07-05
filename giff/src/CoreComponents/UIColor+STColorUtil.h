//
// Created by BLACKGENE on 2014. 9. 30..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor (STColorUtil)

+ (UIColor *)colorWithRGBHex:(NSUInteger)rgbHex;
+ (UIColor *)colorWithRGBAHex:(NSUInteger)rgbaHex;
+ (UIColor *)colorWithRGBHexString:(NSString *)hexString;
+ (UIColor *)colorWithRGBAHexString:(NSString *)hexString;

- (UIColor *)multiplyColorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;
- (UIColor *)colorByInterpolatingWith:(UIColor *)color factor:(CGFloat)factor;
- (NSString *)hexValue;

@end