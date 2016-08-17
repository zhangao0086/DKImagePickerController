//
// Created by BLACKGENE on 8/16/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "GPUImageSaturationFilter+STGPUImageFilter.h"



@implementation GPUImageSaturationFilter (STGPUImageFilter)
+ (instancetype)saturation:(CGFloat)saturation {
    GPUImageSaturationFilter * contrastFilter = GPUImageSaturationFilter.new;
    contrastFilter.saturation = saturation;
    return contrastFilter;
}
@end