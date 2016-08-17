//
// Created by BLACKGENE on 8/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageMotionBlurFilter.h"

@interface GPUImageMotionBlurFilter (STGPUImageFilter)
+ (NSArray<GPUImageMotionBlurFilter *> *)filtersWithBlurSize:(CGFloat)blurSize countToDivide360Degree:(NSUInteger)count;
@end