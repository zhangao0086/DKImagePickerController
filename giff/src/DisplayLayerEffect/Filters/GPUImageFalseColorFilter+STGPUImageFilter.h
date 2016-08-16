//
// Created by BLACKGENE on 8/16/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage/GPUImageFalseColorFilter.h>

@interface GPUImageFalseColorFilter (STGPUImageFilter)

+ (instancetype)filterWithColors:(NSArray <UIColor *> *)colors;

@end