//
// Created by BLACKGENE on 2014. 10. 13..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import "UIGestureRecognizer+BlocksKit.h"
#import "UIScrollView+AGK+Properties.h"
#import "STThumbnailGridView.h"
#import "STPhotoItem.h"
#import "STThumbnailGridViewCell.h"
#import "STMainControl.h"
#import "NSIndexPath+STIndexPathForSingleSection.h"
#import "STPhotoSelector.h"
#import "NSArray+BlocksKit.h"
#import "UIView+STUtil.h"
#import "NSObject+STUtil.h"
#import "STMotionScrollView.h"
#import "STElieStatusBar.h"
#import "STUserActor.h"
#import "STTimeOperator.h"
#import "NSObject+STPopAnimatableProperty.h"
#import "STStandardSimpleSlider.h"
#import "NSArray+STUtil.h"
#import "SFDYCIDebugMacro.h"
#import "STPermissionManager.h"
#import "STMotionScrollLivePhotoView.h"
#import "UITouchLongPressGestureRecognizer.h"
#import "SVGKImage.h"
#import "R.h"
#import "SVGKImage+STUtil.h"
#import "STStandardReachableButton.h"
#import "STLivePhotoView.h"
#import "NSObject+STThreadUtil.h"
#import "STApp+Logger.h"
#import "STGIFCAppSetting.h"
#import "STElieCamera.h"
#import "PHAsset+STUtil.h"
#import "STCapturedImageSetProtected.h"
#import "STCapturedImage.h"

@import AssetsLibrary;

#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnavailableInDeploymentTarget"
#define kHeaderId @"HeaderView"
#define kFooterId @"FooterView"
#define kCellId @"STThumbnailCellView"

@implementation STThumbnailGridView {
    CGPoint _lastScrollPosition;
    CGPoint _currentScrollPosition;
    CGRect _originalFrame;

    void(^_whenDidBatchUpdated)(BOOL finished);

    BOOL _startedPullToRefresh;

    STStandardSimpleSlider * _quickSliderPreviewView;

    UIImageView * _slideDownGuideView;
}

