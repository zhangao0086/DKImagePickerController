//
// Created by BLACKGENE on 7/21/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STCapturedImageSet;
@class STCapturedImageSetDisplayLayerSet;
@class STCapturedImageSetDisplayLayer;


@interface STCapturedImageSetDisplayProcessor : NSObject
@property(nonatomic, readonly) STCapturedImageSetDisplayLayerSet * layerSet;
@property(nonatomic, assign) BOOL loselessImageEncoding;
@property(nonatomic, assign) NSRange preferredRangeOfSourceSet;

- (instancetype)initWithLayerSet:(STCapturedImageSetDisplayLayerSet *)targetLayer;

+ (instancetype)processorWithLayerSet:(STCapturedImageSetDisplayLayerSet *)targetLayer;

- (NSArray<NSURL *> *)processForImageUrls:(BOOL)forceReprocess;

- (NSArray<NSArray *> *)sourceSetOfImagesForLayerSet;

- (NSArray<NSArray *> *)sourceSetOfImagesForLayerSetApplyingRangeIfNeeded;

- (NSArray<id> *)sourceOfImagesForLayer:(STCapturedImageSetDisplayLayer *)layer;

- (NSArray<UIImage *> *)loadImagesFromSourceSet:(NSArray *)sourceSetOfImages;
@end