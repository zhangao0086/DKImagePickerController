
//
// Created by BLACKGENE on 2014. 11. 28..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "iCarousel.h"
#import "STPreview.h"
#import "STSelectableView.h"
#import "STGIFCAppSetting.h"
#import "UIView+STUtil.h"
#import "CAShapeLayer+STUtil.h"
#import "STMainControl.h"
#import "M13ProgressViewBorderedCenterBar.h"
#import "STStandardUIFactory.h"
#import "NSString+STUtil.h"
#import "NSNumber+STUtil.h"
#import "STViewFinderPointLayer.h"
#import "CALayer+STUtil.h"
#import "M13ProgressViewBorderedSlider.h"
#import "NSObject+STUtil.h"
#import "STStandardPointableSlider.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "R.h"
#import "SVGKImage.h"
#import "SVGKImage+STUtil.h"
#import "SVGKFastImageView.h"
#import "SVGKFastImageView+STUtil.h"
#import "STContinuousForceTouchGestureRecognizer.h"
#import "BlocksKit+UIKit.h"
#import "STPhotoSelector.h"
#import "STElieStatusBar.h"
#import "UIImage+Filtering.h"
#import "STCapturedImageSet+PostFocus.h"
#import "NSArray+STUtil.h"
#import "STPhotoItem+UIAccessory.h"

@interface iCarouselPreviewPrivate:iCarousel
@end

@implementation iCarouselPreviewPrivate
@end

@interface STPreview ()
/*
 * camera
 */
//pointing
@property(nonatomic, strong) UIVisualEffectView * focusPointerView;
@property(nonatomic, strong) UIView * verticalFocusPointerView;

@property(nonatomic, strong) STViewFinderPointLayer *pointerLayer;
//view finder
@property(nonatomic, strong) UIView *viewFinderView;
//lock
@property(nonatomic, strong) UIView * afAELockButton;
//zoom
@property(nonatomic, strong) UIVisualEffectView * zoomProgressBarEffectView;
@property(nonatomic, strong) M13ProgressViewBorderedCenterBar * zoomProgressBar;
@property(nonatomic, strong) UILabel * zoomProgressLabel;
//exposure
@property(nonatomic, strong) STStandardPointableSlider * exposureSlider;
@property(nonatomic, strong) UIVisualEffectView * exposureSliderView;

@property (nonatomic, readonly) STUIView *cameraControlView;

/*
 * preview
 */
@property(nonatomic, strong) STUIView * previewControlView;
@property(nonatomic, strong) STStandardPointableSlider * postFocusSlider;
@property(nonatomic, strong) UIVisualEffectView * postFocusSliderView;
@end

@implementation STPreview {
    UIView *_tapAndPinchTarget;
    UIView *_panTarget;

    BOOL _separateAFAEBegan;
    BOOL _resetIsRunning;
    BOOL _useForCamera;

    UIImageView *_simulationCameraView;

    GPUImageView * _backgroundView;
    UIImageView * _backgroundImageOverlayView;

    iCarousel * _filterCollectionView;
}

- (id)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {
        self.lazyCreateContent = YES;

        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)didCreateContent; {
    [super didCreateContent];

//    self.autoOrientationEnabled = YES;
}

- (__typed_collection(NSArray,UIView *))targetViewsForChangingTransformFromOrientation {
    if(_useForCamera){
        self.autoOrientationAnimationEnabled = NO;
        return self.focusPointerView ? @[self.focusPointerView] : nil;
    }else{
        self.autoOrientationAnimationEnabled = YES;
        return _filterCollectionView ? @[_filterCollectionView] : nil;
    }
    return nil;
}

#pragma mark Command

- (void)start:(BOOL)useForCamera {
    _useForCamera = useForCamera;

    [self clearFilterCollectionView];

    [self addBackgroundView:useForCamera];

    _filterCollectionView = [[iCarouselPreviewPrivate alloc] initWithFrame:[self st_originClearedBounds]];
    [self insertSubview:_filterCollectionView aboveSubview:_backgroundView];

    if([STGIFCApp isInSimulator]){
        if(!_simulationCameraView){
            _simulationCameraView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LaunchScreenIcon"]];
            _simulationCameraView.frame = [self st_originClearedBounds];
            _simulationCameraView.userInteractionEnabled = YES;
        }
        [self insertSubview:_simulationCameraView aboveSubview:_filterCollectionView];
    }

    [self updateControlViewsState:useForCamera];
}

- (void)finish; {
    [self clearFilterCollectionView];

    [self updateControlViewsState:NO];

    [[STMainControl sharedInstance] hideContextNeededResetButton];

    [self changeZoomFactor:1.0 smooth:NO];
}

- (void)reset {
    [self reset:YES];
}

- (void)reset:(BOOL)animation {
    [self resetAFAE];

    [self endFocusPoint];
    [self resetExposure];

    if(_filterCollectionView.numberOfItems){
        [_filterCollectionView scrollToItemAtIndex:0 animated:animation];
    }

    [[STMainControl sharedInstance] hideContextNeededResetButton];
    [self changeZoomFactor:1.0 smooth:animation];
}

- (void)resetAFAE{
    [self resetAFAE:NO];
}

- (void)resetAFAE:(BOOL)ignoreCamera{
    if(_resetIsRunning){
        return;
    }
    _resetIsRunning = YES;

    [self setAFAELock:NO];

    CGPoint location = self.boundsCenter;
    [self beginFocusPoint:location];
    [self beginExposurePoint:location];

    Weaks
    [[STElieCamera sharedInstance] unlockRequestFocus];
    [[STElieCamera sharedInstance] unlockRequestExposure];

    void(^completeRequest)(void) = ^{
        Strongs
        [Wself endAndMarkFocusPoint:location];
        [Wself endAndMarkExposurePoint:location];

        Sself->_resetIsRunning = NO;
    };
    if(ignoreCamera){
        completeRequest();
        [[STElieCamera sharedInstance] cancelRequestFocus];
        [[STElieCamera sharedInstance] requestContinuousFocusWithCenter:YES completion:nil];
    }else{
        [[STElieCamera sharedInstance] requestContinuousFocusWithCenter:YES completion:completeRequest];
    }

    self.afAELockButton.animatableVisible = NO;

    [self disableExposure];
}

