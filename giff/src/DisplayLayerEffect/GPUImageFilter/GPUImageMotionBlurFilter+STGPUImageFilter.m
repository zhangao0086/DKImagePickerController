//
// Created by BLACKGENE on 8/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "GPUImageMotionBlurFilter+STGPUImageFilter.h"
#import "NSNumber+STUtil.h"


@implementation GPUImageMotionBlurFilter (STGPUImageFilter)

+ (NSArray<GPUImageMotionBlurFilter *> *)filtersWithBlurSize:(CGFloat)blurSize countToDivide360Degree:(NSUInteger)count{
    NSMutableArray * filters = [NSMutableArray array];
    [[@(count) st_intArray] eachWithIndex:^(id object, NSUInteger index) {
        GPUImageMotionBlurFilter * blurFilter0 = [[GPUImageMotionBlurFilter alloc] init];
        blurFilter0.blurSize = blurSize;
        blurFilter0.blurAngle = (CGFloat)index * 360.f/count;
        [filters addObject:blurFilter0];
    }];
    return filters;
}
@end