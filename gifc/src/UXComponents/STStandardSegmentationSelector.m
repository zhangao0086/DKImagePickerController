//
// Created by BLACKGENE on 2014. 9. 11..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <BlocksKit/NSObject+BKBlockObservation.h>
#import "STStandardSegmentationSelector.h"
#import "STStandardButton.h"
#import "NSArray+STUtil.h"
#import "CAShapeLayer+STUtil.h"
#import "UIView+STUtil.h"

@implementation STStandardSegmentationSelector {

}

- (instancetype)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegateSlider = self;
    }
    return self;
}

- (void)dealloc {
    [self bk_removeAllBlockObservers];
}

- (void)didCreateContent {
    [super didCreateContent];
    self.multipleSelection = NO;
}

- (void)setCurrentIndex:(NSInteger)index; {
    if(_rollingThumbAnimationEnabled){
        if(self.currentIndex!=index){
            self.thumbView.layer.easeInEaseOut.rotation = (self.currentIndex > index ? -1 : 1) * M_PI * 2.0;
        }
    }
    [super setCurrentIndex:index];
}

#pragma mark Impl.
- (void)setSegmentationViewsFromButtons:(NSArray *)buttons{
    [self.backgroundView removeFromSuperview];

    Weaks
    [self setSegmentationViewAsPresentableObject:[buttons mapWithOriginal:^id(NSArray *array, id object, NSInteger index) {
        STStandardButton *button = object;
        button.allowSelectAsTap = YES;
        [button whenSelected:^(STSelectableView *selectedView, NSInteger _index) {
            Wself.currentIndex = [array indexOfObject:selectedView];
            [Wself dispatchSelected];
        }];
        return button;
    }]];
}

- (void)setSegmentationsForSelector:(NSArray *)imageNames maskColors:(NSArray *)colors{
    [self setSegmentationViewsFromButtons:[imageNames mapWithOriginal:^id(NSArray *array, id object, NSInteger index) {
        STStandardButton *button = [[STStandardButton alloc] initWithFrame:CGRectMakeWithSize_AGK(CGSizeMake(self.boundsHeight, self.boundsHeight))];
        [button setButtons:@[object] colors:@[colors[(NSUInteger) index]]];
        return button;
    }]];
}

- (void)setSegmentationsForSlider:(NSArray *)imageNames maskColors:(NSArray *)colors{
//    [self setViews:[self _createThumbButtons:imageNames maskColors:colors]];
    [self setSegmentationViewsFromButtons:[imageNames mapWithOriginal:^id(NSArray *array, id object, NSInteger index) {
        STStandardButton *button = [[STStandardButton alloc] initWithFrame:CGRectMakeWithSize_AGK(CGSizeMake(self.boundsHeight, self.boundsHeight))];
        [button setButtons:@[object] colors:@[colors[(NSUInteger) index]]];
        return button;
    }]];
}

- (void)setMultipleSelection:(BOOL)multipleSelection {
    _multipleSelection = multipleSelection;

    Weaks
    NSString * t_currentIndex = @"t_currentIndex";
    if(multipleSelection){
        [self.segmentationViews eachWithIndexMatchClass:STStandardButton.class block:^(id object, NSUInteger index){
            ((STStandardButton *)object).toggleEnabled = NO;
        }];
        [self bk_removeObserverForKeyPath:@keypath(self.currentIndex) identifier:t_currentIndex];
        [self whenBeforeClearViews:nil];

    }else{
        [self.segmentationViews eachWithIndexMatchClass:STStandardButton.class block:^(id object, NSUInteger index){
            ((STStandardButton *)object).toggleEnabled = YES;
        }];

        [self bk_addObserverForKeyPath:@keypath(self.currentIndex) identifier:t_currentIndex options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
            Strongs
            [Sself.segmentationViews[Sself.lastSelectedIndex] setSelectedState:NO];
            [Sself.segmentationViews[Sself.currentIndex] setSelectedState:YES];
        }];

        [self whenBeforeClearViews:^{
            [self bk_removeObserversWithIdentifier:t_currentIndex];
        }];
    }
}

- (NSArray *)_createThumbButtons:(NSArray *)imageNames maskColors:(NSArray *)colors{
    return [imageNames mapWithIndex:^id(id object, NSInteger index) {
        STStandardButton * button = [[STStandardButton alloc] initWithFrame:CGRectMakeWithSize_AGK(CGSizeMake(self.boundsHeight, self.boundsHeight)) buttons:@[object] maskColors:@[colors[(NSUInteger) index]]];
        button.allowSelectAsTap = NO;
        button.userInteractionEnabled = NO;
        button.selectedState = YES;
        button.allowSelectAsSlide = NO;
        return button;
    }];
}

- (UIView *)createBackgroundView:(CGRect)bounds; {
    UIView * view = [[UIView alloc] initWithSize:bounds.size];//[self st_createBlurView:UIBlurEffectStyleLight];
    view.layer.mask = [[CAShapeLayer roundRect:bounds.size color:nil] clearLineWidth];
    return view;
}

- (void)deselectStateAll {
    [self.segmentationViews eachWithIndexMatchClass:STStandardButton.class block:^(UIView *view, NSUInteger index) {
        ((STStandardButton *)view).selectedState = NO;
    }];
}

@end