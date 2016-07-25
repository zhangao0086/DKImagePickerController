//
// Created by BLACKGENE on 2014. 10. 30..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Colours/Colours.h>
#import "STSubControl.h"
#import "STPhotoSelector.h"
#import "UIView+STUtil.h"
#import "STGIFFAppSetting.h"
#import "STStandardButton.h"
#import "STEditorCommand.h"
#import "STTransformEditorCommand.h"
#import "NSObject+STPopAnimatableProperty.h"
#import "STMainControl.h"
#import "NSString+STUtil.h"
#import "STStandardNavigationButton.h"
#import "R.h"


#import "BlocksKit.h"
#import "NSNumber+STUtil.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "NSGIF.h"
#import "STPhotoItem+STExporterIO.h"
#import "NSArray+STUtil.h"
#import "STExporter+IOGIF.h"
#import "STPhotoItem+STExporterIOGIF.h"
#import "NSObject+STUtil.h"
#import "STElieStatusBar.h"
#import "STApp+Logger.h"

@implementation STSubControl {
    STControlDisplayMode _mode;
    STControlDisplayMode _previousMode;
    STSubControlVisibleEffect _lastVisbleEffect;
    STStandardNavigationButton *_left;
    NSMutableDictionary *_leftLastSelectedIndex;
    NSMutableDictionary *_leftFuturePromiseSelectedIndex;
    NSMutableDictionary *_leftFuturePromiseBadgeTexts;

    STStandardNavigationButton *_right;
    NSMutableDictionary *_rightLastSelectedIndex;
    NSMutableDictionary *_rightFuturePromiseSelectedIndex;
    NSMutableDictionary *_rightFuturePromiseBadgeTexts;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _mode = STControlDisplayModeMain_initial;
        _lastVisbleEffect = STSubControlVisibleEffectNone;

        CGFloat subControlWidth = [STStandardLayout widthMainSmall];
        CGFloat minDistanceFromCenterX = ([STStandardLayout widthMain] + [STStandardLayout widthSubAssistance]*2 + subControlWidth)/2;
        minDistanceFromCenterX += (self.width/4-minDistanceFromCenterX/2)/2;

        _left = [[STStandardNavigationButton alloc] initWithSizeWidth:subControlWidth];
        _left.centerX = self.centerX - minDistanceFromCenterX;
        _left.centerY = self.centerY;
        [_left saveInitialLayout];
        _left.allowSelectAsTap = YES;
//        _left.shadowOffset = 1.8f;
//        _left.shadowEnabled = YES;
//        _left.autoOrientationEnabled = YES;
        _left.autoOrientationAnimationEnabled = YES;
        _left.invertMaskInButtonAreaForCollectableBackground = YES;
        _leftLastSelectedIndex = [NSMutableDictionary dictionary];
        _leftFuturePromiseSelectedIndex = [NSMutableDictionary dictionary];
        _leftFuturePromiseBadgeTexts = [NSMutableDictionary dictionary];

        _right = [[STStandardNavigationButton alloc] initWithSizeWidth:subControlWidth];
        _right.centerX = self.centerX + minDistanceFromCenterX;
        _right.centerY = self.centerY;
        [_right saveInitialLayout];
        _right.allowSelectAsTap = YES;
//        _right.shadowOffset = _left.shadowOffset;
//        _right.shadowEnabled = YES;
//        _right.autoOrientationEnabled = YES;
        _right.autoOrientationAnimationEnabled = YES;
        _right.invertMaskInButtonAreaForCollectableBackground = YES;
        _rightLastSelectedIndex = [NSMutableDictionary dictionary];
        _rightFuturePromiseSelectedIndex = [NSMutableDictionary dictionary];
        _rightFuturePromiseBadgeTexts = [NSMutableDictionary dictionary];

    }
    return self;
}

- (void)didCreateContent; {
    [super didCreateContent];

    [self addSubview:_left];
    [self addSubview:_right];

    [STStandardUI setDropShadowWithDarkBackground:_left.layer];
    [STStandardUI setDropShadowWithDarkBackground:_right.layer];
}

- (void)layoutSubviewsByMode:(STControlDisplayMode)mode previousMode:(STControlDisplayMode)previousMode; {
    BOOL changed = _mode != mode;

    if(changed){
        [self willChangeLayoutSubviewsByMode:mode previousMode:previousMode];

        _previousMode = previousMode;
        _mode = mode;

        [self setNeedsButtonDisplay];
        [self setNeedsStateByCurrentModeIfNeeded];
    }
}

