//
// Created by BLACKGENE on 2014. 9. 5..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <GPUImage/GPUImageView.h>
#import "STHome.h"
#import "CAShapeLayer+STUtil.h"
#import "M13ProgressViewRing.h"
#import "STElieCamera.h"
#import "STPhotoSelector.h"
#import "STFilter.h"
#import "STFilterManager.h"
#import "MMMaterialDesignSpinner.h"
#import "GPUImageView+STGPUImageFilterHelper.h"
#import "UIImage+STUtil.h"
#import "NSObject+STPopAnimatableProperty.h"
#import "STSelectableView.h"
#import "STStandardButton.h"
#import "STStandardCollectableButton.h"
#import "STStandardNavigationButton.h"
#import "NSObject+STUtil.h"
#import "NSObject+STThreadUtil.h"
#import "STTimeOperator.h"
#import "STMainControl.h"
#import "STElieStatusBar.h"
#import "SVGKImageView.h"
#import "SVGKImage+STUtil.h"
#import "R.h"
#import "STPermissionManager.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "STGIFCAnimatableLogoView.h"


@implementation STHome {

    GPUImageView * _preview;
    CAShapeLayer * _previewMask;
    STFilterItem * _previewFilterItem;
    NSArray * _previewFilterChain;
    MMMaterialDesignSpinner *_spinner;

    M13ProgressViewRing * _indexView;
    M13ProgressViewRing * _subIndexView;

    UIImageView *_arrow;

    STGIFCAnimatableLogoView * _logoView;

    void (^_slidingBeganBlock)(STSlideDirection direction);
    void (^_slidedBlock)(BOOL confirmed, STSlideDirection direction);
    void (^_slidingChangeBlock)(CGFloat reachRatio, BOOL confirmed, STSlideDirection direction);
}

- (id)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {
        self.shouldDisableAnimationWhileCreateContent = YES;
    }
    return self;
}

- (void) createContent;{

    // preview
    _preview = [[GPUImageView alloc] initWithFrame:[STElieCamera.sharedInstance outputRect:self.bounds]];
    _preview.fillMode = kGPUImageFillModePreserveAspectRatio;
    _preview.contentMode = UIViewContentModeScaleAspectFill;
    _preview.centerY = self.height/2;
    if([STGIFCApp isInSimulator]){
        [_preview setGPUImage:[[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"LaunchScreenIcon"]]];
    }

    _previewMask = [CAShapeLayer circle:_preview.boundsWidth];
    _previewMask.contentsGravity = kCAGravityCenter;
    _previewMask.lineWidth = 0;
    _previewMask.fillColor = [[UIColor redColor] CGColor];
    _previewMask.positionY = _preview.boundsHeightHalf-_previewMask.pathHeightHalf;
    [_preview.layer addSublayer:_previewMask];
    _preview.layer.mask = _previewMask;
    _preview.hidden = YES;


    /*
        indexing
     */
    _indexView = [[M13ProgressViewRing alloc] initWithFrame:CGRectInset(self.bounds, -[STStandardLayout circularStrokeWidthDefault], -[STStandardLayout circularStrokeWidthDefault])];
    _indexView.backgroundRingWidth = _indexView.progressRingWidth = [STStandardLayout circularStrokeWidthDefault];
    _indexView.showPercentage = NO;
    _indexView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    _indexView.primaryColor = [STStandardUI pointColor];
    _indexView.secondaryColor = nil;//[[UIColor whiteColor] colorWithAlphaComponent:[STStandardUI alphaForDimmingGlass]];
    [_indexView.layer setShouldRasterize:YES];
    [_indexView.layer setRasterizationScale:(CGFloat) (TwiceMaxScreenScale() * 2.0)];
    _indexView.alpha = 0;

    /*
        Spinner
     */
//    CGFloat strokeWidth = 4;
//    CGFloat strokePadding = 2;
//    _spinner = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectInset([self st_originClearedBounds], -(strokeWidth + strokePadding), -(strokeWidth + strokePadding))]; //outter stroke
//    _spinner.lineWidth = strokeWidth;
//    _spinner.hidesWhenStopped = YES;
//    _spinner.userInteractionEnabled = NO;
//    _spinner.duration = 20/3.5f;
//    _spinner.y = -_spinner.lineWidth-2;
//
//    CGFloat offsetOutter = -_spinner.lineWidth + 3;
//    UIImageView *spinnerMaskView = [SVGKImage UIImageViewNamed:[R patt_home_spinner] withSizeWidth:_spinner.width + offsetOutter];
//    spinnerMaskView.layer.frameOrigin = CGPointMake(-offsetOutter *.5f,-offsetOutter *.5f);
//
//    //start spinner
//    _spinner.tintColor = [UIColor whiteColor];
//    _spinner.layer.mask = spinnerMaskView.layer;

    /*
     *  Arrow
     */
//    _arrow = [[UIImageView alloc] initWithSize:[STStandardLayout sizeBullet]];
//    _arrow.contentMode = UIViewContentModeCenter;

    /*
        background button=
     */
    _containerButton = [STStandardButton mainSmallSize];
//    _containerButton.autoOrientationEnabled = YES;
    _containerButton.autoOrientationOnlySelectableViews = YES;
    _containerButton.autoAdjustVectorIconImagePaddingIfNeeded = YES;
    _containerButton.preferredIconImagePadding = _containerButton.width/5;
    [_containerButton setButtons:@[[R logo]] colors:nil bgColors:nil style:STStandardButtonStylePTTP];
//    _containerButton.shadowOffset = 1.5f;
//    _containerButton.shadowEnabled = YES;
    _containerButton.forceBubblingTapGesturesWhenSelected = YES;
//    _containerButton.backgroundViewAsColoredImage = [STStandardUI buttonColorBackgroundOverlay];
//    _containerButton.backgroundView.alpha = [STStandardUI alphaForGlassLikeOverlayButtonBackground];

    [STStandardUI setDropShadowWithDarkBackground:_containerButton.layer];


    /*
     * logo view
     */
    _logoView = [[STGIFCAnimatableLogoView alloc] initWithSize:[STStandardLayout sizeSubSmall]];
    _logoView.userInteractionEnabled = NO;
    _logoView.visible = NO;

    /*
        add childes
     */
    [self addSubview:_containerButton];
//    [_containerButton addSubview:_spinner];
    [_containerButton addSubview:_preview];
    [_containerButton addSubview:_indexView];

    [self addSubview:_logoView];
    [_logoView centerToParent];

//    [_containerButton addSubview:_arrow];

    /*
        slide action
     */
    [self resetSubLayout];

    /*
     * restore state
     */
//    [self restoreStatesIfPossible];
}


