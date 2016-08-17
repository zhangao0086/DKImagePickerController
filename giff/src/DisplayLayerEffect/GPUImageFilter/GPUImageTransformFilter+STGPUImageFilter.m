//
// Created by BLACKGENE on 8/13/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "GPUImageTransformFilter+STGPUImageFilter.h"


@implementation GPUImageTransformFilter (STGPUImageFilter)

+ (instancetype)filterByTransform:(CGAffineTransform)transform{
    GPUImageTransformFilter * transformFilter = GPUImageTransformFilter.new;
    transformFilter.affineTransform = transform;
    return transformFilter;
}

- (instancetype)addTransfrom:(CGAffineTransform)transform{
    self.affineTransform = CGAffineTransformConcat(self.affineTransform, transform);
    return self;
}

- (instancetype)addScaleScalar:(CGFloat)scaleScalar{
    return [self addScale:CGPointMake(scaleScalar,scaleScalar)];
}

- (instancetype)addScale:(CGPoint)scale{
    return [self addTransfrom:CGAffineTransformMakeScale(scale.x,scale.y)];
}

@end