- (id)initWithFrame:(CGRect)frame; {
    _originalFrame = frame;

    NHBalancedFlowLayout *layout = [[NHBalancedFlowLayout alloc] init];
    layout.headerReferenceSize = CGSizeZero;
    layout.footerReferenceSize = CGSizeZero;
    layout.minimumLineSpacing = layout.minimumInteritemSpacing = 2;
    layout.sectionInset = UIEdgeInsetsZero;

    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {

        _items = [NSMutableArray array];
        _enabledCellAnimations = YES;

        [self registerClass:[STThumbnailGridViewCell class] forCellWithReuseIdentifier:kCellId];
        [self registerClass:[STThumbnailGridViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderId];
        [self registerClass:[STThumbnailGridViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterId];

        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.allowsMultipleSelection = YES;

        self.delegate = self;
        self.dataSource = self;

        self.contentInsetBottom = [STMainControl sharedInstance].height;

//        if([STGIFCApp isDebugMode] || STGIFCAppSetting.get.isFirstLaunch){
//            _slideDownGuideView = [SVGKImage UIImageViewNamed:[R slide_arrow_down_ios] withSizeWidth:[STStandardLayout widthSubSmall] color:nil degree:0];
//            _slideDownGuideView.alpha = [STStandardUI alphaForDimmingWeak];
//            _slideDownGuideView.y = [STStandardLayout widthSubAssistance];
//            [self addSubview:_slideDownGuideView];
//            [_slideDownGuideView centerToParentHorizontal];
//        }

        [(NHBalancedFlowLayout *) self.collectionViewLayout setPreferredRowSize:frame.size.height/4.6f];
    }
    return self;
}

- (void)didMoveToSuperview; {
    [super didMoveToSuperview];

    Weaks
    BlockOnce(^{
        [STTimeOperator st_performOnceAfterDelay:.2 block:^{
            [Wself addQuickViewGestures];
        }];
    });
}

- (void)setType:(STPhotoViewType)type{
    _type = type;
}

- (BOOL)isItemsEmpty {
    return self.items.count == 0;
}

#pragma mark override touches

- (void)_handleTouches:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(![STApp isForceTouchCompatible]){
        return;
    }

    for(UITouch * touch in touches){
        if(touch.force && [self isQuickPreviewing]){
            [self forceTouchToQuickPreview:touch];
            break;
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self _handleTouches:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self _handleTouches:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self _handleTouches:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self _handleTouches:touches withEvent:event];
    [super touchesCancelled:touches withEvent:event];
}

#pragma mark QuickPreview
static BOOL _quickPreviewing;
static CGFloat _quickPreviewTouchedForce;
static CGFloat _quickPreviewLivePhotoWasPlayed;
static CGPoint _quickPreviewTouchStartPointInContainer;

static STMotionScrollView *_quickPreviewView;
static UIView *_guideSliderView;
static UIImageView *_slideArrowUpView;
static UIImageView *_slideArrowDownView;
static STStandardReachableButton *_quickPreviewForceTouchIndicator;

static NSString * const QuickPreviewFakeImageViewTagName = @"transitionFromView";
static NSString * const QuickPreviewLivePhotoViewPlayingObserverId = @"livephotoviewplaying";
static CGFloat const QuickPreviewDecoBaseGap = 20;

- (STMotionScrollLivePhotoView *)quickPreviewLivePhotoViewOrNil{
    if([_quickPreviewView isKindOfClass:STMotionScrollLivePhotoView.class]){
        return (STMotionScrollLivePhotoView *) _quickPreviewView;
    }
    return nil;
}

- (UIView *)containerQuickPreview {
    static UIView * _targetContainerQuickPreviewView;
    BlockOnce(^{
        _targetContainerQuickPreviewView = [self st_rootUVC].view;
    });
    return _targetContainerQuickPreviewView;
}

- (void)forceTouchToQuickPreview:(UITouch *)touch {
    if(![STApp isForceTouchCompatible] || ![STApp isLivePhotoCompatible]){
        return;
    }

    /*
     * play LivePhoto
     */
    if(touch.phase == UITouchPhaseBegan){
        _quickPreviewTouchedForce = 0;
        _quickPreviewLivePhotoWasPlayed = NO;
    }

    /*
     * set indicator
     */
    CGFloat forceOffset = _quickPreviewTouchedForce-touch.force;
    STMotionScrollLivePhotoView * view = [self quickPreviewLivePhotoViewOrNil];
    BOOL forceForPlay = 3;

    if(!view.contentLivePhotoView.playing){
//        _quickPreviewForceTouchIndicator.reachedProgress = AGKRemapToZeroOneAndClamp(touch.force, 0,touch.maximumPossibleForce);
        _quickPreviewForceTouchIndicator.reachedProgress = AGKRemapToZeroOneAndClamp(touch.force, 0, forceForPlay);
    }

    if(touch.force>=1){
        view.contentLivePhotoView.repeats = touch.force > [STStandardUX touchForceThresholdToPlayLivePhoto];

        if(!_quickPreviewLivePhotoWasPlayed && _quickPreviewForceTouchIndicator.reachedProgress>.95/* && forceOffset < -.35*/){
            _quickPreviewLivePhotoWasPlayed = YES;
            [[view contentLivePhotoView] startPlayback];
        }

    }else{
        if(_quickPreviewLivePhotoWasPlayed){
            [[view contentLivePhotoView] stopPlayback];
            _quickPreviewLivePhotoWasPlayed = NO;
        }
    }

    _quickPreviewTouchedForce = touch.force;
}

- (void)forceTouchIndicatorReset {
    _quickPreviewForceTouchIndicator.outlineProgress = 0;
    _quickPreviewForceTouchIndicator.reachedProgress = 0;
    _quickPreviewForceTouchIndicator.visible = NO;
    _quickPreviewForceTouchIndicator.alpha = 0;
    [_quickPreviewForceTouchIndicator centerToParentHorizontal];
    _quickPreviewForceTouchIndicator.y = QuickPreviewDecoBaseGap * 3;
    [_quickPreviewForceTouchIndicator saveInitialLayout];
}

- (void)forceTouchIndicatorPlayingStateForLivePhotoViewer:(BOOL)playing{
    static CGFloat originalAlpha;
    if(!originalAlpha){
        originalAlpha = _quickPreviewForceTouchIndicator.currentButtonView.alpha;
    }

    if(playing){
        if(_quickPreviewForceTouchIndicator.reachedProgress<1){
            [UIView animateWithDuration:.3 animations:^{
                _quickPreviewForceTouchIndicator.reachedProgress = 1;
            } completion:nil];
        }
        [_quickPreviewForceTouchIndicator.currentButtonView animateWithReverse:@"alpha" to:[STStandardUI alphaForDimmingWeak] repeat:YES duration:.5 durationReverse:.5 springDamping:0 completion:nil];

        _quickPreviewForceTouchIndicator.outlineProgress = 0;
        [_quickPreviewForceTouchIndicator startAutoIncreasingOutlineProgress:3 performFirstCycleImmediately:NO];

        _quickPreviewForceTouchIndicator.spring.alpha = 1;

    }else{
        [_quickPreviewForceTouchIndicator.currentButtonView.layer removeAllAnimations];
        _quickPreviewForceTouchIndicator.currentButtonView.alpha = originalAlpha;
        [UIView animateWithDuration:.3 animations:^{
            _quickPreviewForceTouchIndicator.reachedProgress = 0;
        }];

        [_quickPreviewForceTouchIndicator stopAutoIncreasingOutlineProgress];
        _quickPreviewForceTouchIndicator.outlineProgress = 0;

        _quickPreviewForceTouchIndicator.spring.alpha = [STStandardUI alphaForDimming];
    }
}

- (void)attachQuickPreviewViewContent:(STPhotoItem *)photoItem view:(STMotionScrollView *)view{
    //set media
    if(photoItem.sourceForALAsset && (photoItem.mediaSubtypesForAsset & PHAssetMediaSubtypePhotoLive) && [self quickPreviewLivePhotoViewOrNil]){
        STMotionScrollLivePhotoView * scrollView = [self quickPreviewLivePhotoViewOrNil];
        if(!scrollView){
            return;
        }

        //set livephoto
        scrollView.assetAsLivePhoto = photoItem.sourceForAsset;

        //complete loaded livephoto
        Weaks
        [scrollView whenNewValueOnceOf:@keypath(scrollView.contentLivePhotoView) changed:^(STLivePhotoView * livePhotoView, id _weakSelf) {

            //attach 3D-Touch indicator
            if(!_quickPreviewForceTouchIndicator){
                STStandardReachableButton * button = [STStandardReachableButton subAssistanceBigSize];
                button.animationEnabled = YES;

                //play style
//                button.preferredIconImageRotationDegree = -90;
//                button.autoVisiblityOutlineProgressViaThresholdToReach = NO;
//                button.reachedMinimumProgressToDisplayScale = .5;
//                [button setButtons:@[[R ico_play]] colors:nil];

                //os style
                button.preferredIconImagePadding = 3.5;
                button.autoVisiblityOutlineProgressViaThresholdToReach = YES;
                button.reachedProgressCircleColor = [STStandardUI iOSSystemCameraHighlightColor];
                button.reachedMinimumProgressToDisplayScale = .5;
                button.reachedProgressCirclePadding = 0;
                button.outlineStrokeWidth = 1.5;
                button.outlineStrokeColor = [[STStandardUI iOSSystemCameraHighlightColor] colorWithAlphaComponent:[STStandardUI alphaForDimmingWeak]];
                button.outlineStrokeBackgroundColor = nil;
                [button setButtons:@[[STGIFCApp livePhotosBadgeImageName]] colors:@[[UIColor whiteColor]] bgColors:@[[STStandardUI iOSSystemCameraHighlightColor]] style:STStandardButtonStylePTBT];

                button.userInteractionEnabled = NO;
                _quickPreviewForceTouchIndicator = button;
            }
            [_quickPreviewView addSubview:_quickPreviewForceTouchIndicator];
            [Wself forceTouchIndicatorReset];

            _quickPreviewForceTouchIndicator.animatableVisible = YES;

            //listen playing
            Strongs
            WeakObject(Sself) WSself = Sself;
            [livePhotoView whenValueOf:@keypath(livePhotoView.playing) id:QuickPreviewLivePhotoViewPlayingObserverId changed:^(id value, id __weakSelf) {
                [WSself st_runAsMainQueueAsyncWithSelf:^(id selfObject) {
                    [selfObject forceTouchIndicatorPlayingStateForLivePhotoViewer:[value boolValue]];
                }];

            }];
        }];

    }else{
        view.image = [photoItem loadFullResolutionImage];
    }
    Weaks

    //listening zoom scale change
    _quickPreviewView.whenDidZoomScaleChanged = ^(STMotionScrollView *weakSelf, CGFloat scale) {
        [Wself updateGuidesStates:scale == 1 willEnteringZoomMode:weakSelf.isEnteredZoomScrollMode];
    };
}

- (void)dettachQuickPreviewView:(BOOL)enteredZoomScrollMode {
    [_quickPreviewView disposeContent];
    _quickPreviewView.whenDidZoomScaleChanged = nil;
    [_quickPreviewView st_removeAllGestureRecognizers];
    [_quickPreviewView removeFromSuperview];
    [_quickPreviewView.contentView st_removeAllKeypathListenersWidthId:QuickPreviewLivePhotoViewPlayingObserverId];

    [self forceTouchIndicatorReset];
    [_quickPreviewForceTouchIndicator removeFromSuperview];

    [STGIFCApp logQuickPreviewDismissed:enteredZoomScrollMode];
}

static NSArray * _prevUpdatedGuidesState;
- (void)updateGuidesStates:(BOOL)show willEnteringZoomMode:(BOOL)enteringZoomMode {
    if(_prevUpdatedGuidesState && ([_prevUpdatedGuidesState[0] boolValue] == show && [_prevUpdatedGuidesState[1] boolValue] == enteringZoomMode)){
        return;
    }
    _prevUpdatedGuidesState = @[@(show), @(enteringZoomMode)];

    /*
     * arrow
     */
    CGFloat dynamicGap = AGKRemapAndClamp(_quickPreviewView.contentView.y, 0, self.containerQuickPreview.boundsHeightHalf, 0, QuickPreviewDecoBaseGap /2);
    BOOL touchPointsAreOverHalf = _quickPreviewTouchStartPointInContainer.y <= self.containerQuickPreview.boundsHeightHalf;

    _guideSliderView.visible = YES;

    if(touchPointsAreOverHalf){
        _slideArrowUpView.visible = enteringZoomMode;
        _slideArrowDownView.visible = YES;
    }else{
        _slideArrowUpView.visible = YES;
        _slideArrowDownView.visible = enteringZoomMode;
    }

    _guideSliderView.pop_duration = .2;
    _guideSliderView.easeInEaseOut.alpha = show ? [STStandardUI alphaForDimmingGhostly] : 0;

    /*
     * force touch indicator
     */
    if(enteringZoomMode){
        [self forceTouchIndicatorReset];
    }else{
        if(!_quickPreviewForceTouchIndicator.visible){
            _quickPreviewForceTouchIndicator.animatableVisible = YES;
        }
    }

    /*
     * perform animation
     */
    Weaks
    [UIView animateWithDuration:.45 animations:^{
        if(show){
            if(enteringZoomMode){
                if(CGSizeAspectRatio_AGK(_quickPreviewView.contentView.size) < .6){
                    _slideArrowUpView.y = QuickPreviewDecoBaseGap;
                    _slideArrowDownView.bottom = Wself.containerQuickPreview.height - QuickPreviewDecoBaseGap;
                }else{
                    _slideArrowUpView.bottom = _quickPreviewView.contentView.y - dynamicGap;
                    _slideArrowDownView.y = _quickPreviewView.contentView.bottom + dynamicGap;
                }
            }else{
                _slideArrowUpView.y = QuickPreviewDecoBaseGap;
                _slideArrowDownView.bottom = Wself.containerQuickPreview.boundsHeight - QuickPreviewDecoBaseGap;
            }
        }else{
            _slideArrowUpView.bottom = 0;
            _slideArrowDownView.y = _guideSliderView.height;
        }
    }];
}

- (void)attachGuideArrow{
    _prevUpdatedGuidesState = nil;

    /*
     * * add slide guide view
     */
    _guideSliderView = [[UIView alloc] initWithSize:self.containerQuickPreview.size];
    _guideSliderView.userInteractionEnabled = NO;
    _guideSliderView.alpha = [STStandardUI alphaForDimmingGhostly];
    _guideSliderView.visible = NO;

    _slideArrowUpView = [SVGKImage UIImageViewNamed:[R slide_arrow_down_ios] withSizeWidth:[STStandardLayout widthSubSmall] color:nil degree:180];
    _slideArrowUpView.y = [STStandardLayout widthSubAssistance];
    [_guideSliderView addSubview:_slideArrowUpView];
    [_slideArrowUpView centerToParentHorizontal];

    _slideArrowDownView = [SVGKImage UIImageViewNamed:[R slide_arrow_down_ios] withSizeWidth:[STStandardLayout widthSubSmall]];
    _slideArrowDownView.bottom = _guideSliderView.height-[STStandardLayout widthSubAssistance];
    [_guideSliderView addSubview:_slideArrowDownView];
    [_slideArrowDownView centerToParentHorizontal];

    [self.containerQuickPreview addSubview:_guideSliderView];

}

- (void)dettachGuideArrows{
    [_guideSliderView clearAllOwnedImagesIfNeeded:YES removeSubViews:YES];
    [_guideSliderView removeFromSuperview];
}

- (void)attachSlider{
    NSAssert(_quickPreviewView, @"_quickPreviewView was nil");

    if(!_quickSliderPreviewView){
        _quickSliderPreviewView = [[STStandardSimpleSlider alloc] initWithSize:[STStandardLayout sizeOverlayThinHorizontal]];
    }
    [_quickPreviewView addSubview:_quickSliderPreviewView];
    [_quickSliderPreviewView centerToParent];
    _quickSliderPreviewView.visible = YES;
    _quickSliderPreviewView.alpha = 0;
    _quickSliderPreviewView.bottom = _quickPreviewView.bottom-[STStandardLayout paddingForAutofitDistanceDefault];
    [_quickSliderPreviewView setProgress:.5 animated:NO];
}

#pragma mark QuickPreview - Responses from Motion Scroll
NSString * TimerIdForDelayMotionScrolling = @"quickpreviewslider";

- (void)updateFromQuickViewMotionScroll:(BOOL)enteringZoomMode {
    Weaks
    if(enteringZoomMode){
        _quickPreviewView.whenDidScrollToProgress = nil;

    }else{
        _quickPreviewView.whenDidScrollToProgress = !_quickPreviewView.isContentSizeScrollable ? nil : ^(__weak STMotionScrollView *weakSelf, CGFloat progress) {
            if(weakSelf.isContentSizeScrollable){
                [Wself showQuickViewSliderAndGuideViewFromMotionScroll:enteringZoomMode progress:progress];
            }else{
                [Wself resetForQuickViewMotionScroll:enteringZoomMode animation:NO];
            }
        };
    }

    [self resetForQuickViewMotionScroll:enteringZoomMode animation:NO];
}

- (void)showQuickViewSliderAndGuideViewFromMotionScroll:(BOOL)enteringZoomMode progress:(CGFloat)progress{
    CGFloat dimmedAlpha = [STStandardUI alphaForDimmingGhostly];

    //slider
    if(_quickSliderPreviewView.progress != progress){
        [_quickSliderPreviewView setProgress:progress animated:NO];
    }
    if(_quickSliderPreviewView.alpha!=dimmedAlpha){
        _quickSliderPreviewView.alpha = dimmedAlpha;

    }

    //guide arrow
    [self updateGuidesStates:NO willEnteringZoomMode:_quickPreviewView.isEnteredZoomScrollMode];

    Weaks
    [STStandardUX resetAndRevertStateAfterShortDelay:TimerIdForDelayMotionScrolling block:^{
        [Wself resetForQuickViewMotionScroll:enteringZoomMode animation:YES];
    }];
}

- (void)resetForQuickViewMotionScroll:(BOOL)enteringZoomMode animation:(BOOL)animation {
    if(animation){
        _quickSliderPreviewView.easeInEaseOut.alpha = 0;
    }else{
        _quickSliderPreviewView.alpha = 0;
    }

    [self updateGuidesStates:YES willEnteringZoomMode:enteringZoomMode];

    [STStandardUX clearDelay:TimerIdForDelayMotionScrolling];
}


#pragma mark QuickPreview - Add / Remove
- (void)addQuickViewGestures{
    __block CGRect targetCellFrame = CGRectNull;
    __block STThumbnailGridViewCell *targetCellView = nil;
    __block STPhotoItem * targetPhotoItem = nil;
    CGFloat scaleForEnter = 2;
    CGFloat scaleForScroll = 1.05;

    Weaks
    void(^dismiss)(UILongPressGestureRecognizer *) = ^(UILongPressGestureRecognizer *sender) {
        BOOL enteredZoomScrollMode = [_quickPreviewView isEnteredZoomScrollMode];

        //revert photoselector view
        [[STPhotoSelector sharedInstance] pop_removeAllAnimations];
        if([_quickPreviewView isEnteredZoomScrollMode]){
            [STPhotoSelector sharedInstance].easeInEaseOut.scaleXYValue = 1;
        }else{
            [STPhotoSelector sharedInstance].scaleXYValue = 1;
        }

        [STPhotoSelector sharedInstance].visible = YES;
        [[STPhotoSelector sharedInstance] st_coverBlurRemoveIfShowen];
//        [[STPhotoSelector sharedInstance] st_springCGPoint:CGPointMake(1, 1) keypath:@"scaleXY"];
//        [STPhotoSelector sharedInstance].animatableVisible = YES;

        //start dismiss
        [STTimeOperator st_performOnceAfterDelay:@"dismissquickprevie" interval:.0 block:^{

            // remove slide guide view
            [self dettachGuideArrows];

            // remove fakeImageView
            UIImageView *fakeImageView = (UIImageView *) [self.containerQuickPreview viewWithTagName:QuickPreviewFakeImageViewTagName];
            [fakeImageView removeFromSuperview];

            fakeImageView = [[UIImageView alloc] initWithImage:targetPhotoItem.previewImage];

            UIView * _targetCellView = targetCellView;
            targetPhotoItem = nil;
            targetCellView = nil;

            //fit size
            if([_quickPreviewView isEnteredZoomScrollMode] || ![_quickPreviewView isContentSizeScrollable]){
                fakeImageView.contentMode = UIViewContentModeScaleAspectFit;
            }else{
                fakeImageView.contentMode = UIViewContentModeScaleAspectFill;
            }

            fakeImageView.frame = _quickPreviewView.frame;
//            fakeImageView.x = -_quickPreviewView.contentOffset.x;
            fakeImageView.tagName = QuickPreviewFakeImageViewTagName;
            [self.containerQuickPreview addSubview:fakeImageView];

            if(!CGRectIsNull(targetCellFrame)){
                [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    fakeImageView.frame = targetCellFrame;
                } completion:^(BOOL finished) {
                    _targetCellView.visible = YES;

                    [fakeImageView removeFromSuperview];
                    fakeImageView.image = nil;

                    _quickPreviewing = NO;
                }];
            }else{
                _quickPreviewing = NO;
            }

            //dettach quick view content
            [Wself dettachQuickPreviewView:enteredZoomScrollMode];

            //reset main component
            [[STMainControl sharedInstance] showControls];
            [[STMainControl sharedInstance] startParallaxEffect];
            [[STUserActor sharedInstance] act:STUserActionChangeCameraMode object:@(STCameraModeElie)];
        }];
    };

    @weakify(self)
    [STStandardUX resolveLongTapDelay:[self whenLongTouchAsTapDownUp:^(UITouchLongPressGestureRecognizer *sender, CGPoint location) {
        if(self.isItemsEmpty){
            [sender bk_cancel];
            return;
        }

        _quickPreviewTouchStartPointInContainer = [sender locationInView:self.containerQuickPreview];

        NSIndexPath *indexPath = [self indexPathForItemAtPoint:[sender locationInView:sender.view]];
        targetPhotoItem = [self photoItemForIndexPath:indexPath];

        //cancel if blanked item
        if(targetPhotoItem.blanked){
            [sender bk_cancel];
            return;
        }

        _quickPreviewing = YES;

        //mesure cell
        targetCellView = (STThumbnailGridViewCell *) [self cellForItemAtIndexPath:indexPath];
        targetCellView.visible = NO;
        targetCellFrame = [self convertRect:targetCellView.frame toView:self.containerQuickPreview];

        [[STMainControl sharedInstance] hideControls];
        [[STMainControl sharedInstance] stopParallaxEffect];

        //set photoselector view
//        [[STPhotoSelector sharedInstance] st_coverImage:[[[STPhotoSelector sharedInstance] st_takeSnapshot] applyDarkEffect] animation:NO completion:nil];
        [[STPhotoSelector sharedInstance] st_springCGPoint:CGPointMake(scaleForEnter, scaleForEnter) keypath:@"scaleXY"];
//        [STPhotoSelector sharedInstance].animatableVisible = NO;

        //create face imageview for animation
        UIImageView *fakeImageView = [[UIImageView alloc] initWithImage:[targetPhotoItem previewImage]];
        fakeImageView.frame = targetCellFrame;
        fakeImageView.tagName = QuickPreviewFakeImageViewTagName;
        if(CGSizeAspectRatio_AGK(fakeImageView.size) <= (CGSizeAspectRatio_AGK(self.containerQuickPreview.size))){
            fakeImageView.contentMode = UIViewContentModeScaleAspectFit;
        }else{
            fakeImageView.contentMode = UIViewContentModeScaleAspectFill;
        }
        [self.containerQuickPreview addSubview:fakeImageView];

        [[STPhotoSelector sharedInstance] st_coverBlur:YES styleDark:YES completion:nil];

        [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            fakeImageView.frame = self.containerQuickPreview.frame;

        } completion:^(BOOL finished) {
            if(finished){
                @strongify(self)
                //create quickpreview
                if(_quickPreviewView){
                    _quickPreviewView.frame = self.containerQuickPreview.frame;
                }else{
                    if([targetPhotoItem.sourceForAsset isLivePhoto]){
                        _quickPreviewView = [[STMotionScrollLivePhotoView alloc] initWithFrame:self.containerQuickPreview.frame];
                    }else{
                        _quickPreviewView = [[STMotionScrollView alloc] initWithFrame:self.containerQuickPreview.frame];
                    }
                    _quickPreviewView.tagName = @"quickview";
                }

                //set and insert quick preview
                [self.containerQuickPreview insertSubview:_quickPreviewView belowSubview:fakeImageView];

                //attach content
                [self attachQuickPreviewViewContent:targetPhotoItem view:_quickPreviewView];

                //remove fakeimageview
                fakeImageView.easeInEaseOut.alpha = 0;
                fakeImageView.image = nil;
                [fakeImageView removeFromSuperview];

                //revert photoselector view
                [[STPhotoSelector sharedInstance] pop_removeAllAnimations];
//                [STPhotoSelector sharedInstance].scaleXYValue = 1;
//                [STPhotoSelector sharedInstance].visible = YES;
//                [STPhotoSelector sharedInstance].alpha = 1;
//                [[STPhotoSelector sharedInstance] st_coverBlurSnapshot:NO styleDark:YES completion:nil];

                if([_quickPreviewView isPossibleScroll]){
                    [self attachGuideArrow];
                    [self attachSlider];

                    [self updateFromQuickViewMotionScroll:NO];
                }

            }
        }];

        [[STUserActor sharedInstance] act:STUserActionChangeCameraMode object:@(STCameraModeEliePause)];

    } changed:^(UITouchLongPressGestureRecognizer *sender, CGPoint location){
        if(self.isItemsEmpty){
            [sender bk_cancel];
            return;
        }

        CGPoint p = [sender locationInView:_quickPreviewView];
        CGFloat movedYReach = fabsf(p.y- _quickPreviewTouchStartPointInContainer.y) / [STStandardUX reachingDistanceForPanning];

        if(movedYReach > 1.f && !_quickPreviewView.isEnteredZoomScrollMode && _quickPreviewView.isContentSizeScrollable){
            //enter zoom mode
            [_quickPreviewView enterZoomScrollMode];

            _quickSliderPreviewView.visible = NO;
            _quickSliderPreviewView.alpha = 0;

            [[STPhotoSelector sharedInstance] pop_removeAllAnimations];
            [STPhotoSelector sharedInstance].scaleXYValue = scaleForScroll;

            __block CGFloat pannedDistance = 0;
            [_quickPreviewView whenPanAsSlideVertical:_quickPreviewView started:^(UIPanGestureRecognizer *_sender, CGPoint locationInSelf) {
                [sender bk_cancel];

                //cancel animation
                [[STPhotoSelector sharedInstance].st_coveredView pop_removeAllAnimations];
                [_quickPreviewView pop_removeAllAnimations];

                [self updateGuidesStates:NO willEnteringZoomMode:_quickPreviewView.isEnteredZoomScrollMode];

                _quickSliderPreviewView.visible = NO;

            } changed:^(UIPanGestureRecognizer *_sender, CGPoint locationInSelf, CGFloat distance, CGPoint movedOffset, CGFloat distanceReachRatio, STSlideDirection direction, BOOL confirmed) {
                pannedDistance = distance;

                CGFloat progress = AGKRemapToZeroOneAndClamp(pannedDistance, 0, _sender.view.height/4);
                [STPhotoSelector sharedInstance].scaleXYValue = AGKRemap(progress,0,1,scaleForScroll,1);
                [STPhotoSelector sharedInstance].st_coveredView.alpha = 1-(progress/3);

                if(progress==1 && fabs([_sender velocityInView:_sender.view.superview].y) > [STStandardUX reachingVelocityForPanning]){
                    dismiss(sender);
                }

            } ended:^(UIPanGestureRecognizer *_sender, CGPoint locationInSelf, STSlideDirection direction, BOOL confirmed) {
                if(pannedDistance > [STStandardUX reachingDistanceForPanning]){
                    dismiss(sender);
                }else{
                    _quickSliderPreviewView.visible = YES;
                    [self updateGuidesStates:YES willEnteringZoomMode:_quickPreviewView.isEnteredZoomScrollMode];

                    //animation
                    [STStandardUX setAnimationFeelToHighTensionSpring:[STPhotoSelector sharedInstance]];
                    [STPhotoSelector sharedInstance].spring.scaleXYValue = scaleForScroll;

                    [STStandardUX setAnimationFeelsToFastShortSpring:[STPhotoSelector sharedInstance].st_coveredView];
                    [STPhotoSelector sharedInstance].st_coveredView.easeInEaseOut.alpha = 1;

                    [STStandardUX setAnimationFeelToHighTensionSpring:_quickPreviewView];
                    _quickPreviewView.spring.centerY = _quickPreviewView.superview.boundsHeightHalf;
                }
            }];

            CGFloat initialZoomScale = _quickPreviewView.zoomScale;

            [_quickPreviewView whenTapped:^(UIGestureRecognizer *_sender, UIGestureRecognizerState state, CGPoint _location) {
                if([[[self quickPreviewLivePhotoViewOrNil] contentLivePhotoView] isPlaying]){
                    [_sender bk_cancel];
                    return;
                }

                BOOL willDismiss = _quickPreviewView.isEnteredZoomScrollMode;
                willDismiss ? [_quickPreviewView dismissZoomScrollMode:YES] : [_quickPreviewView enterZoomScrollMode];

                _quickSliderPreviewView.visible = willDismiss;
                if(!willDismiss){
                    _quickSliderPreviewView.alpha = 0;
                }

                [self updateGuidesStates:YES willEnteringZoomMode:!willDismiss];
                [self updateFromQuickViewMotionScroll:!willDismiss];

            } orDoubleTapped:^(UIGestureRecognizer *_sender, UIGestureRecognizerState state, CGPoint _location) {
                _quickPreviewView.zoomScale = _quickPreviewView.zoomScale == initialZoomScale ? initialZoomScale * 4 : initialZoomScale;
            }];

            [self updateGuidesStates:YES willEnteringZoomMode:_quickPreviewView.isEnteredZoomScrollMode];
            [self updateFromQuickViewMotionScroll:_quickPreviewView.isEnteredZoomScrollMode];

            [sender bk_cancel];
        }


    } ended:^(UITouchLongPressGestureRecognizer *sender, CGPoint location) {
        if(self.isItemsEmpty){
            [sender bk_cancel];
            return;
        }

        CGPoint p = [sender locationInView:_quickPreviewView];

        if(_quickPreviewView.isEnteredZoomScrollMode){
            [sender bk_cancel];
            return;
        }

        //cancel if blanked item
        if(targetPhotoItem.blanked){
            [sender bk_cancel];
            return;
        }

        dismiss(sender);
    }]];
}