- (void)willChangeLayoutSubviewsByMode:(STControlDisplayMode)mode previousMode:(STControlDisplayMode)previousMode{
    //clear last index
    BOOL clearLastIndex = (previousMode==STControlDisplayModeEdit && mode==STControlDisplayModeHome)
            || (previousMode==STControlDisplayModeLivePreview)
            || (previousMode==STControlDisplayModeEditAfterCapture && mode==STControlDisplayModeLivePreview);

    if(clearLastIndex){
        [self _clearLastIndex:previousMode];
    }else{
        [self _setLastIndex];
    }

    //clear previos view state
    if(_lastVisbleEffect != STSubControlVisibleEffectNone){
        [self setVisibleWithEffect:YES effect:_lastVisbleEffect];
        _lastVisbleEffect = STSubControlVisibleEffectNone;
    }
}

#pragma mark Effect
- (void)setVisibleWithEffect:(BOOL)visible effect:(STSubControlVisibleEffect)effect{
    [self visibleWithEffect:visible effect:effect completion:nil];
}

- (void)visibleWithEffect:(BOOL)visible effect:(STSubControlVisibleEffect)effect completion:(void (^)(POPAnimation *anim, BOOL finished))completion;{
    [self setVisibleWithEffect:visible effect:effect relationView:nil completion:completion];
}

- (void)setVisibleWithEffect:(BOOL)visible effect:(STSubControlVisibleEffect)effect relationView:(UIView *)view completion:(void (^)(POPAnimation *anim, BOOL finished))completion;{
    _lastVisbleEffect = effect;

    /*
     * default
     */
    if(effect==STSubControlVisibleEffectNone){
        _left.visible = visible;
        _right.visible = visible;
        !completion?:completion(nil,YES);
        return;
    }

    /*
     * other
     */
    //will animation
    switch(effect) {
        case STSubControlVisibleEffectEnterCenter:
        case STSubControlVisibleEffectOutside:
            [_left pop_removeAllAnimations];
            [_right pop_removeAllAnimations];
            break;
        default:
            break;
    }

    //perform visible animation
    if(visible){
        switch(effect) {
            case STSubControlVisibleEffectEnterCenter:{
                [STStandardUX setAnimationFeelToRelaxedSpring:_left];
                [STStandardUX setAnimationFeelToRelaxedSpring:_right];

                _left.animatableVisible = YES;
                [_left st_springCGRect:_left.initialFrame keypath:@"frame" completion:completion];

                _right.animatableVisible = YES;
                [_right st_springCGRect:_right.initialFrame keypath:@"frame"];
            };
            case STSubControlVisibleEffectOutside:
            {
                [_left st_springCGRect:_left.initialFrame keypath:@"frame" completion:completion];
                [_right st_springCGRect:_right.initialFrame keypath:@"frame"];
                break;
            };
            case STSubControlVisibleEffectCover:{
                switch(_mode){
                    case STControlDisplayModeMain:{
                        if(view){
                            [_left coverWithBlur:[STPhotoSelector sharedInstance] presentingTarget:view comletion:^(STStandardButton *button, BOOL covered) {
                                !completion ?: completion(nil, covered);
                            }];
                        }
                        break;
                    };
                    default:
                        break;
                }
            };
            default:
                break;
        }

    }else{

        switch(effect) {
            case STSubControlVisibleEffectEnterCenter:{
                [STStandardUX setAnimationFeelToRelaxedSpring:_left];
                [STStandardUX setAnimationFeelToRelaxedSpring:_right];

                [UIView animateWithDuration:.3 animations:^{
                    _left.alpha = 0;
                    _right.alpha = 0;
                }];
                [_left st_springCGPoint:self.center keypath:@"center" completion:completion];
                [_right st_springCGPoint:self.center keypath:@"center"];

                break;
            };

            case STSubControlVisibleEffectOutside:{
                [_left st_springCGFloat:0 keypath:@"right" completion:completion];
                [_right st_springCGFloat:self.width keypath:@"left"];
                break;
            };

            case STSubControlVisibleEffectCover:{
                switch(_mode){
                    case STControlDisplayModeHome:{
                        if(view){
                            [_left uncoverWithBlur:YES comletion:^(STStandardButton *button, BOOL covered) {
                                !completion?:completion(nil,YES);
                            }];
                        }
                        break;
                    };
                    default:
                        break;
                }
                break;
            };

            default:
                break;
        }
    }
}

#pragma mark ButtonsDisplay
- (void)resetDefaultButtonsDisplay {

    [@[_left, _right] each:^(STStandardNavigationButton * button) {
        button.titleText = nil;

        button.animatableVisible = YES;
        button.animatableVisible = YES;

        [button retract];
        button.denySelect = NO;
        button.shadowEnabled = NO;

        button.animatableVisible = YES;
        button.denyDeselectWhenAlreadySelected = NO;
        button.valuesMap = nil;
        button.synchronizeCollectableSelection = NO;

        button.autoRetractWhenSelectCollectableItem = NO;
        button.autoUXLayoutWhenExpanding = YES;

        button.toggleEnabled = NO;
        button.collectablesSelectAsIndependent = NO;
        button.collectableSelectedState = NO;
        button.collectableToggleEnabled = NO;

        [button whenToggled:nil];
        [button whenSelected:nil];
        [button whenCollectableSelected:nil];

        button.badgeVisible = NO;
    }];
}

