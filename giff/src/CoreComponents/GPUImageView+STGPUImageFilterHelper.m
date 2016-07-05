//
// Created by BLACKGENE on 2014. 10. 1..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <GPUImage/GPUImagePicture.h>
#import <GPUImage/GPUImageFilter.h>
#import "GPUImageView+STGPUImageFilterHelper.h"


@implementation GPUImageView (STGPUImageFilterHelper)

- (GPUImageView *)setGPUImage:(GPUImagePicture *)imageSource withFilter:(GPUImageOutput <GPUImageInput> *)filter;{
    if(!filter){
        filter = [[GPUImageFilter alloc] initWithFragmentShaderFromString:kGPUImagePassthroughFragmentShaderString];
    }

    if([[imageSource targets] count]){
        [imageSource removeAllTargets];
    }
    [imageSource addTarget:filter];
    [filter addTarget:self];
    [imageSource processImage];

    return self;
}

- (GPUImageView *)setGPUImage:(GPUImagePicture *)imageSource {
    return [self setGPUImage:imageSource withFilter:nil];
}

@end