- (void)updateControlViewsState:(BOOL)useForCamera{
    if(useForCamera){
        [self addCameraControlsView];
        [self removePreviewControlsView];

    }else{
        [self removeCameraControlsView];
        [self addPreviewControlsView];
    }

    [self addFocusPointView];

    //set visible
    [self initControlsVisibles:useForCamera];

    //set interaction
    [self setInteraction:useForCamera];
}

#pragma mark visible controls
- (void)setVisibleControl:(BOOL)visibleControl {
    //NOTE: UIBlurEffect has some bugs, when visible = NO or alpha = 0. So it resolved by scaleXY =0
    if(visibleControl){
        self.currentControlView.alpha = .1;
        self.currentControlView.easeInEaseOut.alpha = 1;
        self.currentControlView.scaleXYValue = 1;

        self.focusPointerView.alpha = .1;
        self.focusPointerView.easeInEaseOut.alpha = 1;
        self.focusPointerView.scaleXYValue = 1;

    }else{
        [self.currentControlView pop_removeAllAnimations];
        self.currentControlView.scaleXYValue = 0;

        [self.focusPointerView pop_removeAllAnimations];
        self.focusPointerView.scaleXYValue = 0;
    }
    self.currentControlView.userInteractionEnabled = visibleControl;

    _visibleControl = visibleControl;
}

- (void)setFocusPointerCenter:(CGPoint)centerPoint{
    self.focusPointerView.center = centerPoint;
    if(self.verticalFocusPointerView.visible){
        self.verticalFocusPointerView.center = CGPointMake(self.width/2, centerPoint.y);
    }
}

#pragma mark Filter
- (void)clearFilterCollectionView; {
    [self clearAllInteractions];
    [_filterCollectionView removeFromSuperview];
    _filterCollectionView = nil;
}

- (iCarousel *)iCarouselView; {
    return _filterCollectionView;
}

- (UIView *)contentView {
    return [self iCarouselView];
}

#pragma mark BackgroundView
- (void)clearBackgroundView{
    [_backgroundView clearAllOwnedImagesIfNeededAndRemoveFromSuperview:NO];
}

- (void)addBackgroundView:(BOOL)userForCamera{
    CGFloat downScaleRatio = 2;
    CGFloat verticalRatio = ceil([STPhotoSelector sharedInstance].height/[STElieCamera sharedInstance].outputScreenSize.height);
    if(!_backgroundView){
        GPUImageView * activeBackgroundView = [[GPUImageView alloc] initWithSize:CGSizeByScale([STElieCamera sharedInstance].outputScreenSize,1/downScaleRatio)];
        activeBackgroundView.contentMode = UIViewContentModeScaleToFill;
        [self insertSubview:activeBackgroundView atIndex:0];
        [activeBackgroundView centerToParent];
        activeBackgroundView.scaleX = downScaleRatio;
        activeBackgroundView.scaleY = downScaleRatio * verticalRatio;
        activeBackgroundView.y += [STElieStatusBar sharedInstance].layoutHeight / verticalRatio;
        activeBackgroundView.userInteractionEnabled = NO;
        [activeBackgroundView st_coverBlur:NO styleDark:NO completion:nil];
        _backgroundView = activeBackgroundView;
    }

    if(userForCamera){
        _backgroundImageOverlayView.image = nil;
        [_backgroundImageOverlayView removeFromSuperview];

        [[STElieCamera sharedInstance] addTarget:_backgroundView];

    }else{
        [[STElieCamera sharedInstance] removeTarget:_backgroundView];

        //overlay image
        if(!_backgroundImageOverlayView){
            _backgroundImageOverlayView = [[UIImageView alloc] initWithSize:CGSizeByScale([STElieCamera sharedInstance].outputScreenSize,1/downScaleRatio)];
            _backgroundImageOverlayView.contentMode = UIViewContentModeScaleToFill;
        }
        _backgroundImageOverlayView.image = [[[STPhotoSelector sharedInstance].previewTargetPhotoItem previewImage] brightenWithValue:-60];
        [_backgroundView insertSubview:_backgroundImageOverlayView belowSubview:[_backgroundView st_coveredView]];
    }
}

#pragma mark Focus Point
- (void)addFocusPointView{
    Weaks
    /*
     * Focus Pointer
     */
    if(!self.pointerLayer){
        self.pointerLayer = [STViewFinderPointLayer layerWithSize:CGSizeMakeValue([STStandardLayout widthFocusPointLayer])];
        self.pointerLayer.fillColor = [[UIColor clearColor] CGColor];
        [self.pointerLayer setRasterize];
        self.focusPointerView = [self addMaskedEffectLayer:self.pointerLayer style:UIBlurEffectStyleLight subviewsForVibrancy:nil];
        self.focusPointerCenter = self.center;
    }

    /*
     * Vertical Focus Pointer
     */

    if(!_useForCamera){
        if(STPostFocusModeVertical3Points ==[self currentFocusMode]){
            if(!self.verticalFocusPointerView){
                self.verticalFocusPointerView = [SVGKFastImageView viewWithImageNamed:[R bg_viewfinder_postfocus_v3point_line] sizeWidth:self.width];
                [_previewControlView addSubview:self.verticalFocusPointerView];
            }
            self.verticalFocusPointerView.alpha = .5;
        }
    }
}

#pragma mark PreviewMode Controls

