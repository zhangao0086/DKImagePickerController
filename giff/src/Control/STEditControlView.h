//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STEditControlFrameEditView.h"

@class STEditControlFrameEditView;
@class STEditControlEffectSelectorView;

@interface STEditControlView : STUIView <STSegmentedSliderControlDelegate>
@property (nonatomic, readonly) STEditControlFrameEditView * frameEditView;
@property (nonatomic, readonly) STEditControlEffectSelectorView * effectSelectorView;
@end
