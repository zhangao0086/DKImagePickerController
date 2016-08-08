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
#import "STCapturedImageSet.h"

@implementation STEditControlFrameEditView {
    STStandardButton * _frameAddButton;
    STUIView * _frameEditItemViewContainer;

    STSegmentedSliderView * _masterOffsetSlider;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _frameEditItemViewContainer = [[STUIView alloc] initWithSize:self.size];
        [self addSubview:_frameEditItemViewContainer];

        _frameAddButton = [[STStandardButton alloc] initWithSize:CGSizeMake(self.width,self.heightForFrameItemView)];
        _frameAddButton.fitIconImageSizeToCenterSquare = YES;
        [self addSubview:_frameAddButton];
        [_frameAddButton setButtons:@[[R set_add]] colors:nil style:STStandardButtonStylePTBT];

        [_frameAddButton whenSelected:^(STSelectableView *selectedView, NSInteger index) {
            [[STPhotoSelector sharedInstance] doExitEditAfterCapture:YES];
        }];

        _masterOffsetSlider = [[STSegmentedSliderView alloc] initWithSize:CGSizeMake(self.width,self.heightForFrameItemView)];
        _masterOffsetSlider.delegateSlider = self;
        [self addSubview:_masterOffsetSlider];
    }

    return self;
}

- (CGFloat)heightForFrameItemView{
    return 40;
}

- (NSUInteger)maxNumberOfLayersOfLayerSet {
    return 2;
}

- (STEditControlFrameEditItemView *)itemViewOfLayer:(STCapturedImageSetAnimatableLayer *)layer {
    return (STEditControlFrameEditItemView *) [_frameEditItemViewContainer viewWithTagName:layer.uuid];
}


- (void)setLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet {
    if(layerSet.layers.count){
        _layerSet = layerSet;

        Weaks
        for(STCapturedImageSetAnimatableLayer *layer in layerSet.layers){
            NSAssert([layer isKindOfClass:STCapturedImageSetAnimatableLayer.class],@"Only STCapturedImageSetAnimatableLayer is allowed");

            STEditControlFrameEditItemView * editItemView = (STEditControlFrameEditItemView *) [_frameEditItemViewContainer viewWithTagName:layer.uuid];
            if(!editItemView){
                editItemView = [[STEditControlFrameEditItemView alloc] initWithSize:CGSizeMake(self.width,self.heightForFrameItemView)];
                [editItemView.removeButton whenSelected:^(STSelectableView *selectedView, NSInteger index) {
                    [Wself removeLayerTapped:editItemView];
                }];
                [_frameEditItemViewContainer addSubview:editItemView];
            }
            editItemView.tagName = layer.uuid;
            editItemView.displayLayer = layer;
        }

    }else{
        _layerSet = nil;

        [_frameEditItemViewContainer st_eachSubviews:^(UIView *view, NSUInteger index) {
            ((STEditControlFrameEditItemView *) view).displayLayer = nil;
            [((STEditControlFrameEditItemView *) view) disposeContent];
        }];
        [_frameEditItemViewContainer clearAllOwnedImagesIfNeeded:NO removeSubViews:YES];
    }

    [self setNeedsLayersDisplayAndLayout];
}

- (void)setNeedsLayersDisplayAndLayout {
    _masterOffsetSlider.visible = self.layerSet.frameCount>1;
    if(_masterOffsetSlider.visible){
        _masterOffsetSlider.normalizedPosition = self.layerSet.frameIndexOffset/self.layerSet.frameCount;
    }

    _frameEditItemViewContainer.top = _masterOffsetSlider.visible ? _masterOffsetSlider.bottom : 0;
    [_frameEditItemViewContainer st_eachSubviews:^(UIView *view, NSUInteger index) {
        STEditControlFrameEditItemView * editItemView = (STEditControlFrameEditItemView *)view;
        editItemView.y = index*editItemView.height;
    }];

    _frameAddButton.y = _frameEditItemViewContainer.top+[_frameEditItemViewContainer lastSubview].bottom;
    _frameAddButton.visible = _frameEditItemViewContainer.subviews.count<self.maxNumberOfLayersOfLayerSet;
}

- (void)removeLayerTapped:(STEditControlFrameEditItemView *)editItemView{
    NSAssert(editItemView.displayLayer, @"layerView.displayLayer does not existed");

    NSMutableArray * layersOfLayerSet = [self.layerSet.layers mutableCopy];
    [layersOfLayerSet removeObject:editItemView.displayLayer];

    /*
     * set new layers
     */
    self.layerSet.layers = layersOfLayerSet;

    editItemView.displayLayer = nil;
    [editItemView clearAllOwnedImagesIfNeededAndRemoveFromSuperview:YES];

    NSAssert(_layerSet.layers.count==_frameEditItemViewContainer.subviews.count,@"_contentView's subviews count and layerSet.layer's count must be same.");

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
    thumbView.backgroundColor = [UIColor whiteColor];
    return thumbView;
}

- (UIView *)createBackgroundView:(CGRect)bounds {
    return nil;
}

- (void)didSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {
    [self doingSlide:timeSlider withSelectedIndex:index];
}

- (void)doingSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {

    STCapturedImageSetDisplayLayer * anyLayer = [self.layerSet.layers firstObject];
    NSUInteger currentMasterFrameIndex = (NSUInteger) round(anyLayer.imageSet.count*timeSlider.normalizedPosition);
    if(currentMasterFrameIndex!=_currentMasterFrameIndex){
        [self willChangeValueForKey:@keypath(self.currentMasterFrameIndex)];
        _currentMasterFrameIndex = currentMasterFrameIndex;
        [self didChangeValueForKey:@keypath(self.currentMasterFrameIndex)];
    }
}

@end