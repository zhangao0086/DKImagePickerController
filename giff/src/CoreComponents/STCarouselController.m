//
// Created by BLACKGENE on 2014. 9. 30..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import "STCarouselController.h"
#import "NSArray+STUtil.h"
#import "UIView+STUtil.h"

#define kDefaultNumbersOfVisible 5

@interface STCarouselController ()
@end

@implementation STCarouselController {

    NSMutableArray * _items;

    void (^_whenDidEndScroll)(NSInteger);
    void (^_whenDidSelected)(NSInteger);
    void (^_whenChangedScrolledIndex)(NSInteger);
}

- (instancetype)initWithCarousel:(iCarousel *)carousel;{
    self = [super init];
    if (self) {
        _carousel = carousel;
    }
    return self;
}

- (void)initItems:(NSMutableArray *)items; {
    _items = items;
}

- (void)dealloc; {
    [_items removeAllObjects];
    _items = nil;
}

- (NSMutableArray *)items; {
    if(!_items){
        _items = [NSMutableArray array];
    }
    return _items;
}

- (void)setCarousel:(iCarousel *)carousel; {
    [[_carousel visibleItemViews] eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        [view clearAllOwnedImagesIfNeeded:YES removeSubViews:YES];
        [view removeFromSuperview];
    }];
    [_carousel removeFromSuperview];

    _carousel = carousel;
    _scrolledIndex = 0;
}

- (void)delegateSelf {
    if(_carousel.dataSource!=self){
        _carousel.dataSource = self;
    }
    if(_carousel.delegate!=self){
        _carousel.delegate = self;
    }
}

- (void)changedCarouselScrollIndex:(NSUInteger)scrolledIndex {
    if(_whenChangedScrolledIndex){
        _whenChangedScrolledIndex(scrolledIndex);
    }
}

- (UIView *)validateItemView:(NSInteger)index reusingView:(UIView *)view; {
//    NSAssert(self.class!=[STCarouselController class], @"must override [- (UIView *)validateItemView:(NSInteger)index reusingView:(UIView *)view;]");
    return self.blockForItemView ? self.blockForItemView(index, view) : nil;
}

- (void)whenDidEndScroll:(void (^)(NSInteger))block; {
    _whenDidEndScroll = block;
}

- (void)whenDidSelected:(void (^)(NSInteger))block; {
    _whenDidSelected = block;
}

- (void)whenChangedScrolledIndex:(void (^)(NSInteger))block; {
    _whenChangedScrolledIndex = block;
}

#pragma mark Delegate iCarousel
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view{
//    if([self _checkViewFromICarouselUpdateItemWidthBugs:index]){
//        return [[UIView allocWithZone:NULL] init];
//    }
    return [self validateItemView:index reusingView:view];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if(self.blockForiCarouselOption){
        return self.blockForiCarouselOption(option, value);
    }
    return value;
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel; {
    return self.items.count;
}

- (void)carouselDidScroll:(iCarousel *)carousel; {

    NSUInteger currentIndex = (NSUInteger) MAX(0.0, carousel.currentItemIndex);
    BOOL indexChanged = currentIndex!=_scrolledIndex;
    _scrolledIndex = currentIndex;
    if(indexChanged){
        [self changedCarouselScrollIndex:currentIndex];
    }
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel; {
    return self.itemWidth>0 ? self.itemWidth : self.carousel.superview.bounds.size.width;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index; {

    if(_whenDidSelected){
        _whenDidSelected(index);
    }
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel; {

    if(_whenDidEndScroll){
        _whenDidEndScroll(self.carousel.currentItemIndex);
    }
}

#pragma mark iCarousel fix
- (BOOL)_checkViewFromICarouselUpdateItemWidthBugs:(NSInteger)index{
    return index==0
        && self.carousel.numberOfVisibleItems==0
        && self.carousel.scrollOffset >= 1
        && [self _offsetIsInVisibleRange:self.carousel.scrollOffset];
}

- (BOOL)_offsetIsInVisibleRange:(CGFloat)currentOffset{
    CGFloat visibleRange = floorf([self carousel:self.carousel valueForOption:iCarouselOptionVisibleItems withDefault:kDefaultNumbersOfVisible]/2);
    return currentOffset < self.items.count-visibleRange && currentOffset > visibleRange;
}

@end