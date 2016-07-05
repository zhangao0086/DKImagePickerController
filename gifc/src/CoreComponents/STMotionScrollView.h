//
//  CRMotionView.h
//  CRMotionView
//
//  Created by Christian Roman on 06/02/14.
//  Copyright (c) 2014 Christian Roman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;

@interface STMotionScrollView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImage  *image;
@property (nonatomic, strong) PHAsset  *asset;
@property (nonatomic, strong) UIView   *contentView;
@property (nonatomic, assign, getter = isMotionEnabled) BOOL motionEnabled;
@property (nonatomic, assign, getter = isZoomEnabled) BOOL zoomEnabled;
@property (nonatomic, assign) CGFloat zoomScale;
@property (nonatomic, assign, getter = isScrollDragEnabled) BOOL scrollDragEnabled;
@property (nonatomic, assign, getter = isScrollBounceEnabled) BOOL scrollBounceEnabled;
@property (nonatomic, readonly) BOOL isContentSizeScrollable;
@property (nonatomic, readonly) BOOL isPossibleScroll;
@property (nonatomic, readonly) BOOL isEnteredZoomScrollMode;
@property (copy) void(^whenDidScrollToProgress)(STMotionScrollView * __weak weakSelf, CGFloat progress);
@property (copy) void(^whenDidZoomScaleChanged)(STMotionScrollView * __weak weakSelf, CGFloat scale);

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image;

- (instancetype)initWithFrame:(CGRect)frame contentView:(UIView *)contentView;

- (void)enterZoomScrollMode;

- (void)dismissZoomScrollMode:(BOOL)animation;

- (void)disposeContent;

@end