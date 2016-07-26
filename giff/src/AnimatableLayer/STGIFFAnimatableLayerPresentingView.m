//
// Created by BLACKGENE on 7/8/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageSet.h"
#import "NSArray+STUtil.h"
#import "STCapturedImageSetAnimatableLayerSet.h"
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
        STCapturedImageSetAnimatableLayerSet *layerSet = [self.layerSets st_objectOrNilAtIndex:index];

        NSInteger layerIndex = self.currentIndex + layerSet.frameIndexOffset;
        BOOL overRanged = layerIndex<0 || layerIndex>=layerView.count;

        if(overRanged){
            layerView.visible = NO;
        }else{
            layerView.scaleXYValue = layerSet.scale;
            layerView.visible = YES;
            layerView.alpha = layerSet.alpha;
            layerView.currentIndex = layerIndex;
        }
    }];

}

- (void)appendLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet{
    [super appendLayerSet:layerSet];

    [self processLayerSetAndSetNeedsView:layerSet forceAppend:YES];
}

- (void)updateLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet{
    [self processLayerSetAndSetNeedsView:layerSet forceAppend:NO];
}

- (void)processLayerSetAndSetNeedsView:(STCapturedImageSetAnimatableLayerSet *)layerSet forceAppend:(BOOL)forceAppend{
    STCapturedImageSetDisplayProcessor * processor = [STCapturedImageSetDisplayProcessor processorWithTargetLayerSet:layerSet];
    if(layerSet.effect){
        Weaks
        dispatch_async([STQueueManager sharedQueue].uiProcessing,^{
            NSArray * effectAppliedImageUrls = [processor processResources];

            dispatch_async(dispatch_get_main_queue(),^{
                [Wself setLayerView:layerSet presentableObjects:effectAppliedImageUrls forceAppend:forceAppend];
            });
        });
    }else{
        //set default 0 STCapturedImageSet
        [self setLayerView:layerSet presentableObjects:[processor resourcesToProcessFromSourceLayer:[layerSet.layers firstObject]] forceAppend:forceAppend];
    }
}

- (void)setLayerView:(STCapturedImageSetAnimatableLayerSet *)layerSet presentableObjects:(NSArray *)presentableObjects forceAppend:(BOOL)forceAppend{
    //layer
    STSelectableView *layerView = (STSelectableView *)[_contentView viewWithTagName:layerSet.uuid];
    if(forceAppend || !layerView){
        layerView = [[STSelectableView alloc] initWithSize:_contentView.size];
        layerView.fitViewsImageToBounds = YES;
        layerView.tagName = layerSet.uuid;
        [_contentView addSubview:layerView];
    }
    [layerView setViews:presentableObjects];

    [self setNeedsLayersDisplayAndLayout];
}

- (UIView *)itemViewOfLayerSetAt:(STCapturedImageSetAnimatableLayerSet *)layerSet {
    return [_contentView viewWithTagName:layerSet.uuid];
}

#pragma mark OffsetSlider
- (void)didSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {
    [self doingSlide:timeSlider withSelectedIndex:index];
}

- (void)doingSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {
    NSInteger targetIndexOfLayer = timeSlider.tag;
    STCapturedImageSetAnimatableLayerSet * layerSet = [self.layerSets st_objectOrNilAtIndex:targetIndexOfLayer];

    layerSet.frameIndexOffset = (NSInteger) round(timeSlider.normalizedCenterPositionOfThumbView*10) - 5;

    [self setNeedsLayersDisplayAndLayout];
}

- (UIView *)createThumbView {
    if(self.layerSets.count){
        UIView * thumbView = [[UIView alloc] initWithSize:CGSizeMake(20, _contentView.height/self.layerSets.count)];
        thumbView.backgroundColor = [UIColor blackColor];
        return thumbView;
    }
    return nil;
}

- (UIView *)createBackgroundView:(CGRect)bounds {
    return nil;
}

@end