- (BOOL)isQuickPreviewing {
    return _quickPreviewing;
}

#pragma mark updateViews
- (void)representPhotoItemOfAllVisibleCells:(BOOL)disposeUnVisibles {
    NSArray<STPhotoItem *> * visibleItems = [self.visibleCells bk_map:^id(STThumbnailGridViewCell * cell) {
        return cell.item;
    }];

    for(STPhotoItem * item in self.items){
        if([visibleItems containsObject:item]){
            STThumbnailGridViewCell * cell = [self cellForPhotoItem:item];
            [cell presentItem:cell.item];
        }else{
            if(disposeUnVisibles){
                [item disposePreviewImage];
            }
        }
    }
}

- (void)updateViewsByItemCount {
    [self.items eachWithIndex:^(id object, NSUInteger index) {
        if(((STPhotoItem *) object).selected){
            [self selectItemAtIndexPath:[NSIndexPath itemPath:index] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }else{
            [self deselectItemAtIndexPath:[NSIndexPath itemPath:index] animated:NO];
        }
    }];
    [[STMainControl sharedInstance] setDisplayHomeScrolledGridView:self.scrolledIndex withCount:self.items.count - 1];
}

- (void)updateViewsBySelected{
//    [[STMainControl sharedInstance] setPhotoSelected:self.indexPathsForSelectedItems.count];
}

#pragma mark LAST SCROLL
- (void)updateViewsByScrolled {
    if(!self.contentSize.height){
        return;
    }
    _lastScrollPosition = _currentScrollPosition;
    _currentScrollPosition = self.contentOffset;

    STMainControl * mainControl = [STMainControl sharedInstance];

    NSInteger count = self.items.count;
    //WARN : 아래의 scrolledIndex는 현재의 scrollView가 보여주는 정확한 인덱스가 아니라 height을 단순히 count로 봤을때의 인덱스 이다.
    NSUInteger scrolledIndex = [@(count * ((_currentScrollPosition.y < 0 ? 0 : _currentScrollPosition.y) / (self.contentSize.height - (self.bounds.size.height-self.contentInsetBottom)))) unsignedIntegerValue];

    if(scrolledIndex < count){
        [mainControl setDisplayHomeScrolledGridView:scrolledIndex withCount:self.items.count - 1];
        _scrolledIndex = scrolledIndex;
    }

    //last scrolled height
    BOOL scrolledLast = (self.bounds.size.height-self.contentInsetBottom) + _currentScrollPosition.y >= self.contentSize.height;
    CGFloat movedOffsetY = _lastScrollPosition.y-_currentScrollPosition.y;
    _scrolledLast = scrolledLast;

    //show/hide controls
    if(fabsf(movedOffsetY) > [STStandardUX velocityForStartScrolling]){
        BOOL needsAppending = [[STPhotoSelector sharedInstance] isCurrentTypePhotoAndHasMoreAppendingPhotos];

        if(!needsAppending && _scrolledLast){
            [mainControl showControlsWhenStopScrolling];
        }else{
            if(movedOffsetY<0){
                [mainControl hideControlsWhenStartScrolling];
            }else if(movedOffsetY>0){
                [mainControl showControlsWhenStopScrolling];
            }
        }
    }
}

#pragma mark Manage Collection
- (void)deselectAll {
    [self.indexPathsForSelectedItems bk_each:^(id obj) {
        [self deselectItemAtIndexPath:obj animated:YES];
    }];
    [self updateViewsBySelected];
}

- (void)selectPhotoItemAtIndex:(NSUInteger)index{
    [self selectItemAtIndexPath:[NSIndexPath itemPath:index] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)selectPhotoItem:(STPhotoItem *)item{
    [self selectPhotoItemAtIndex:[self.items indexOfObject:item]];
}

- (void)deselectPhotoItemAtIndex:(NSUInteger)index{
    [self deselectItemAtIndexPath:[NSIndexPath itemPath:index] animated:NO];
}

- (void)deselectPhotoItem:(STPhotoItem *)item{
    [self deselectPhotoItemAtIndex:[self.items indexOfObject:item]];
}

- (STPhotoItem *)photoItemForIndexPath:(NSIndexPath *)path{
    return [self items][path.item];
}

- (NSIndexPath *)indexPathForPhotoItem:(STPhotoItem *)item{
    NSUInteger itemIndex = [self.items indexOfObject:item];
    if(itemIndex==NSNotFound){
        return nil;
    }
    return [NSIndexPath itemPath:itemIndex];
}

- (NSArray *)indexPathsForPhotoItems:(NSArray *)items{
    Weaks
    NSMutableArray *paths = [NSMutableArray array];
    for(STPhotoItem * item in items){
        NSIndexPath * path = [self indexPathForPhotoItem:item];
        if(path){
            [paths addObject:path];
        }
    }
    return paths;
}

- (STThumbnailGridViewCell *)cellForIndex:(NSUInteger)index{
    return (STThumbnailGridViewCell *)[self cellForItemAtIndexPath:[NSIndexPath itemPath:index]];
}

- (STThumbnailGridViewCell *)cellForPhotoItem:(STPhotoItem *)item{
    return [self cellForIndex:[self.items indexOfObject:item]];
}

#pragma mark Override
- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL finished))completion; {
    if([self isItemsEmpty]){
        !completion?:completion(YES);
        return;
    }

    @weakify(self)
    [super performBatchUpdates:updates completion:^(BOOL finished) {
        [self updateViewsByItemCount];
        [self updateViewsBySelected];

        if(completion){
            completion(finished);
            !_whenDidBatchUpdated?:_whenDidBatchUpdated(finished);
        }
    }];
}

