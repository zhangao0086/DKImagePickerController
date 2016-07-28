//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCapturedImageSetAnimatableLayerSetCollectionView.h"
#import "STSegmentedSliderView.h"

@class STEditControlFrameEditItemView;


@class STCapturedImageSetAnimatableLayer;

@interface STEditControlFrameEditView : STUIView <STSegmentedSliderControlDelegate>
@property (nonatomic, readwrite) STCapturedImageSetAnimatableLayerSet * layerSet;
@property (nonatomic, readonly) NSUInteger maxNumberOfLayersOfLayerSet;
@property (nonatomic, readonly) NSUInteger currentMasterFrameIndex;

- (STEditControlFrameEditItemView *)itemViewOfLayer:(STCapturedImageSetAnimatableLayer *)layer;
@end