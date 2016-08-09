//
// Created by BLACKGENE on 2014. 11. 28..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageView.h"
#import "iCarousel.h"
#import "STUIView.h"

@class STViewFinderPointLayer;

typedef NS_ENUM(NSInteger, STViewFinderType) {
    STViewFinderTypeNone,
    STViewFinderTypePostFocusModeVertical3Points,
    STViewFinderTypePostFocus5Point,
    STViewFinderTypePostFocusFullRangeDefault,
    STViewFinderType_count
};

@interface STPreview : STUIView

@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, readonly) BOOL lockAFAE;

@property (nonatomic, assign) BOOL visibleControl;

@property(nonatomic, readonly) STViewFinderPointLayer *pointerLayer;

//post focus - lens position
@property (nonatomic, assign) CGFloat masterPositionSliderValue;
@property (nonatomic, assign) BOOL masterPositionSliderSliding;
@property (nonatomic, assign) CGFloat masterPositionSlidingValue;

- (void)reset:(BOOL)animation;

- (void)resetAFAE;

- (void)setPostFocusSliderValueWithAnimation:(CGFloat)postFocusSliderValue;

- (void)startLoopingSliderValue:(BOOL)reverse;

- (void)stopLoopingSliderValue;

- (void)resetExposure;
@end