NSString * coverViewTagName = @"STHomePrevieImageView";
static UIView * coverView;

- (void)saveStates {

}

- (void)restoreStatesIfPossible {
    if([STGIFCApp isInSimulator]){
        return;
    }

    if(STElieCamera.mode == STCameraModeNotInitialized){
        Weaks
        coverView = [[UIView alloc] initWithSize:_preview.size];
        coverView.tagName = coverViewTagName;
        coverView.scaleXYValue = 1.01;
        [self addSubview:coverView];
        [coverView centerToParent];

        UIImageView * coverImageView = [[UIImageView alloc] initWithSizeWidth:_preview.width];
        coverImageView.image = [UIImage imageBundled:@"homePatttern.png"];
        [coverView addSubview:coverImageView];
        [coverImageView centerToParent];

        CAShapeLayer * mask = [CAShapeLayer circle:coverView.boundsWidth];
        mask.contentsGravity = kCAGravityCenter;
        mask.lineWidth = 0;
        mask.fillColor = [[UIColor redColor] CGColor];
        mask.positionY = coverView.boundsHeightHalf-mask.pathHeightHalf;
        coverView.layer.mask = mask;

        [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueueOnlyOnce:self forName:STNotificationFaceDetectionInitialized usingBlock:^(NSNotification *note, id observer) {
            Strongs
            __block UIView *_coveredView = [Sself viewWithTagName:coverViewTagName];
            UIImageView *_coverImageView = (UIImageView *) [_coveredView subviews].firstObject;

            if(_coverImageView){
                WeakAssign(Sself)
                [UIView animateWithDuration:.7 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    _coverImageView.scaleXYValue = 3;
                    _coverImageView.alpha = 0;

                } completion:^(BOOL finished) {
                    [weak_Sself removeRestoreStateViews];

                    [[NSNotificationCenter defaultCenter] postNotificationName:STNotificationFaceDetectionAndHomePreviewInitialized object:nil];
                }];
            }
            coverViewTagName = nil;
        }];
    }
}

- (void)removeRestoreStateViews{
    coverView.layer.mask = nil;
    [coverView clearAllOwnedImagesIfNeededAndRemoveFromSuperview:YES];
    coverView = nil;
}

- (void)cancelRestoreStateEffect {
    [[NSNotificationCenter defaultCenter] st_removeObserverWithMainQueue:self forName:STNotificationFaceDetectionInitialized];
    [self removeRestoreStateViews];
}

#pragma mark Impl.
- (void)resetSubLayout {
    _indexView.scaleXY = ST_PP(1);
}

