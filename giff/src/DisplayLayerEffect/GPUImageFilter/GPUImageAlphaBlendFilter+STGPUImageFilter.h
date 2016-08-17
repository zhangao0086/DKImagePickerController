//
// Created by BLACKGENE on 8/12/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageAlphaBlendFilter.h"

@interface GPUImageAlphaBlendFilter (STGPUImageFilter)

+ (instancetype)filterWithAlphaMix:(CGFloat)mix;

@end