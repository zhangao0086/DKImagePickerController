//
// Created by BLACKGENE on 8/13/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage/GPUImageTransformFilter.h>

@interface GPUImageTransformFilter (STGPUImageFilter)
+ (instancetype)transform:(CGAffineTransform)transform;

- (instancetype)addTransfrom:(CGAffineTransform)transform;

- (instancetype)addScaleScalar:(CGFloat)scaleScalar;

- (instancetype)addScale:(CGPoint)scale;
@end