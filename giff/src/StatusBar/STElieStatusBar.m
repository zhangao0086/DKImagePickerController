//
// Created by BLACKGENE on 2014. 9. 16..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <BlocksKit/NSArray+BlocksKit.h>
#import <iCarousel/iCarousel.h>
#import <SVGKit/SVGKFastImageView.h>
#import "STElieStatusBar.h"
#import "STGIFFAppSetting.h"
#import "STSelectableView.h"
#import "NSObject+STUtil.h"
#import "UIView+STUtil.h"
#import "STCarouselHolderController.h"
#import "STStandardUIFactory.h"
#import "SVGKImage+STUtil.h"

#import "R.h"
#import "NSString+STUtil.h"
#import "STGIFFAnimatableLogoView.h"
#import "STUserActor.h"
#import "STMainControl.h"
#import "STAppInfoView.h"
#import "STPhotoSelector.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "STUIApplication.h"

#define DELAY_ID_REVERT @"statusbar.result"

@implementation STElieStatusBar {

    //widget
    STUIView * _widgetContainer;

    STCarouselHolderController * _msg;

    UIView *_blurBackgroundView;
    UIView *_vibrancyBackgroundView;

    //center
//    MMMaterialDesignSpinner *_spinner;
    STGIFFAnimatableLogoView * _elie;
    STUIView *_centerContainer;
    UILabel * _label;
    UIView *_iconView;

    BOOL _lockShowOrHide;
}

static STElieStatusBar *_instance = nil;

+ (STElieStatusBar *)sharedInstance{
    BlockOnce(^{
        _instance = [[self alloc] initWithFrame:[self initialFrame]];
        _instance.shouldDisableAnimationWhileCreateContent = YES;
//        _instance.autoOrientationEnabled = YES;
    });
    return _instance;
}

- (CGFloat)layoutHeight {
    return [STApp screenFamily]>STScreenFamily35 ? self.height : 0;
}

- (void)show{
    _showen = YES;

    if(_lockShowOrHide){
        return;
    }

    [UIView animateWithDuration:.3 animations:^{
        _blurBackgroundView.y = _widgetContainer.y = _centerContainer.y = 0;
    }];

    [self setVisibleBackground:_visibleBackground];
}

- (void)hide{
    _showen = NO;

    if(_lockShowOrHide){
        return;
    }

    [UIView animateWithDuration:.2 animations:^{
        _blurBackgroundView.bottom = _widgetContainer.bottom = _centerContainer.bottom = 0;
    }];
}

- (void)lockShowHide {
    if(_lockShowOrHide){
        return;
    }
    _lockShowOrHide = YES;
}

- (void)unlockShowHide {
    if(!_lockShowOrHide){
        return;
    }
    _lockShowOrHide = NO;
}

- (void)unlockShowHideAndRevert {
    if(!_lockShowOrHide){
        return;
    }
    _lockShowOrHide = NO;

    _showen ? [self show] : [self hide];
}


#pragma mark External Changed
- (void)setFocusIsRunnig:(BOOL)focusIsRunnig; {
    _focusIsRunnig = focusIsRunnig;
}

- (void)setFaceDistance:(STFaceDistance)faceDistance; {
    _faceDistance = faceDistance;
}

- (BOOL)faceDistanceIsInAvailableRange {
    return STFaceDistanceNotDetected < _faceDistance && _faceDistance < STFaceDistanceFarWithDisappeared;
}

#pragma mark CommonViews
- (void)showLogo{
    _elie.visible = YES;
//    _spinner.visible = NO;
    _label.visible = NO;
    _iconView.visible = NO;
}

- (void)hideLogo{
    _elie.visible = NO;
}

- (void)showProgress:(BOOL)withLabel{
    _elie.visible = YES;
//    _spinner.visible = YES;
    _label.visible = YES;
    _iconView.visible = NO;

    if(withLabel){
        _label.visible = YES;
        _elie.right = _label.x - 4;
    }else{
        _label.visible = NO;
        [_elie centerToParent];
    }
}

- (void)showResult{
    _elie.visible = NO;
//    _spinner.visible = NO;
    _label.visible = NO;
    _iconView.visible = YES;
}

- (void)showLabel{
    _elie.visible = NO;
//    _spinner.visible = NO;
    _label.visible = YES;
    _iconView.visible = NO;
}

#pragma mark Progress
- (void)startProgress:(NSString *)message{
    if(self._isPendingProgress){
        return;
    }

    [self setDisplayToVibrancy:NO];

    [self setLabel:message];

    [self showProgress:!isEmpty(message)];

    [_elie startIndicating];
//    [_spinner startAnimating];
}

