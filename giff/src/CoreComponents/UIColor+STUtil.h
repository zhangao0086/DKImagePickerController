//
// Created by BLACKGENE on 2015. 7. 1..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor (STUtil)
+ (UIColor *)colorIf:(UIColor *)color or:(UIColor *)defaultColor;

+ (UIColor *)colorPatternRect:(CGSize)size rect:(CGRect)fillRect;

+ (UIColor *)colorPatternRect:(CGSize)size rect:(CGRect)fillRect opaque:(BOOL)opaque;

+ (UIColor *)colorPatternRect:(CGSize)size rect:(CGRect)fillRect color:(UIColor *)color bgColor:(UIColor *)bgColor;

+ (UIColor *)colorPatternRect:(CGSize)size rect:(CGRect)fillRect color:(UIColor *)color bgColor:(UIColor *)bgColor opaque:(BOOL)opaque;

- (UIColor *)negative;
@end