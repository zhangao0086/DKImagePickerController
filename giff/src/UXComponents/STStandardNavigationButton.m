//
// Created by BLACKGENE on 2015. 4. 3..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <BlocksKit/NSArray+BlocksKit.h>
#import "STStandardNavigationButton.h"
#import "NSArray+STUtil.h"
#import "UIView+STUtil.h"
#import "NSObject+STUtil.h"
#import "UIColor+STUtil.h"
#import "M13ProgressViewPie.h"
#import "CAShapeLayer+STUtil.h"
#import "STStandardLayout.h"
#import "STStandardUI.h"

@interface STStandardCollectableButton (Protected)
- (void)setUserInteractionToSelectCollectables;
- (void)_setAutoUXLayoutWhenExpanding:(BOOL)autoUXLayoutWhenExpanding;
- (void)_setCollectableButtonSelectedState:(BOOL)collectableButtonSelectedState;
- (void)_clearCollectableButtonSelectedState;
- (void)dispatchCollectableSelected;
@end

@implementation STStandardNavigationButton {
    STStandardButton *_navigationFocusBackgroundView;
//    M13ProgressViewPie * _pieProgressView;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled; {
    super.userInteractionEnabled = userInteractionEnabled;
    self.touchInsidePolicy = userInteractionEnabled ? STUIViewTouchInsidePolicyContentInside : STUIViewTouchInsidePolicyNone;
}

#pragma mark Override from root

- (void)clearCollectableViews; {
    [_navigationFocusBackgroundView clearViews];
    [_navigationFocusBackgroundView removeFromSuperview];
    _navigationFocusBackgroundView = nil;

    if(_contentView.subviews.count){
        _contentView.blockForForceTestHit = nil;
    }

    if(self.collectableView.count){
        self.collectableView.blockForForceTestHit = nil;
        self.collectableBackgroundCreateBlock = nil;
    }
    self.collectableView.backgroundColor = [UIColor clearColor];

    [super clearCollectableViews];
}

#pragma mark Override from STStandardCollectableButton

+ (STStandardNavigationButton *)setButtonsWithCollectables:(NSArray *)imageNames size:(CGSize)buttonSize colllectableIcons:(NSArray *)colllectableIcons colllectableSize:(CGSize)radialSize maskColors:(NSArray *)colors; {
    STStandardNavigationButton *button = [[STStandardNavigationButton alloc] initWithFrame:CGRectMakeWithSize_AGK(buttonSize)];
    [button setButtons:imageNames colors:colors];
    [button setCollectables:colllectableIcons colors:colors size:radialSize];
    return button;
}

- (instancetype)setCollectablesAsDefault:(NSArray *)imageNames{
    return [self setCollectables:imageNames colors:nil size:[STStandardLayout sizeSubAssistance]];
}

- (instancetype)setCollectables:(NSArray *)imageNames colors:(NSArray *)colors size:(CGSize)size; {
    return [self setCollectables:imageNames colors:colors bgColors:nil size:size];
}

- (instancetype)setCollectables:(NSArray *)imageNames colors:(NSArray *)colors bgColors:(NSArray *)bgColors size:(CGSize)size{
    return [self setCollectables:imageNames colors:colors bgColors:bgColors size:size style:STStandardButtonStylePTBT];
}

- (instancetype)setCollectables:(NSArray *)imageNames colors:(NSArray *)colors bgColors:(NSArray *)bgColors size:(CGSize)size style:(STStandardButtonStyle)style;{
    return [self setCollectables:imageNames colors:colors bgColors:bgColors size:size style:STStandardButtonStylePTBT backgroundStyle:STStandardButtonStyleSkipImageInvert];
}