- (void)setCommonButtonDisplay{
    [@[_left, _right] each:^(STStandardNavigationButton * button) {
        button.backgroundViewAsColoredImage = [STStandardUI buttonColorBackgroundOverlay];
        button.backgroundView.alpha = [STStandardUI alphaForGlassLikeOverlayButtonBackground];
        button.alphaCollectableBackground = STStandardUI.alphaForDimmingMoreWeak;
    }];
}

#pragma mark setNeedsButtonDisplay
- (void)setNeedsButtonDisplay {
    [self resetDefaultButtonsDisplay];

    STStandardButtonStyle defaultStyle = STStandardButtonStylePTTP;
    STStandardButtonStyle defaultCollectableStyle = STStandardButtonStylePTBT;
    STStandardButtonStyle defaultCollectableBackgroundStyle = STStandardButtonStyleSkipImageInvertNormalDimmed;

    if(_mode == STControlDisplayModeHome){
        _left.visible = NO;
        _right.visible = NO;
//        [_left setButtons:@[[R set_main_preset_current]] colors:nil style:defaultStyle];
//        [_left whenSelected:^(STSelectableView *button, NSInteger index) {
//            [[STMainControl sharedInstance] main];//index==1 ? [[STMainControl sharedInstance] main] : [[STMainControl sharedInstance] home];
//        }];
//        _left.shadowEnabled = YES;
//        _left.backgroundView.alpha = [STStandardUI alphaForStrongGlassLikeOverlayButtonBackground];
//
//        Weaks
//        [_right setButtons:@[[R go_room_current], [R go_roll]] colors:nil style:defaultStyle];
//        [_right whenSelected:^(STSelectableView *button, NSInteger index) {
//            STPhotoSource destSource = index == 0 ? STPhotoSourceAssetLibrary : STPhotoSourceRoom;
//            button.userInteractionEnabled = NO;
//
//            [button st_performAfterDelay:.01 block:^{
//                [[STPhotoSelector sharedInstance] doChangeSource:destSource canChange:^(BOOL canChange) {
//                    STStandardButton * _button = Wself.rightButton;
//                    if (!canChange) {
//                        if(_button.currentIndex!=_button.lastSelectedIndex){
//                            _button.currentIndex = _button.lastSelectedIndex;
//                        }
//                        [STStandardUX expressDenied:_button];
//                    }
//                    _button.userInteractionEnabled = YES;
//                }];
//            }];
//        }];
////        _right.currentIndex = (NSUInteger) [[[STGIFFAppSetting get] read:@keypath([STGIFFAppSetting get].photoSource)] integerValue];
//        _right.badgeVisible = YES;
//        _right.shadowEnabled = YES;
//        _right.backgroundView.alpha = _left.backgroundView.alpha;

    }
    else if(_mode == STControlDisplayModeExport){
        Weaks
        [_left setButtons:@[R.go_back] colors:nil style:defaultStyle];
        [_left whenSelected:^(STSelectableView *button, NSInteger index) {
            [[STPhotoSelector sharedInstance] deselectAllCurrentSelected];
            [[STMainControl sharedInstance] back];
        }];
//        _left.shadowEnabled = YES;

        //right
//        _right.shadowEnabled = YES;
        switch (_previousMode){
            case STControlDisplayModeEditAfterCapture:
                _right.animatableVisible = NO;
                break;
            case STControlDisplayModeReviewAfterAnimatableCapture:
                break;
            default:{
                [_right setButtons:@[[R go_remove]] colors:@[[STStandardUI negativeColor]] style:defaultStyle];
                [_right whenSelected:^(STSelectableView *button, NSInteger index) {

                    switch (_previousMode){
                        case STControlDisplayModeEdit:
                            [[STPhotoSelector sharedInstance] deletePhotos:[[STPhotoSelector sharedInstance] currentFocusedPhotoItems] completion:^(BOOL succeed) {
                                if(succeed){
                                    [[STPhotoSelector sharedInstance] doCancelEdit:STPhotoViewTypeGrid transition:STPreviewCollectorExitTransitionContextDeletingInExport];
                                    [[STMainControl sharedInstance] home];
                                }else{
                                    [[STMainControl sharedInstance] back];
                                }
                            }];
                            break;
                        case STControlDisplayModeHome:
                            [[STPhotoSelector sharedInstance] deleteAllSelectedPhotos:nil];
                            break;
                        default:
                            break;
                    }
                }];
                break;
            }
        }
    }
    else if(_mode == STControlDisplayModeEdit){

        Weaks
        [_left setButtons:@[R.go_back] colors:nil style:defaultStyle];
        [_left whenSelected:^(STSelectableView *button, NSInteger index) {
            [[STPhotoSelector sharedInstance] doCancelEdit];
        }];
        //reset
        [self _setNeedsCollectablesForReset:_left whenReset:^(STStandardButton *button, NSUInteger index) {
            Strongs
            [Sself->_left retract:YES];
            [[STPhotoSelector sharedInstance] doResetPreview];
        }];

        [_right setButtons:@[[R go_transform], [R go_transform_undo]] colors:nil style:defaultStyle];
        [_right whenSelected:^(STSelectableView *button, NSInteger index) {
            if(index==1){
                [[STPhotoSelector sharedInstance] doEnterTool];
            }else{
                [[STPhotoSelector sharedInstance] doUndoTool];
            }
        }];
        [self _setNeedsCollectablesForAutoEnhanceInEditMode:_right];
        [_right expand];
    }
    else if(_mode == STControlDisplayModeEditAfterCapture){
        Weaks
        if(_previousMode==STControlDisplayModeHome){
            //from grid
            [_left setButtons:@[[R go_back]] colors:nil style:defaultStyle];

            [_left setCollectables:@[[R set_reset],R.go_remove] colors:@[[NSNull null], [STStandardUI negativeColor]] bgColors:nil size:[STStandardLayout sizeSubAssistance] style:STStandardButtonStylePTBT backgroundStyle:STStandardButtonStyleSkipImageInvertNormalDimmed];
            [_left whenCollectableSelected:^(STStandardButton *button, NSUInteger index) {
                Strongs
                if(index==0){
                    [[STPhotoSelector sharedInstance] doResetPreview];
                }else{
                    [[STPhotoSelector sharedInstance] deletePhotos:[[STPhotoSelector sharedInstance] currentFocusedPhotoItems] completion:^(BOOL succeed) {
                        if(succeed){
                            [_left dispatchSelected];
                        }
                    }];
                }
            }];
            //hide reset
            [_left expand:YES];
            [_left.collectableView itemViewAtIndex:0].visible = NO;

        }else{
            //from camera
            [_left setButtons:@[R.go_x] colors:nil style:defaultStyle];

            [self _setDefaultCollectableButtons:_left imageNames:@[[R set_reset]]];
            [_left whenCollectableSelected:^(STStandardButton *button, NSUInteger index) {
                Strongs
                [Sself->_left retract:YES];
                [[STPhotoSelector sharedInstance] doResetPreview];
            }];
        }
        [_left whenSelected:^(STSelectableView *button, NSInteger index) {
            [[STPhotoSelector sharedInstance] doExitEditAndCancelAfterCapture];
        }];
        //reset
        _left.collectablesSelectAsIndependent = NO;

        /*
         * right
         */
        if([STPhotoSelector sharedInstance].previewTargetPhotoItem.sourceForCapturedImageSet){
            //stop if change main mode
            [[STMainControl sharedInstance] whenNewValueOnceOf:@keypath([STMainControl sharedInstance].mode) id:@"STSubControl_[STMainControl sharedInstance].mode" changed:^(id value, id _weakSelf) {
                [[STPhotoSelector sharedInstance].previewView stopLoopingSliderValue];
            }];

            //start loop
//            [[STPhotoSelector sharedInstance].previewView startLoopingSliderValue:YES];

            [_right setButtons:@[[R ico_animatable]] colors:nil style:defaultStyle];
            _right.toggleEnabled = YES;
            _right.selectedState = NO;

            [_right whenToggled:^(STStandardButton *selectedView, BOOL selected) {

                if(selected){

                    NSArray * photoItems = [[[STPhotoSelector sharedInstance] currentFocusedPhotoItems] mapWithIndex:^id(STPhotoItem * item, NSInteger index) {
                        item.exportGIFRequest = [[NSGIFRequest alloc] init];
                        item.exportGIFRequest.destinationVideoFile = [[@"STExporter_exportGIFsFromPhotoItems" st_add:[@(index) stringValue]] URLForTemp:@"gif"];
                        item.exportGIFRequest.maxDuration = 2;
                        return item;
                    }];

                    [_right retract];
                    [_right startAlert];
                    _right.selectedState = NO;

                    [[STElieStatusBar sharedInstance] message:NSLocalizedString(@"Please wait for a moment.",nil) showLogoAfterDelay:NO];

                    [STApp logUnique:@"StartExportGIF"];

                    [STExporter exportGIFsFromPhotoItems:YES photoItems:photoItems progress:^(CGFloat d) {

                    } completion:^(NSArray *gifURLs, NSArray *succeedItems, NSArray *errorItems) {
                        [_right stopAlert];

//                        FLAnimatedImageView * imageView = [[FLAnimatedImageView alloc] initWithSize:[STPhotoSelector sharedInstance].previewView.size];
//                        [[self st_rootUVC].view addSubview:imageView];
//                        imageView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:((NSURL *)[gifURLs firstObject]).path options:NSDataReadingUncached error:NULL]];;

                        if(gifURLs.count){
                            _right.selectedState = YES;

                            [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueueOnlyOnce:self forName:STPreviewCollectorNotificationPreviewBeginDragging usingBlock:^(NSNotification *note, id observer) {
                                selectedView.selectedState = NO;
                                [selectedView dispatchToggled];
                            }];

                            [[STPhotoSelector sharedInstance].previewView startLoopingSliderValue:YES];

                            [[STElieStatusBar sharedInstance] success];
                        }else{

                            [STStandardUX expressDenied:_right];
                            _right.selectedState = NO;
                            [_right expand];

                            [[STElieStatusBar sharedInstance] fail];
                        }
                    }];

                }else{
                    [_right expand];

                    [[STPhotoSelector sharedInstance].previewView stopLoopingSliderValue];
                }
            }];

            _right.titleLabelPositionedGapFromButton = [STStandardLayout gapForButtonBottomToTitleLabel]/2;
            _right.titleText = @"GIF";

        }else{
            [_right setButtons:@[[R go_transform], [R go_transform_undo]] colors:nil style:defaultStyle];
            [_right whenSelected:^(STSelectableView *button, NSInteger index) {
                if(index==1){
                    [[STPhotoSelector sharedInstance] doEnterTool];
                }else{
                    [[STPhotoSelector sharedInstance] doUndoTool];
                }
            }];
        }

        [self _setNeedsCollectablesForAutoEnhanceInEditMode:_right];
        [_right expand];

    }
    else if(_mode == STControlDisplayModeReviewAfterAnimatableCapture){
        Weaks
        [_left setButtons:@[R.go_x]colors:nil style:defaultStyle];

        [_left whenSelected:^(STSelectableView *button, NSInteger index) {
            [[STPhotoSelector sharedInstance] doExitAnimatableReviewAfterCapture];
        }];
        //reset
        [self _setNeedsCollectablesForReset:_left whenReset:^(STStandardButton *button, NSUInteger index) {
            Strongs
            [Sself->_left retract:YES];
            [[STPhotoSelector sharedInstance] doResetPreview];
        }];

        [_right setButtons:@[[R go_transform], [R go_transform_undo]] colors:nil style:defaultStyle];

        [_right whenSelected:^(STSelectableView *button, NSInteger index) {
//            if(index==1){
//                [[STPhotoSelector sharedInstance] doEnterTool];
//            }else{
//                [[STPhotoSelector sharedInstance] doUndoTool];
//            }
        }];

        [self _setNeedsCollectablesForAutoEnhanceInEditMode:_right];
        [_right expand];

    }
    else if(_mode == STControlDisplayModeEditTool){
        Weaks

        [_left setButtons:@[R.go_x] colors:nil style:defaultStyle];
        [_left whenSelected:^(STSelectableView *button, NSInteger index) {
            [Wself _setRightPromiseIndexIfBackToPreviousMode:0];
            [[STPhotoSelector sharedInstance] doCancelTool];
        }];
        //reset
        [self _setNeedsCollectablesForReset:_left whenReset:^(STStandardButton *button, NSUInteger index) {
            if (![[STPhotoSelector sharedInstance] doCommandTool:[[STTransformEditorCommand create] reset]]) {
                [STStandardUX expressDenied:button];
            }
        }];

        [_right setButtons:@[[R set_transform_square]] colors:nil style:defaultStyle];
        _right.toggleEnabled = YES;
        [_right whenToggled:^(STStandardButton *selectedView, BOOL selected) {
            [[STPhotoSelector sharedInstance] doCommandTool:selected ? [[STTransformEditorCommand create] square] : [[STTransformEditorCommand create] defaultAspectRatio]];
        }];
        // rotation, aspect ratio
        _right.collectablesSelectAsIndependent = NO;
        [_right setCollectablesAsDefault:@[[R set_transform_rotate90]]];
        [_right whenCollectableSelected:^(STStandardButton *button, NSUInteger index) {
            [[STPhotoSelector sharedInstance] doCommandTool:[[STTransformEditorCommand create] rotateLeft]];
        }];
        [_right expand];

    }
    else if(_mode == STControlDisplayModeLivePreview){
        /*
         * left
         */
        // torchlight
        [self.class torchLightSwitcher:_left setButtonsBlock:^(__weak STStandardButton *Self, NSArray *imageNames, NSArray *colors) {
            [Self setButtons:imageNames colors:nil style:defaultStyle];
        }];
        _left.collectablesSelectAsIndependent = YES;

        //reset
        Weaks
        [self _setNeedsCollectablesForReset:_left whenReset:^(STStandardButton *button, NSUInteger index) {
            Strongs
            [Sself->_left retract:YES];
            [[STPhotoSelector sharedInstance] doResetPreview];
        }];

        /*
         * right
         */
        NSArray * valuesForPostFocus = @[
                @(STPostFocusModeFullRange),
                @(STPostFocusModeVertical3Points),
                @(STPostFocusMode5Points)
        ];

        [_right setButtons:[valuesForPostFocus bk_map:^id(id obj) {
            switch ((STPostFocusMode)[obj integerValue]){
                case STPostFocusModeVertical3Points:
                    return [R set_postfocus_vertical_3point];
                case STPostFocusMode5Points:
                    return [R set_postfocus_point];
                case STPostFocusModeFullRange:
                    return [R set_postfocus_fullrange];
                case STPostFocusModeNone:
                    return [R ico_camera];
                default:
                    NSParameterAssert(NO);
                    return nil;
            }
        }] colors:nil style:defaultStyle];
        _right.valuesMap = valuesForPostFocus;
        _right.currentMappedValue = @(STGIFFAppSetting.get.postFocusMode);
        [_right whenSelectedWithMappedValue:^(STSelectableView *_button, NSInteger index, id value) {
            STGIFFAppSetting.get.postFocusMode = [value integerValue];

//            [self.class setExtractRetractForPostFocusMode:_right postFocusMode:[_right.currentMappedValue integerValue] animation:YES];

            if([value integerValue]!=STPostFocusModeNone && [_right.valuesMap[_right.lastSelectedIndex] integerValue]==STPostFocusModeNone){
                //reset preview
                [[STPhotoSelector sharedInstance].previewView resetAFAE];
                [[STPhotoSelector sharedInstance].previewView resetExposure];

                //change facing camera
                if([[_right currentCollectableButton].currentMappedValue boolValue]){
                    [_right currentCollectableButton].currentMappedValue = @(NO);
                    [[_right currentCollectableButton] dispatchSelected];
                }
            }

            NSString * labelPostFocusMode = [STGIFFAppSetting.get labelForPostFocusMode:(STPostFocusMode) [value integerValue]];
            if(labelPostFocusMode){
                [[STElieStatusBar sharedInstance] message:labelPostFocusMode];
            }
        }];

        //front/back - collectable
//        STStandardButton *facingCameraSwitcherCollectable = [STStandardButton subAssistanceSize];
//        facingCameraSwitcherCollectable.allowSelectedStateFromTouchingOutside = YES;
//        facingCameraSwitcherCollectable.preferredIconImagePadding = facingCameraSwitcherCollectable.height/6;
//        [facingCameraSwitcherCollectable setButtons:@[[R set_manual_rear],[R set_manual_front]] colors:@[[STStandardUI pointColor],[STStandardUI pointColor]] style:defaultCollectableStyle];
//        facingCameraSwitcherCollectable.valuesMap = @[@(NO), @(YES)];
//        facingCameraSwitcherCollectable.currentMappedValue = [STElieCamera sharedInstance].isPositionFront ? @(YES) : @(NO);
//        [facingCameraSwitcherCollectable whenSelectedWithMappedValue:^(STSelectableView *button, NSInteger index, id value) {
//
//            //if STCameraModeManualWithElie is On
//            [_left pop_removeAllAnimations];
//            if([value boolValue]){
//                _left.denySelect = YES;
//                _left.currentMappedValue = @(STTorchLightModeOff);
//                _left.currentButtonView.easeInEaseOut.alpha = [STStandardUI alphaForDimmingGhostly];
//                [_left dispatchSelected];
//            }else{
//                _left.denySelect = NO;
//                _left.currentButtonView.easeInEaseOut.alpha = 1;
//            }
//
//            [[STPhotoSelector sharedInstance] doBlurPreviewBegin];
//            [[STElieCamera sharedInstance] changeFacingCamera:[value boolValue] completion:^(BOOL changed){
//                [[STPhotoSelector sharedInstance] doBlurPreviewEnd];
//            }];
//        }];

        // save policy
//        STStandardButton *manualAfterCaptureCollectable = [STStandardButton subAssistanceSize];
//        manualAfterCaptureCollectable.allowSelectedStateFromTouchingOutside = YES;
//        [manualAfterCaptureCollectable setButtons:@[[R set_manual_continue], [R set_manual_single]] colors:@[[STStandardUI pointColor],[STStandardUI pointColor]] style:STStandardButtonStylePTBT];
//        manualAfterCaptureCollectable.valuesMap = @[@(STAfterManualCaptureActionSaveToLocalAndContinue), @(STAfterManualCaptureActionEnterEdit)];
//        manualAfterCaptureCollectable.currentMappedValue = @(STGIFFAppSetting.get.afterManualCaptureAction);
//        [manualAfterCaptureCollectable whenSelectedWithMappedValue:^(STSelectableView *button, NSInteger index, id value) {
//            STGIFFAppSetting.get.afterManualCaptureAction = [value integerValue];
//        }];
//
//        _right.collectablesSelectAsIndependent = NO;
//        _right.collectableToggleEnabled = YES;
//
//        [_right setCollectablesAsButtons:@[manualAfterCaptureCollectable] backgroundStyle:STStandardButtonStylePTTP];
//
//        [_right expand:NO];
//        [self.class setExtractRetractForPostFocusMode:_right postFocusMode:[_right.currentMappedValue integerValue] animation:NO];

    }
    else if(_mode == STControlDisplayModeMain){


    }else{

    }

    // Common button display
    [self setCommonButtonDisplay];

    // FuturePromise -> LastSelectedIndex
    if(_leftFuturePromiseSelectedIndex[@(_mode)]){
        _left.currentIndex = [_leftFuturePromiseSelectedIndex[@(_mode)] unsignedIntegerValue];
        [_leftFuturePromiseSelectedIndex removeObjectForKey:@(_mode)];
    }else{
        if(_leftLastSelectedIndex[@(_mode)]){
            _left.currentIndex = [_leftLastSelectedIndex[@(_mode)] unsignedIntegerValue];
        }
    }

    if(_rightFuturePromiseSelectedIndex[@(_mode)]){
        _right.currentIndex = [_rightFuturePromiseSelectedIndex[@(_mode)] unsignedIntegerValue];
        [_rightFuturePromiseSelectedIndex removeObjectForKey:@(_mode)];

    }else{
        if(_rightLastSelectedIndex[@(_mode)]){
            _right.currentIndex = [_rightLastSelectedIndex[@(_mode)] unsignedIntegerValue];
        }
    }

    //Badge Text
    [self setNeedsBadgeTextToRight];
    [self setNeedsBadgeTextToLeft];
}

