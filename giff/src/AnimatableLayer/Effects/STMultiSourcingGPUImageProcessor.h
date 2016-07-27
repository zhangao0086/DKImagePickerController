//
// Created by BLACKGENE on 7/27/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMultiSourcingImageProcessor.h"

@class GPUImageOutput;
@protocol GPUImageInput;


@interface STMultiSourcingGPUImageProcessor : STMultiSourcingImageProcessor

- (GPUImageOutput * __nullable )processImages:(NSArray<UIImage *> *__nullable)sourceImages forInput:(id<GPUImageInput> __nullable)input;
@end