#pragma mark Touch
- (void)selectContainerButton{
//    [_containerButton st_performOnceAfterDelay:@"_containerButton_touchbegin" interval:.08 block:^{
        _containerButton.selectedState = YES;
//    }];
}

- (void)deselectContainerButton{
    [_containerButton st_clearPerformOnceAfterDelay:@"_containerButton_touchbegin"];
    _containerButton.selectedState = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self selectContainerButton];
}


- (void)touchesCancelled:(__typed_collection(NSSet, UITouch *))touches withEvent:(UIEvent *)event {
    [self deselectContainerButton];
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self deselectContainerButton];
    [super touchesEnded:touches withEvent:event];
}

#pragma mark Slide
- (BOOL)enabledSlide{
    return _slidedBlock != nil;
}

- (void)_dispatchSlidingBegan:(STSlideDirection) direction{
    !_slidingBeganBlock ?: _slidingBeganBlock(direction);
}

- (void)_dispatchSlide:(BOOL)confirmed direction:(STSlideDirection) direction{
    !_slidedBlock ?: _slidedBlock(confirmed, direction);
}

- (void)_dispatchSlidingChange:(CGFloat)reachRatio confirmed:(BOOL)confirmed direction:(STSlideDirection) direction{
    !_slidingChangeBlock ?: _slidingChangeBlock(reachRatio, confirmed, direction);
}

- (void)whenSlidingBegan:(void (^)(STSlideDirection direction))block{
    _slidingBeganBlock = block;
}

- (void)whenSlidingChange:(void (^)(CGFloat reachRatio, BOOL confirmed, STSlideDirection direction))block{
    _slidingChangeBlock = block;
}

- (void)whenSlidedAsConfirmed:(void (^)(STSlideDirection direction))block{
    [self whenSlided:!block ? nil : ^(BOOL confirmed, STSlideDirection direction) {
        !confirmed ?: block(direction);
    }];
}

- (void)whenSlided:(void (^)(BOOL confirmed, STSlideDirection direction))block{
    _slidedBlock = block;
    BOOL enableSlide = _slidedBlock !=nil;
    if(!enableSlide){
        _slidingChangeBlock = nil;
    }
    UIPanGestureRecognizer * panGestureRecognizer = [self _registSlideAction:enableSlide];
    if(panGestureRecognizer){
        [_containerButton.gestureRecognizerForSelection requireGestureRecognizerToFail:panGestureRecognizer];
    }
}

