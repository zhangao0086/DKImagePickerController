//
// Created by BLACKGENE on 8/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Colours/Colours.h>
#import "GPUImageMonochromeFilter+STGPUImageFilter.h"


@implementation GPUImageMonochromeFilter (STGPUImageFilter)

+ (instancetype)filterWithColor:(UIColor *)color{
    GPUImageMonochromeFilter * colorFilter = [[GPUImageMonochromeFilter alloc] init];
    colorFilter.intensity = 1;
    NSArray* colors = [color rgbaArray];
    [colorFilter setColorRed:[colors[0] floatValue] green:[colors[1] floatValue] blue:[colors[2] floatValue]];
    return colorFilter;
}
@end