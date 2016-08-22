//
// Created by BLACKGENE on 8/13/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage/GPUImageTransformFilter.h>

@interface GPUImageTransformFilter (STGPUImageFilter)
+ (instancetype)transform:(CGAffineTransform)transform;

+ (instancetype)translate:(CGFloat)x y:(CGFloat)y;

+ (instancetype)scaleScalar:(CGFloat)scalar;

+ (instancetype)scale:(CGFloat)x y:(CGFloat)y;

- (instancetype)addTransfrom:(CGAffineTransform)transform;

- (instancetype)scaleScalar:(CGFloat)scaleScalar;

- (instancetype)scale:(CGPoint)scale;

- (instancetype)rotate:(CGFloat)angle;

- (instancetype)translate:(CGFloat)x y:(CGFloat)y;
@end