- (UIPanGestureRecognizer *)_registSlideAction:(BOOL)regist{
    if(!regist){
        [_containerButton whenPan:nil];
        return nil;
    }

    __block CGPoint _startPoint = CGPointZero;
    __block CGPoint _startGesturePoint = CGPointZero;
    __block CGFloat _maxDistance = _containerButton.height/4;
    __block STSlideDirection _direction = STSlideDirectionNone;
    __block BOOL _confirmed = NO;
    __block BOOL _restricted = NO;

    __block BOOL spinnerWasVisible = NO;
    __block BOOL previewWasVisible = NO;
    __block BOOL collectableWasVisible = NO;
    __block STStandardButton *slideDestinationSelectable = nil;

    void(^slideFinished)(BOOL, UIPanGestureRecognizer *, CGPoint) = ^(BOOL confirmed, UIPanGestureRecognizer *recognizer, CGPoint locationInSelf) {
        /*
         * if canceled
         */
        if(!confirmed){
//            [self _setPreviewVisiblity:previewWasVisible];
            self.spinnerVisiblity = spinnerWasVisible;
            self.selectableButton.visible = collectableWasVisible;
        }

        /*
         * reset arrow
         */
        [self setNeedsArrowDisplay:YES];

        /*
         * reset release circle
         */
        [slideDestinationSelectable removeFromSuperview];
        slideDestinationSelectable = nil;

        /*
         * reset container
         */
        _containerButton.currentButtonView.visible = !confirmed;
        _containerButton.center = _startPoint;
        _containerButton.scaleXYValue = 1;
        [self deselectContainerButton];

    };

    @weakify(self)
    return [_containerButton whenPan:^(UIPanGestureRecognizer *recognizer, CGPoint locationInSelf) {
        [self deselectContainerButton];
        _startPoint = recognizer.view.center;
        _startGesturePoint = [recognizer translationInView:self];

        /*
         * restrict
         */
        if ((_restricted = [self _restrictSlide:[recognizer velocityInView:self] whenDirection:STSlideDirectionNone])) {
            //[recognizer bk_cancel];
            return;
        }

        /*
         * attach release circle
         */

        slideDestinationSelectable = (STStandardButton *) [self viewWithTagName:@"releasedislay"];
        if (!slideDestinationSelectable) {
            slideDestinationSelectable = [STStandardButton mainSmallSize];
            slideDestinationSelectable.tagName = @"releasedislay";
            slideDestinationSelectable.userInteractionEnabled = NO;
            slideDestinationSelectable.center = _containerButton.boundsCenter;
            slideDestinationSelectable.animationEnabled = NO;
            slideDestinationSelectable.toggleEnabled = YES;
            slideDestinationSelectable.visible = NO;
            [slideDestinationSelectable setButtons:@[[R go_elie], [R go_manual]]
                                            colors:@[STStandardUI.buttonColorFront, STStandardUI.buttonColorFront]
                                          bgColors:@[STStandardUI.buttonColorBack, STStandardUI.buttonColorBack]
                                             style:STStandardButtonStyleDefault];
        }

        [self insertSubview:slideDestinationSelectable atIndex:0];

        previewWasVisible = self.previewVisiblity == 1;
        spinnerWasVisible = self.spinnerVisiblity;
        collectableWasVisible = self.selectableButton && self.selectableButton.collectableView.count && self.selectableButton.visible;

        [self _dispatchSlidingBegan:STSlideDirectionNone];

    } changed:^(UIPanGestureRecognizer *recognizer, CGPoint locationInSelf) {

        //TODO: 이시점에서collectionview에서 터치를 떼 실행되는에니메이션를 즉시 중지(떨리는현상)
        CGPoint movedPoint = [recognizer translationInView:self];
        movedPoint.x = 0;//_startGesturePoint.x;
        CGPoint pannedCenter;

        /*
            calc position
         */
        CGFloat distance = sqrtf(movedPoint.x * movedPoint.x + movedPoint.y * movedPoint.y);
        CGFloat distanceReachRatio = distance / _maxDistance;
        BOOL reachSelectToRelease = distanceReachRatio > .8;

        if (distance < _maxDistance) {
            pannedCenter = CGPointMake(_startPoint.x + movedPoint.x, _startPoint.y + movedPoint.y);
            _confirmed = NO;

        } else {
            float x = (movedPoint.x / distance) * _maxDistance;
            float y = (movedPoint.y / distance) * _maxDistance;

            pannedCenter = CGPointMake(_startPoint.x + x, _startPoint.y + y);
            _confirmed = YES;

            distanceReachRatio = 1;
        }

        STSlideDirection direction = /*pannedView.centerY==self.boundsHeightHalf ? STSlideDirectionNone :*/
                (pannedCenter.y < self.boundsHeightHalf ? STSlideDirectionUp : STSlideDirectionDown);

        /*
         * restrict
         */
        BOOL restriction = [self _restrictSlide:[recognizer velocityInView:self] whenDirection:direction];
        if (_restricted || _restricted != restriction) {
            _restricted = YES;
            _confirmed = NO;
            if (_direction != STSlideDirectionNone) {
                _direction = STSlideDirectionNone;
                slideFinished(_confirmed, recognizer, locationInSelf);
            }
            return;
        }

        /*
         * start change
         */
        _containerButton.currentButtonView.visible = NO;
        _containerButton.center = pannedCenter;
        _containerButton.scaleXYValue = AGKRemapAndClamp(distanceReachRatio,1,0,.6,1);

        /*
            pull down action
         */
        //pre-state

        if (previewWasVisible) {
//            [self _setPreviewVisiblity:1 - distanceReachRatio];
        }
        if (spinnerWasVisible) {
            self.spinnerVisiblity = 0;
        }
        if (collectableWasVisible && self.selectableButton.visible) {
            self.selectableButton.visible = NO;
        }

        /*
         * release
         */
        slideDestinationSelectable.visible = YES;

        CGFloat gap = (_containerButton.boundsHeightHalf) * distanceReachRatio;

        if (direction == STSlideDirectionUp) {
            slideDestinationSelectable.centerY = recognizer.view.boundsCenter.y + gap;
            slideDestinationSelectable.currentIndex = 0;

        } else if (direction == STSlideDirectionDown) {
            slideDestinationSelectable.centerY = recognizer.view.boundsCenter.y - gap;
            slideDestinationSelectable.currentIndex = 1;
        }
        slideDestinationSelectable.currentButtonView.scaleXYValue = AGKRemapAndClamp(distanceReachRatio,0,1,.5,.9);
        slideDestinationSelectable.selectedState = reachSelectToRelease;

        /*
         * arrow
         */
        //set image
        UIImage *image = [self _arrowImageByDirection:direction highlighted:YES reached:reachSelectToRelease];
        if (![image isEqual:_arrow.highlightedImage]) {
            _arrow.highlighted = NO;
            _arrow.highlightedImage = image;
            _arrow.highlighted = YES;
        }
//        _arrow.alpha = 1;

        //transform
        if (reachSelectToRelease) {
            if (distanceReachRatio == 1.f) {
                CGFloat gapFromCenter = 20;
                _arrow.spring.centerY = direction == STSlideDirectionUp ? _arrow.superview.boundsHeightHalf + gapFromCenter : gapFromCenter;
            } else {
                _arrow.spring.centerY = _arrow.superview.boundsHeightHalf;
            }

            _arrow.layer.rotation = (CGFloat) M_PI;

        } else {
            _arrow.spring.centerY = _arrow.superview.boundsHeightHalf;
            _arrow.layer.rotation = 0;
        }

        [self _dispatchSlidingChange:distanceReachRatio confirmed:_confirmed direction:direction];

        _direction = direction;

    } ended:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf) {
        if(!_restricted){
            slideFinished(_confirmed, sender, locationInSelf);
        }
        [self _dispatchSlide:_confirmed direction:_direction];
    }];
};

