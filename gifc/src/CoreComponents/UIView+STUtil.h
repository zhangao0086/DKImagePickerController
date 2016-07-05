//
// Created by BLACKGENE on 2014. 11. 6..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class STContinuousForceTouchGestureRecognizer;
@class UITouchLongPressGestureRecognizer;

/*
    UI Action
 */
typedef NS_ENUM(NSUInteger, STSlideDirection) {
    STSlideDirectionUp = 1 << 0,
    STSlideDirectionDown = 1 << 1,
    STSlideDirectionLeft = 1 << 2,
    STSlideDirectionRight = 1 << 3,
    STSlideDirectionNone = 0xFFFFFFFF
};

typedef NS_ENUM(NSInteger, STSlideAllowedDirection) {
    STSlideAllowedDirectionBoth,
    STSlideAllowedDirectionVertical,
    STSlideAllowedDirectionHorizontal
};

@interface UIView (STUtil)

@property (nonatomic, readonly) CGRect initialFrame;
@property (nonatomic, readonly) CGRect initialBounds;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) BOOL animatableVisible;
@property (nonatomic, readwrite) NSString * tagName;
@property (nonatomic, assign) CGFloat scaleXYValue;
@property (nonatomic, assign) CGFloat originOffsetX;
@property (nonatomic, assign) CGFloat originOffsetY;

/*
 * AutoOrientation
 */
@property (nonatomic, assign) BOOL autoOrientationEnabled;
@property (nonatomic, assign) BOOL autoOrientationAnimationEnabled;
@property (nonatomic, assign) BOOL autoOrientationAnimationSpringStyled;
@property (nonatomic, assign) CGFloat autoOrientationAnimationDuration;

- (id)initWithSize:(CGSize)size;

- (id)initWithSizeWidth:(CGFloat)width;

- (void)saveInitialLayout;

- (void)restoreInitialLayout;

- (void)lockVisibleToHide;

- (void)lockVisibleToHideExcludingSubviews:(NSSet *)subviewsToExclude;

- (void)unlockVisible;

- (void)unlockVisibleToAllSubviews;

- (UIView *)viewWithTagName:(NSString *)name;

- (NSArray *)viewsWithTagName:(NSString *)name;

- (NSArray *)viewsWithoutTagName:(NSString *)name;

- (NSArray *)viewsWithTagNameFromAllSubviews:(NSString *)name;

- (NSArray *)viewsWithClass:(Class)Class1;

- (UIView *)viewWithClass:(Class)Class1;

- (UIView *)viewWithTagName:(NSString *)name create:(UIView *(^)(UIView __weak * weakSelf))block;

+ (void)lockAnimation;

+ (void)unlockAnimation;

+ (UIView *)st_createViewFromPresentableObject:(id)object;

+ (void)st_removeDelayedToggleAlpha:(NSArray *)views;

+ (CGFloat)st_setDelayedToggleAlpha:(NSArray *)views delay:(NSTimeInterval)delay;

+ (CGFloat)st_setDelayedToggleAlpha:(NSArray *)views delay:(NSTimeInterval)delay duration:(CGFloat)duration minAlpha:(CGFloat)minAlpha maxAlpha:(CGFloat)maxAlpha;

+ (void)setGlobalAutoOrientationEnabled:(BOOL)enable;

+ (BOOL)globalAutoOrientationEnabled;

+ (instancetype)allocIfNot:(UIView *)instance frame:(CGRect)frame;

- (void)setShadowEnabledForOverlay:(BOOL)enable;

- (void)insertBelowToSuperview:(UIView *)view;

- (void)insertAboveToSuperview:(UIView *)view;

- (UIView *)viewWithTagNameFirst:(NSString *)name;

- (UIView *)viewWithTagNameLast:(NSString *)name;

- (void)st_eachSubviews:(void (^)(UIView *view, NSUInteger index))block;

- (UIView *)firstSubview;

- (UIView *)lastSubview;

- (UIView *)st_matchSubviews:(BOOL (^)(UIView *view, NSUInteger index))block;

- (void)st_addSubPresentableObject:(id)object;

- (void)clearAllOwnedImagesIfNeededAndRemoveFromSuperview:(BOOL)recursive;

- (void)clearAllOwnedImagesIfNeeded:(BOOL)recursive;

- (void)clearAllOwnedImagesIfNeeded:(BOOL)recursive removeSubViews:(BOOL)removeSubviews;

- (UIVisualEffectView *)maskedEffectView:(CALayer *)layer;