- (void)reloadData; {
    [super reloadData];

    [self updateViewsByItemCount];
    [self updateViewsBySelected];
    [self updateViewsByScrolled];
}

- (void)layoutSubviews; {
    [super layoutSubviews];
    [self updateViewsByScrolled];
}

- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths; {
    NSMutableIndexSet * deleteIndexes = [NSMutableIndexSet indexSet];
    for(NSIndexPath * path in indexPaths){
        [deleteIndexes addIndex:(NSUInteger) path.item];
    }
    [self.items removeObjectsAtIndexes:deleteIndexes];
    [super deleteItemsAtIndexPaths:indexPaths];
}

- (void)scrollToTop{
    [self scrollTo:0];
}

- (void)scrollTo:(NSUInteger)index{
    [self scrollTo:index animated:YES];
}

- (void)scrollTo:(NSUInteger)index animated:(BOOL)animated{
    if(index==0 && self.y!=0){
        self.y = 0;
    }

    if(self.contentOffset.y == 0 && index==0){
        return;
    }
    [self scrollToItemAtIndexPath:[NSIndexPath itemPath:index] atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
}

- (BOOL)isCurrentScrollAsPull{
    return self.contentOffset.y <= -[STStandardUX maxOffsetForPullToGridView];
}

- (CGFloat)currentPullingDistanceRatio{
    return self.contentOffset.y==0 ? 0 : -1*(self.contentOffset.y/ [STStandardUX maxOffsetForPullToGridView]);
}

- (void)whenDidBatchUpdated:(void (^)(BOOL finished))block; {
    _whenDidBatchUpdated = block;
}

#pragma mark - UICollectionViewFlowLayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(NHBalancedFlowLayout *)collectionViewLayout preferredSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    STPhotoItem * item = _items[(NSUInteger) indexPath.item];
    CGSize size = item.pixelSizeOfPreviewImage;
    NSAssert(!CGSizeEqualToSize(CGSizeZero, size),@"collectionView's photoitem size is 0");
    return size;
}

