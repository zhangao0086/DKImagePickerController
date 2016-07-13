//
//  STSegmentedSliderControl.h
//  Betify
//
//  Created by Alok on 28/06/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "STSelectableView.h"

@class STSegmentedSliderView;
@protocol STSegmentedSliderControlDelegate <STSeletableViewDelegate>
@optional
- (void)didSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index;
- (CALayer *)createBackgroundLayer:(CGRect)bounds;
- (UIView *)createBackgroundView:(CGRect)bounds;
- (UIView *)createThumbView;
@end

@interface STSegmentedSliderView : STSelectableView

@property (nonatomic, readwrite) id<STSegmentedSliderControlDelegate> delegateSlider;
@property (nonatomic, assign) BOOL movingThumbAnimationEnabled;
@property (nonatomic, assign) BOOL allowMoveThumbAsSlide;
@property (nonatomic, assign) BOOL allowMoveThumbAsTap;
@property (nonatomic, readonly) UIView *thumbView;
@property (nonatomic, assign) CGFloat normalizedCenterPositionOfThumbView;
@property (nonatomic, readonly) UIView *thumbBoundView;
@property (nonatomic, readonly) UIView *backgroundView;
@property (nonatomic, readonly) NSArray *centerPositions;
@property (nonatomic, readwrite) NSArray *segmentationViews;
@property (copy) id (^blockForCreateBackgroundPresentableObject)(CGRect);

- (void)setSegmentationViewAsPresentableObject:(NSArray *)presentableObjects;
@end
