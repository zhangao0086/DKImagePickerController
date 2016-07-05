//
// Created by BLACKGENE on 15. 5. 26..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "SVGKSourceLocalFile.h"
#import "SVGKFastImageView.h"
#import "UIImage+Rotating.h"
#import "SVGKImage+STUtil.h"
#import "UIView+STUtil.h"
#import "CALayer+STUtil.h"
#import "NSObject+STUtil.h"
#import "UIColor+STColorUtil.h"
#import "UIImage+STUtil.h"


@implementation SVGKImage (STUtil)

+ (SVGKImage *)imageNamed:(NSString *)name withSizeWidth:(CGFloat)sizeWidth{
    SVGKImage * image = [SVGKImage imageNamed:name];
    NSAssert([image hasSize], @"not found svg' size");
    image.size = CGSizeMake(sizeWidth, sizeWidth*(image.size.height/image.size.width));
    return image;
}

+ (SVGKImage *)imageNamed:(NSString *)name widthSize:(CGSize)size{
    SVGKImage * image = [SVGKImage imageNamed:name];
    image.size = size;
    return image;
}

+ (UIImage *)UIImageNamed:(NSString *)name withSizeWidth:(CGFloat)sizeWidth{
    return [self UIImageNamed:name withSizeWidth:sizeWidth color:nil];
}

+ (UIImage *)UIImageNamed:(NSString *)name withSizeWidth:(CGFloat)sizeWidth color:(UIColor *)color{
    return [self UIImageNamed:name withSizeWidth:sizeWidth color:color degree:0];
}

+ (UIImage *)UIImageNamed:(NSString *)name withSizeWidth:(CGFloat)sizeWidth color:(UIColor *)color degree:(CGFloat)degree{
    return [self UIImageNamed:name widthSize:CGSizeMakeValue(sizeWidth) color:color degree:degree];
}

+ (UIImage *)UIImageNamed:(NSString *)name widthSize:(CGSize)size{
    return [self UIImageNamed:name widthSize:size color:nil];
}

+ (UIImage *)UIImageNamed:(NSString *)name widthSize:(CGSize)size color:(UIColor *)color{
    return [self UIImageNamed:name widthSize:size color:color degree:0];
}

+ (UIImage *)UIImageNamed:(NSString *)name widthSize:(CGSize)size color:(UIColor *)color degree:(CGFloat)degree{
    BOOL bySizeWidth = size.width==size.height;
    BOOL withRotated = degree != 0;

    //n{name}w{888}h{999}c{hex}
    NSString *cacheKey = [NSString stringWithFormat:@"n%@w%fh%fc%@", name, size.width, size.height, color ? [color hexValue] : @""];

    UIImage * cachedImage = [self.class st_cachedImage:cacheKey init:^UIImage * {
        UIImage *image = bySizeWidth ?
                [SVGKImage imageNamed:name withSizeWidth:size.width].UIImage :
                [SVGKImage imageNamed:name widthSize:size].UIImage;

        return color ? [image maskWithColor:color] : image;
    }];

    //n{name}w{888}h{999}c{hex}d{rotated_degree}
    if(withRotated){
        WeakObject(cachedImage) _rotatedCachedImage = cachedImage;
        cachedImage = [self.class st_cachedImage:[NSString stringWithFormat:@"%@d%f",cacheKey, degree] init:^UIImage * {
            return [_rotatedCachedImage rotateInDegrees:degree];
        }];
    }

    return cachedImage;
}


+ (UIImageView *)UIImageViewNamed:(NSString *)name withSizeWidth:(CGFloat)sizeWidth{
    return [self UIImageViewNamed:name withSizeWidth:sizeWidth color:nil];
}

+ (UIImageView *)UIImageViewNamed:(NSString *)name withSizeWidth:(CGFloat)sizeWidth color:(UIColor *)color{
    return [[UIImageView alloc] initWithImage:[self UIImageNamed:name withSizeWidth:sizeWidth color:color]];
}

+ (UIImageView *)UIImageViewNamed:(NSString *)name withSizeWidth:(CGFloat)sizeWidth color:(UIColor *)color degree:(CGFloat)degree{
    return [[UIImageView alloc] initWithImage:[self UIImageNamed:name withSizeWidth:sizeWidth color:color degree:degree]];
}

+ (SVGKImage *)imageNamedNoCache:(NSString *)name{
    return [SVGKImage imageWithSource:[SVGKSourceLocalFile internalSourceAnywhereInBundleUsingName:name]];
}

+ (SVGKImage *)imageNamedNoCache:(NSString *)name withSize:(CGSize)size{
    SVGKImage * image = [SVGKImage imageWithSource:[SVGKSourceLocalFile internalSourceAnywhereInBundleUsingName:name]];
    NSAssert([image hasSize], @"not found svg' size");
    image.size = CGSizeByScale(size, [UIScreen mainScreen].scale);
    return image;
}

+ (SVGKImage *)imageNamedNoCache:(NSString *)name widthSizeWidth:(CGFloat)sizeWidth{
    SVGKImage * image = [SVGKImage imageWithSource:[SVGKSourceLocalFile internalSourceAnywhereInBundleUsingName:name]];
    NSAssert([image hasSize], @"not found svg' size");
    image.size = CGSizeMake(sizeWidth, sizeWidth*(image.size.height/image.size.width));
    return image;
}

+ (CALayer *)layerNamedWithFillColor:(NSString *)name size:(CGSize)size color:(UIColor *)color{
    SVGKImage * image = [SVGKImage imageNamed:name widthSize:size];
    //FIXME : svg상에서 0,0정렬이 안되어있는 layer들은 position을 이유로 마스크시 보이지 않는다.
//    [image.CALayerTree.sublayers each:^(id object) {
//        logPOINT([((CAShapeLayer *)object) position]);
//        [(CAShapeLayer *) object setPosition:CGPointZero];
//    }];
    return [CALayer layerWithColorMaskWrapped:image.CALayerTree color:color];
}

+ (UIView *)viewNamedWithFillColor:(NSString *)name size:(CGSize)size color:(UIColor *)color{
    SVGKImage * image = [SVGKImage imageNamed:name widthSize:size];
    UIView *view = [[UIView alloc] initWithSize:image.size];
    [view setBackgroundColor:color];
    view.layer.mask = image.CALayerTree;
    return view;
}

@end