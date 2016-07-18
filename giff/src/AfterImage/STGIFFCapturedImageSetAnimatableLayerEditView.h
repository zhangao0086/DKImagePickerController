//
// Created by BLACKGENE on 7/8/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STSelectableView.h"
#import "STSelectableCapturedImageSetView.h"
#import "STSegmentedSliderView.h"

@class STCapturedImageSetAnimatableLayer;

@interface STGIFFCapturedImageSetAnimatableLayerEditView : STUIView <STSegmentedSliderControlDelegate>
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, readonly) NSArray<STCapturedImageSetAnimatableLayer *> * layers;

- (void)appendLayer:(STCapturedImageSetAnimatableLayer *)layerItem;

- (void)removeAllLayers;
@end