- (UIVisualEffectView *)maskedVibrancyEffectView:(UIVisualEffectView *)effectView;

- (UIVisualEffectView *)addMaskedEffectView:(UIView *)subview subviewsForVibrancy:(NSArray *)subviewsForVibrancy;

- (UIVisualEffectView *)addMaskedEffectView:(UIView *)subview style:(UIBlurEffectStyle)style subviewsForVibrancy:(NSArray *)subviewsForVibrancy;

- (UIVisualEffectView *)addMaskedEffectLayer:(CALayer *)layer style:(UIBlurEffectStyle)style subviewsForVibrancy:(NSArray *)subviewsForVibrancy;

- (void)removeMaskedEffectView:(UIView *)subview subviewsForVibrancy:(NSArray *)subviewsForVibrancy;

- (void)removeMaskedEffectLayer:(CALayer *)layer subviewsForVibrancy:(NSArray *)subviewsForVibrancy;

- (void)removeAllMaskedEffectViews;

- (UIViewController *)parentViewController;

- (BOOL)st_isSuperviewsVisible;

- (NSArray *)st_allSuperviews;

- (NSArray *)st_allSuperviewsContainSelf;

- (NSArray *)st_allSubviews;

- (NSArray *)st_allSubviewsContainSelf;

- (CGFloat)st_maxSubviewWidth;

- (CGFloat)st_minSubviewWidth;

- (CGFloat)st_maxSubviewHeight;

- (CGFloat)st_minSubviewHeight;

- (CGRect)st_originClearedBounds;

- (CGRect)boundsWithScale:(CGFloat)sx sy:(CGFloat)sy;

- (CGRect)boundsWithScaleRatio:(CGFloat)scaleXY;

- (CGRect)boundsWithScale:(CGPoint)scaleXY;

- (CGRect)boundsWithScaleX:(CGFloat)sx;

- (CGRect)boundsWithScaleY:(CGFloat)sy;

- (CGRect)frameWithScale:(CGFloat)sx sy:(CGFloat)sy;

- (CGRect)frameWithScaleRatio:(CGFloat)scaleXY;

- (CGRect)frameWithScaleX:(CGFloat)sx;

- (CGRect)setFrameWithScaleY:(CGFloat)sx;

- (CGFloat)st_maxLength;

- (CGFloat)st_minLength;

- (CGRect)frameToView:(UIView *)destinationBoundsView;

//- (void)setOriginOffsetX:(CGFloat)x;
//
//- (void)setOriginOffsetY:(CGFloat)y;

- (void)setOriginOffset:(CGPoint)point;

- (void)st_distributeSubviewsAsCenterHorizontally:(CGFloat)spacing;

- (void)st_gridSubviewsAsCenter:(CGFloat)spacing rowHeight:(CGFloat)rowHeight column:(NSUInteger)col;

- (UIView *)st_createNewViewWithBackgroundColor:(UIColor *)color alpha:(CGFloat)alpha;

- (CGRect)boundsAsSizeWidth;

- (CGRect)boundsAsSizeHeight;

- (void)st_removeAllSubviews;

- (void)st_removeAllSubviewsRecursively;

- (BOOL)isAddedToSuperviewAtIndex:(NSUInteger)index;

- (BOOL)isAddedBackToSuperview;

- (BOOL)isAddedBelowFromOtherview:(UIView *)view;

- (BOOL)isAddedFrontToSuperview;

- (BOOL)isAddedAboveFromOtherview:(UIView *)view;

- (void)setOrientationToTransform:(UIInterfaceOrientation)orientation;

- (void)resetAutoOrientedTransformToDefaultIfNeeded;

- (void)resetAutoOrientedTransformToCurrentIfNeeded;

- (UIImage *)st_takeSnapshot:(CGRect)frame afterScreenUpdates:(BOOL)afterScreenUpdates;

- (UIImage *)st_takeSnapshot:(CGRect)frame afterScreenUpdates:(BOOL)afterScreenUpdates useTransparent:(BOOL)useTransparent;

- (UIImage *)st_takeSnapshot:(CGRect)frame afterScreenUpdates:(BOOL)afterScreenUpdates useTransparent:(BOOL)useTransparent maxTwiceScale:(BOOL)maxTwiceScale;

- (UIImage *)st_takeSnapshot;

- (UIImage *)st_takeSnapshotExcludingAllSubviewsBoundsOrigin:(CGRect)frame;