#pragma mark setNeedsStateIfNeeded
- (void)setNeedsStateByCurrentModeIfNeeded; {

}

#pragma mark setActions By Functions
- (STStandardNavigationButton * )_setNeedsCollectablesForReset:(STStandardNavigationButton *)target whenReset:(void (^)(STStandardButton *button, NSUInteger index))block;{
    //reset
    target.collectablesSelectAsIndependent = NO;
    [self _setDefaultCollectableButtons:target imageNames:@[[R set_reset]]];
    [target whenCollectableSelected:block];

    return target;
}

- (STStandardNavigationButton * )_setNeedsCollectablesForAutoEnhanceInEditMode:(STStandardNavigationButton *)target {
    target.collectablesSelectAsIndependent = NO;
    [self _setDefaultCollectableButtons:target imageNames:@[[R set_edit_autoenhance]]];
    target.collectableToggleEnabled = YES;
    target.collectableSelectedState = [[STGIFFAppSetting.get read:@keypath([STGIFFAppSetting get].autoEnhanceEnabledInEdit)] boolValue];
    [target whenCollectableSelected:^(STStandardButton *collectableButton, NSUInteger index) {
        STGIFFAppSetting.get.autoEnhanceEnabledInEdit = target.collectableSelectedState;

    }];
    return target;
}