- (UIView *)currentControlView {
    if(_cameraControlView.visible){
        return _cameraControlView;
    }
    if(_previewControlView.visible){
        return _previewControlView;
    }
    return nil;
}


NSString * const TimerIdForEditControls = @"finished_post_focusing";
- (void)addPreviewControlsView{
    Weaks
    if(_previewControlView){
        _previewControlView.visible = YES;
        _previewControlView.userInteractionEnabled = YES;

        //return
        return;
    }

    _previewControlView = [[STUIView alloc] initWithFrame:[self st_originClearedBounds]];
    [_previewControlView setTouchInsidePolicy:STUIViewTouchInsidePolicyContentInside];
    [self addSubview:_previewControlView];


    CGFloat padding = 10;


    //Lens Position Control
    self.postFocusSlider = [[STStandardPointableSlider alloc] initWithSize:CGSizeMake(self.width/2,STStandardLayout.heightOverlayHorizontal)];
    [self.postFocusSlider setProgress:.5 animated:NO];
    [self.postFocusSlider.layer setRasterize];
    self.postFocusSlider.iconViewOfMinimumSide = [SVGKFastImageView viewWithImageNamed:[R ico_landscape] sizeValue:15];
    self.postFocusSlider.iconViewOfMaximumSide = [SVGKFastImageView viewWithImageNamed:[R ico_macro] sizeValue:16];
    self.postFocusSliderView = [_previewControlView addMaskedEffectView:self.postFocusSlider style:UIBlurEffectStyleLight subviewsForVibrancy:nil];
    self.postFocusSliderView.frame = CGRectInset(self.postFocusSliderView.frame, -30, -10);
    [self.postFocusSliderView centerToParent];
    self.postFocusSlider.layer.position = self.postFocusSliderView.boundsCenter;
    self.postFocusSliderView.centerY = self.boundsHeight-padding-self.postFocusSlider.boundsHeightHalf;

    /*
     * Lens Position
     */
    CGFloat rmag = .2;
    [self.postFocusSliderView whenPanAsSlide:nil direction:STSlideAllowedDirectionHorizontal started:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf) {
        [self _setPostFocusSliding:NO];

        [Wself st_clearPerformOnceAfterDelay:TimerIdForEditControls];

    } changed:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf, CGFloat distance, CGPoint movedOffset, CGFloat distanceReachRatio, STSlideDirection direction, BOOL confirmed) {
        [self _setPostFocusSliding:YES];

        CGFloat progress = CLAMP(Wself.postFocusSlider.progress+(movedOffset.x/self.postFocusSlider.boundsWidth), 0, 1);
//        if(fabs(distanceReachRatio)<=.11){
//            progress = .5;
//        }

        self.postFocusSliderValue = progress;

    } ended:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf, STSlideDirection direction, BOOL confirmed) {
        [self st_performOnceAfterDelay:TimerIdForEditControls interval:.4 block:^{
            [self _setPostFocusSliding:NO];
        }];
    }];

    [self.postFocusSliderView.layer setRasterize];

//    self.postFocusSliderValue = _postFocusSliderValue;
//    self.postFocusSlider.progressOfPointer = _postFocusSliderValue;
}

- (void)setControlStateByCurrentPostFocusMode{

}

#pragma mark PostFocus - LensPosition
- (void)setPostFocusSliderValue:(CGFloat)postFocusSliderValue {
    if(_postFocusSliderValue==postFocusSliderValue){
        return;
    }

    [self willChangeValueForKey:@keypath(self.postFocusSliderValue)];
    _postFocusSliderValue = postFocusSliderValue;
    [self didChangeValueForKey:@keypath(self.postFocusSliderValue)];

    [self.postFocusSlider setProgress:_postFocusSliderValue animated:NO];
}

- (void)setPostFocusSliderValueWithAnimation:(CGFloat)postFocusSliderValue {
    _postFocusSliderValue = postFocusSliderValue;
    [self.postFocusSlider setProgress:_postFocusSliderValue animated:YES];
}

- (void)setPostFocusSliderPointingValue:(CGFloat)postFocusSliderPointingValue {
    _postFocusSliderPointingValue = postFocusSliderPointingValue;
    self.postFocusSlider.progressOfPointer = _postFocusSliderPointingValue;
}

- (void)_setPostFocusSliding:(BOOL)sliding{
    if(_postFocusSliding==sliding){
        return;
    }
    [self willChangeValueForKey:@keypath(self.postFocusSliding)];
    _postFocusSliding = sliding;
    [self didChangeValueForKey:@keypath(self.postFocusSliding)];
}

#pragma mark PostFocus - FocusPoints

- (void)setPostFocusPointOfInterestValue:(CGPoint)postFocusPointOfInterestValue {
    if(CGPointEqualToPoint(_postFocusPointOfInterestValue,postFocusPointOfInterestValue)){
       return;
    }
    self.focusPointerCenter = CGPointMake(self.width*postFocusPointOfInterestValue.x, self.height*postFocusPointOfInterestValue.y);

    [self willChangeValueForKey:@keypath(self.postFocusPointOfInterestValue)];
    _postFocusPointOfInterestValue = postFocusPointOfInterestValue;
    [self didChangeValueForKey:@keypath(self.postFocusPointOfInterestValue)];
}

- (void)removePreviewControlsView{
    [self st_clearPerformOnceAfterDelay:TimerIdForEditControls];

    _previewControlView.visible = NO;
    _previewControlView.userInteractionEnabled = NO;

//    [self.exposureSliderView whenPan:nil];
//    self.exposureSliderView = nil;
//    self.exposureSlider = nil;
}

