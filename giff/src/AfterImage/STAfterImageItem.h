//
// Created by BLACKGENE on 7/8/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"
#import "STRLMFileWritable.h"
#import "RLMCapturedImage.h"

@class STAfterImageLayerItem;

@interface STAfterImageItem : STItem
@property (nonatomic, readonly) NSArray<STAfterImageLayerItem *> * layers;

- (instancetype)initWithLayers:(NSArray<STAfterImageLayerItem *> *)layers;

+ (instancetype)itemWithLayers:(NSArray<STAfterImageLayerItem *> *)layers;

@end