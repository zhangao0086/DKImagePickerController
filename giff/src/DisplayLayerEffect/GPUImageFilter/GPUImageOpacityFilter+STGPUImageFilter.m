//
// Created by BLACKGENE on 8/21/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "GPUImageOpacityFilter+STGPUImageFilter.h"


@implementation GPUImageOpacityFilter (STGPUImageFilter)

+ (instancetype)opacity:(CGFloat)opacity {
    GPUImageOpacityFilter * opacityFilter = [[GPUImageOpacityFilter alloc] init];
    opacityFilter.opacity = opacity;
    return opacityFilter;
}

@end