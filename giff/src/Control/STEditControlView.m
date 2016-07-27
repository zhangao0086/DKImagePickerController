//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STEditControlView.h"
#import "STStandardButton.h"
#import "R.h"
#import "UIView+STUtil.h"
#import "STCapturedImageSetAnimatableLayerSet.h"


@implementation STEditControlView {
    STStandardButton *_backButton;

    STStandardButton *_exportButton;

    STEditControlFrameEditView * _frameEditView;

    STSegmentedSliderView * _masterOffsetSlider;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
     }

    return self;
}

- (void)createContent {
    [super createContent];

    [self createEditControls];
    [self createEffectSelector];
    [self createSourceControls];

    CGFloat padding = [STStandardLayout widthBullet];

    [self addSubview:_backButton];
    _backButton.x = padding;
    _backButton.bottom = self.height - padding;

    [self addSubview:_exportButton];
    _exportButton.right = self.width-padding;
    _exportButton.bottom = self.height-padding;

    _masterOffsetSlider = [[STSegmentedSliderView alloc] initWithSize:CGSizeMake(self.width,20)];
    _masterOffsetSlider.normalizedCenterPositionOfThumbView = .5;
    _masterOffsetSlider.delegateSlider = self;
    [self addSubview:_masterOffsetSlider];

    [self addSubview:_frameEditView];
    _frameEditView.top = _masterOffsetSlider.bottom;
}

- (void)createEffectSelector {

}

- (void)createEditControls {
    [self frameEditView];
}

- (STEditControlFrameEditView *)frameEditView {
    return _frameEditView ?: (_frameEditView = [[STEditControlFrameEditView alloc] initWithSize:CGSizeMake(self.width, self.height/4)]);
}


- (void)createSourceControls {

    //left button
    _backButton = [STStandardButton subSmallSize];
    _backButton.preferredIconImagePadding = _backButton.height/4;
    [_backButton setButtons:@[[R go_back]] style:STStandardButtonStylePTTP];
    [_backButton whenSelected:^(STSelectableView *selectedView, NSInteger index) {

    }];

    //right button
    _exportButton = [STStandardButton subSmallSize];
    _exportButton.allowSelectAsTap = YES;
    _exportButton.preferredIconImagePadding = _exportButton.height/4;

    [_exportButton setButtons:@[R.export.share] style:STStandardButtonStylePTTP];
    [_exportButton whenSelected:^(STSelectableView *selectedView, NSInteger index) {

    }];
}

#pragma mark Slider
- (void)didSlide:(STSegmentedSliderView *)slider withSelectedIndex:(int)index {
    [self doingSlide:slider withSelectedIndex:index];

//    [self willChangeValueForKey:@keypath(self.currentMasterFrameIndex)];
//    [self didChangeValueForKey:@keypath(self.currentMasterFrameIndex)];
}

- (void)doingSlide:(STSegmentedSliderView *)slider withSelectedIndex:(int)index {

    NSUInteger currentMasterFrameIndex = (NSUInteger) round(slider.normalizedCenterPositionOfThumbView*10) - 5;

    if(_currentMasterFrameIndex!=index){
        [self willChangeValueForKey:@keypath(self.currentMasterFrameIndex)];
        _currentMasterFrameIndex = (NSUInteger) index;
        [self didChangeValueForKey:@keypath(self.currentMasterFrameIndex)];
    }
}

- (UIView *)createThumbView {
    UIView * thumbView = [[UIView alloc] initWithSize:CGSizeMake(14, 20)];
    thumbView.backgroundColor = [UIColor blackColor];
    return thumbView;
}

@end