- (void)_setDefaultCollectableButtons:(STStandardNavigationButton *)target imageNames:(NSArray *)images{
    [target setCollectables:images colors:nil bgColors:nil size:[STStandardLayout sizeSubAssistance] style:STStandardButtonStylePTBT backgroundStyle:STStandardButtonStyleSkipImageInvertNormalDimmed];
}


#pragma mark man index
- (void)_clearLastIndex:(STControlDisplayMode) mode{
    [_leftLastSelectedIndex removeObjectForKey:@(mode)];
    [_rightLastSelectedIndex removeObjectForKey:@(mode)];
}

- (void)_setLastIndex{
    _leftLastSelectedIndex[@(_mode)] = @(_left.currentIndex);
    _rightLastSelectedIndex[@(_mode)] = @(_right.currentIndex);
}

- (void)_setRightPromiseIndex:(NSUInteger)index{
    _rightFuturePromiseSelectedIndex[@(_mode)] = @(index);
}

- (void)_setRightPromiseIndexIfBackToPreviousMode:(NSUInteger)index{
    _rightFuturePromiseSelectedIndex[@(_previousMode)] = @(index);
}

- (void)_setLeftPromiseIndex:(NSUInteger)index{
    _leftFuturePromiseSelectedIndex[@(_mode)] = @(index);
}

