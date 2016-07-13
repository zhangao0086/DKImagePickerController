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
    UIView * _sublayersContainerView;
    UIView * _controlView;
    STAfterImageItem * _afterImageItem;
}

- (void)dealloc {
    self.imageSet = nil;
}

- (void)setViewsDisplay {
    [super setViewsDisplay];

    if(self.fitViewsImageToBounds){
        if(!CGSizeEqualToSize(_sublayersContainerView.size, self.size)){
            _sublayersContainerView.size = self.size;
        }
    }else{
        [_sublayersContainerView restoreInitialLayout];
    }

    [_sublayersContainerView.subviews eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        STSelectableView * layerView = (STSelectableView *) view;
        STAfterImageLayerItem *layerItem = [_afterImageItem.layers st_objectOrNilAtIndex:index];
        NSInteger layerIndex = self.currentIndex + layerItem.frameIndexOffset;
        BOOL overRanged = layerIndex<0 || layerIndex>=layerView.count;

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

    if(!_sublayersContainerView){
        _sublayersContainerView = [[UIView alloc] initWithSize:self.size];
        [self insertSubview:_sublayersContainerView aboveSubview:_contentView];
        [_sublayersContainerView saveInitialLayout];
    }

    if(!_controlView){
        _controlView = [[UIView alloc] initWithSize:self.size];
        [self insertSubview:_controlView aboveSubview:_sublayersContainerView];
        [_controlView saveInitialLayout];
    }

    for (STAfterImageLayerItem *layerItem in _afterImageItem.layers) {

        //layer
        STSelectableView *layerView = [[STSelectableView alloc] initWithSize:_sublayersContainerView.size];
        layerView.fitViewsImageToBounds = YES;
        //TODO: preheating - 여기서 미리 랜더링된 필터를 temp url에 저장 후 그 url을 보여주는 것도 나쁘지 않을듯
        [_sublayersContainerView addSubview:layerView];
        [layerView setViews:presentableObjects];

        //control - slider
        STSegmentedSliderView * offsetSlider = [[STSegmentedSliderView alloc] initWithSize:layerView.size];
        offsetSlider.tag = [_afterImageItem.layers indexOfObject:layerItem];
        offsetSlider.tagName = layerItem.uuid;
        offsetSlider.delegateSlider = self;
//        offsetSlider.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.4];
        offsetSlider.normalizedCenterPositionOfThumbView = .5;

        Weaks
        [offsetSlider.thumbView whenPanAsSlideVertical:nil started:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf) {

        } changed:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf, CGFloat distance, CGPoint movedOffset, CGFloat distanceReachRatio, STSlideDirection direction, BOOL confirmed) {

            layerItem.alpha = CLAMP(locationInSelf.y,0,offsetSlider.thumbBoundView.height)/offsetSlider.thumbBoundView.height;
            [Wself setViewsDisplay];

        } ended:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf, STSlideDirection direction, BOOL confirmed) {

        }];
        [_controlView addSubview:offsetSlider];
    }

    [super willSetViews:presentableObjects];
}

- (void)willClearViews {
    if(_afterImageItem){
        return;
    }

    [_sublayersContainerView st_eachSubviews:^(UIView *view, NSUInteger index) {
        [((STSelectableView *) view) clearViews];
    }];
    [_sublayersContainerView clearAllOwnedImagesIfNeeded:NO removeSubViews:YES];

    [_controlView clearAllOwnedImagesIfNeeded:NO removeSubViews:YES];

    [super willClearViews];
}

#pragma mark OffsetSlider
- (void)didSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {
    NSInteger targetIndexOfLayer = timeSlider.tag;
    STAfterImageLayerItem * layerItem = [_afterImageItem.layers st_objectOrNilAtIndex:targetIndexOfLayer];
    layerItem.frameIndexOffset = (NSInteger) ((NSInteger) round(timeSlider.normalizedCenterPositionOfThumbView*10) - 5);

    self.currentIndex = (NSUInteger) round((self.count-1) * timeSlider.normalizedCenterPositionOfThumbView);

    ii(self.count);
    ff(round(timeSlider.normalizedCenterPositionOfThumbView*10));
    ii(layerItem.frameIndexOffset);
}

- (UIView *)createThumbView {
    UIView * thumbView = [[UIView alloc] initWithSize:CGSizeMake(20, self.height)];
    thumbView.backgroundColor = [UIColor blackColor];
    return thumbView;
}

- (UIView *)createBackgroundView:(CGRect)bounds {
    return nil;
}

@end