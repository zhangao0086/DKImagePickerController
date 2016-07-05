//
// Created by BLACKGENE on 15. 5. 26..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SVGKFastImageView.h"

@class SVGKImage;

@interface SVGKFastImageView (STUtil)

+ (SVGKFastImageView *)viewWithImageNamed:(NSString *)name size:(CGSize)size;

+ (SVGKFastImageView *)viewWithImageNamed:(NSString *)name sizeValue:(CGFloat)sizeValue;

+ (SVGKFastImageView *)viewWithImageNamed:(NSString *)name sizeWidth:(CGFloat)sizeWidth;

+ (SVGKFastImageView *)viewWithImageNamedNoCache:(NSString *)name size:(CGSize)size;

+ (SVGKFastImageView *)viewWithImageNamedNoCache:(NSString *)name sizeValue:(CGFloat)sizeValue;

+ (SVGKFastImageView *)viewWithImageNamedNoCache:(NSString *)name sizeWidth:(CGFloat)sizeWidth;
@end