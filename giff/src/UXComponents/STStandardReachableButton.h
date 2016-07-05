//
// Created by BLACKGENE on 2015. 7. 24..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STStandardButton.h"


@interface STStandardReachableButton : STStandardButton
@property (nonatomic, readonly) BOOL reached;
@property (nonatomic, assign) CGFloat reachedProgress;
@property (nonatomic, assign) CGFloat thresholdToReach; //0~1, default :1
@property (nonatomic, assign) CGFloat reachedMinimumProgressToDisplayScale;
@property (nonatomic, assign) BOOL bindReachedProgressToCurrentIndex;
@property (nonatomic, assign) BOOL bindReachedToSelectedState;

//style
@property (nonatomic, readwrite) UIColor * reachedProgressCircleColor;
@property (nonatomic, assign) CGFloat reachedProgressCirclePadding;

// priority : visibleOutlineProgress > autoVisiblityOutlineProgressViaThresholdToReach
@property (nonatomic, assign) BOOL visibleOutlineProgress;
@property (nonatomic, assign) BOOL animateOutlineProgress;
@property (nonatomic, assign) BOOL animateSelectedViewScaleIfVisibleOutlineProgress;
@property (nonatomic, assign) BOOL autoVisiblityOutlineProgressViaThresholdToReach;
@property (nonatomic, assign) NSTimeInterval autoIncreasingOutlineProgressDurationWhenAfterReached;
@property (nonatomic, readonly, getter=isAutoIncreasingOutlineProgressStarting) BOOL autoIncreasingOutlineProgressStarting;

@property (nonatomic, assign) CGFloat outlineProgress;
@property (nonatomic, readwrite) UIColor * outlineStrokeColor;
@property (nonatomic, readwrite) UIColor * outlineStrokeBackgroundColor;
@property (nonatomic, assign) CGFloat outlineStrokeWidth;

@property (copy) void (^blockForWhenChangeReached)(STStandardButton *buttonSelf, BOOL reached);
@property (copy) void (^blockForWhenChangeReachedProgress)(STStandardButton *buttonSelf, CGFloat progress, BOOL reached);

- (void)startAutoIncreasingOutlineProgress:(NSTimeInterval)autoIncreasingOutlineProgressDuration performFirstCycleImmediately:(BOOL)start;

- (void)startAutoIncreasingOutlineProgress:(NSTimeInterval)autoIncreasingOutlineProgressDuration performFirstCycleImmediately:(BOOL)start resetWhenEnded:(BOOL)reset;

- (void)stopAutoIncreasingOutlineProgress;
@end