//
// Created by BLACKGENE on 8/17/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "GPUImageBrightnessFilter+STGPUImageFilter.h"

@implementation GPUImageBrightnessFilter (STGPUImageFilter)
+ (instancetype)brightness:(CGFloat)brightness {
    GPUImageBrightnessFilter * brightnessFilter = GPUImageBrightnessFilter.new;
    brightnessFilter.brightness = brightness;
    return brightnessFilter;
}
@end