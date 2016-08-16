//
// Created by BLACKGENE on 8/16/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "GPUImageContrastFilter+STGPUImageFilter.h"


@implementation GPUImageContrastFilter (STGPUImageFilter)
+ (instancetype)contrast:(CGFloat)contrast {
    GPUImageContrastFilter * contrastFilter = GPUImageContrastFilter.new;
    contrastFilter.contrast = contrast;
    return contrastFilter;
}

@end