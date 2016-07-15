//
// Created by BLACKGENE on 7/9/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"

@class STAfterImageLayerEffect;

@interface STAfterImageLayerItem : STItem
@property (nonatomic, readonly) STAfterImageLayerItem * superlayer;
@property (nonatomic, readonly) NSArray<STAfterImageLayerItem *> * layers;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) NSInteger frameIndexOffset;
@property (nonatomic, readwrite) STAfterImageLayerEffect * effect;

- (instancetype)initWithLayers:(NSArray<STAfterImageLayerItem *> *)layers;

+ (instancetype)itemWithLayers:(NSArray<STAfterImageLayerItem *> *)layers;

- (NSArray *)processPresentableObjects:(NSArray *)presentableObjects;

@end