- (UIImage *)st_takeSnapshotWithBlurredOverlayView:(BOOL)bestQuality dark:(BOOL)dark;

- (UIImage *)st_takeSnapshotWithBlurredOverlayView:(BOOL)bestQuality dark:(BOOL)dark alpha:(CGFloat)alpha;

- (UIImage *)st_takeSnapshotWithBlurredOverlayView:(BOOL)bestQuality dark:(BOOL)dark alpha:(CGFloat)alpha useTransparent:(BOOL)useTransparent maxTwiceScale:(BOOL)maxTwiceScale;

- (UIImage *)st_takeSnapshotWithBlurredOverlayView:(BOOL)bestQuality dark:(BOOL)dark alpha:(CGFloat)alpha useTransparent:(BOOL)useTransparent maxTwiceScale:(BOOL)maxTwiceScale afterScreenUpdates:(BOOL)afterScreenUpdates;

- (NSArray *)viewsWithTagFromAllSubviews:(NSInteger)tag;

- (UIView *)viewWithTagFromAllSubviews:(NSInteger)tag;

- (CGRect)st_subviewsUnionFrame;

- (void)sizeToFitSubviewsUnionSize;

- (CGRect)st_subviewsUnionFrameWithExcluding:(NSArray *)excludesSubviews;

- (void)visibleAlphaFromZero;

- (void)startAlphaBlinking;

- (void)startAlphaBlinking:(NSUInteger)repeatCount;

- (void)startAlphaBlinking:(NSTimeInterval)animationDuration repeatCount:(NSUInteger)repeatCount;

- (void)startAlphaBlinking:(NSTimeInterval)animationDuration maxAlpha:(CGFloat)alpha repeatCount:(NSUInteger)repeatCount;

- (void)stopAlphaBlinking;

- (void)animateWithReverse:(NSString *)keypath3 to:(CGFloat)value completion:(void (^)(BOOL finished))completionBlock;

- (void)animateWithReverse:(NSString *)keypath3 to:(CGFloat)value repeat:(BOOL)repeat completion:(void (^)(BOOL finished))block;

- (void)animateWithReverse:(NSString *)keypath3 to:(CGFloat)value duration:(CGFloat)duration delay:(NSTimeInterval)delay completion:(void (^)(BOOL finished))block;

- (void)animateWithReverse:(NSString *)keypath3 to:(CGFloat)value repeat:(BOOL)repeat duration:(CGFloat)duration delay:(NSTimeInterval)delay completion:(void (^)(BOOL finished))block;

- (void)animateWithReverse:(NSString *)keypath3 to:(CGFloat)value repeat:(BOOL)repeat duration:(CGFloat)duration durationReverse:(CGFloat)durationReverse completion:(void (^)(BOOL finished))block;

- (void)animateWithReverse:(NSString *)keypath3 to:(CGFloat)value repeat:(BOOL)repeat duration:(CGFloat)duration durationReverse:(CGFloat)durationReverse springDamping:(CGFloat)damping completion:(void (^)(BOOL finished))block;

- (void)animateWithReverse:(NSString *)keypath3 to:(CGFloat)value repeat:(BOOL)repeat duration:(CGFloat)duration durationReverse:(CGFloat)durationReverse springDamping:(CGFloat)damping delay:(NSTimeInterval)delay completion:(void (^)(BOOL finished))block;

- (void)disableUserInteraction;

- (void)restoreUserInteractionEnabled;

- (void)st_dispatchGestureHandlerToViews:(NSArray *)targetViews from:(UIGestureRecognizer *)bindingFrom classOfGestureRecognizer:(Class)Class state:(UIGestureRecognizerState)state;

- (void)st_dispatchGestureHandlerToViews:(NSArray *)targetViews from:(UIGestureRecognizer *)bindingFrom;

- (void)st_dispatchGestureHandlerToAll:(UIGestureRecognizer *)bindingFrom;

- (void)st_removeAllGestureRecognizers;

- (UIView *)st_setUserInteractionEnabledToSubviews:(BOOL)userInteractionEnabledToSubviews;

- (CGPoint)st_midXY;

- (CGPoint)st_halfXY;

- (void)st_centerToMidSuperview;

- (void)st_centerToHalfSuperview;

- (void)st_centerSubview:(UIView *)subview;

- (void)centerToParentHorizontal;

- (void)centerToParentVertical;

- (UIVisualEffectView *)st_createBlurView:(UIBlurEffectStyle)style;

