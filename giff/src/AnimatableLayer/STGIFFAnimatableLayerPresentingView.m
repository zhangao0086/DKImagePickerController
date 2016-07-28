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
#import "STFastUIViewSelectableView.h"
#import "NSNumber+STUtil.h"

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

        STCapturedImageSetAnimatableLayerSet *layerSet = nil;
        for(STCapturedImageSetAnimatableLayerSet * set in self.layerSets){
            if([set.uuid isEqualToString:layerView.tagName]){
                layerSet = set;
                break;
            }
        }

        NSInteger layerIndex = self.currentIndex + layerSet.frameIndexOffset;
        BOOL overRanged = layerIndex<0 || layerIndex>=layerView.count;

        if(overRanged){
            layerView.visible = NO;
        }else{
            layerView.scaleXYValue = layerSet.scale;
            layerView.visible = YES;
            layerView.alpha = layerSet.alpha;
            layerView.currentIndex = (NSUInteger) layerIndex;
        }
    }];
}

- (void)appendLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet{
    NSParameterAssert(layerSet);
    [super appendLayerSet:layerSet];
    [self processLayerSetAndSetNeedsView:layerSet forceAppend:YES forceReprocess:NO preferredRange:NSRangeNull];
}

- (void)updateAllLayersOfLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet{
    NSParameterAssert(layerSet);
    [self processLayerSetAndSetNeedsView:layerSet forceAppend:NO forceReprocess:YES preferredRange:NSRangeNull];
}

- (void)updateCurrentLayerOfLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet{
    NSParameterAssert(layerSet);
    [self processLayerSetAndSetNeedsView:layerSet forceAppend:NO forceReprocess:YES preferredRange:NSMakeRange(self.currentIndex, 1)];
}

- (void)processLayerSetAndSetNeedsView:(STCapturedImageSetAnimatableLayerSet *)layerSet
                           forceAppend:(BOOL)forceAppend
                        forceReprocess:(BOOL)forceReprocess
                        preferredRange:(NSRange)range{

    STSelectableView * itemViewOfLayerSet = (STSelectableView *) [self itemViewOfLayerSet:layerSet];
    NSAssert(!itemViewOfLayerSet.count || itemViewOfLayerSet.count==layerSet.frameCount,@"itemViewOfLayerSet.count must be empty OR same as layerSet.frameCount");

    NSArray * existedAllPresentableObjects = [[@(itemViewOfLayerSet.count) st_intArray] mapWithIndex:^id(id object, NSInteger i) {
        return [itemViewOfLayerSet presentableObjectAtIndex:i];
    }];

    STCapturedImageSetDisplayProcessor * processor = [STCapturedImageSetDisplayProcessor processorWithLayerSet:layerSet];
    processor.preferredRangeOfSourceSet = range;

    if(layerSet.effect){
        Weaks
        dispatch_async([STQueueManager sharedQueue].uiProcessing,^{
            @autoreleasepool {
                BOOL _needsSetViews = YES;

                NSArray<id> * presentableObjects = nil;
                /*
                 * STMultiSourcingGPUImageProcessor
                 */
                if([layerSet.effect isKindOfClass:STMultiSourcingGPUImageProcessor.class]){

                    if(!existedAllPresentableObjects.count){
                        presentableObjects = [[processor sourceSetOfImagesForLayerSet] mapWithIndex:^id(id object, NSInteger index) {
                            @autoreleasepool {
                                return [[GPUImageView alloc] initWithSize:_contentView.size];
                            }
                        }];
                    }else{
                        presentableObjects = existedAllPresentableObjects;
                        _needsSetViews = NO;
                    }

                    if(![processor processForImageInput:presentableObjects]){
                        NSAssert(NO, @"STMultiSourcingGPUImageProcessor -> processForImageInput was failed.");
                        presentableObjects = nil;
                    }

                }
                /*
                 * STMultiSourcingImageProcessor
                 */
                else{
                    presentableObjects = [processor processForImageUrls:forceReprocess];

                    if(existedAllPresentableObjects.count && !isNSRangeNull(processor.preferredRangeOfSourceSet)){
                        presentableObjects = [existedAllPresentableObjects replaceFromOtherArray:presentableObjects inRange:processor.preferredRangeOfSourceSet];
                    }
                }

                NSAssert(presentableObjects.count, @"presentableObjects's count is 0");
                if(_needsSetViews){
                    dispatch_async(dispatch_get_main_queue(),^{
                        NSArray * presentableObjectsToApply = presentableObjects.count ?
                                presentableObjects : [processor sourceOfImagesForLayer:[layerSet.layers firstObject]];

                        [Wself setLayerView:layerSet presentableObjects:presentableObjectsToApply forceAppend:forceAppend];
                    });
                }
            }
        });
    }else{
        //set default 0 STCapturedImageSet
        [self setLayerView:layerSet presentableObjects:[processor sourceOfImagesForLayer:[layerSet.layers firstObject]] forceAppend:forceAppend];
    }
}

- (void)setLayerView:(STCapturedImageSetAnimatableLayerSet *)layerSet presentableObjects:(NSArray *)presentableObjects forceAppend:(BOOL)forceAppend{
    //layer
    STFastUIViewSelectableView *layerView = (STFastUIViewSelectableView *)[_contentView viewWithTagName:layerSet.uuid];
    if(forceAppend || !layerView){
        layerView = [[STFastUIViewSelectableView alloc] initWithSize:_contentView.size];
        layerView.fitViewsImageToBounds = YES;
        layerView.tagName = layerSet.uuid;
        [_contentView addSubview:layerView];
    }
    [layerView setViews:presentableObjects];

    [self setNeedsLayersDisplayAndLayout];
}

- (UIView *)itemViewOfLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet {
    return [_contentView viewWithTagName:layerSet.uuid];
}

#pragma mark OffsetSlider
- (void)didSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {
    [self doingSlide:timeSlider withSelectedIndex:index];
}

- (void)doingSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {
    NSInteger targetIndexOfLayer = timeSlider.tag;
    STCapturedImageSetAnimatableLayerSet * layerSet = [self.layerSets st_objectOrNilAtIndex:targetIndexOfLayer];

    layerSet.frameIndexOffset = (NSInteger) round(timeSlider.normalizedPosition*10) - 5;

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