#pragma mark Visible Controls
- (void)initControlsVisibles:(BOOL)useForCamera {
    [self setVisibleControl:YES];

    self.afAELockButton.visible = NO;
    self.zoomProgressBarEffectView.visible = NO;
    if(useForCamera){
        self.focusPointerView.visible = YES;
        self.postFocusSliderView.visible = [STGIFCApp postFocusAvailable];
        self.verticalFocusPointerView.visible = NO;

    }else{
        STPhotoItem * currentPhotoItem = [STPhotoSelector sharedInstance].previewTargetPhotoItem;
        if(STCapturedImageSetTypePostFocus==currentPhotoItem.sourceForCapturedImageSet.type){
            self.postFocusSliderView.visible = YES;

            //visible focus pointer view
            switch ([currentPhotoItem.sourceForCapturedImageSet postFocusMode]){
                case STPostFocusMode5Points:
                case STPostFocusModeVertical3Points:
                    self.focusPointerView.visible = YES;
                    break;
                default:
                    self.focusPointerView.visible = NO;
                    break;
            }

            if(self.focusPointerView.visible){
                CGPoint initialFocusPoint = [[currentPhotoItem.sourceForCapturedImageSet.focusPointsOfInterestSet st_objectOrNilAtIndex:currentPhotoItem.sourceForCapturedImageSet.indexOfFocusPointsOfInterestSet] CGPointValue];
                self.focusPointerCenter = CGPointMake(self.width*initialFocusPoint.x, self.height*initialFocusPoint.y);
            }

            //visible vertical focus pointer
            switch ([currentPhotoItem.sourceForCapturedImageSet postFocusMode]){
                case STPostFocusModeVertical3Points:{
                    self.verticalFocusPointerView.visible = YES;
                    NSValue * focusedPointValue = [currentPhotoItem.sourceForCapturedImageSet.focusPointsOfInterestSet st_objectOrNilAtIndex:currentPhotoItem.sourceForCapturedImageSet.indexOfFocusPointsOfInterestSet];
                    if(focusedPointValue){
                        self.verticalFocusPointerView.y = self.height*[focusedPointValue CGPointValue].y;
                    }else{
                        [self.verticalFocusPointerView centerToParentVertical];
                    }
                }
                    break;
                default:
                    self.verticalFocusPointerView.visible = NO;
                    break;
            }

            /*
             * visible iconview
             */
            if(currentPhotoItem.origin != STPhotoItemOriginUndefined){
                if([STApp screenFamily] > STScreenFamily35){
                    [currentPhotoItem presentIcon:_previewControlView];
                }
            }else{
                [currentPhotoItem unpresentIcon:_previewControlView];
            }

        } else{
            [currentPhotoItem unpresentIcon:_previewControlView];

            self.postFocusSliderView.visible = NO;
            self.focusPointerView.visible = NO;
            self.verticalFocusPointerView.visible = NO;
        }
    }
}

- (void)setAFAELock:(BOOL)lock{
    [self willChangeValueForKey:@keypath(self.lockAFAE)];
    _lockAFAE = lock;
    [self didChangeValueForKey:@keypath(self.lockAFAE)];
}

- (void)removeCameraControlsView {
    _cameraControlView.visible = NO;
    _cameraControlView.userInteractionEnabled = NO;

//    [_cameraControlView removeAllMaskedEffectViews];
//    [_cameraControlView st_removeAllSubviews];

//    self.focusPointerView = nil;
//    self.pointerLayer = nil;
//
//    [self.exposureSliderView whenPan:nil];
//    self.exposureSliderView = nil;
//    self.exposureSlider = nil;
//
//    [self.afAELockButton clearAllOwnedImagesIfNeededAndRemoveFromSuperview:YES];
//    self.afAELockButton = nil;
//    self.zoomProgressBarEffectView = nil;
//    self.zoomProgressBar = nil;
//    self.zoomProgressLabel = nil;
}

- (void)setViewFinderType:(STViewFinderType)type{
    if(type==STViewFinderTypeNone){
        self.viewFinderView.visible = NO;

    }else{
        NSString * imageName = nil;
        switch (type){
            case STViewFinderTypePostFocus5Point:
                imageName = [R bg_viewfinder_postfocus_5point];
                break;
            case STViewFinderTypePostFocusModeVertical3Points:
                imageName = [R bg_viewfinder_postfocus_v3point];
                break;
            case STViewFinderTypePostFocusFullRangeDefault:
                imageName = [R bg_viewfinder_fullrange_default];
                break;
            default:
                NSAssert(NO,@"not supported");
                break;
        }

        //view finder
        if(!self.viewFinderView){
            self.viewFinderView = [[UIImageView alloc] initWithSize:self.size];
            [_cameraControlView insertSubview:self.viewFinderView atIndex:0];
        }

        ((UIImageView *)self.viewFinderView).image = [self st_cachedImage:[@"STViewFinder" st_add:imageName] useDisk:YES init:^UIImage * {
            return [[SVGKImage imageNamedNoCache:imageName widthSizeWidth:self.width] UIImage];
        }];
        self.viewFinderView.userInteractionEnabled = NO;
        self.viewFinderView.alpha = .35f;
    }
}

