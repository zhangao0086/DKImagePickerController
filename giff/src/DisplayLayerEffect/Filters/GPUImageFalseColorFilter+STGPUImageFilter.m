//
// Created by BLACKGENE on 8/16/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "GPUImageFalseColorFilter+STGPUImageFilter.h"
#import "Colours.h"


@implementation GPUImageFalseColorFilter (STGPUImageFilter)

+ (instancetype)filterWithColors:(NSArray <UIColor *> *)colors {
    NSParameterAssert(colors.count>0);
    GPUImageFalseColorFilter * falseColorFilter = [[GPUImageFalseColorFilter alloc] init];

    NSArray* firstColorArr = [[colors firstObject] rgbaArray];
    [falseColorFilter setFirstColorRed:[firstColorArr[0] floatValue] green:[firstColorArr[1] floatValue] blue:[firstColorArr[2] floatValue]];

    if(colors.count>1){
        NSArray* secondColorArr = [colors[1] rgbaArray];
        [falseColorFilter setFirstColorRed:[secondColorArr[0] floatValue] green:[secondColorArr[1] floatValue] blue:[secondColorArr[2] floatValue]];
    }

    return falseColorFilter;

}

@end