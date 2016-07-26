//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STSegmentedSliderView.h"

@class STCapturedImageSet;
@class STCapturedImageSetDisplayLayerSet;
@class STCapturedImageSetAnimatableLayerSet;


@interface STEditControlFrameEditItemView : STUIView
@property (nonatomic, readwrite) STCapturedImageSet * imageSet;
@property (nonatomic, readonly) STSegmentedSliderView * frameOffsetSlider;
@end