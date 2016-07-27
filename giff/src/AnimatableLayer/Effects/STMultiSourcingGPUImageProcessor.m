//
// Created by BLACKGENE on 7/27/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STMultiSourcingGPUImageProcessor.h"
#import "GPUImageOutput.h"
#import "GPUImageContext.h"


@implementation STMultiSourcingGPUImageProcessor {

}

- (GPUImageOutput *)processImages:(NSArray<UIImage *> *__nullable)sourceImages forInput:(id<GPUImageInput> __nullable)input{
    return nil;
}

- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    return [[self processImages:sourceImages forInput:nil] imageFromCurrentFramebuffer];
}

@end