- (void)_setLeftPromiseIndexFroBackToPreviousMode:(NSUInteger)index{
    _leftFuturePromiseSelectedIndex[@(_previousMode)] = @(index);
}

#pragma mark Badge
//left
- (void)setBadgeToLeft:(NSString *)text mode:(STControlDisplayMode)mode; {
    _leftFuturePromiseBadgeTexts[@(mode)] = text;

    if(_mode==mode){
        [self setNeedsBadgeTextToLeft];
    }
}

- (void)setNeedsBadgeTextToLeft {
    if(_leftFuturePromiseBadgeTexts.count && [_leftFuturePromiseBadgeTexts hasKey:@(_mode)]){
        _left.badgeText = _leftFuturePromiseBadgeTexts[@(_mode)];
    }
}

//right
- (void)setBadgeToRight:(NSString *)text mode:(STControlDisplayMode)mode; {
    _rightFuturePromiseBadgeTexts[@(mode)] = text;

    if(_mode==mode){
        [self setNeedsBadgeTextToRight];
    }
}

- (void)setNeedsBadgeTextToRight {
    if(_rightFuturePromiseBadgeTexts.count && [_rightFuturePromiseBadgeTexts hasKey:@(_mode)]){
        _right.badgeText = _rightFuturePromiseBadgeTexts[@(_mode)];
    }
}

