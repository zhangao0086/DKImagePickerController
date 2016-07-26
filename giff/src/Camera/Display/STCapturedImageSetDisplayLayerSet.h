//
// Created by BLACKGENE on 7/9/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"

@class STMultiSourcingImageProcessor;
@class STCapturedImageSet;

@interface STCapturedImageSetDisplayLayerSet : STItem
//initial attributes
@property (nonatomic, readwrite) NSArray<STCapturedImageSet *> * sourceImageSets;
@property (nonatomic, readonly) STCapturedImageSetDisplayLayerSet * superlayer;
//storing attributes
//@property (nonatomic, readonly) NSArray<STAfterImageLayerItem *> * layers;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, readwrite) STMultiSourcingImageProcessor * effect;

//- (instancetype)initWithLayers:(NSArray<STAfterImageLayerItem *> *)layers;
//
//+ (instancetype)itemWithLayers:(NSArray<STAfterImageLayerItem *> *)layers;

- (instancetype)initWithSourceImageSets:(NSArray *)sourceImageSets;

+ (instancetype)itemWithSourceImageSets:(NSArray *)sourceImageSets;
@end