//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFAnimatableLayerFrameEditItemView.h"
#import "STCapturedImageSet.h"


@implementation STGIFFAnimatableLayerFrameEditItemView {

}

- (void)createContent {
    [super createContent];


//    //control
//    CGSize sliderControlSize = CGSizeMake(_sublayersContainerView.width, _sublayersContainerView.height/_layers.count);
//    STSegmentedSliderView * offsetSlider = [[STSegmentedSliderView alloc] initWithSize:sliderControlSize];
//    offsetSlider.y = layerItem.index * sliderControlSize.height;
//    offsetSlider.tag = layerItem.index;
//    offsetSlider.tagName = layerItem.uuid;
//    offsetSlider.delegateSlider = self;
////        offsetSlider.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.4];
//    offsetSlider.normalizedCenterPositionOfThumbView = .5;
//
////        Weaks
////        [offsetSlider.thumbView whenPanAsSlideVertical:nil started:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf) {
////
////        } changed:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf, CGFloat distance, CGPoint movedOffset, CGFloat distanceReachRatio, STSlideDirection direction, BOOL confirmed) {
////
////            layerItem.alpha = CLAMP(locationInSelf.y,0,offsetSlider.thumbBoundView.height)/offsetSlider.thumbBoundView.height;
////            [Wself setViewsDisplay];
////
////        } ended:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf, STSlideDirection direction, BOOL confirmed) {
////
////        }];
//    [_controlView addSubview:offsetSlider];
//    [_controlView st_gridSubviewsAsCenter:0 rowHeight:sliderControlSize.height column:1];
}

@end