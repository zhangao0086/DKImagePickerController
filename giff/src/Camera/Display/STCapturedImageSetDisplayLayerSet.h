//
// Created by BLACKGENE on 7/9/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"
#import "STCapturedImageSetDisplayObject.h"

@class STMultiSourcingImageProcessor;
@class STCapturedImageSet;
@class STCapturedImageSetDisplayLayer;

@interface STCapturedImageSetDisplayLayerSet : STCapturedImageSetDisplayObject
@property (nullable, nonatomic, readonly) STCapturedImageSet * firstImageSet;
//storing attributes
@property (nonatomic, readwrite) NSArray<STCapturedImageSetDisplayLayer *> * layers;
@property (nonatomic, readwrite) STMultiSourcingImageProcessor * effect;

- (instancetype)initWithLayers:(NSArray *)layers;

+ (instancetype)setWithLayers:(NSArray *)layers;

@end