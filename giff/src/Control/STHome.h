//
// Created by BLACKGENE on 2014. 9. 5..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <M13ProgressSuite/M13ProgressView.h>
#import "UIView+STUtil.h"

@class STStandardButton;
@class STStandardCollectableButton;
@class STStandardNavigationButton;
@class STFilterItem;


@interface STHome : STUIView <STUIViewPersistantState>

@property (nonatomic, readonly) STStandardButton *containerButton; //default
@property (nonatomic, readonly) STStandardButton *selectableButton; //optinal by mode

@property (nonatomic, assign) CGFloat previewVisiblity;
@property (nonatomic, assign) BOOL previewQuickCaptureMode;
@property (nonatomic, assign) BOOL previewExpended;
@property (nonatomic, assign) BOOL previewSuspending;
@property (nonatomic, assign) BOOL previewCurtain;
@property (nonatomic, assign) BOOL spinnerVisiblity;
@property (nonatomic, assign) CGFloat indexProgress;
@property (nonatomic, assign) BOOL indexProgressDisplayInstantly;
@property (nonatomic, readwrite) UIColor *indexProgressColor;
@property (nonatomic, readwrite) UIColor *backgroundCircleColor;
@property (nonatomic, readwrite) NSString *backgroundCircleIconImageName;
@property (nonatomic, assign) CGFloat logoProgress;

- (void)cancelRestoreStateEffect;

- (void)whenSlidingBegan:(void (^)(STSlideDirection direction))block;

- (void)whenSlidingChange:(void (^)(CGFloat reachRatio, BOOL confirmed, STSlideDirection direction))block;

- (void)whenSlided:(void (^)(BOOL confirmed, STSlideDirection direction))block;

- (void)whenSlidedAsConfirmed:(void (^)(STSlideDirection direction))block;

- (void)setDisplayToDefault;

- (STStandardButton *)setDisplayOnlyButton;

- (STStandardButton *)setDisplayOnlyButton:(STStandardButton *)button;

- (STStandardButton *)setDisplayScrollTop;

- (STStandardNavigationButton *)setDisplayWithCollectables:(BOOL)expanding;

- (STStandardNavigationButton *)setDisplayWithCollectables:(BOOL)expanding visibleHome:(BOOL)visibleHome;

- (STStandardNavigationButton *)setDisplayWithCollectables:(BOOL)expanding visibleHome:(BOOL)visibleHome width:(CGFloat)width;

- (void)setIndexNumberOfSegments:(NSInteger)numberOfSegment;

- (UIImage *)snapshotCurrent;

@end