#pragma mark - UICollectionView data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section; {
    return _items.count;
}

- (NSInteger)numberOfSections; {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return _items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)queueIndexPath;
{
    STThumbnailGridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:queueIndexPath];
//    [cell clearItem];

    if(!isEmpty(_items) && queueIndexPath.item < _items.count){

        STPhotoItem * photoItem = _items[(NSUInteger) queueIndexPath.item];
        [cell presentItem:photoItem];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    //TODO: 여기에서 선행작업을 실행 / cellForItemAtIndexPath에서 하지 말고
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath; {

}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = nil;

    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderId forIndexPath:indexPath];
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kFooterId forIndexPath:indexPath];
    }

    return view;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath; {
    BOOL preventForQuickPreview = ![self isQuickPreviewing];
    BOOL preventForExportMaxCount = self.indexPathsForSelectedItems.count < MAX_ALLOWED_EXPORT_COUNT;

    if(preventForQuickPreview && !preventForExportMaxCount){
        [STStandardUX expressDenied:self];
    }

    return preventForQuickPreview && preventForExportMaxCount;
}

- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated; {
    [super deselectItemAtIndexPath:indexPath animated:animated];

//    STPhotoItem *item = [self.items st_objectOrNilAtIndex:(NSUInteger) indexPath.item];
//    item.selected = NO;
//
//    // remove filter
//    if(item.isEdited){
//        [item clearCurrentEditedAndReloadPreviewImage];
//        [self updateCellFromForSelect:indexPath animation:animated updateViaBatch:YES];
//    }else{
//        [self updateCellFromForSelect:indexPath animation:animated updateViaBatch:NO];
//    }
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition; {
    [super selectItemAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];

//    STPhotoItem * item = self.items[(NSUInteger) indexPath.item];
//    item.selected = YES;
//
//    // set changes
//    [self updateCellFromForSelect:indexPath animation:animated updateViaBatch:NO];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath; {
    [self selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];

    // set changes
    [self updateViewsBySelected];

//    [[STMainControl sharedInstance] export];

    [[STPhotoSelector sharedInstance] doEnterEditAfterCaptureByItem:[self.items st_objectOrNilAtIndex:(NSUInteger) indexPath.item] transition:STPreviewCollectorEnterTransitionContextFromCollectionViewItemSelected];
//    [[STPhotoSelector sharedInstance] doEnterEditByItem:[self.items st_objectOrNilAtIndex:(NSUInteger) indexPath.item]];

}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath; {
    [self deselectItemAtIndexPath:indexPath animated:YES];

    // set changes
    [self updateViewsBySelected];

//    if(self.indexPathsForSelectedItems.count){
//        [[STMainControl sharedInstance] export];
//    }else{
//        [[STMainControl sharedInstance] home];
//    }
}

- (void)updateCellFromForSelect:(NSIndexPath *)indexPath animation:(BOOL)animation updateViaBatch:(BOOL)updateViaBatch{
    STPhotoItem *item = [self.items st_objectOrNilAtIndex:(NSUInteger) indexPath.item];
    if(!item){
        return;
    }

    CGSize diffPreviewImageSize = item.previewImage.size;
//    if(CGSizeEqualToSize(diffPreviewImageSize, item.previewImage.size)){
    if(!updateViaBatch){
        STThumbnailGridViewCell * cell = (STThumbnailGridViewCell *)[self cellForItemAtIndexPath:indexPath];
        [cell presentItem:item animation:animation];

    }else{
        Weaks
        [self performBatchUpdates:^{
            [Wself reloadItemsAtIndexPaths:@[indexPath]];
        } completion:^(BOOL finished) {

        }];
    }
}

#pragma mark - UIScrollView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView; {
    CGFloat velocity = [scrollView.panGestureRecognizer velocityInView:self].y;
    BOOL caseOfStopAndPull = velocity>0 && scrollView.contentOffset.y==0;
    BOOL caseOfScrollingWithPull = velocity==0 && scrollView.contentOffset.y<0;
    BOOL canUseCamera = STPermissionManager.camera.isAuthorized;

    if(canUseCamera && (caseOfStopAndPull || caseOfScrollingWithPull)){
        oo(@"-----------scrollViewWillBeginDragging-");
        _startedPullToRefresh = YES;

        if([self.gridViewDelegate respondsToSelector:@selector(beganPerformedPullToRefresh:)]){
            [self.gridViewDelegate beganPerformedPullToRefresh:scrollView];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(_startedPullToRefresh){
        if ([self isCurrentScrollAsPull]) {
            if([self.gridViewDelegate respondsToSelector:@selector(didPerformedPullToRefresh:willDecelerate:)]){
                [self.gridViewDelegate didPerformedPullToRefresh:scrollView willDecelerate:decelerate];

                //TODO: 적당한 장소로 옮김
                if(_slideDownGuideView){
                    [_slideDownGuideView clearAllOwnedImagesIfNeededAndRemoveFromSuperview:NO];
                }
            }
        }else {
            if([self.gridViewDelegate respondsToSelector:@selector(didCancelPullToRefresh:)]){
                [self.gridViewDelegate didCancelPullToRefresh:scrollView];
            }
        }
    }
    _startedPullToRefresh = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView; {

}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView; {

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(_scrolledLast){
        [[self gridViewDelegate] didScrolledToLastPosition:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(_startedPullToRefresh){
        if (scrollView.contentOffset.y<0) {
            if([self.gridViewDelegate respondsToSelector:@selector(performmingPullToRefresh:)]){
                [self.gridViewDelegate performmingPullToRefresh:scrollView];
            }
        }else {
            if([self.gridViewDelegate respondsToSelector:@selector(didCancelPullToRefresh:)]){
                [self.gridViewDelegate didCancelPullToRefresh:scrollView];
                _startedPullToRefresh = NO;
            }
        }
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView; {

}


- (CGPoint)scrollSpeed {
    return CGPointMake(_lastScrollPosition.x - _currentScrollPosition.x,
            _lastScrollPosition.y - _currentScrollPosition.y);
}

@end
#pragma clang diagnostic pop