//
// Created by BLACKGENE on 2014. 10. 1..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage/GPUImageView.h>

@interface GPUImageView (STGPUImageFilterHelper)

- (GPUImageView *)setGPUImage:(GPUImagePicture *)imageSource withFilter:(GPUImageOutput <GPUImageInput> *)filter;

- (GPUImageView *)setGPUImage:(GPUImagePicture *)imageSource;
@end