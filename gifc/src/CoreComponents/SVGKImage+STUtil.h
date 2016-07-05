//
// Created by BLACKGENE on 15. 5. 26..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVGKImage.h"
#import <CoreGraphics/CoreGraphics.h>

@interface SVGKImage (STUtil)
+ (SVGKImage *)imageNamed:(NSString *)name withSizeWidth:(CGFloat)sizeWidth;

+ (SVGKImage *)imageNamed:(NSString *)name widthSize:(CGSize)size;

+ (UIImage *)UIImageNamed:(NSString *)name withSizeWidth:(CGFloat)sizeWidth;

+ (UIImage *)UIImageNamed:(NSString *)name withSizeWidth:(CGFloat)sizeWidth color:(UIColor *)color;

+ (UIImage *)UIImageNamed:(NSString *)name withSizeWidth:(CGFloat)sizeWidth color:(UIColor *)color degree:(CGFloat)degree;

+ (UIImage *)UIImageNamed:(NSString *)name widthSize:(CGSize)size;

+ (UIImage *)UIImageNamed:(NSString *)name widthSize:(CGSize)size color:(UIColor *)color;

+ (UIImage *)UIImageNamed:(NSString *)name widthSize:(CGSize)size color:(UIColor *)color degree:(CGFloat)degree;

+ (UIImageView *)UIImageViewNamed:(NSString *)name withSizeWidth:(CGFloat)sizeWidth;

+ (UIImageView *)UIImageViewNamed:(NSString *)name withSizeWidth:(CGFloat)sizeWidth color:(UIColor *)color;

+ (UIImageView *)UIImageViewNamed:(NSString *)name withSizeWidth:(CGFloat)sizeWidth color:(UIColor *)color degree:(CGFloat)degree;

+ (SVGKImage *)imageNamedNoCache:(NSString *)name;

+ (SVGKImage *)imageNamedNoCache:(NSString *)name withSize:(CGSize)size;

+ (SVGKImage *)imageNamedNoCache:(NSString *)name widthSizeWidth:(CGFloat)sizeWidth;

+ (CALayer *)layerNamedWithFillColor:(NSString *)name size:(CGSize)size color:(UIColor *)color;

+ (UIView *)viewNamedWithFillColor:(NSString *)name size:(CGSize)size color:(UIColor *)color;
@end