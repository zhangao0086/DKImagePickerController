//
// Created by BLACKGENE on 2014. 9. 30..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iCarousel.h"
#import "STPhotoSelector.h"
#import "STCarouselController.h"
#import "STFilterCollector.h"

@class STFilterCollector;
@class STEditorResult;
@class STFilterItem;
@class STEditorCommand;
@class STFilter;
@class STPreview;

extern NSString * const STPreviewCollectorNotificationPreviewBeginDragging;

@interface STPreviewCollector : STFilterCollector

@property (nonatomic, readonly) STPhotoViewType type;
@property (nonatomic, readonly) STPreview *previewView;
@property (nonatomic, assign) STPreviewCollectorEnterTransitionContext enterTransitionContext;
@property (nonatomic, assign) STPreviewCollectorExitTransitionContext exitTransitionContext;

- (instancetype)initWithPreviewFrame:(CGRect)frame;

- (void)start:(STPhotoViewType)type;

- (void)apply;

- (void)reloadSmoothly;

- (void)reset;

- (BOOL)isCurrentTypeAllowedTool;

- (void)startTool;

- (STEditorResult *)applyAndCloseTool;

- (void)closeTool;

- (void)resetTool;

- (BOOL)commandTool:(STEditorCommand *)command;

- (void)willEnterTransitionLive;

- (void)cancelPreTransitionLive;
@end