- (void)stopProgress{
    [self setDisplayToVibrancy:YES];

//    [_label removeFromSuperview];
//    _label = nil;

    [_elie stopIndicating];
//    _spinner.alpha = 1;

//    [_spinner stopAnimating];

    [self showLogo];
}

- (BOOL)_isPendingProgress{
//    return _spinner.visible && [_spinner isAnimating];
    return [_elie indicating];
}

#pragma mark Label
- (void)setLabel:(NSString *)text{
    if(!_label && text){
        _label = [STStandardUIFactory labelStatusBar];
        [_centerContainer addSubview:_label];

        [_label whenValueOf:@keypath(_label.hidden) id:@"hidden_button_connect" changed:^(id value, id _weakSelf) {
            if(![value boolValue]){
                _leftButton.easeInEaseOut.duration = .1;
                _leftButton.easeInEaseOut.alpha = 0;
                _rightButton.easeInEaseOut.duration = .1;
                _rightButton.easeInEaseOut.alpha = 0;
            }else{
                _leftButton.easeInEaseOut.duration = .6;
                _leftButton.easeInEaseOut.alpha = 1;
                _rightButton.easeInEaseOut.duration = .6;
                _rightButton.easeInEaseOut.alpha = 1;
            }
        } getInitialValue:YES];
    }

    [STStandardUX animateAlphaFadeInFromDimmed:_label];
    _label.text = text;
    [_label sizeToFit];
    [_label centerToParent];
}

- (void)message:(NSString *)message {
    [self message:message showLogoAfterDelay:YES];
}

- (void)message:(NSString *)message showLogoAfterDelay:(BOOL)showLogoAfterDelay{
    if(!message){
        [self logo:YES];
        return;
    }
    if(self._isPendingProgress){
        return;
    }

    [self showLabel];

    [self setLabel:message];

    if(showLogoAfterDelay){
        [self logoDelay];
    }
}

#pragma mark Result
- (void)success{
    [self stopProgress];

    [self removeIcon];

    [self displayIcon:[R check_circle] color:[STStandardUI positiveColor]];
}

- (void)fail{
    [self stopProgress];

    [self removeIcon];

    [self displayIcon:[R x_circle] color:[UIColor whiteColor]];
}

- (void)fatal{
    [self stopProgress];

    [self removeIcon];

    [self displayIcon:[R x_circle] color:[STStandardUI negativeColor]];
}

#pragma mark Icon
- (void)displayIcon:(NSString *)imageName color:(UIColor *)color{
    if(!_iconView){
        [self setDisplayToVibrancy:NO];

        _iconView = [SVGKImage viewNamedWithFillColor:imageName size:_elie.size color:color];
        _iconView.alpha = 0;

        [_centerContainer addSubview:_iconView];
        [_iconView centerToParent];

        _iconView.easeInEaseOut.duration = 1;
        _iconView.easeInEaseOut.alpha = 1;

        [self logoDelay];
    }
    [self showResult];
}

- (void)removeIcon {
    [_iconView pop_removeAllAnimations];
    [_iconView removeFromSuperview];
    _iconView = nil;
}

#pragma mark Logo
- (void)logoDelay{
    Weaks
    [STStandardUX resetAndRevertStateAfterLongDelay:DELAY_ID_REVERT block:^{
        Strongs
        if([Sself _isPendingProgress]){
           return;
        }
        [Sself logo:YES];
    }];
}

- (void)logo:(BOOL)animation{
    [STStandardUX clearDelay:DELAY_ID_REVERT];

    [self showLogo];

    [_elie highlightIndicating];

    [self setDisplayToVibrancy:YES];
}

#pragma mark initialize
+ (CGRect)initialFrame {
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat kStatusBarHeight = [STApp screenFamily]==STScreenFamily35 ? 20 : 38;
    return CGRectMake(0, size.height-kStatusBarHeight, size.width, kStatusBarHeight);
}

- (UIImage *)icoImage:(NSString *)imageName{
    return [imageName imageSVG:[STStandardLayout widthBullet]];
}

- (void)createContent; {
    [super createContent];

    STGIFFAppSetting * pref = STGIFFAppSetting.get;
    STSelectableView * (^makeWidget)(NSArray *, NSUInteger) = ^STSelectableView * (NSArray * buttons, NSUInteger index) {
        STSelectableView * b = [[STSelectableView alloc] initWithFrame:[STStandardLayout rectBullet] viewsAsInteractionDisabled:buttons];
        b.hidden = (buttons.count==1 && index==0) || (index >= buttons.count);
        if(b.visible){
            [b setCurrentIndex:index];
        }
        return b;
    };

    Weaks

    // Containers
    UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];

    _blurBackgroundView = [[UIView alloc] init];
    //TODO: 추후 vibrancy 써도 될거 같다고 생각되면 이 라인을 해제한다