- (BOOL)st_isCoverShowen;

- (UIView *)st_coveredView;

- (void)st_coverBlurIfNotShown;

- (void)st_coverBlur;

- (void)st_coverBlur:(BOOL)animation styleDark:(BOOL)dark completion:(void (^)(void))block;

- (UIImageView *)st_coverBlurSnapshot:(BOOL)animation styleDark:(BOOL)dark completion:(void (^)(void))block;

- (UIImageView *)st_coverBlurSnapshot:(BOOL)animation styleDark:(BOOL)dark useTransparent:(BOOL)useTransparent maxTwiceScale:(BOOL)maxTwiceScale completion:(void (^)(void))block;

- (UIImageView *)st_coverBlurSnapshot:(BOOL)animation styleDark:(BOOL)dark useTransparent:(BOOL)useTransparent maxTwiceScale:(BOOL)maxTwiceScale afterScreenUpdates:(BOOL)afterScreenUpdates completion:(void (^)(void))block;

- (UIImageView *)st_coverSnapshot:(BOOL)animation completion:(void (^)(void))block;

- (UIImageView *)st_coverSnapshot:(BOOL)animation useTransparent:(BOOL)useTransparent maxTwiceScale:(BOOL)maxTwiceScale completion:(void (^)(void))block;

- (UIImageView *)st_coverSnapshot:(BOOL)animation useTransparent:(BOOL)useTransparent maxTwiceScale:(BOOL)maxTwiceScale afterScreenUpdates:(BOOL)afterScreenUpdates completion:(void (^)(void))block;

- (UIImageView *)st_coverImage:(UIImage *)image animation:(BOOL)animation completion:(void (^)(void))block;

- (UIImageView *)_present_cover_image:(UIImage *)resultImage animation:(BOOL)animation completion:(void (^)(void))block;

- (void)st_coverBlurRemoveIfShowen;

- (void)st_coverRemove;

- (void)st_coverRemove:(BOOL)animation;

- (void)st_coverRemove:(BOOL)animation promiseIfAnimationFinished:(BOOL)promise;

- (void)st_coverRemove:(BOOL)animation promiseIfAnimationFinished:(BOOL)promise finished:(void (^)(void))block;

- (void)st_coverRemove:(BOOL)animation promiseIfAnimationFinished:(BOOL)promise duration:(NSTimeInterval)duration finished:(void (^)(void))block;

- (void)st_coverHide;

- (void)st_coverHide:(BOOL)animation;

- (UIImageView *)st_setShadowToBack:(UIRectEdge)edge size:(CGFloat)size shadowColor:(UIColor *)color;

- (UIImageView *)st_setShadowToFront:(UIRectEdge)edge size:(CGFloat)size shadowColor:(UIColor *)color;

- (UIImageView *)st_setShadow:(UIRectEdge)edge size:(CGFloat)size shadowColor:(UIColor *)color rasterize:(BOOL)rasterize strong:(BOOL)strong atIndex:(NSUInteger)index;

- (UIImageView *)st_shadow;

- (void)st_removeShadow;

- (UIView *)animateSpecial:(CGFloat)speed;

- (void)transitionZeroScaleTo:(UIView *)toView presentImage:(UIImage *)image completion:(void (^)(UIView *trasitionView, BOOL finished))block;

- (void)transitionFrameTo:(UIView *)toView presentImage:(UIImage *)image completion:(void (^)(UIView *trasitionView, BOOL finished))block;

- (void)transitionTo:(UIView *)toView presentImage:(UIImage *)image animations:(void (^)(UIView *trasitionView))animationsBlock completion:(void (^)(UIView *trasitionView, BOOL finished))completionBlock;

- (void)removeGestureRecognizersByClass:(Class)class;

- (UIPanGestureRecognizer *)whenPanning:(void (^)(UIPanGestureRecognizer *))block;

- (UIPanGestureRecognizer *)whenPan:(void (^)(UIPanGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block;

- (UIPanGestureRecognizer *)whenPan:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panStart changed:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panChanging ended:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panEnded;

- (UIPanGestureRecognizer *)whenPan:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panStart changed:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panChanging ended:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panEnded delayPanChanged:(NSTimeInterval)delayPanChanged;

- (UIPanGestureRecognizer *)whenPanAsSlideVerticalSelf:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panStart changed:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, CGFloat distance, CGPoint movedOffset, CGFloat distanceReachRatio, STSlideDirection direction, BOOL confirmed))panChanging ended:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, STSlideDirection direction, BOOL confirmed))panEnded;