- (void)addCameraControlsView {
    if(_cameraControlView){
        _cameraControlView.visible = YES;
        _cameraControlView.userInteractionEnabled = YES;
        return;
    }

    _cameraControlView = [[STUIView alloc] initWithFrame:[self st_originClearedBounds]];
    [_cameraControlView setTouchInsidePolicy:STUIViewTouchInsidePolicyContentInside];
    [self addSubview:_cameraControlView];

    CGFloat padding = 10;

    Weaks
    //AF/AE Lock
    UIView * lockIcon = [UIView st_createViewFromPresentableObject:[SVGKImage UIImageNamed:[R ico_manual_af_lock] withSizeWidth:10]];
    [lockIcon sizeToFit];
    UILabel * afAeLockLabel = [STStandardUIFactory labelBulletLighten];
    afAeLockLabel.text = @"AF/AE LOCK";
    afAeLockLabel.textAlignment = NSTextAlignmentCenter;
    [afAeLockLabel sizeToFit];

    CAShapeLayer * bgShape = [[CAShapeLayer roundRect:[STStandardLayout sizeOverlayHorizontal]] clearLineWidthAndRasterizeDoubleScaled];

    self.afAELockButton = [_cameraControlView addMaskedEffectLayer:bgShape style:UIBlurEffectStyleExtraLight subviewsForVibrancy:@[lockIcon, afAeLockLabel]];

    CGFloat _padding = (bgShape.pathWidth - (lockIcon.width + 3 + afAeLockLabel.width))*.5f;
    [lockIcon centerToParent];
    [afAeLockLabel centerToParent];
    afAeLockLabel.right = bgShape.pathWidth-_padding;
    lockIcon.x = _padding;

    self.afAELockButton.bottom = self.boundsHeight-padding;
    self.afAELockButton.centerX = self.centerX;
    self.afAELockButton.visible = NO;
    [self.afAELockButton whenTapped:^{
        _separateAFAEBegan = NO;
        [Wself resetAFAE];
    }];


    //Zoom HUD
    self.zoomProgressBar = [[M13ProgressViewBorderedCenterBar alloc] initWithSize:[STStandardLayout sizeOverlayMidLongHorizontal]];
    self.zoomProgressBar.borderWidth = 1;
    self.zoomProgressBar.cornerType = M13ProgressViewBorderedBarCornerTypeCircle;
    self.zoomProgressBar.cornerRadius = self.zoomProgressBar.boundsHeightHalf;
    [self.zoomProgressBar setProgress:[STElieCamera sharedInstance].zoomFactor animated:NO];

    self.zoomProgressLabel = [STStandardUIFactory labelBulletLighten];
    self.zoomProgressLabel.text = @"10.0x";
    self.zoomProgressLabel.textAlignment = NSTextAlignmentCenter;

    self.zoomProgressBarEffectView = [_cameraControlView addMaskedEffectView:self.zoomProgressBar style:UIBlurEffectStyleExtraLight subviewsForVibrancy:@[self.zoomProgressLabel]];

    [self.zoomProgressLabel sizeToFit];
    [self.zoomProgressLabel centerToParent];
    [self.zoomProgressBar centerToParent];

    [self.zoomProgressBarEffectView centerToParent];
    self.zoomProgressBarEffectView.y = padding;

    //Exposure Control
    self.exposureSlider = [[STStandardPointableSlider alloc] initWithSize:CGSizeMake(self.width/2,STStandardLayout.heightOverlayHorizontal)];
    [self.exposureSlider setProgress:.5 animated:NO];
    [self.exposureSlider.layer setRasterize];
    self.exposureSlider.iconViewOfMinimumSide = [SVGKFastImageView viewWithImageNamed:[R ico_exposure_min] sizeValue:15];
    self.exposureSlider.iconViewOfMaximumSide = [SVGKFastImageView viewWithImageNamed:[R ico_exposure_max] sizeValue:16];
    self.exposureSlider.progressOfPointer = .5;

    self.exposureSliderView = [_cameraControlView addMaskedEffectView:self.exposureSlider style:UIBlurEffectStyleLight subviewsForVibrancy:nil];
    self.exposureSliderView.frame = CGRectInset(self.exposureSliderView.frame, -30, -10);
    [self.exposureSliderView centerToParent];
    self.exposureSlider.layer.position = self.exposureSliderView.boundsCenter;

    self.exposureSliderView.centerY = self.boundsHeight-padding-self.exposureSlider.boundsHeightHalf;

    //pan slider
    [self.exposureSliderView whenPanAsSlide:nil direction:STSlideAllowedDirectionHorizontal started:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf) {
        Strongs
        [Sself setAFAELock:YES];

        [Wself st_clearPerformOnceAfterDelay:@"finish_exposure_layer"];

        [Wself.pointerLayer finishFocusing];
        [Wself.pointerLayer startExposure];

    } changed:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf, CGFloat distance, CGPoint movedOffset, CGFloat distanceReachRatio, STSlideDirection direction, BOOL confirmed) {
        CGFloat progress = CLAMP(Wself.exposureSlider.progress+(movedOffset.x/self.exposureSlider.boundsWidth), 0, 1);
        if(fabs(distanceReachRatio)<=.06){
            progress = .5;
        }

        [Wself.exposureSlider setProgress:progress animated:NO];

        Wself.pointerLayer.exposureIntensityValue = 1-progress;

        CGFloat bias = progress>=.5f ? AGKRemap(progress, .5f, 1, 0, [STElieCamera sharedInstance].maxAdjustingExposureBias) : AGKRemap(progress, 0, .5f, [STElieCamera sharedInstance].minAdjustingExposureBias, 0);

        [STElieCamera sharedInstance].exposureBias = bias;

    } ended:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf, STSlideDirection direction, BOOL confirmed) {
        [STStandardUX revertStateAfterShortDelay:@"finish_exposure_layer" block:^{
            Strongs
            [Sself setAFAELock:NO];
            [Sself.pointerLayer finishExposure];
        }];
    }];


    [self.exposureSliderView.layer setRasterize];

    [self disableExposure];
}

#pragma mark User Interaction
- (void)clearAllInteractions {
    [_tapAndPinchTarget whenTappedParams:nil];
    [_tapAndPinchTarget whenDoubleTappedParams:nil];
    [_tapAndPinchTarget whenLongTapped:nil];
    [_tapAndPinchTarget whenPinch:nil];
    [_tapAndPinchTarget whenForceTouched:nil];
    _tapAndPinchTarget = nil;

    [_panTarget whenPan:nil];
    _panTarget = nil;
}