//    _blurBackgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _blurBackgroundView.frame = self.bounds;

    [self addSubview:_blurBackgroundView];

    _vibrancyBackgroundView = [[UIView alloc] init];//[[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:blurEffect]];
    _vibrancyBackgroundView.frame = self.bounds;
    [_blurBackgroundView addSubview:_vibrancyBackgroundView];

//    [self addSubview:_msg.carousel];

    _widgetContainer = [[STUIView alloc] initWithSize:self.bounds.size];
    [_widgetContainer setTouchInsidePolicy:STUIViewTouchInsidePolicyContentInside];
    [self addSubview:_widgetContainer];

    _centerContainer = [[STUIView alloc] initWithSize:self.boundsSize];
    [_centerContainer setTouchInsidePolicy:STUIViewTouchInsidePolicyContentInside];
    [self addSubview:_centerContainer];

    // left

    //left button
    _leftButton = [[STStandardButton alloc] initWithSizeWidth:self.height];
    _leftButton.preferredIconImagePadding = self.height/4;
    [_leftButton setButtons:@[[R set_info_indicator_bullet]] colors:nil style:STStandardButtonStylePTTP];
    [_widgetContainer addSubview:_leftButton];
    [_leftButton whenSelected:^(STSelectableView *selectedView, NSInteger index) {
        [[STElieCamera sharedInstance] pauseCameraCapture];

        _leftButton.badgeSmallPoint = NO;

        STUIView * appInfoViewContainer = [[STUIView alloc] initWithSize:[self st_rootUVC].view.size];
        [[self st_rootUVC].view addSubview:appInfoViewContainer];

        STAppInfoView * appInfoView = [[STAppInfoView alloc] initWithSize:appInfoViewContainer.size];
        [appInfoViewContainer addSubview:appInfoView];
        [appInfoView setContents];

        [_leftButton coverWithBlur:[self st_rootUVC].view presentingTarget:appInfoViewContainer blurStyle:UIBlurEffectStyleDark comletion:nil];

        [appInfoView.closeButton whenSelected:^(STSelectableView *_selectedView, NSInteger _index) {
            [[STElieCamera sharedInstance] resumeCameraCapture];

            [_leftButton uncoverWithBlur:YES comletion:^(STStandardButton *button, BOOL covered) {
                [appInfoViewContainer clearAllOwnedImagesIfNeededAndRemoveFromSuperview:YES];

            }];
        }];
    }];

    _leftButton.badgeSmallPoint = STAppSetting.get.isFirstLaunchSinceLastBuild;


    //right button
    _rightButton = [[STStandardButton alloc] initWithSizeWidth:self.height];
    _rightButton.allowSelectAsTap = YES;
    _rightButton.preferredIconImagePadding = self.height/4;
    [_rightButton setButtons:@[[R go_roll]] colors:nil style:STStandardButtonStylePTTP];
    [_widgetContainer addSubview:_rightButton];
    [_rightButton whenSelected:^(STSelectableView *selectedView, NSInteger index) {
        _rightButton.badgeSmallPoint = NO;

        // fix for Fully Cached image - blanked image
//        if([STUIApplication sharedApplication].hasBeenReceivedMemoryWarning){
//            [[[STPhotoSelector sharedInstance] collectionView] representPhotoItemOfAllVisibleCells:YES];
//        }

        if(STElieCamera.mode==STCameraModeManualExitAndPause){
            [[STMainControl sharedInstance] backToHome];
        }else {

            if ([STMainControl sharedInstance].mode == STControlDisplayModeLivePreview) {

                UIImageView *coveredView = [_rightButton coverAndUncoverBegin:self.st_rootUVC.view presentingTarget:[STPhotoSelector sharedInstance]];
                [[STUserActor sharedInstance] act:STUserActionChangeCameraMode object:@(STCameraModeManualExitAndPause)];
                [_rightButton coverAndUncoverEnd:self.st_rootUVC.view presentingTarget:[STPhotoSelector sharedInstance] beforeCoverView:coveredView comletion:nil];

            } else {
                [[STPhotoSelector sharedInstance] doDirectlyEnterHome];

                [[STUserActor sharedInstance] act:STUserActionChangeCameraMode object:@(STCameraModeManualExitAndPause)];
            }
        }
    }];

    [[NSNotificationCenter get] st_addObserverWithMainQueue:self forName:STNotificationPhotosDidLocalSaved usingBlock:^(NSNotification *note, id observer) {
        _rightButton.badgeSmallPoint = YES;
    }];


