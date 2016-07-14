//
// Created by BLACKGENE on 7/8/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageView.h"
#import "STCapturedImageSet.h"
#import "NSArray+STUtil.h"
#import "STAfterImageLayerItem.h"
#import "UIView+STUtil.h"
#import "STAfterImageLayerView.h"
#import "STQueueManager.h"
#import "NSString+STUtil.h"
#import "STAfterImageLayerEffect.h"

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
        STAfterImageLayerView * layerView = (STAfterImageLayerView *) view;
        STAfterImageLayerItem *layerItem = [_afterImageItem.layers st_objectOrNilAtIndex:index];
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


    CGSize sliderSize = CGSizeMake(_sublayersContainerView.width, _sublayersContainerView.height/_afterImageItem.layers.count);

    for (STAfterImageLayerItem *layerItem in _afterImageItem.layers) {

        Weaks
        dispatch_async([STQueueManager sharedQueue].uiProcessing,^{
            STAfterImageLayerItem *_layerItem = layerItem;
            
            NSArray <NSURL *> * preheatedImageUrls = !_layerItem.effect ? nil : [presentableObjects mapWithIndex:^id(NSURL *imageUrl, NSInteger index) {
                NSAssert([imageUrl isKindOfClass:NSURL.class], @"only NSURL was allowed.");

                @autoreleasepool {
                    NSURL * tempURLToApplyEffect = [[NSString stringWithFormat:@"l_%@_e_%@_f_%d",
                                                                               _layerItem.uuid,
                                                                               _layerItem.effect.uuid,
                                                                               index
                    ] URLForTemp:@"filter_applied_after_image" extension:@"jpg"];

                    if([[NSFileManager defaultManager] fileExistsAtPath:tempURLToApplyEffect.path]){
                        //cached
                                                return tempURLToApplyEffect;

                    }else{
                        //newly create

                        if([UIImageJPEGRepresentation([_layerItem.effect processEffect:[UIImage imageWithContentsOfFile:imageUrl.path]], 1)
                                writeToURL:tempURLToApplyEffect
                                atomically:NO]){

                                                        return tempURLToApplyEffect;
                        }
                    }

                                        return nil;
                }
            }];

            if(preheatedImageUrls.count){
                dispatch_async(dispatch_get_main_queue(),^{
                    //layercb
                    STAfterImageLayerView *layerView = [[STAfterImageLayerView alloc] initWithSize:_sublayersContainerView.size];
                    layerView.layerItem = _layerItem;
                    layerView.fitViewsImageToBounds = YES;
                    [_sublayersContainerView addSubview:layerView];

                    [layerView setViews:preheatedImageUrls];

                    [Wself setViewsDisplay];
                });
            }

        });
        NSUInteger index = [_afterImageItem.layers indexOfObject:layerItem];

        //control - slider
        STSegmentedSliderView * offsetSlider = [[STSegmentedSliderView alloc] initWithSize:sliderSize];
        offsetSlider.y = index * sliderSize.height;
        offsetSlider.tag = index;
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
    }

    [_controlView st_gridSubviewsAsCenter:0 rowHeight:sliderSize.height column:1];

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
    [self doingSlide:timeSlider withSelectedIndex:index];
}

- (void)doingSlide:(STSegmentedSliderView *)timeSlider withSelectedIndex:(int)index {
    NSInteger targetIndexOfLayer = timeSlider.tag;
    STAfterImageLayerItem * layerItem = [_afterImageItem.layers st_objectOrNilAtIndex:targetIndexOfLayer];

        
    layerItem.frameIndexOffset = (NSInteger) round(timeSlider.normalizedCenterPositionOfThumbView*10) - 5;
    
    [self setViewsDisplay];
}

- (UIView *)createThumbView {
    if(_afterImageItem.layers.count){
        UIView * thumbView = [[UIView alloc] initWithSize:CGSizeMake(20, _sublayersContainerView.height/_afterImageItem.layers.count)];
        thumbView.backgroundColor = [UIColor blackColor];
        return thumbView;
    }
    return nil;
}

- (UIView *)createBackgroundView:(CGRect)bounds {
    return nil;
}

@end