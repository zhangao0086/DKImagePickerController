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


@interface STEditControlFrameEditItemView : STUIView
@property (nonatomic, readwrite) STCapturedImageSetAnimatableLayer * displayLayer;
@property (nonatomic, readonly) STSegmentedSliderView * frameOffsetSlider;
@end