//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STSegmentedSliderView.h"

@class STCapturedImageSet;
@class STCapturedImageSetDisplayLayerSet;
@class STCapturedImageSetAnimatableLayerSet;
@class STCapturedImageSetAnimatableLayer;


@interface STEditControlFrameEditItemView : STUIView <STSegmentedSliderControlDelegate>
@property (nonatomic, readwrite) STCapturedImageSetAnimatableLayer * displayLayer;
@property (nonatomic, assign) NSInteger frameIndexOffset;
@property (nonatomic, assign) BOOL frameIndexOffsetHasChanging;
@property (nonatomic, readonly) STStandardButton * removeButton;
@end