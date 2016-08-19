//
// Created by BLACKGENE on 8/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMultiSourcingImageProcessor.h"

@class STGPUImageOutputComposeItem;


@interface STMultiSourcingGPUImageComposerProcessor : STMultiSourcingImageProcessor

- (UIImage *__nullable)processComposers:(NSArray<STGPUImageOutputComposeItem *> *__nullable)composers;

- (NSArray *)composersToProcess:(NSArray<UIImage *> *__nullable)sourceImages;

- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages;

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage;
@end