- (instancetype)setCollectables:(NSArray *)imageNames colors:(NSArray *)colors bgColors:(NSArray *)bgColors size:(CGSize)size style:(STStandardButtonStyle)style backgroundStyle:(STStandardButtonStyle)backgroundStyle; {
    NSArray * targetSource = imageNames ? imageNames : colors;

    [self setCollectablesAsButtons:[targetSource mapWithIndex:^id(id object, NSInteger index) {
        STStandardButton *button = [[STStandardButton alloc] initWithFrame:CGRectMakeWithSize_AGK(size)];
        NSString * image = [imageNames st_objectOrNilAtIndex:index];
        UIColor * color = [UIColor colorIf:[colors st_objectOrNilAtIndex:index] or:self.class.defaultCollectableForegroundImageColor];
        UIColor * bgcolor = [UIColor colorIf:[bgColors st_objectOrNilAtIndex:index] or:self.class.defaultCollectableBackgroundImageColor];
        button.allowSelectedStateFromTouchingOutside = YES;
        [button setButtons:image ? @[image] : nil
                    colors:color ? @[color] : nil
                  bgColors:bgcolor ? @[bgcolor] : nil
                     style:style];
        return button;

    }] backgroundStyle:backgroundStyle];

    return self;
}

- (instancetype)setCollectablesAsButtons:(NSArray *)buttons {
    return [self setCollectablesAsButtons:buttons backgroundStyle:STStandardButtonStyleDefault];
}

- (instancetype)setCollectablesAsButtons:(NSArray *)buttons backgroundStyle:(STStandardButtonStyle)backgroundStyle{
    NSAssert(![buttons bk_any:^BOOL(id obj) { return ![obj isKindOfClass:STStandardButton.class]; }], @"only STStandardButton");

    [self setCollectableViews:buttons];

    NSArray * colors = [buttons bk_map:^id(STStandardButton * button ) { return [UIColor colorIf:button.maskColors.first or:[self.class defaultCollectableForegroundImageColor]]; }];
    NSArray * bgColors = [buttons bk_map:^id(STStandardButton * button ) { return [UIColor colorIf:button.backgroundColors.first or:[self.class defaultCollectableBackgroundImageColor]]; }];

    [self _setCollectableNavigationBackground:colors bgColors:bgColors size:[buttons.first size] style:backgroundStyle];
    return self;
}


+ (UIColor *)defaultCollectableBackgroundImageColor{
    return [STStandardUI buttonColorBackgroundAssistance];
}

+ (UIColor *)defaultCollectableForegroundImageColor{
    return [STStandardUI buttonColorForegroundAssistance];
}

- (void)_setCollectableButtonSelectedState:(BOOL)collectableButtonSelectedState; {
    [super _setCollectableButtonSelectedState:collectableButtonSelectedState];
    [self _setCollectableNavigationBackgroundSelectedState:collectableButtonSelectedState];
}

- (void)setCurrentCollectableIndex:(NSUInteger)currentCollectableIndex; {
    super.currentCollectableIndex = currentCollectableIndex;

    _navigationFocusBackgroundView.currentIndex = currentCollectableIndex;
    [self _setCollectableNavigationBackgroundSelectedState:self.currentCollectableButton.selectedState];
}