- (NSUInteger)_allowedSlideDirection{
    if(!STPermissionManager.camera.isAuthorized){
        return STSlideDirectionNone;
    }

    switch ([STMainControl sharedInstance].mode){
        case STControlDisplayModeHome:
            return STSlideDirectionDown;

//        case STControlDisplayModeLivePreview:
//            return STSlideDirectionUp;

        default:
            return STSlideDirectionNone;
    }
}

- (BOOL)_restrictSlide:(CGPoint)velocity whenDirection:(STSlideDirection)currentLocatedDirection{
    NSUInteger allowedDirectionBits = [self _allowedSlideDirection];
    STSlideDirection velocityDirection = (velocity.y < 0 ? STSlideDirectionUp : STSlideDirectionDown);
    BOOL matchCurrentLocatedDirection = (currentLocatedDirection == STSlideDirectionNone ? YES : currentLocatedDirection==velocityDirection);
    BOOL matched = NO;

    if(CHK_BIT(STSlideDirectionDown, allowedDirectionBits) && velocityDirection==STSlideDirectionUp){
        matched = YES;

    }else if(CHK_BIT(STSlideDirectionUp, allowedDirectionBits) && velocityDirection==STSlideDirectionDown){
        matched = YES;
    }

    matched = matched && matchCurrentLocatedDirection;

    return matched;
}

#pragma mark Arrow
- (UIImage *)_arrowImageByDirection:(STSlideDirection)direction highlighted:(BOOL)highlighted reached:(BOOL)reached{
    NSString * imageName = reached ? [R down_triangle_rounded] : [R slide_arrow_down];

    CGFloat width = highlighted ? [STStandardLayout widthSubAssistance] : [STStandardLayout widthBullet];
    UIImage * image = direction==STSlideDirectionUp ?
            [SVGKImage UIImageNamed:imageName withSizeWidth:width color:nil degree:180] :
            [SVGKImage UIImageNamed:imageName withSizeWidth:width];
    return image;
}

- (void)setNeedsArrowDisplay:(BOOL)animation {
    NSInteger allowedSlideDirection = [self _allowedSlideDirection];
    if(allowedSlideDirection==STSlideDirectionNone){
        _arrow.visible = NO;
        return;
    }

    if(!_arrow.image){
        [_arrow centerToParent];
    }

    _arrow.visible = YES;
    CGFloat centerY = allowedSlideDirection==STSlideDirectionUp ? [STStandardLayout widthBullet] : self.boundsHeight - [STStandardLayout widthBullet];;
    if(centerY!=_arrow.centerY){
        if(animation){
            _arrow.spring.centerY = centerY;
        }else{
            [_arrow pop_removeAllAnimations];
            _arrow.centerY = centerY;
        }
    }
    
    _arrow.image = [self _arrowImageByDirection:(STSlideDirection) allowedSlideDirection highlighted:NO reached:NO];
    _arrow.highlighted = NO;
    _arrow.highlightedImage = nil;
    _arrow.layer.rotation = 0;
}

#pragma mark setDisplay
- (void)setDisplayToDefault {
    _containerButton.visible = YES;
    self.logoProgress = 0;
    [self clearSelectables];
    [self setNeedsArrowDisplay:STElieCamera.mode != STCameraModeNotInitialized];
}

- (void)clearSelectables{
    if(!_selectableButton){
        return;
    }

    if([_selectableButton isKindOfClass:STStandardNavigationButton.class]){
        [self setDisplayWithCollectables:NO];
    }

    [_subIndexView removeFromSuperview];
    _subIndexView = nil;

    [_selectableButton.collectableView retract:NO];
    [_selectableButton clearViews];
    [_selectableButton removeFromSuperview];
    _selectableButton = nil;
}

