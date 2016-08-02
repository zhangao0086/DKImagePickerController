//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STEditControlView.h"
#import "STStandardButton.h"
#import "R.h"
#import "UIView+STUtil.h"
#import "iCarousel.h"
#import "STCarouselController.h"
#import "STEditControlEffectSelectorView.h"
#import "STPhotoSelector.h"
#import "STMainControl.h"


@implementation STEditControlView {
    STStandardButton *_backButton;
    STStandardButton *_exportButton;

    STEditControlFrameEditView * _frameEditView;

    STEditControlEffectSelectorView * _effectSelectorView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
     }

    return self;
}

- (void)createContent {
    [super createContent];

    [self addFrameEditControls];
    [self addSourceControls];
    [self addEffectSelector];
}


- (void)addEffectSelector {
    CGFloat padding = [STStandardLayout widthBullet];
    [self addSubview:self.effectSelectorView];
    self.effectSelectorView.bottom = _backButton.top - padding;
}

- (STEditControlEffectSelectorView *)effectSelectorView {
    if(!_effectSelectorView){
        CGFloat padding = [STStandardLayout widthBullet];
        CGFloat frameEditViewHeight = (self.frameEditView.maxNumberOfLayersOfLayerSet+1)*self.frameEditView.heightForFrameItemView;
        CGFloat sizeHeight = self.height - (frameEditViewHeight + padding) - (_backButton.height+(padding*2));
        _effectSelectorView = [[STEditControlEffectSelectorView alloc] initWithSize:CGSizeMake(self.width, sizeHeight)];
    }
    return _effectSelectorView;
}


- (void)addFrameEditControls {
    [self frameEditView];
    [self addSubview:_frameEditView];
}

- (STEditControlFrameEditView *)frameEditView {
    if(!_frameEditView){
        _frameEditView = [[STEditControlFrameEditView alloc] initWithSize:CGSizeMake(self.width, self.height)];
    }
    return _frameEditView;
}

- (void)addSourceControls {

    //left button
    _backButton = [STStandardButton subSmallSize];
    _backButton.preferredIconImagePadding = _backButton.height/4;
    [_backButton setButtons:@[[R go_back]] style:STStandardButtonStylePTTP];
    [_backButton whenSelected:^(STSelectableView *selectedView, NSInteger index) {
        [[STPhotoSelector sharedInstance] doExitEditAfterCapture:NO];
    }];

    //right button
    _exportButton = [STStandardButton subSmallSize];
    _exportButton.allowSelectAsTap = YES;
    _exportButton.preferredIconImagePadding = _exportButton.height/4;

    [_exportButton setButtons:@[R.export.share_fit] style:STStandardButtonStylePTTP];
    [_exportButton whenSelected:^(STSelectableView *selectedView, NSInteger index) {
        [[STMainControl sharedInstance] export];
    }];

    CGFloat padding = [STStandardLayout widthBullet];
    [self addSubview:_backButton];
    _backButton.x = padding;
    _backButton.bottom = self.height - padding;

    [self addSubview:_exportButton];
    _exportButton.right = self.width-padding;
    _exportButton.bottom = self.height-padding;
}


@end