//
// Created by BLACKGENE on 7/21/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STCapturedImageSet;
@class STCapturedImageSetDisplayLayerSet;
@class STCapturedImageSetDisplayLayer;


@interface STCapturedImageSetDisplayProcessor : NSObject
//@property(nonatomic, readonly) STCapturedImageSetDisplayLayer * targetLayer;
@property(nonatomic, assign) BOOL loselessImageEncoding;

- (instancetype)initWithTargetLayer:(STCapturedImageSetDisplayLayerSet *)targetLayer;

+ (instancetype)processorWithTargetLayerSet:(STCapturedImageSetDisplayLayerSet *)targetLayer;

- (NSArray *)processResources;

- (NSArray<NSArray *> *)resourcesSetToProcessFromSourceLayers;

- (NSArray<id> *)resourcesToProcessFromSourceLayer:(STCapturedImageSetDisplayLayer *)layer;
@end