- (STStandardButton *)setDisplayOnlyButton {
    return [self setDisplayOnlyButton:[STStandardButton mainSize]];
}

- (STStandardButton *)setDisplayOnlyButton:(STStandardButton *)button {
    _containerButton.visible = NO;

    if(!_selectableButton){
        _selectableButton = button;
        _selectableButton.forceBubblingTapGesturesWhenSelected = YES;
        _selectableButton.allowSelectAsTap = NO;
        _selectableButton.fitViewsImageToBounds = YES;
        [self insertSubview:_selectableButton belowSubview:_containerButton];
        _selectableButton.centerX = self.boundsWidthHalf;
        _selectableButton.centerY = self.boundsHeightHalf;
    }
    return _selectableButton;
}

- (STStandardButton *)setDisplayScrollTop{
    BOOL newcreated = _selectableButton==nil;

    STStandardButton * button = [self setDisplayOnlyButton:[STStandardButton subSmallSize]];

    if(newcreated){
        [button setButtons:@[[R go_scroll_top]] colors:nil style:STStandardButtonStylePTTP];
        button.backgroundViewAsOwnBackgroundColorWithShapeMask = [[STStandardUI pointColorDarken] colorWithAlphaComponent:[STStandardUI alphaForDimming]];
        button.allowSelectAsTap = YES;

        _subIndexView = [[M13ProgressViewRing alloc] initWithFrame:CGRectInset(button.bounds, -[STStandardLayout circularStrokeWidthDefault], -[STStandardLayout circularStrokeWidthDefault])];
        _subIndexView.backgroundRingWidth = [STStandardLayout circularStrokeWidthDefault];
        _subIndexView.progressRingWidth = [STStandardLayout circularStrokeWidthDefault];
        _subIndexView.showPercentage = NO;
        _subIndexView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        _subIndexView.primaryColor = [STStandardUI strokeColorProgressFront];
        _subIndexView.secondaryColor = [STStandardUI strokeColorProgressBackground];

        [button insertSubview:_subIndexView atIndex:0];

        _subIndexView.scaleXYValue = 0;
        _subIndexView.pop_duration = .4;
        _subIndexView.springSpeed = 15;

        _subIndexView.spring.scaleXYValue = 1;
    }

    return button;
}

- (STStandardNavigationButton *)setDisplayWithCollectables:(BOOL)expanding {
    return [self setDisplayWithCollectables:expanding visibleHome:YES];
}

- (STStandardNavigationButton *)setDisplayWithCollectables:(BOOL)expanding visibleHome:(BOOL)visibleHome {
    return [self setDisplayWithCollectables:expanding visibleHome:visibleHome width:[STStandardLayout widthMain]];
}

- (STStandardNavigationButton *)setDisplayWithCollectables:(BOOL)expanding visibleHome:(BOOL)visibleHome width:(CGFloat)width {
    Weaks
    _containerButton.visible = visibleHome;
    _containerButton.blockForForceTestHit = !expanding || !visibleHome ? nil : ^UIView *(CGPoint point, UIEvent *event) {
        Strongs
        if(CGPointLengthBetween_AGK(point, Wself.boundsCenter) <= Wself.boundsWidthHalf-2){
            return Sself->_containerButton;
        }
        return nil;
    };

    if(!_selectableButton){
        Weaks
        STStandardNavigationButton *button = [[STStandardNavigationButton alloc] initWithFrame:CGRectMakeValue(width)];
        button.userInteractionEnabled = YES;
        button.fitViewsImageToBounds = YES;

        button.collectablesSelectAsIndependent = YES;
        button.autoUXLayoutWhenExpanding = YES;
        button.autoRetractWhenSelectCollectableItem = YES;

        [self insertSubview:button belowSubview:_containerButton];

        button.centerX = self.boundsWidthHalf;
        button.centerY = self.boundsHeightHalf;
        _selectableButton = button;
    }
    return (STStandardNavigationButton *) _selectableButton;
}

#pragma mark Style
- (UIColor *)indexProgressColor {
    return _indexView.primaryColor;
}

- (void)setIndexProgressColor:(UIColor *)indexProgressColor {
    _indexView.primaryColor = indexProgressColor;
}


