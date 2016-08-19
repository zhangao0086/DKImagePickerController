//
// Created by BLACKGENE on 8/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageMonochromeFilter.h"

@interface GPUImageMonochromeFilter (STGPUImageFilter)

+ (instancetype)color:(UIColor *)color;

+ (instancetype)color:(UIColor *)color intensity:(CGFloat)intensity;
@end