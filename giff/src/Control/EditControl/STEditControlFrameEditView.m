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
#import "STPhotoSelector.h"


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

        [_frameAddButton whenSelected:^(STSelectableView *selectedView, NSInteger index) {
            [[STPhotoSelector sharedInstance] doExitEditAfterCapture:YES];
        }];
    }

    return self;
}


- (NSUInteger)maxNumberOfLayersOfLayerSet {
    return 2;
}

- (void)setNeedsLayersDisplayAndLayout {
    [super setNeedsLayersDisplayAndLayout];

    [_contentView st_eachSubviews:^(UIView *view, NSUInteger index) {
        STEditControlFrameEditItemView * editItemView = (STEditControlFrameEditItemView *)view;
        editItemView.y = index*editItemView.height;
    }];

    _frameAddButton.y = [_contentView lastSubview].bottom;
    _frameAddButton.visible = _contentView.subviews.count<2;
}

- (CGFloat)heightForFrameItemView{
    return self.height/2;
}

- (void)appendLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet {
    [super appendLayerSet:layerSet];

    //layer
    Weaks
    for(STCapturedImageSetAnimatableLayer *layer in layerSet.layers){
        NSAssert([layer isKindOfClass:STCapturedImageSetAnimatableLayer.class],@"Only STCapturedImageSetAnimatableLayer is allowed");
        STEditControlFrameEditItemView * editItemView = [[STEditControlFrameEditItemView alloc] initWithSize:CGSizeMake(self.width, self.heightForFrameItemView)];
        editItemView.tagName = editItemView.frameOffsetSlider.tagName = layer.uuid;
        editItemView.displayLayer = layer;
        editItemView.backgroundColor = [UIColor orangeColor];
        editItemView.frameOffsetSlider.delegateSlider = self;
        [editItemView.removeButton whenSelected:^(STSelectableView *selectedView, NSInteger index) {
            [Wself removeLayerTapped:editItemView layerSet:layerSet];
        }];
        [_contentView addSubview:editItemView];
    }

    [self setNeedsLayersDisplayAndLayout];
}

- (UIView *)itemViewOfLayerSetAt:(STCapturedImageSetAnimatableLayerSet *)layerSet {
    return [_contentView viewWithTagName:layerSet.uuid];
}

- (void)removeAllLayersSets {
    [_contentView st_eachSubviews:^(UIView *view, NSUInteger index) {
        ((STEditControlFrameEditItemView *)view).displayLayer = nil;
    }];

    [super removeAllLayersSets];
}

- (void)removeLayerTapped:(STEditControlFrameEditItemView *)editItemView layerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet{
    NSAssert(editItemView.displayLayer, @"layerView.displayLayer does not existed");

    NSMutableArray * layersOfLayerSet = [layerSet.layers mutableCopy];
    [layersOfLayerSet removeObject:editItemView.displayLayer];
    layerSet.layers = layersOfLayerSet;

    editItemView.displayLayer = nil;
    [editItemView clearAllOwnedImagesIfNeededAndRemoveFromSuperview:YES];

    NSAssert(layerSet.layers.count==_contentView.subviews.count, @"It is differ from the number of layers and the number of contentview's subviews.");

    [self setNeedsLayersDisplayAndLayout];

    if(layerSet.layers.count==0){
        [[STPhotoSelector sharedInstance] doExitEditAfterCapture:NO];
    }
}

#pragma mark OffsetSlider
- (UIView *)createThumbView {
    UIView * thumbView = [[UIView alloc] initWithSize:CGSizeMake(14, self.heightForFrameItemView)];
    thumbView.backgroundColor = [UIColor blackColor];
    return thumbView;
}

- (UIView *)createBackgroundView:(CGRect)bounds {
    return nil;
}


- (void)didSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {
    [self doingSlide:timeSlider withSelectedIndex:index];
}

- (void)doingSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {
    STEditControlFrameEditItemView * editItemView = (STEditControlFrameEditItemView *) [_contentView viewWithTagName:timeSlider.tagName];

    editItemView.displayLayer.frameIndexOffset = (NSInteger) round(timeSlider.normalizedCenterPositionOfThumbView*10) - 5;

    [self setNeedsLayersDisplayAndLayout];
}

@end