- (void)setBackgroundCircleColor:(UIColor*) color{
//    if(!_containerButton.backgroundView){
//        UIView * backgroundView = [[UIView alloc] initWithSizeWidth:[STStandardLayout widthMain]];
//        backgroundView.layer.mask = [CAShapeLayer circleRaster:backgroundView.width];
//        _containerButton.backgroundView = backgroundView;
//    }

    Weaks
    [UIView animateWithDuration:.6 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//        _indexView.primaryColor = color;

        Strongs
//        Sself->_containerButton.backgroundView.backgroundColor = color?:[STStandardUI buttonColorBack];
    } completion:nil];
}

- (UIColor *)backgroundCircleColor {
    return _indexView.primaryColor;//_containerButton.backgroundView.backgroundColor;
}

//- (void)setBackgroundCircleIconImageName:(NSString *) iconName{
//    if(![_backgroundCircleIconImageName isEqualToString:iconName]){
//        if(iconName){
//            [_containerButton setButtons:@[iconName] colors:@[[STStandardUI buttonColorFront]] bgColors:@[self.backgroundCircleColor] style:STStandardButtonStylePTTP blockForCreateBackgroundView:nil];
//        }else{
//            [_containerButton clearViews];
//        }
//    }
//    _backgroundCircleIconImageName = iconName;
//}

#pragma mark preview
- (void)setPreviewVisiblity:(CGFloat)previewVisiblity; {
    if(!self.contentDidCreated){
        return;
    }
    if(_previewVisiblity==previewVisiblity){
        return;
    }


    NSAssert(previewVisiblity>=0 && previewVisiblity<=1, @"previewVisiblity allowed 0 to 1.");

    _previewVisiblity = previewVisiblity;
//    [self _setPreviewVisiblity:previewVisiblity];
};

//- (void)_setPreviewVisiblity:(CGFloat)previewVisiblity; {
//    CGFloat marginInvisible = _preview.boundsWidthHalf;
//
//    _preview.visible = previewVisiblity > 0;
//    [_previewMask circleRadiusWithPadding:_preview.boundsAsSizeWidth padding:marginInvisible - (marginInvisible * previewVisiblity)];
//
//    [self _setPreviewFilter];
//}

- (void)setPreviewCurtain:(BOOL)previewCurtain; {
    if(_previewCurtain==previewCurtain){
        return;
    }
    _previewCurtain = previewCurtain;
}

- (void)_setPreviewFilter{
    if(![STElieCamera sharedInstance].captureSession.isRunning){
        oo(@"[!]WARNING : setPreviewFilter was called while [STElieCamera sharedInstance].captureSession.isRunning == NO");
    }

    STFilterItem * filterItem = [STMainControl sharedInstance].homeSelectedFilterItem;
    if(_previewFilterItem && [_previewFilterItem.uid isEqualToString:filterItem.uid]){
        return;
    }
    _previewFilterItem = filterItem;

    /*
     * remove previous filter
     */
    if(_previewFilterChain){
        [[STFilterManager sharedManager] clearOutputChain:_previewFilterChain];
        _previewFilterChain = nil;
    }
//    _previewFilterItem = nil;

    /*
     * add current filter
     */
    NSMutableArray * filterChain = [NSMutableArray array];
    //curtain effect
    if(_previewCurtain){

    }
    //user selected filters
    else{
        [filterChain addObject:[[STFilterManager sharedManager] acquire:filterItem]];
    }

    _previewFilterChain = [[STFilterManager sharedManager] buildOutputChain:[STElieCamera sharedInstance] filters:filterChain to:_preview enhance:NO];
}

- (void)setPreviewQuickCaptureMode:(BOOL)previewQuickCaptureMode; {
    if(_previewQuickCaptureMode == previewQuickCaptureMode){
        return;
    }
    _previewQuickCaptureMode = previewQuickCaptureMode;

    self.userInteractionEnabled = NO;

    static CGRect _previewOriginalBounds;
    BlockOnce(^{
        _previewOriginalBounds = _preview.bounds;
    });

    if(previewQuickCaptureMode){
        Weaks
        [self insertSubview:_preview aboveSubview:self.subviews.last];
        _containerButton.visible = NO;
//        [_indicatorContainer st_springCGPoint:CGPointMake(.7,.7) keypath:@"scaleXY"];

        CGFloat scaleFactor = [STPhotoSelector sharedInstance].width/(_previewOriginalBounds.size.width+5);

        [_preview st_springCGRect:CGRectApplyAffineTransform(_previewOriginalBounds, CGAffineTransformMakeScale(scaleFactor, scaleFactor)) block:^(id target, CGRect rect) {
            _preview.bounds = rect;
            _preview.bottom = [STElieStatusBar sharedInstance].height;

            [_previewMask circleRadius:_preview.boundsWidth];
            _previewMask.positionY = _preview.boundsHeightHalf-_previewMask.pathHeightHalf;
        } completion:^(POPAnimation *anim, BOOL finished) {
            _previewExpended = finished;
            Wself.userInteractionEnabled = YES;

            if(finished){
                if(Wself.previewSuspending){
                    [_preview st_coverBlurIfNotShown];
                }
            }
        }];

    }else{
        if(self.previewSuspending){
            _previewSuspending = NO;
            [_preview st_coverRemove:NO];
        }

        UIView * previewStroke = [self viewWithTagNameFirst:@"previewStroke"];
        [previewStroke removeFromSuperview];

        _containerButton.visible = YES;
        [_containerButton insertSubview:_preview belowSubview:_indexView];
//        [_indicatorContainer st_springCGPoint:CGPointMake(1,1) keypath:@"scaleXY"];

        [_preview st_springCGRect:CGRectApplyAffineTransform(_previewOriginalBounds, CGAffineTransformMakeScale(1, 1)) block:^(id target, CGRect rect) {
            _preview.bounds = rect;
            _preview.bottom = self.initialBounds.size.height/2+_preview.boundsHeightHalf;

            [_previewMask circleRadius:_preview.boundsWidth];
            _previewMask.positionY = _preview.boundsHeightHalf-_previewMask.pathHeightHalf;

        } completion:^(POPAnimation *anim, BOOL finished) {
            _previewExpended = !finished;
        }];
    }
}