- (void)setInteraction:(BOOL)useForCamera; {
    [self clearAllInteractions];

    _tapAndPinchTarget = [STGIFCApp isInSimulator] ? _simulationCameraView : _filterCollectionView.contentView;
    _panTarget = [STGIFCApp isInSimulator] ? _simulationCameraView : _filterCollectionView;
    _resetIsRunning = NO;

    if(useForCamera){
        [self setAFAELock:NO];

        Weaks
        [self setInteractionForAFAE];

        [self setInteractionForZoom];

        [self subscribeWhenUsingCamera];

        if([STGIFCApp isInSimulator]){
            _simulationCameraView.visible = YES;
        }

        [self resetAFAE:YES];

    }else{
        [self setInteractionForPostFocus];

        [self unsubscribeWhenUsingCamera];

        if([STGIFCApp isInSimulator]){
            _simulationCameraView.visible = NO;
        }
    }
}

#pragma mark AFAE
- (void)setInteractionForAFAE {
    Weaks
    //tap
    // WARN : iCarousel 내에 tap을 지정하고 있지만, whenTappedParams을 호출하면 _removeGestureRecognizer를 먼저 호출하므로 기존것이 무시됨.
    UITapGestureRecognizer * singleTap = [_tapAndPinchTarget whenTappedParams:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if([STGIFCApp postFocusAvailable]) {
            [self enableExposure];

        }else{
            [Wself setAFAELock:NO];

            if (_separateAFAEBegan) {
                [Wself AF:location];
                _separateAFAEBegan = NO;
            } else {
                [Wself AFAE:location];
            }
        }

    }];
    singleTap.delaysTouchesEnded = NO;

    //double tap
//    UITapGestureRecognizer * doubleTap = [_tapAndPinchTarget whenDoubleTappedParams:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
//        [self setAFAELock:NO];
//        _separateAFAEBegan = YES;
//
//        [Wself AE:location];
//    }];
//    [singleTap requireGestureRecognizerToFail:doubleTap];

    //long tap
    [_tapAndPinchTarget whenLongTappedParams:^(UILongPressGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if([STGIFCApp postFocusAvailable]){
            [sender bk_cancel];
            return;
        }

        [Wself setAFAELock:YES];
        _separateAFAEBegan = NO;

        [Wself AFAE_lock:location];
    }];

}

#pragma mark Zoom
- (void)setInteractionForZoom {
    __block CGFloat initialScale = [STElieCamera sharedInstance].zoomFactor;
    __block CGFloat currentZoomScale = initialScale;

    /*
        pinch
     */
    Weaks
    [_tapAndPinchTarget whenPinch:^(UIPinchGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if ([sender numberOfTouches] < 2)
            return;

        if (sender.state == UIGestureRecognizerStateBegan) {
            initialScale = [STElieCamera sharedInstance].zoomFactor;
        }

        BOOL zoomIn = sender.scale < 1.0;

        currentZoomScale = [Wself changeZoomFactor:initialScale * sender.scale smooth:zoomIn];
    }];

    /*
        pan
     */
    __block BOOL finishedZoomRange = currentZoomScale ==1.0;
    CGFloat heightForPanTarget = _panTarget.height;
    [_panTarget whenPanAsSlideVertical:nil started:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf) {

        currentZoomScale = [STElieCamera sharedInstance].zoomFactor;

    } changed:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf, CGFloat distanceFromCenter, CGPoint movedOffset, CGFloat distanceReachRatio, STSlideDirection direction, BOOL confirmed) {
        BOOL zoomIn = movedOffset.y > 0;
        Strongs
        if (!Sself->_panTarget) {
            return;
        }

        if (!zoomIn && finishedZoomRange) {
            /*
             * 패닝이 끝에 도달했을떄 액션 -> 편집 액션 시작으로 해도 좋을듯
             */
//            [[STUserActor sharedInstance] act:STUserActionChangeCameraMode object:@(STCameraModeManualExitAndPause)];
            return;
        }

        if (zoomIn) {
            finishedZoomRange = NO;
        }

        CGFloat zoomScaleOffset = (movedOffset.y / heightForPanTarget) * (4 * currentZoomScale);
        if (isnan(zoomScaleOffset)) {
            return;
        }

        currentZoomScale = [Wself changeZoomFactor:currentZoomScale + zoomScaleOffset smooth:NO];


    } ended:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf, STSlideDirection direction, BOOL confirmed) {

        finishedZoomRange = currentZoomScale == 1.0;

        if ([@"1.0" isEqualToString:[@(currentZoomScale) st_decimalPointedAsString:1]] && currentZoomScale > 1.f) {
            [self changeZoomFactor:1 smooth:YES];
        }
    }];
}

- (CGFloat)changeZoomFactor:(CGFloat)scale smooth:(BOOL)smooth{
    CGFloat maxZoomFactor = [STElieCamera sharedInstance].maxZoomFactor;
    scale = CLAMP(scale, 1.f, maxZoomFactor);

    if([STElieCamera sharedInstance].zoomFactor!=scale){
        if(smooth){
            [STElieCamera sharedInstance].zoomFactorSmoothly = scale;
        }else{
            [STElieCamera sharedInstance].zoomFactor = scale;
        }

        BOOL filterSelecting = _filterCollectionView.scrollOffset!=0;
        BOOL zoomChanging = scale>1.0;

        filterSelecting || zoomChanging ? [[STMainControl sharedInstance] showContextNeededResetButton] : [[STMainControl sharedInstance] hideContextNeededResetButton];
    }

    CGFloat normalizedZoomFactor = AGKRemap(scale, 1, [STElieCamera sharedInstance].maxZoomFactor, 0, 1);//NORMALIZE(scale, 1.f, [STElieCamera sharedInstance].maxZoomFactor);
    self.zoomProgressBarEffectView.animatableVisible = normalizedZoomFactor>0;
    [self.zoomProgressBar setProgress:AGKRemap(1-normalizedZoomFactor, 1, 0, 1, .18f) animated:smooth];

    self.zoomProgressLabel.text = [scale==maxZoomFactor ? [@(scale) stringValue] : [@(scale) st_firstDecimalPointedAsString] st_add:@"x"];

    return scale;
}