- (void)resetBadgeNumberToRight {
    if(_right.badgeText){
        _right.badgeText = nil;
    }
    if(_rightFuturePromiseBadgeTexts.count){
        [_rightFuturePromiseBadgeTexts removeAllObjects];
    }
}

- (void)incrementBadgeNumberToRight:(STControlDisplayMode)mode; {
    NSString * value = _rightFuturePromiseBadgeTexts.count ? _rightFuturePromiseBadgeTexts[@(mode)] : nil;
    if(value && [value isInteger]){
        [self setBadgeToRight:[@([value integerValue]+1) stringValue] mode:mode];
    }else{
        [self setBadgeToRight:[@(1) stringValue] mode:mode];
    }
}

#pragma mark ButtonView

- (STStandardButton *)leftButton {
    return _left;
}

- (STStandardButton *)rightButton {
    return _right;
}

#pragma mark UpdateState Context Needed
- (void)expandCollectablesContextNeeded {
    switch (_mode){
        case STControlDisplayModeEditAfterCapture:{
            if(_previousMode==STControlDisplayModeHome){
                [_left.collectableView itemViewAtIndex:0].animatableVisible = YES;
            }else{
                [_left expand];
            }
        }
            break;
        case STControlDisplayModeEdit:
        case STControlDisplayModeReviewAfterAnimatableCapture:
        case STControlDisplayModeEditTool:
        case STControlDisplayModeLivePreview:
            [_left expand];
            break;
        default:
            break;
    }
}