- (void)setUserInteractionToSelectCollectables; {
    [super setUserInteractionToSelectCollectables];

    Weaks
    if(self.collectablesUserInteractionEnabled){
        //content
        [_contentView setBlockForForceHitTestCircleShapedBound:^UIView * {
            Strongs
            return [Sself currentButtonView];
        }];

        //touch up/down
        [self.collectableView.itemViews eachViewsWithIndex:^(UIView *view, NSUInteger index) {
            STStandardButton *button = (STStandardButton *) view;
            button.blockForButtonDown = ^(STStandardButton *buttonSelf) {
                Strongs
                NSUInteger _index = [Wself.collectableView.itemViews indexOfObject:buttonSelf];
                [Sself _clearCollectableButtonSelectedState];

                Sself->_navigationFocusBackgroundView.currentIndex = _index;
                [Sself _setCollectableNavigationBackgroundSelectedState:YES];
                [Sself.collectableView.itemViews[index] setSelectedState:YES];
            };
            button.blockForButtonUp = ^(STStandardButton *buttonSelf) {
                Strongs
                if (Wself.collectableToggleEnabled) {
                    [Sself _setCollectableButtonSelectedState:Wself.collectableSelectedState];

                } else if (Wself.count == 1 || Wself.collectablesSelectAsIndependent) {
                    [buttonSelf setSelectedState:NO];
                    [Sself _setCollectableButtonSelectedState:NO];
                }
            };
        }];

        //collectable container view
        if(self.autoUXLayoutWhenExpanding){
            self.collectableView.blockForForceTestHit = ^UIView *(CGPoint point, UIEvent *event) {
                Strongs
                CGFloat degree = [Sself degreeWithCenter:Sself.collectableView.boundsCenter location:point];
                CGFloat startDegreeOffset = Sself.collectableView.startDegree-(Sself.collectableView.degreeForEachItems/2);
                degree -= startDegreeOffset;
                NSUInteger hitIndex = [Sself indexWithDegree:degree totalCount:(NSUInteger) Sself.collectableView.count];

                UIView * hitTarget = [Sself.collectableView itemViewAtIndex:hitIndex];
                return hitTarget.userInteractionEnabled ? [hitTarget hitTest:CGPointZero withEvent:event] : nil;
            };
        }else{
            self.collectableView.blockForForceTestHit = nil;
        }

    }else{
        //content
        _contentView.blockForForceTestHit = ^UIView *(CGPoint point, UIEvent *event) {
            Strongs
            return [Sself currentButtonView];
        };

        //touch up/down
        [self.collectableView.itemViews eachViewsWithIndex:^(UIView *view, NSUInteger index) {
            STStandardButton *button = (STStandardButton *) view;
            button.blockForButtonDown = nil;
            button.blockForButtonUp = nil;
        }];

        //collectable container view
        self.collectableView.blockForForceTestHit = ^UIView *(CGPoint point, UIEvent *event) {
            Strongs
            return [Sself currentButtonView];
        };
    }

    //clear userInteraction non-focused views
    @weakify(self)
    [[self subviews] eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        if(!([view isEqual:_contentView] || [view isEqual:self.collectableView])){
            view.userInteractionEnabled = NO;
        }
    }];
}

- (void)_setAutoUXLayoutWhenExpanding:(BOOL)autoUXLayoutWhenExpanding; {
    Weaks
    if(autoUXLayoutWhenExpanding){

        if(self.collectableView.count){
            self.collectableView.totalDegreeForAllItems = 360;
        }

        if(self.collectableView.isExpanded){
            !self.collectableView.blockForWillExpand ?:self.collectableView.blockForWillExpand(NO);
        }
    }
}

#pragma mark Decorate Collectable Background

- (void)setInvertMaskInButtonAreaForCollectableBackground:(BOOL)invertMaskInButtonAreaForCollectableBackground {
    _invertMaskInButtonAreaForCollectableBackground = invertMaskInButtonAreaForCollectableBackground;

    if(self.currentCollectableButton){
        [self _setInvertMaskInButtonAreaForCollectableBackground];
    }
}

- (void)_setInvertMaskInButtonAreaForCollectableBackground{
    NSAssert(self.currentCollectableButton, @"self.currentCollectableButton must need.");

    if(_invertMaskInButtonAreaForCollectableBackground){
        _navigationFocusBackgroundView.layer.mask = [CAShapeLayer circleInvertFilled:_navigationFocusBackgroundView.bounds diameter:_navigationFocusBackgroundView.width-self.currentCollectableButton.width*2 color:[UIColor blackColor]];;
    }else{
        _navigationFocusBackgroundView.layer.mask = nil;
    }
}

- (void)setAlphaCollectableBackground:(CGFloat)alphaCollectableBackground {
    _alphaCollectableBackground = alphaCollectableBackground;
    if(_navigationFocusBackgroundView){
        _navigationFocusBackgroundView->_contentView.alpha = _alphaCollectableBackground;
    }
}

- (void)setShadowEnabledCollectableBackground:(BOOL)shadowEnabledCollectableBackground {
    _shadowEnabledCollectableBackground = shadowEnabledCollectableBackground;
    _navigationFocusBackgroundView.shadowEnabled = _shadowEnabledCollectableBackground;
    self.shadowOffsetCollectableBackground = 1.5f;
}

- (CGFloat)shadowOffsetCollectableBackground {
    return _navigationFocusBackgroundView.shadowOffset;
}

- (void)setShadowOffsetCollectableBackground:(CGFloat)shadowOffsetCollectableBackground {
    if(_navigationFocusBackgroundView.shadowEnabled){
        _navigationFocusBackgroundView.shadowOffset = shadowOffsetCollectableBackground;
    }
}

- (void)setProgressCollectableBackground:(CGFloat)progressCollectableBackground {
    _progressCollectableBackground = progressCollectableBackground;
    [self _setProgressCollectableBackgroundIfNeeded:YES];
}