#pragma mark Listen From Camera
- (void)subscribeWhenUsingCamera {
    Weaks
    //subject area
    [[STElieCamera sharedInstance] removeSubjectAreaChangeMonitor:self];
    [[STElieCamera sharedInstance] addSubjectAreaChangeMonitor:self block:^{
        if([[STElieCamera sharedInstance] isPositionFront]){
            return;
        }

        _separateAFAEBegan = NO;

        //user already setted lock mode
        if(_lockAFAE){
            return;
        }

        //user already changed exposure
        if([STElieCamera sharedInstance].exposureBias!=0){
            return;
        }

        //do reset
        [Wself resetAFAE];
    }];
//    [[STElieCamera sharedInstance] startMonitoringSubjectAreaDidChanged];

    //taken manual camera
    [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueue:self forName:STNotificationManualCapture usingBlock:^(NSNotification *note, id observer) {
        [Wself.pointerLayer setOutterCicleFill:YES];
        [Wself st_performOnceAfterDelay:@"tick_after_capture" interval:.2 block:^{
            [Wself.pointerLayer setOutterCicleFill:NO];

            [Wself st_performOnceAfterDelay:@"tick_after_start_capture" interval:.2 block:^{
                Strongs
                [Sself beginFocusPoint:Sself.focusPointerView.center];
            }];
        }];
    }];

    //finished take maual camera
    [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueue:self forName:STNotificationManualCaptureFinished usingBlock:^(NSNotification *note, id observer) {
        [Wself endFocusPoint];
    }];

    [[STElieCamera sharedInstance] whenValueOf:@keypath([STElieCamera sharedInstance].changingFacingCamera) id:@"STPreview.observe.changingFacingCamera" changed:^(id value, id _weakSelf) {
        [Wself resetAFAE];
    }];

    [[STGIFCAppSetting get] whenValueOf:@keypath([STGIFCAppSetting get].postFocusMode) id:@"STPreview.observe.postFocusMode" changed:^(id value, id _weakSelf) {
        switch ((STPostFocusMode) [value integerValue]) {
            case STPostFocusMode5Points:
                self.viewFinderType = STViewFinderTypePostFocus5Point;
                break;
            case STPostFocusModeVertical3Points:
                self.viewFinderType = STViewFinderTypePostFocusModeVertical3Points;
                break;
            case STPostFocusModeFullRange:
                self.viewFinderType = STViewFinderTypePostFocusFullRangeDefault;
                break;
            case STPostFocusModeNone:
                self.viewFinderType = STViewFinderTypeNone;
                break;
            default:
                break;
        }
    } getInitialValue:YES];
}

- (void)unsubscribeWhenUsingCamera {
    [[STElieCamera sharedInstance] stopMonitoringSubjectAreaDidChanged];

    [[STElieCamera sharedInstance] removeSubjectAreaChangeMonitor:self];

    [[STElieCamera sharedInstance] whenValueOf:@keypath([STElieCamera sharedInstance].changingFacingCamera) id:@"STPreview.observe.changingFacingCamera" changed:nil];

    [[STGIFCAppSetting get] whenValueOf:@keypath([STGIFCAppSetting get].postFocusMode) id:@"STPreview.observe.postFocusMode" changed:nil];

    [[NSNotificationCenter defaultCenter] st_removeObserverWithMainQueue:self forName:STNotificationManualCapture];

    [[NSNotificationCenter defaultCenter] st_removeObserverWithMainQueue:self forName:STNotificationManualCaptureFinished];
}

- (STPostFocusMode)currentFocusMode{
    STPostFocusMode focusMode;
    if(_useForCamera){
        focusMode = (STPostFocusMode) STGIFCAppSetting.get.postFocusMode;
    }else{
        focusMode = [STPhotoSelector sharedInstance].previewTargetPhotoItem.sourceForCapturedImageSet.postFocusMode;
    }
    return focusMode;
}

#pragma mark Display
- (void)AF:(CGPoint) location{
    [self beginFocusPoint:location];

    Weaks
    [[STElieCamera sharedInstance] requestSingleFocus:self.bounds pointInRect:location syncWithExposure:NO completion:^{
        [Wself endAndHoldFocusPoint:location];
    }];

    self.afAELockButton.visible = NO;
}

- (void)AFAE:(CGPoint) location{
    [self beginFocusPoint:location];
    [self beginExposurePoint:location];

    Weaks
    [[STElieCamera sharedInstance] requestSingleFocus:self.bounds pointInRect:location completion:^{
        [Wself endAndMarkFocusPoint:location];
        [Wself endAndMarkExposurePoint:location];
    }];

    self.afAELockButton.visible = NO;

    [self enableExposure];
}


- (void)AFAE_lock:(CGPoint) location{
    [self beginFocusPoint:location];
    [self beginExposurePoint:location];

    Weaks
    [[STElieCamera sharedInstance] unlockRequestFocus];
    [[STElieCamera sharedInstance] unlockRequestExposure];
    [[STElieCamera sharedInstance] requestSingleFocus:self.bounds pointInRect:location completion:^{
        [Wself endAndMarkFocusPoint:location];
        [Wself endAndMarkExposurePoint:location];
    }];
    [[STElieCamera sharedInstance] lockRequestFocus];
    [[STElieCamera sharedInstance] lockRequestExposure];

    self.afAELockButton.animatableVisible = YES;

    [self disableExposure];
}

- (void)AE:(CGPoint) location{
    [self beginExposurePoint:location];

    Weaks
    [[STElieCamera sharedInstance] requestExposure:self.bounds pointInRect:location continuous:NO completion:^{
        [Wself endAndMarkExposurePoint:location];
    }];

    self.afAELockButton.animatableVisible = NO;
}

