//
// Created by BLACKGENE on 2014. 9. 2..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STSegmentedSliderView.h"
#import "STSelectableView.h"
#import "STExporter.h"
#import "STSubControl.h"
#import "STElieCamera.h"
#import "STEditControlView.h"

@class STHome;
@class STStandardButton;
@class STSubControl;
@class STFilterItem;
@class STEditControlView;

@interface STMainControl : STUIView <STSegmentedSliderControlDelegate, STUIViewPersistantState>

@property (atomic, readonly) STControlDisplayMode mode;

@property (nonatomic, readonly) STHome * homeView;

@property (nonatomic, readonly) STSubControl * subControl;

@property (nonatomic, readonly) STFilterItem * homeSelectedFilterItem;

@property (nonatomic, readonly) STEditControlView * editControlView;

+ (STMainControl *)initSharedInstanceWithFrame:(CGRect)frame;

+ (STMainControl *)sharedInstance;

- (void)showControls;

- (void)hideControls;

- (void)showControlsWhenStopScrolling;

- (void)hideControlsWhenStartScrolling;

- (void)startParallaxEffect;

- (void)stopParallaxEffect;

- (BOOL)showContextNeededResetButton;

- (BOOL)hideContextNeededResetButton;

- (void)tryExportByType:(STExportType)exportType;

// home
- (void)home;

- (void)main;

- (void)requestGoMain;

- (void)export;

// submode

- (void)enterEdit;

- (void)exitEdit;

- (void)enterEditAfterCapture;

- (void)exitEditAfterCapture;

- (void)enterReviewAfterAnimatableCapture;

- (void)exitReviewAfterAnimatableCapture;

- (void)enterEditTool;

- (void)exitEditTool;

- (void)enterLivePreview;

- (void)exitLivePreview;

- (void)setPreviewVisibility:(CGFloat)visibility;

- (void)setPreviewCurtain:(BOOL)visibility;

- (void)setPhotoSelected:(NSUInteger)count;

- (void)setDisplayHomeScrolledGridView:(CGFloat)offset withCount:(NSUInteger)count;

- (void)setDisplayHomeScrolledFilters:(NSUInteger)index withCount:(NSUInteger)count;

- (void)whenChangedDisplayMode:(void (^)(STControlDisplayMode mode, STControlDisplayMode previousMode))block;

- (void)requestQuickPostFocusCaptureIfPossible:(STPostFocusMode)mode;

- (void)backToHome;

- (void)back;
@end