- (void)_setProgressCollectableBackgroundIfNeeded:(BOOL)animation{
    _navigationFocusBackgroundView.pieProgressAnimationEnabled = animation;
    _navigationFocusBackgroundView.pieProgress = _progressCollectableBackground;

//    //FIXME: progress를 addSubView하기 전에 걸어놓고 버튼을 생성하면서 동시에 addSubView를 즉시 할경우 _navigationFocusBackgroundProgressView::M13ProgressViewPie 가 사라지는 현상
//    if(_progressCollectableBackground <= 0){
//        [_pieProgressView removeFromSuperview];
//        _pieProgressView = nil;
//
//    }else{
//        if(!_pieProgressView && _navigationFocusBackgroundView){
//            _pieProgressView = [[M13ProgressViewPie alloc] initWithSizeWidth:_navigationFocusBackgroundView.width];
//            _pieProgressView.backgroundRingWidth = 0;
//            _pieProgressView.primaryColor = [STStandardUI pointColor];
//            _pieProgressView.alpha = [STStandardUI alphaForDimmingGhostly];
//            [_navigationFocusBackgroundView addSubview:_pieProgressView];
//            [_pieProgressView centerToParent];
//        }
//        [_pieProgressView setProgress:_progressCollectableBackground animated:animation];
//    }
}

#pragma Collectable Background
- (void)_setCollectableNavigationBackgroundSelectedState:(BOOL)selected{
    _navigationFocusBackgroundView.selectedState = selected;
}

- (void)_setCollectableNavigationBackground:(NSArray *)colors bgColors:(NSArray *)bgColors size:(CGSize)size style:(STStandardButtonStyle)style; {
    //autofit background size
    size = CGSizeModified_AGK(size, ^CGSize(CGSize _size) {
        _size.width+=self.collectableView.paddingForAutofitDistance*2;
        _size.height+=self.collectableView.paddingForAutofitDistance*2;
        return _size;
    });

    Weaks
    if(_collectableBackgroundCreateBlock){
        _navigationFocusBackgroundView = _collectableBackgroundCreateBlock(self, colors);

    }else{
        _navigationFocusBackgroundView = [[STStandardButton alloc] initWithFrame:CGRectInset(self.bounds, -size.width, -size.height)];
        [_navigationFocusBackgroundView setButtons:nil colors:colors bgColors:bgColors style:style];
    }

    if(!_navigationFocusBackgroundView){
        return;
    }

//    _navigationFocusBackgroundView.userInteractionEnabled = NO;
    _navigationFocusBackgroundView.lockCurrentIndexAfterSelected = YES;

    [self insertSubview:_navigationFocusBackgroundView atIndex:0];

    //InvertMaskInButtonAreaForCollectableBackground
    [self _setInvertMaskInButtonAreaForCollectableBackground];

    [self _setCollectableButtonSelectedState:self.collectableSelectedState];

    self.collectableView.blockForWillRetract = ^(BOOL animation){
        if(animation){
            [_navigationFocusBackgroundView.layer removeAllAnimations];
            [Wself.collectableView animateWithExpanding:^{
                _navigationFocusBackgroundView.scaleXYValue = 0;
            } completion:^(BOOL finished) {
                if(finished){
                    _navigationFocusBackgroundView.visible = NO;
                }
            } delay:0];
        }else{
            _navigationFocusBackgroundView.scaleXYValue = 0;
            _navigationFocusBackgroundView.visible = NO;
        }
    };
    self.collectableView.blockForWillExpand = ^(BOOL animation){
        _navigationFocusBackgroundView.visible = YES;
        if(animation){
            [_navigationFocusBackgroundView.layer removeAllAnimations];
            [Wself.collectableView animateWithExpanding:^{
                _navigationFocusBackgroundView.scaleXYValue = 1;
            } completion:nil delay:0];
        }else{
            _navigationFocusBackgroundView.scaleXYValue = 1;
        }

        //update progress in collectable background
        [Wself _setProgressCollectableBackgroundIfNeeded:NO];
    };
    _navigationFocusBackgroundView.scaleXYValue = 0;
    _navigationFocusBackgroundView.visible = NO;
}
@end