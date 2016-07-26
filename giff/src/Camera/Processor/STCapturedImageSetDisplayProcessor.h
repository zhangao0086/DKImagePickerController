//
// Created by BLACKGENE on 7/21/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STCapturedImageSet;
@class STCapturedImageSetDisplayLayerSet;


@interface STCapturedImageSetDisplayProcessor : NSObject
//@property(nonatomic, readonly) STCapturedImageSetDisplayLayer * targetLayer;
@property(nonatomic, assign) BOOL loselessImageEncoding;

- (instancetype)initWithTargetLayer:(STCapturedImageSetDisplayLayerSet *)targetLayer;

+ (instancetype)processorWithTargetLayer:(STCapturedImageSetDisplayLayerSet *)targetLayer;

- (NSArray *)processResources;

- (NSArray<NSArray *> *)resourcesSetToProcessFromSourceImageSets;

- (NSArray<id> *)resourcesToProcessFromSourceImageSet:(STCapturedImageSet *)imageSet;
@end