//
// Created by BLACKGENE on 15. 5. 26..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "SVGKFastImageView+STUtil.h"
#import "SVGKImage+STUtil.h"


@implementation SVGKFastImageView (STUtil)

+ (SVGKFastImageView *)viewWithImageNamed:(NSString *)name size:(CGSize)size{
    return [[SVGKFastImageView alloc] initWithSVGKImage:[SVGKImage imageNamed:name widthSize:size]];
}

+ (SVGKFastImageView *)viewWithImageNamed:(NSString *)name sizeValue:(CGFloat)sizeValue{
    return [self viewWithImageNamed:name size:CGSizeMakeValue(sizeValue)];
}

+ (SVGKFastImageView *)viewWithImageNamed:(NSString *)name sizeWidth:(CGFloat)sizeWidth{
    return [[SVGKFastImageView alloc] initWithSVGKImage:[SVGKImage imageNamed:name withSizeWidth:sizeWidth]];
}

+ (SVGKFastImageView *)viewWithImageNamedNoCache:(NSString *)name size:(CGSize)size{
    return [[SVGKFastImageView alloc] initWithSVGKImage:[SVGKImage imageNamedNoCache:name withSize:size]];
}

+ (SVGKFastImageView *)viewWithImageNamedNoCache:(NSString *)name sizeValue:(CGFloat)sizeValue{
    return [self viewWithImageNamedNoCache:name size:CGSizeMakeValue(sizeValue)];
}

+ (SVGKFastImageView *)viewWithImageNamedNoCache:(NSString *)name sizeWidth:(CGFloat)sizeWidth{
    return [[SVGKFastImageView alloc] initWithSVGKImage:[SVGKImage imageNamedNoCache:name widthSizeWidth:sizeWidth]];
}

@end