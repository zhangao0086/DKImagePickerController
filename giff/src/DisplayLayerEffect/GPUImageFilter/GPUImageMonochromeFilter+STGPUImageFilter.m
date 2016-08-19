//
// Created by BLACKGENE on 8/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Colours/Colours.h>
#import "GPUImageMonochromeFilter+STGPUImageFilter.h"


@implementation GPUImageMonochromeFilter (STGPUImageFilter)

+ (instancetype)color:(UIColor *)color{
    return [self color:color intensity:1];
}

+ (instancetype)color:(UIColor *)color intensity:(CGFloat)intensity{
    GPUImageMonochromeFilter * colorFilter = [[GPUImageMonochromeFilter alloc] init];
    colorFilter.intensity = intensity;
    NSArray* colors = [color rgbaArray];
    [colorFilter setColorRed:[colors[0] floatValue] green:[colors[1] floatValue] blue:[colors[2] floatValue]];
    return colorFilter;
}
@end