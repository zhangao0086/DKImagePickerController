//
// Created by BLACKGENE on 7/27/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMultiSourcingImageProcessor.h"

@class GPUImageOutput;


@interface STMultiSourcingGPUImageProcessor : STMultiSourcingImageProcessor

- (GPUImageOutput *)outputToProcess:(NSArray<UIImage *> *__nullable)sourceImages forImage:(BOOL)forImage;
@end