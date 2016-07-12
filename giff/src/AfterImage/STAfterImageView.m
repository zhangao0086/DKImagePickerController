//
// Created by BLACKGENE on 7/8/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageView.h"
#import "STCapturedImageSet.h"
#import "NSArray+STUtil.h"
#import "STAfterImageLayerItem.h"
#import "UIView+STUtil.h"

@interface STSelectableView(Protected)
- (void)setViewsDisplay;
@end

@implementation STAfterImageView {
    UIView * _afterImageSublayersContainerView;
    STAfterImageItem * _afterImageItem;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {


    }

    return self;
}


- (void)dealloc {
    self.imageSet = nil;
    [_afterImageSublayersContainerView removeFromSuperview];
    _afterImageSublayersContainerView = nil;
}

- (void)setViewsDisplay {
    [super setViewsDisplay];

    if(self.fitViewsImageToBounds){
        if(!CGSizeEqualToSize(_afterImageSublayersContainerView.size, self.size)){
            _afterImageSublayersContainerView.size = self.size;
        }
    }else{
        [_afterImageSublayersContainerView restoreInitialLayout];
    }

    [_afterImageSublayersContainerView.subviews eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        STSelectableView * layerView = (STSelectableView *) view;
        STAfterImageLayerItem *layerItem = [_afterImageItem.layers st_objectOrNilAtIndex:index];
        NSUInteger layerIndex = self.currentIndex + layerItem.frameIndexOffset;
        BOOL overRanged = layerIndex>=self.count;

        if(overRanged){
            layerView.visible = NO;
        }else{
            layerView.visible = YES;
            layerView.alpha = layerItem.alpha;
            //TODO: render filter
            layerView.currentIndex = layerIndex;
        }
    }];
}

- (void)setImageSet:(STCapturedImageSet *)imageSet {
    NSAssert(!imageSet || [imageSet.extensionObject isKindOfClass:[STAfterImageItem class]], @"given imageSet did not contain STAfterImageItem in .extensionData");
    if([imageSet.extensionObject isKindOfClass:[STAfterImageItem class]]){
        _afterImageItem = (STAfterImageItem *)imageSet.extensionObject;
    }else{
        _afterImageItem = nil;
    }

    [super setImageSet:imageSet];
}

- (void)willSetViews:(NSArray *)presentableObjects {
    if(!_afterImageItem.layers){
        return;
    }

    if(!_afterImageSublayersContainerView){
        _afterImageSublayersContainerView = [[UIView alloc] initWithSize:self.size];
        [self insertSubview:_afterImageSublayersContainerView aboveSubview:_contentView];
        [_afterImageSublayersContainerView saveInitialLayout];
    }

    for (STAfterImageLayerItem *layerItem in _afterImageItem.layers) {
        //layer view
        STSelectableView *layerView = [[STSelectableView alloc] initWithSize:_afterImageSublayersContainerView.size];
        layerView.fitViewsImageToBounds = YES;
        //TODO: preheating - 여기서 미리 랜더링된 필터를 temp url에 저장 후 그 url을 보여주는 것도 나쁘지 않을듯
        [_afterImageSublayersContainerView addSubview:layerView];
        [layerView setViews:presentableObjects];

        //slider
        STSegmentedSliderView * offsetSlider = [[STSegmentedSliderView alloc] initWithSize:layerView.size];
        offsetSlider.delegateSlider = self;
        offsetSlider.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.4];
        offsetSlider.normalizedCenterPositionOfThumbView = .5;
        [layerView addSubview:offsetSlider];
    }

    [super willSetViews:presentableObjects];
}

- (void)willClearViews {
    if(_afterImageItem){
        return;
    }

    [_afterImageSublayersContainerView st_eachSubviews:^(UIView *view, NSUInteger index) {
        [((STSelectableView *) view) clearViews];
    }];
    [_afterImageSublayersContainerView clearAllOwnedImagesIfNeeded:NO removeSubViews:YES];

    [super willClearViews];
}

#pragma mark OffsetSlider
- (void)didSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {

    ff(timeSlider.normalizedCenterPositionOfThumbView*10);
}

- (UIView *)createThumbView {
    UIView * thumbView = [[UIView alloc] initWithSize:CGSizeMake(10, self.height)];
    thumbView.backgroundColor = [UIColor blackColor];
    return thumbView;
}

- (UIView *)createBackgroundView:(CGRect)bounds {
    return nil;
}

@end