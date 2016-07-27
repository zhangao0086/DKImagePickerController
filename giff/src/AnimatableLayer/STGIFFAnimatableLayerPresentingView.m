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
#import "GPUImageView.h"
#import "STMultiSourcingGPUImageProcessor.h"
#import "STCapturedImageSetDisplayProcessor+GPUImage.h"

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
    NSParameterAssert(layerSet);
    [super appendLayerSet:layerSet];
    [self processLayerSetAndSetNeedsView:layerSet forceAppend:YES forceReprocess:NO];
}

- (void)updateLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet{
    NSParameterAssert(layerSet);
    [self processLayerSetAndSetNeedsView:layerSet forceAppend:NO forceReprocess:YES];
}

//TODO:GPUImageView로 직접 투사하는 부분 / export를 위해서 url을 추출하는 부분 따로.
- (void)processLayerSetAndSetNeedsView:(STCapturedImageSetAnimatableLayerSet *)layerSet forceAppend:(BOOL)forceAppend forceReprocess:(BOOL)forceReprocess{

    STCapturedImageSetDisplayProcessor * processor = [STCapturedImageSetDisplayProcessor processorWithLayerSet:layerSet];

    if(layerSet.effect){
        Weaks
//        dispatch_async([STQueueManager sharedQueue].uiProcessing,^{

            NSArray<id> * presentableObjects = nil;
            if([layerSet.effect isKindOfClass:STMultiSourcingGPUImageProcessor.class]){
                //STMultiSourcingGPUImageProcessor
                presentableObjects = [[processor sourceSetOfImagesForLayerSet] mapWithIndex:^id(id object, NSInteger index) {
                    @autoreleasepool {
                        return [[GPUImageView alloc] initWithSize:_contentView.size];
                    }
                }];
                if(![processor processForImageInput:presentableObjects]){
                    NSAssert(NO, @"STMultiSourcingGPUImageProcessor -> processForImageInput was failed.");
                    presentableObjects = nil;
                }

            }else{
                // STMultiSourcingImageProcessor
                presentableObjects = [processor processForImageUrls:forceReprocess];
            }

            NSAssert(presentableObjects.count, @"presentableObjects's count is 0");
            dispatch_async(dispatch_get_main_queue(),^{
                if(presentableObjects.count){
                    [Wself setLayerView:layerSet presentableObjects:presentableObjects forceAppend:forceAppend];
                } else{
                    [Wself setLayerView:layerSet presentableObjects:[processor sourceOfImagesForLayer:[layerSet.layers firstObject]] forceAppend:forceAppend];
                }
            });
//        });
    }else{
        //set default 0 STCapturedImageSet
        [self setLayerView:layerSet presentableObjects:[processor sourceOfImagesForLayer:[layerSet.layers firstObject]] forceAppend:forceAppend];
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

//    [self setNeedsLayersDisplayAndLayout];
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