- (void)setPreviewSuspending:(BOOL)previewSuspending; {
    _previewSuspending = previewSuspending;

    if(_previewExpended){
    }
            previewSuspending ? [_preview st_coverBlurIfNotShown] : [_preview st_coverBlurRemoveIfShowen];
//    previewSuspending ? [_preview st_coverBlurSnapshot:YES styleDark:YES completion:nil] : [_preview st_coverBlurRemoveIfShowen];
}

#pragma mark spinner
- (void)setSpinnerVisiblity:(BOOL)spinnerVisiblity; {
    if(!STPermissionManager.camera.isAuthorized){
        spinnerVisiblity = NO;
    }

    if(spinnerVisiblity){
        [STStandardUX resetAndRevertStateAfterShortDelay:@"home.spinner" block:^{
            [self st_runAsMainQueueAsync:^{
                _spinner.visible = YES;
                [_spinner startAnimating];
            }];
        }];

    }else{
        [STTimeOperator st_clearPerformOnceAfterDelay:@"home.spinner"];
        [_spinner stopAnimating];
        _spinner.visible = NO;
    }
    _spinnerVisiblity = spinnerVisiblity;

}

#pragma mark Index

- (void)setIndexProgressDisplayInstantly:(BOOL)indexProgressDisplayInstantly; {
    _indexProgressDisplayInstantly = indexProgressDisplayInstantly;

    if(!indexProgressDisplayInstantly){
        [UIView st_removeDelayedToggleAlpha:_subIndexView ? @[_indexView, _subIndexView] : @[_indexView]];
    }
}

- (void)setIndexNumberOfSegments:(NSInteger)numberOfSegment; {
    if(numberOfSegment < 0){
        return;
    }
    [self _setIndexNumberOfSegments:numberOfSegment];
}

- (void)_setIndexNumberOfSegments:(NSInteger)numberOfSegment; {
    _indexView.visible = 1 <= numberOfSegment;
    [_indexView layoutSubviews];
}

- (void)setIndexProgress:(CGFloat)progress; {
    if([_indexView progress] == progress || progress < 0){
        return;
    }

    if(self.indexProgressDisplayInstantly){
        Weaks
        if([UIView st_setDelayedToggleAlpha:_subIndexView ? @[_indexView, _subIndexView] : @[_indexView]
                                      delay:[STStandardUX delayShortForUserRecognize]] == 1){
            [Wself _setIndexProgress:progress];
        }
    }else{
        [self _setIndexProgress:progress];
    }
}

- (CGFloat)indexProgress; {
    return [_indexView progress];
}

- (void)_setIndexProgress:(CGFloat)progress; {
    if(__inline_isnanf(progress)){
        return;
    }

    if(_indexView.visible){
        [_indexView setProgress:progress animated:NO];
        [_indexView layoutSubviews];
    }

    if(_subIndexView && _subIndexView.visible){
        [_subIndexView setProgress:progress animated:NO];
        [_subIndexView layoutSubviews];
    }
}

- (UIImage *)snapshotCurrent; {
    return [_preview st_takeSnapshot:_preview.bounds afterScreenUpdates:NO useTransparent:NO maxTwiceScale:YES];
}

- (void)setLogoProgress:(CGFloat)progress; {
    _logoProgress = progress;

    _logoView.visible = progress>0;
    [_logoView setProgress:progress];
}

@end
