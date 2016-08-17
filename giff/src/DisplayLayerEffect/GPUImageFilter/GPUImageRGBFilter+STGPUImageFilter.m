//
// Created by BLACKGENE on 8/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Colours/Colours.h>
#import "GPUImageRGBFilter+STGPUImageFilter.h"


@implementation GPUImageRGBFilter (STGPUImageFilter)

+ (instancetype)filterWithColor:(UIColor *)color{
    GPUImageRGBFilter * colorFilter = [[GPUImageRGBFilter alloc] init];
    NSArray* colors = [color rgbaArray];
    colorFilter.red = [colors[0] floatValue];
    colorFilter.green = [colors[1] floatValue];
    colorFilter.blue = [colors[2] floatValue];
    return colorFilter;
}

@end