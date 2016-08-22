//
// Created by BLACKGENE on 8/13/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "GPUImageTransformFilter+STGPUImageFilter.h"


@implementation GPUImageTransformFilter (STGPUImageFilter)

+ (instancetype)transform:(CGAffineTransform)transform{
    GPUImageTransformFilter * transformFilter = GPUImageTransformFilter.new;
    transformFilter.affineTransform = transform;
    return transformFilter;
}

- (instancetype)addTransfrom:(CGAffineTransform)transform{
    self.affineTransform = CGAffineTransformConcat(self.affineTransform, transform);
    return self;
}

+ (instancetype)scaleScalar:(CGFloat)scalar{
    return [self scale:scalar y:scalar];
}

- (instancetype)scaleScalar:(CGFloat)scaleScalar{
    return [self scale:CGPointMake(scaleScalar, scaleScalar)];
}

+ (instancetype)scale:(CGFloat)x y:(CGFloat)y{
    return [[[GPUImageTransformFilter alloc] init] scale:CGPointMake(x,y)];
}

- (instancetype)scale:(CGPoint)scale{
    return [self addTransfrom:CGAffineTransformMakeScale(scale.x,scale.y)];
}

- (instancetype)rotate:(CGFloat)angle{
    return [self addTransfrom:CGAffineTransformMakeRotation(angle)];
}

- (instancetype)translate:(CGFloat)x y:(CGFloat)y{
    return [self addTransfrom:CGAffineTransformMakeTranslation(x,y)];
}

+ (instancetype)translate:(CGFloat)x y:(CGFloat)y{
    return [[[GPUImageTransformFilter alloc] init] translate:x y:y];
}

@end