// focus
- (void)beginFocusPoint:(CGPoint)point {
    self.focusPointerCenter = point;

    [self.pointerLayer startFocusing];

    if([STGIFCApp isInSimulator]){
        [self st_performOnceAfterDelay:2 block:^{
            [self endFocusPoint];
        }];
    }
}

- (void)endFocusPoint{
    if(_lockAFAE){
        [self.pointerLayer finishFocusingWithLocked];
    } else{
        [self.pointerLayer finishFocusing];
    }
}

- (void)endAndHoldFocusPoint:(CGPoint)point {
    [self endFocusPoint];
}

- (void)endAndMarkFocusPoint:(CGPoint)point {
    [self endFocusPoint];
}

// exposure
- (void)enableExposure{
    self.exposureSliderView.animatableVisible = YES;
    [self resetExposure];
}

- (void)disableExposure{
    self.exposureSliderView.visible = NO;
    [self resetExposure];
}

- (void)resetExposure{
    [self.pointerLayer finishExposure];
    [self.exposureSlider setProgress:.5 animated:YES];
    [STElieCamera sharedInstance].exposureBias = 0;
}

- (void)beginExposurePoint:(CGPoint)point {
//    [self.pointerLayer startExposure];
}

- (void)endAndHoldExposurePoint:(CGPoint)point {
//    [self.pointerLayer finishExposure];
}

- (void)endAndMarkExposurePoint:(CGPoint)point {
//    [self.pointerLayer finishExposure];
}

#pragma mark Post Focus
- (void)setInteractionForPostFocus{
    // WARN : iCarousel 내에 tap을 지정하고 있지만, whenTappedParams을 호출하면 _removeGestureRecognizer를 먼저 호출하므로 기존것이 무시됨.
//    STContinuousForceTouchGestureRecognizer * recognizer = [_tapAndPinchTarget whenForceTouched:^(STContinuousForceTouchGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
//        //TODO: 포스 터치가 되면 해당 pointOfInterest 에 해당하는 포스 터치에 focusing 한다
//        //TODO: 포스 터치 프로그래스 인디케이터를 attach
//
//        if(sender.state == UIGestureRecognizerStateEnded){
//            [self setAFAELock:NO];
//            _separateAFAEBegan = NO;
//
//            [self beginFocusPoint:location];
//
//            [self setPostFocusPointOfInterestValue:CGPointMake(location.x/self.width,location.y/self.height)];
//
//            [self st_performOnceAfterDelay:.5 block:^{
//                [self endFocusPoint];
//            }];
//
//            self.afAELockButton.visible = NO;
//        }
//    }];
//    recognizer.triggeringForceTouchPressure = 0;
//    recognizer.minimumPressDuration = 0;
//    recognizer.delaysTouchesEnded = NO;

#pragma mark TutorialGuide - Focus Point
#if DEBUG
    BlockOnce(^{
        STGIFCAppSetting.get._confirmedTutorialPointedFocalPoint = NO;
    });
#endif
    BOOL focusGuideWasShowen = NO;
    if(!STGIFCAppSetting.get._confirmedTutorialPointedFocalPoint){
        STPostFocusMode focusMode = [self currentFocusMode];
        focusGuideWasShowen = !_useForCamera && (STPostFocusMode5Points == focusMode || STPostFocusModeVertical3Points == focusMode);
        if(focusGuideWasShowen){
            NSString * delayId = @"tutorial_touch_point_focus";
            [self st_performOnceAfterDelay:delayId interval:2 block:^{
                [self startTutorialAction];

                [[STMainControl sharedInstance] whenNewValueOnceOf:@keypath([STMainControl sharedInstance].mode) changed:^(id value, id _weakSelf) {
                    [self st_clearPerformOnceAfterDelay:delayId];
                    [self finishTutorialAction:NO];
                }];
            }];
        }
    }

    UITapGestureRecognizer * singleTap = [_tapAndPinchTarget whenTappedParams:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
#pragma mark TutorialGuide - Focus Point
        if(focusGuideWasShowen && !STGIFCAppSetting.get._confirmedTutorialPointedFocalPoint){
            [self finishTutorialAction:YES];
        }

        [self setAFAELock:NO];
        _separateAFAEBegan = NO;

        [self beginFocusPoint:location];
        
        switch([self currentFocusMode]){
            case STPostFocusModeVertical3Points:
                [self setPostFocusPointOfInterestValue:CGPointMake(.5f,location.y/self.height)];
                break;
            default:
                [self setPostFocusPointOfInterestValue:CGPointMake(location.x/self.width,location.y/self.height)];
                break;
        }
        
        [self st_performOnceAfterDelay:.5 block:^{
            [self endFocusPoint];
        }];

        self.afAELockButton.visible = NO;
    }];

    singleTap.delaysTouchesEnded = NO;
}


#pragma mark TutorialGuide - Focus Point
- (void)startTutorialAction{
    [[STElieStatusBar sharedInstance] message:NSLocalizedString(@"Click the area to adjust focus.",nil) showLogoAfterDelay:NO];
    [self.focusPointerView startAlphaBlinking];
    [self.verticalFocusPointerView startAlphaBlinking:.6 maxAlpha:.5f repeatCount:NSUIntegerMax];
}

- (void)finishTutorialAction:(BOOL)userConfirm{
    [[STElieStatusBar sharedInstance] message:nil];
    [self.focusPointerView stopAlphaBlinking];
    [self.verticalFocusPointerView stopAlphaBlinking];
    self.verticalFocusPointerView.alpha = .5;
    if(userConfirm){
        STGIFCAppSetting.get._confirmedTutorialPointedFocalPoint = YES;
        [STGIFCAppSetting.get synchronize];
    }
}
@end