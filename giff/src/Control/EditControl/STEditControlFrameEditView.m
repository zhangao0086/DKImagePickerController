//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STEditControlFrameEditView.h"
#import "STEditControlFrameEditItemView.h"
#import "UIView+STUtil.h"
#import "STCapturedImageSetDisplayLayerSet.h"
#import "STCapturedImageSetAnimatableLayerSet.h"
#import "STCapturedImageSetAnimatableLayer.h"
#import "STStandardButton.h"
#import "R.h"
#import "NSArray+STUtil.h"


@implementation STEditControlFrameEditView {
    STStandardButton * _frameAddButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _frameAddButton = [[STStandardButton alloc] initWithSize:CGSizeMake(self.width,self.heightForFrameItemView)];
        _frameAddButton.fitIconImageSizeToCenterSquare = YES;
        [self addSubview:_frameAddButton];
        [_frameAddButton setButtons:@[[R set_add]] colors:nil style:STStandardButtonStylePTBT];
    }

    return self;
}


- (void)setNeedsLayersDisplayAndLayout {
    [super setNeedsLayersDisplayAndLayout];

    [_contentView st_eachSubviews:^(UIView *view, NSUInteger index) {
        STEditControlFrameEditItemView * editItemView = (STEditControlFrameEditItemView *)view;
        editItemView.y = index*editItemView.height;
    }];

    if((_frameAddButton.visible = _contentView.subviews.count<2)){
        _frameAddButton.y = [_contentView lastSubview].bottom;
    }
}

- (CGFloat)heightForFrameItemView{
    return self.height/2;
}

- (void)appendLayer:(STCapturedImageSetAnimatableLayerSet *)layerSet {
    [super appendLayer:layerSet];

    //layer
    for(STCapturedImageSetAnimatableLayer *layer in layerSet.layers){
        NSAssert([layer isKindOfClass:STCapturedImageSetAnimatableLayer.class],@"Only STCapturedImageSetAnimatableLayer is allowed");
        STEditControlFrameEditItemView * editItemView = [[STEditControlFrameEditItemView alloc] initWithSize:CGSizeMake(self.width, self.heightForFrameItemView)];
        editItemView.displayLayer = layer;
        editItemView.frameOffsetSlider.delegateSlider = self;
        editItemView.tagName = editItemView.frameOffsetSlider.tagName = layer.uuid;
        editItemView.backgroundColor = [UIColor orangeColor];
        [_contentView addSubview:editItemView];
    }

    [self setNeedsLayersDisplayAndLayout];
}

- (void)removeAllLayers {
    [_contentView st_eachSubviews:^(UIView *view, NSUInteger index) {
        ((STEditControlFrameEditItemView *)view).displayLayer = nil;
    }];

    [super removeAllLayers];
}

#pragma mark OffsetSlider
- (void)didSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {
    [self doingSlide:timeSlider withSelectedIndex:index];
}

- (void)doingSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {
    STEditControlFrameEditItemView * editItemView = (STEditControlFrameEditItemView *) [_contentView viewWithTagName:timeSlider.tagName];

    editItemView.displayLayer.frameIndexOffset = (NSInteger) round(timeSlider.normalizedCenterPositionOfThumbView*10) - 5;

    [self setNeedsLayersDisplayAndLayout];
}

@end