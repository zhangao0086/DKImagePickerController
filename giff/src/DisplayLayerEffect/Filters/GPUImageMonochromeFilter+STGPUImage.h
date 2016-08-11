//
// Created by BLACKGENE on 8/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageMonochromeFilter.h"

@interface GPUImageMonochromeFilter (STGPUImage)

+ (instancetype)filterWithColor:(UIColor *)color;
@end