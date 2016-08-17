//
// Created by BLACKGENE on 8/12/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "GPUImageAlphaBlendFilter+STGPUImageFilter.h"


@implementation GPUImageAlphaBlendFilter (STGPUImageFilter)

+ (instancetype)filterWithAlphaMix:(CGFloat)mix {
    GPUImageAlphaBlendFilter * alphaBlendFilter = GPUImageAlphaBlendFilter.new;
    alphaBlendFilter.mix = mix;
    return alphaBlendFilter;
}


@end