- (void)retractCollectablesContextNeeded {
    switch (_mode){
        case STControlDisplayModeEditAfterCapture:{
            if(_previousMode==STControlDisplayModeHome){
                [_left.collectableView itemViewAtIndex:0].animatableVisible = NO;
            }else{
                [_left retract];
            }
        }
            break;
        case STControlDisplayModeEdit:
        case STControlDisplayModeReviewAfterAnimatableCapture:
        case STControlDisplayModeEditTool:
        case STControlDisplayModeLivePreview:
            [_left retract];
            break;
        default:
            break;
    }
}


#pragma mark Mode
+ (void)setExtractRetractForPostFocusMode:(STStandardButton *)button postFocusMode:(NSInteger)postFocusMode animation:(BOOL)animation{
    switch(postFocusMode) {
        case STPostFocusModeVertical3Points:
        case STPostFocusMode5Points:
        case STPostFocusModeFullRange:
            [button retract:animation];
            break;
        default:
            [button expand:animation];
            break;
    }
}

+ (STStandardButton *)torchLightSwitcher:(STStandardButton *)button setButtonsBlock:(STStandardButtonSetButtonsBlock)block{
    NSArray * valuesForTorchLight = [@(STTorchLightMode_count) st_intArray];
    block(button, [valuesForTorchLight bk_map:^id(id obj) {
        switch ((STTorchLightMode)[obj integerValue]){
            case STTorchLightModeOff:
                return [R set_torchlight_off];
            case STTorchLightModeWeak:
                return [R set_torchlight_on];
            case STTorchLightModeMax:
                return [R set_torchlight_strong];
            default:
                NSParameterAssert(NO);
                return nil;
        }
    }], nil);

    button.valuesMap = valuesForTorchLight;
    button.currentMappedValue = @(STTorchLightModeOff);
    [button whenSelectedWithMappedValue:^(STSelectableView *_button, NSInteger index, id value) {
        switch ((STTorchLightMode)[value integerValue]){
            case STTorchLightModeOff:
                [STElieCamera sharedInstance].torchLight = 0;
                break;
            case STTorchLightModeWeak:
                [STElieCamera sharedInstance].torchLight = .1;
                break;
            case STTorchLightModeMax:
                [STElieCamera sharedInstance].torchLight = 1;
                break;
            default:
                break;
        }
    }];
    return button;
}

@end