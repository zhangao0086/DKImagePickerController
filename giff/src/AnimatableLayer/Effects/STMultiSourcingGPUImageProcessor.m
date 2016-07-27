//
// Created by BLACKGENE on 7/27/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STMultiSourcingGPUImageProcessor.h"
#import "GPUImageOutput.h"


@implementation STMultiSourcingGPUImageProcessor {

}

- (GPUImageOutput *)outputToProcess:(NSArray<UIImage *> *__nullable)sourceImages forImage:(BOOL)forImage {
    return nil;
}

- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    return [[self outputToProcess:sourceImages forImage:YES] imageFromCurrentFramebuffer];
}

@end