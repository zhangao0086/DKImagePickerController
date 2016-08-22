//
// Created by BLACKGENE on 8/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMultiSourcingImageProcessor.h"

@class STGPUImageOutputComposeItem;


@interface STMultiSourcingGPUImageComposerProcessor : STMultiSourcingImageProcessor

- (nullable UIImage *)processComposers:(NSArray<STGPUImageOutputComposeItem *> *__nullable)composers;

- (nullable NSArray *)composersToProcess:(NSArray<UIImage *> *__nullable)sourceImages;

- (nullable NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages;

- (nullable NSArray *)composersToProcessSingle:(UIImage * __nullable)sourceImage;
@end