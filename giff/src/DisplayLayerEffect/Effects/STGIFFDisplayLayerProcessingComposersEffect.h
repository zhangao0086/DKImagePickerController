//
// Created by BLACKGENE on 8/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMultiSourcingImageProcessor.h"

@class STGPUImageOutputComposeItem;


@interface STGIFFDisplayLayerProcessingComposersEffect : STMultiSourcingImageProcessor
- (UIImage *__nullable)processImagesAsComposers:(NSArray<STGPUImageOutputComposeItem *> *__nullable)composers;

- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages;

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage;
@end