//    _elie = [SVGKImage UIImageViewNamed:[R logo] withSizeWidth:11];
//    _elie.contentMode = UIViewContentModeCenter;
//    _elie.size = _elie.image.size;

    _elie = [[STGIFFAnimatableLogoView alloc] initWithSizeWidth:self.height/2];
//    [_widgetContainer addSubview:_elie];

//    _spinner = [[MMMaterialDesignSpinner alloc] initWithSizeWidth:9];
//    _spinner.duration = .95;
//    _spinner.lineWidth = STStandardLayout.circularStrokeWidthDefault;
//    _spinner.tintColor = [UIColor whiteColor];
//    _spinner.hidesWhenStopped = YES;
//    _spinner.userInteractionEnabled = NO;

    [_centerContainer addSubview:_elie];
//    [_centerContainer addSubview:_spinner];
//    [_spinner centerToParent];
    [_elie centerToParent];
    _elie.centerY -= 1;

    [self setToInitialState];
}

- (void)setToInitialState{
    [self show];

    [self setDisplayToVibrancy:YES];

    [self st_eachSubviews:^(UIView *view, NSUInteger index) {
        if([view isEqual:_centerContainer]){
            return;
        }
//        view.userInteractionEnabled = NO;
        //top-padding
        view.y -= 1;
    }];

//    self.touchInsidePolicy = STUIViewTouchInsidePolicyContentInside;
}

- (void)setDisplayToVibrancy:(BOOL)vibrancy{
    //TODO: 추후 vibrancy 써도 될거 같다고 생각되면 이 라인을 해제한다
    vibrancy=NO;

    _centerContainer.tagName = @"_msgContainer";

    if(vibrancy){
        if(![_vibrancyBackgroundView viewWithTagName:_centerContainer.tagName]){
            [_vibrancyBackgroundView addSubview:_centerContainer];
        }
    }else{
//        if(![self viewWithTagName:_centerContainer.tagName]){
//            [self addSubview:_centerContainer];
//        }
    };
}

- (void)setVisibleBackground:(BOOL)visibleBackground; {
    [self setVisibleBackground:visibleBackground animation:YES];
}

- (void)setVisibleBackground:(BOOL)visibleBackground animation:(BOOL)animation; {
    //TODO : bg를 안한게 훨씬 고급지다.
//    _blurBackgroundView.visible = NO;

//    if(animation){
//        [self setVisibleBackground:visibleBackground animateAsSlideTransition:YES];
//    }else{
//        _blurBackgroundView.visible = visibleBackground;
//        _blurBackgroundView.alpha = 0;
//    }
}

- (void)setVisibleBackground:(BOOL)visibleBackground animateAsSlideTransition:(BOOL)animateAsSlideTransition; {
    //TODO : bg를 안한게 훨씬 고급지다.
//    if(animateAsSlideTransition){
//        _blurBackgroundView.visible = YES;
//        _blurBackgroundView.alpha = 1;
//        [UIView animateWithDuration:.3 animations:^{
//            _blurBackgroundView.y = (_visibleBackground = visibleBackground) ? 0 : self.height;
//        }];
//    }else{
//        _blurBackgroundView.animatableVisible = _visibleBackground = visibleBackground;
//    }
}

- (void)didCreateContent; {
    [super didCreateContent];

    WeakSelf weakSelf = self;

    /*
        init observer
     */
    [STGIFFAppSetting.get whenSavedToAll:self.identifier withBlock:^(NSString *property, id value) {
        [weakSelf applyFromPreference:property value:value];
    }];

    [[STElieCamera sharedInstance] st_observe:@keypath([STElieCamera sharedInstance].focusAdjusted) block:^(id value, __weak id _weakSelf) {
        weakSelf.focusIsRunnig = ![value boolValue];
    }];

    /*
        apply
     */
    [[STGIFFAppSetting.get st_propertyNames] bk_each:^(id obj) {
        [weakSelf applyFromPreference:obj value:[STGIFFAppSetting.get valueForKey:obj]];
    }];

    [self setFaceDistance:STFaceDistanceNotDetected];
    [self setFocusIsRunnig:NO];

    [self updateWidgetLayout];

}

- (void)applyFromPreference:(NSString *)keyPath value:(id) value{
    STGIFFAppSetting *pref = STGIFFAppSetting.get;

}

- (void)updateWidgetLayout{
    [_leftButton centerToParentVertical];
    _leftButton.left = 0;

    [_rightButton centerToParentVertical];
    _rightButton.right = self.right;
}
@end