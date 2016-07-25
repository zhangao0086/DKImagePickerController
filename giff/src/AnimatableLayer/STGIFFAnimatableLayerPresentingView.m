//
// Created by BLACKGENE on 7/8/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageSet.h"
#import "NSArray+STUtil.h"
#import "STCapturedImageSetAnimatableLayer.h"
#import "UIView+STUtil.h"
#import "STQueueManager.h"
#import "STMultiSourcingImageProcessor.h"
#import "STGIFFAnimatableLayerPresentingView.h"
#import "STCapturedImageSetDisplayProcessor.h"

@interface STSelectableView(Protected)
- (void)setViewsDisplay;
@end

@implementation STGIFFAnimatableLayerPresentingView

- (void)setNeedsLayersDisplayAndLayout {

    if(!CGSizeEqualToSize(_contentView.size, self.size)){
        _contentView.size = self.size;
    }

    [_contentView.subviews eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        STSelectableView * layerView = (STSelectableView *) view;
        STCapturedImageSetAnimatableLayer *layerItem = [self.layers st_objectOrNilAtIndex:index];

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

}

- (void)appendLayer:(STCapturedImageSetAnimatableLayer *)layerItem{
    [super appendLayer:layerItem];

    STCapturedImageSetDisplayProcessor * processor = [STCapturedImageSetDisplayProcessor processorWithTargetLayer:layerItem];
    if(layerItem.effect){
        Weaks
        dispatch_async([STQueueManager sharedQueue].uiProcessing,^{
            NSArray * effectAppliedImageUrls = [processor processResources];

            dispatch_async(dispatch_get_main_queue(),^{
                [Wself appendLayerView:layerItem presentableObjects:effectAppliedImageUrls];
            });
        });
    }else{
        //set default 0 STCapturedImageSet
        [self appendLayerView:layerItem presentableObjects:[processor resourcesToProcessFromSourceImageSet:[[layerItem sourceImageSets] firstObject]]];
    }
}

- (void)appendLayerView:(STCapturedImageSetAnimatableLayer *)layerItem presentableObjects:(NSArray *)presentableObjects{
    //layer
    STSelectableView *layerView = [[STSelectableView alloc] initWithSize:_contentView.size];
    layerView.fitViewsImageToBounds = YES;
    [_contentView addSubview:layerView];
    [layerView setViews:presentableObjects];

    [self setNeedsLayersDisplayAndLayout];
}

#pragma mark OffsetSlider
- (void)didSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {
    [self doingSlide:timeSlider withSelectedIndex:index];
}

- (void)doingSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {
    NSInteger targetIndexOfLayer = timeSlider.tag;
    STCapturedImageSetAnimatableLayer * layerItem = [self.layers st_objectOrNilAtIndex:targetIndexOfLayer];

    layerItem.frameIndexOffset = (NSInteger) round(timeSlider.normalizedCenterPositionOfThumbView*10) - 5;

    [self setNeedsLayersDisplayAndLayout];
}

- (UIView *)createThumbView {
    if(self.layers.count){
        UIView * thumbView = [[UIView alloc] initWithSize:CGSizeMake(20, _contentView.height/self.layers.count)];
        thumbView.backgroundColor = [UIColor blackColor];
        return thumbView;
    }
    return nil;
}

- (UIView *)createBackgroundView:(CGRect)bounds {
    return nil;
}

@end