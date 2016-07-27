//
// Created by BLACKGENE on 7/27/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCapturedImageSetDisplayProcessor.h"


@interface STCapturedImageSetGPUDisplayProcessor : STCapturedImageSetDisplayProcessor
- (BOOL)processForImageInput:(NSArray<id <GPUImageInput>> *)inputs;
@end