- (UIPanGestureRecognizer *)whenPanAsSlideVertical:(UIView *)slideTargetView started:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panStart changed:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, CGFloat distance, CGPoint movedOffset, CGFloat distanceReachRatio, STSlideDirection direction, BOOL confirmed))panChanging ended:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, STSlideDirection direction, BOOL confirmed))panEnded;

- (UIPanGestureRecognizer *)whenPanAsSlideHorizontalSelf:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panStart changed:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, CGFloat distance, CGPoint movedOffset, CGFloat distanceReachRatio, STSlideDirection direction, BOOL confirmed))panChanging ended:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, STSlideDirection direction, BOOL confirmed))panEnded;

- (UIPanGestureRecognizer *)whenPanAsSlideHorizontal:(UIView *)slideTargetView started:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panStart changed:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, CGFloat distance, CGPoint movedOffset, CGFloat distanceReachRatio, STSlideDirection direction, BOOL confirmed))panChanging ended:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, STSlideDirection direction, BOOL confirmed))panEnded;

- (UIPanGestureRecognizer *)whenPanAsSlide:(UIView *)slideTargetView direction:(STSlideAllowedDirection)direction started:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf))panStart changed:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, CGFloat distance, CGPoint movedOffset, CGFloat distanceReachRatio, STSlideDirection direction, BOOL confirmed))panChanging ended:(void (^)(UIPanGestureRecognizer *sender, CGPoint locationInSelf, STSlideDirection direction, BOOL confirmed))panEnded;

- (void)whenSwiped:(void (^)(UISwipeGestureRecognizer *))block;

- (void)whenSwipedUpDown:(void (^)(UISwipeGestureRecognizer *))block;

- (void)whenSwipedLeftRight:(void (^)(UISwipeGestureRecognizer *))block;

- (void)whenSwiped:(void (^)(UISwipeGestureRecognizer *))block withUISwipeGestureRecognizerDirections:(NSArray *)directions;

- (void)st_dispatchTapGestureHandlerToViews:(NSArray *)targetViews from:(UIGestureRecognizer *)bindingFrom;

- (UITapGestureRecognizer *)whenTouches:(NSUInteger)numberOfTouches tapped:(NSUInteger)numberOfTaps handler:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block;

- (UITapGestureRecognizer *)whenTap:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block;

- (UITapGestureRecognizer *)whenTapped:(void (^)(void))block;

- (UITapGestureRecognizer *)whenTappedParams:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block;

- (UITapGestureRecognizer *)whenDoubleTapped:(void (^)(void))block;

- (UITapGestureRecognizer *)whenDoubleTappedParams:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block;

- (NSArray *)whenTapped:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))blockForSingleTapped orDoubleTapped:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))blockForDoubleTapped;

- (UITouchLongPressGestureRecognizer *)whenLongTouchAsTapDownUp:(void (^)(UITouchLongPressGestureRecognizer *sender, CGPoint location))tapDown changed:(void (^)(UITouchLongPressGestureRecognizer *sender, CGPoint location))tapChange ended:(void (^)(UITouchLongPressGestureRecognizer *sender, CGPoint location))tapUp;

- (UILongPressGestureRecognizer *)whenLongTapAsTapDown:(void (^)(UITouchLongPressGestureRecognizer *sender, CGPoint location))tapDown andUp:(void (^)(UITouchLongPressGestureRecognizer *sender, CGPoint location))tapUp;

- (UILongPressGestureRecognizer *)whenLongTapAsTapDownUp:(void (^)(UILongPressGestureRecognizer *sender, CGPoint location))tapDown changed:(void (^)(UILongPressGestureRecognizer *sender, CGPoint location))tapChange ended:(void (^)(UILongPressGestureRecognizer *sender, CGPoint location))tapUp;

- (UILongPressGestureRecognizer *)whenLongTapped:(void (^)(void))block;

- (UILongPressGestureRecognizer *)whenLongTappedParams:(void (^)(UILongPressGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block;

- (STContinuousForceTouchGestureRecognizer *)whenForceTouched:(void (^)(STContinuousForceTouchGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block;

- (STContinuousForceTouchGestureRecognizer *)whenForceTouched:(void (^)(STContinuousForceTouchGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block minimumPressDuration:(NSTimeInterval)minimumPressDuration;

- (UIPinchGestureRecognizer *)whenPinch:(void (^)(UIPinchGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block;
@end