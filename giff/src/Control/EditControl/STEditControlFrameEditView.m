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
    STUIView * _contentView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentView = [[STUIView alloc] initWithSize:self.size];
        [self addSubview:_contentView];

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

- (CGFloat)heightForFrameItemView{
    return self.height/self.maxNumberOfLayersOfLayerSet;
}

- (NSUInteger)maxNumberOfLayersOfLayerSet {
    return 2;
}

- (void)setLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet {
    if(layerSet.layers.count){
        _layerSet = layerSet;

        Weaks
        for(STCapturedImageSetAnimatableLayer *layer in layerSet.layers){
            if([_contentView viewWithTagName:layer.uuid]){
                continue;
            }
            NSAssert([layer isKindOfClass:STCapturedImageSetAnimatableLayer.class],@"Only STCapturedImageSetAnimatableLayer is allowed");
            STEditControlFrameEditItemView * editItemView = [[STEditControlFrameEditItemView alloc] initWithSize:CGSizeMake(self.width,self.heightForFrameItemView)];
            editItemView.tagName = editItemView.frameOffsetSlider.tagName = layer.uuid;
            editItemView.displayLayer = layer;
            editItemView.backgroundColor = [UIColor orangeColor];
            editItemView.frameOffsetSlider.delegateSlider = self;
            [editItemView.removeButton whenSelected:^(STSelectableView *selectedView, NSInteger index) {
                [Wself removeLayerTapped:editItemView];
            }];
            [_contentView addSubview:editItemView];
        }

    }else{
        _layerSet = nil;

        [_contentView st_eachSubviews:^(UIView *view, NSUInteger index) {
            ((STEditControlFrameEditItemView *) view).displayLayer = nil;
            [((STEditControlFrameEditItemView *) view) disposeContent];
        }];
        [_contentView clearAllOwnedImagesIfNeeded:NO removeSubViews:YES];
    }

    [self setNeedsLayersDisplayAndLayout];
}

- (void)setNeedsLayersDisplayAndLayout {
    [_contentView st_eachSubviews:^(UIView *view, NSUInteger index) {
        STEditControlFrameEditItemView * editItemView = (STEditControlFrameEditItemView *)view;
        editItemView.y = index*editItemView.height;
    }];

    _frameAddButton.y = [_contentView lastSubview].bottom;
    _frameAddButton.visible = _contentView.subviews.count<self.maxNumberOfLayersOfLayerSet;
}

- (void)removeLayerTapped:(STEditControlFrameEditItemView *)editItemView{
    NSAssert(editItemView.displayLayer, @"layerView.displayLayer does not existed");

    NSMutableArray * layersOfLayerSet = [self.layerSet.layers mutableCopy];
    [layersOfLayerSet removeObject:editItemView.displayLayer];
    self.layerSet.layers = layersOfLayerSet;

    editItemView.displayLayer = nil;
    [editItemView clearAllOwnedImagesIfNeededAndRemoveFromSuperview:YES];

    NSAssert(_layerSet.layers.count==_contentView.subviews.count,@"_contentView's subviews count and layerSet.layer's count must be same.");

    [self setNeedsLayersDisplayAndLayout];

    if(self.layerSet.layers.count==0){
        [[STPhotoSelector sharedInstance] doExitEditAfterCapture:NO];
    }else{

        [[STPhotoSelector sharedInstance] refreshCurrentDisplayImageLayerSet];
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