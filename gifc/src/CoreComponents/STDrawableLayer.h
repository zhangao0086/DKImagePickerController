//
// Created by BLACKGENE on 15. 5. 11..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface STDrawableLayer : CAShapeLayer
@property (copy, nonatomic) void (^blockForDraw)(CGContextRef ctx);

+ (instancetype)layerWithSize:(CGSize)size;

- (void)st_drawInContext:(CGContextRef)ctx;
@end