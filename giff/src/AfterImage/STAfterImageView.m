//
// Created by BLACKGENE on 7/8/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageSet.h"
#import "NSArray+STUtil.h"
#import "STAfterImageLayerItem.h"
#import "UIView+STUtil.h"
#import "STAfterImageLayerView.h"
#import "STQueueManager.h"
#import "STAfterImageLayerEffect.h"
#import "STAfterImageView.h"

@interface STSelectableView(Protected)
- (void)setViewsDisplay;
@end

@implementation STAfterImageView {
    UIView * _sublayersContainerView;
    UIView * _controlView;
    NSMutableArray * _layers;
}

- (void)dealloc {
    _layers = nil;
}

- (void)setViewsDisplay {

    if(!CGSizeEqualToSize(_sublayersContainerView.size, self.size)){
        _sublayersContainerView.size = self.size;
    }

    [_sublayersContainerView.subviews eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        STAfterImageLayerView * layerView = (STAfterImageLayerView *) view;
        STAfterImageLayerItem *layerItem = [_layers st_objectOrNilAtIndex:index];

        NSInteger layerIndex = self.currentIndex + layerItem.frameIndexOffset;
        BOOL overRanged = layerIndex<0 || layerIndex>=layerView.count;

        if(overRanged){
            layerView.visible = NO;
        }else{
            layerView.scaleXYValue = layerItem.scale;
            layerView.visible = YES;
            layerView.alpha = layerItem.alpha;
            layerView.currentIndex = layerIndex;
        }
    }];

//    self.backgroundColor = [UIColor blackColor];
//    _contentView.visible = NO;
}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    _currentIndex = currentIndex;

    [self setViewsDisplay];
}


- (NSArray *)layers {
    return _layers;
}

- (void)initToAddLayersIfNeeded{
    if(!_sublayersContainerView){
        _sublayersContainerView = [[UIView alloc] initWithSize:self.size];
        [self insertSubview:_sublayersContainerView atIndex:0];
        [_sublayersContainerView saveInitialLayout];
        _sublayersContainerView.clipsToBounds = YES;
    }

    if(!_controlView){
        _controlView = [[UIView alloc] initWithSize:self.size];
        [self insertSubview:_controlView aboveSubview:_sublayersContainerView];
        [_controlView saveInitialLayout];
    }

    if(!_layers.count){
        _layers = [NSMutableArray array];
    }
}

- (void)appendLayer:(STAfterImageLayerItem *)layerItem{
    [self initToAddLayersIfNeeded];

    if(layerItem.effect){
        Weaks
        dispatch_async([STQueueManager sharedQueue].uiProcessing,^{
            NSArray * effectAppliedImageUrls = [layerItem processResources];
            
            dispatch_async(dispatch_get_main_queue(),^{
                [Wself appendLayerView:layerItem presentableObjects:effectAppliedImageUrls];
            });
        });
    }else{
        //set default 0 STCapturedImageSet
        [self appendLayerView:layerItem presentableObjects:[layerItem resourcesToProcessFromSourceImageSet:[[layerItem sourceImageSets] firstObject]]];
    }
}

- (void)removeAllLayers{
    [_sublayersContainerView st_eachSubviews:^(UIView *view, NSUInteger index) {
        [((STSelectableView *) view) clearViews];
    }];
    [_sublayersContainerView clearAllOwnedImagesIfNeeded:NO removeSubViews:YES];

    [_controlView clearAllOwnedImagesIfNeeded:NO removeSubViews:YES];

    [_layers removeAllObjects];
}

- (void)appendLayerView:(STAfterImageLayerItem *)layerItem presentableObjects:(NSArray *)presentableObjects{

    [_layers addObject:layerItem];
    layerItem.index = [_layers indexOfObject:layerItem];

    //layer
    STAfterImageLayerView *layerView = [[STAfterImageLayerView alloc] initWithSize:_sublayersContainerView.size];
    layerView.layerItem = layerItem;
    layerView.fitViewsImageToBounds = YES;
    [_sublayersContainerView addSubview:layerView];
    [layerView setViews:presentableObjects];


    //control
    CGSize sliderControlSize = CGSizeMake(_sublayersContainerView.width, _sublayersContainerView.height/_layers.count);
    STSegmentedSliderView * offsetSlider = [[STSegmentedSliderView alloc] initWithSize:sliderControlSize];
    offsetSlider.y = layerItem.index * sliderControlSize.height;
    offsetSlider.tag = layerItem.index;
    offsetSlider.tagName = layerItem.uuid;
    offsetSlider.delegateSlider = self;
//        offsetSlider.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.4];
    offsetSlider.normalizedCenterPositionOfThumbView = .5;

//        Weaks
//        [offsetSlider.thumbView whenPanAsSlideVertical:nil started:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf) {
//
//        } changed:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf, CGFloat distance, CGPoint movedOffset, CGFloat distanceReachRatio, STSlideDirection direction, BOOL confirmed) {
//
//            layerItem.alpha = CLAMP(locationInSelf.y,0,offsetSlider.thumbBoundView.height)/offsetSlider.thumbBoundView.height;
//            [Wself setViewsDisplay];
//
//        } ended:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf, STSlideDirection direction, BOOL confirmed) {
//
//        }];
    [_controlView addSubview:offsetSlider];
    [_controlView st_gridSubviewsAsCenter:0 rowHeight:sliderControlSize.height column:1];

    [self setViewsDisplay];
}

#pragma mark OffsetSlider
- (void)didSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {
    [self doingSlide:timeSlider withSelectedIndex:index];
}

- (void)doingSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {
    NSInteger targetIndexOfLayer = timeSlider.tag;
    STAfterImageLayerItem * layerItem = [_layers st_objectOrNilAtIndex:targetIndexOfLayer];

    layerItem.frameIndexOffset = (NSInteger) round(timeSlider.normalizedCenterPositionOfThumbView*10) - 5;

    [self setViewsDisplay];
}

- (UIView *)createThumbView {
    if(_layers.count){
        UIView * thumbView = [[UIView alloc] initWithSize:CGSizeMake(20, _sublayersContainerView.height/_layers.count)];
        thumbView.backgroundColor = [UIColor blackColor];
        return thumbView;
    }
    return nil;
}

- (UIView *)createBackgroundView:(CGRect)bounds {
    return nil;
}

@end