//
// Created by BLACKGENE on 2014. 9. 30..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import "iCarousel.h"
#import "NSArray+BlocksKit.h"
#import "STFilterCollector.h"
#import "STPhotoItem.h"
#import "STFilterManager.h"
#import "STFilterGroupItem.h"
#import "STFilterPresenterItemView.h"
#import "STFilterPresenterBase.h"
#import "STFilterPresenterImage.h"
#import "STFilterPresenterLive.h"
#import "NSArray+STUtil.h"
#import "NSObject+STUtil.h"
#import "NSString+STUtil.h"
#import "STPreviewPresenterAnimatableImage.h"

#pragma mark State
@interface STFilterCollectorState ()
@property (nonatomic, assign) NSUInteger currentFocusedGroupIndex;
@property (nonatomic, readwrite) NSArray * currentFocusedGroupItems;
@property (nonatomic, assign) NSUInteger numberOfGroups;
@property (nonatomic, assign) NSUInteger currentFocusedFilterIndex;
@property (nonatomic, assign) NSUInteger numberOfFilters;
@property (nonatomic, readwrite) STFilterItem *currentFocusedFilterItem;
@property (nonatomic, readwrite) STFilterItem *defaultFilterItem;
@end

@implementation STFilterCollectorState
- (GPUImageFillModeType) fillMode{
    return STFilterPresenterItemView.fillMode;
}
@end

#pragma mark STFilterCollector
@implementation STFilterCollector {
    BOOL _initializedItemViewRender;

    STFilterCollectorState * _state;
}

- (instancetype)init; {
    self = [super init];
    if (self) {
        Weaks
        _state = [[STFilterCollectorState alloc] init];

        @synchronized (self) {
            if([STFilterManager sharedManager].filterGroups){
                [self initFilterGroup];

            }else{
                Weaks
                [[STFilterManager sharedManager] whenNewValueOnceOf:@keypath([STFilterManager sharedManager].filterGroups) id:[@"STFilterCollector.filter.loaded" st_add:self.st_uid] changed:^(id value, id _weakSelf) {
                    [Wself initFilterGroup];
                }];
            }
        }

        _presenter = nil;
    }
    return self;
}

- (void)initFilterGroup{
    self.state.numberOfGroups = [STFilterManager sharedManager].filterGroups.count;
    STFilterGroupItem * group = [STFilterManager sharedManager].filterGroups[self.state.currentFocusedGroupIndex];
    _state.currentFocusedGroupItems = group.filters;
    [self initFiltersIncludeDefault];
}

- (void)initFiltersIncludeDefault{
    [self initItems:[@[[STFilterManager sharedManager].defaultFilterItem] mutableCopy]];
    [self.items addObjectsFromArray:_state.currentFocusedGroupItems];
}

- (void)initFiltersExcludeDefault {
    [self initItems:[_state.currentFocusedGroupItems mutableCopy]];
}

- (STFilterCollectorState *)state {
    _state.numberOfFilters = self.items.count;
    _state.currentFocusedFilterIndex = self.scrolledIndex;
    _state.currentFocusedFilterItem = [self.items st_objectOrNilAtIndex:self.scrolledIndex];
    _state.defaultFilterItem = [self.items firstObject];
    return _state;
}

- (void)_start {
    _initializedItemViewRender = NO;

    NSAssert(_presenter, @"[STFilterPresenter] _delegate is must alived when '_start'");

    [_presenter beforeStart];

    [UIView beginAnimations:nil context:NULL];

    if(!self.carousel.delegate){
        self.carousel.delegate = self;
    }

    if(!self.carousel.dataSource){
        self.carousel.dataSource = self;
    }else{
        [self.carousel reloadData];
    }

    self.carousel.bounces = NO;
    self.carousel.scrollEnabled = YES;
    self.carousel.centerItemWhenSelected = YES;

    [UIView commitAnimations];

    [_presenter afterStart];
}

- (void)startForImage:(STPhotoItem *)targetPhoto with:(iCarousel *)carousel {
    if([self isStarted]){
        return;
    }

    _carousel = carousel;
    _presenter = [[STFilterPresenterImage alloc] initWithOrganizer:self];
    [self _start];
    [self updateDisplayState];
}

- (void)startForAnimatableImage:(STPhotoItem *)targetPhoto with:(iCarousel *)carousel {
    if([self isStarted]){
        return;
    }

    _carousel = carousel;
    _presenter = [[STPreviewPresenterAnimatableImage alloc] initWithOrganizer:self];
    [self _start];
    [self updateDisplayState];
}

- (void)startForLive:(iCarousel *)carousel {
    if([self isStarted]){
        return;
    }

    _carousel = carousel;
    _presenter = [[STFilterPresenterLive alloc] initWithOrganizer:self];
    [self _start];
    self.carousel.currentItemIndex = 0;
    [self updateDisplayState];
}

- (void)reloadGroup:(NSUInteger)indexOfGroup{
    _state.currentFocusedGroupIndex = indexOfGroup;
    STFilterGroupItem * group = [STFilterManager sharedManager].filterGroups[indexOfGroup];
    _state.currentFocusedGroupItems = group.filters;

    if(indexOfGroup==0){
        [self initFiltersIncludeDefault];
    }else{
        [self initFiltersExcludeDefault];
    }

    [_presenter beforeClose];
    [_presenter clearFilterCaches];
    [_presenter finishAllResources];

    [self.carousel reloadData];

    [self updateDisplayState];
}

- (void)reload{
    [_presenter finishAllResources];

    Weaks
    [[self.carousel indexesForVisibleItems] bk_each:^(id obj) {
        [Wself.carousel reloadItemAtIndex:[obj integerValue] animated:NO];
    }];
};

- (void)layoutVisibleItems:(BOOL)layoutOnlyVisibleViews{
    if(layoutOnlyVisibleViews){
        [[self.carousel visibleItemViews] eachViewsWithIndex:^(UIView *view, NSUInteger index) {
            [view layoutSubviews];
        }];

    }else{
        [self.carousel layoutSubviews];
    }
};

- (STFilterPresenterItemView *)validateItemView:(NSInteger)index reusingView:(UIView *)view; {
    STFilterItem * filterItem = (STFilterItem *) self.items[index];

    STFilterPresenterItemView * itemView = [self validateFilterItemView:index filterItem:filterItem reusingView:view];

    BOOL reused = view != nil;

    [_presenter presentView:itemView filter:filterItem carousel:self.carousel viewForItemAtIndex:index reused:reused];

    return itemView;
}

- (STFilterPresenterItemView *)validateFilterItemView:(NSInteger)index filterItem:(STFilterItem *)filterItem reusingView:(UIView *)view; {
    if(_blockForFilterItemView){
        return _blockForFilterItemView(index, filterItem, view);

    }else{

        return [_presenter createItemView:index filterItem:filterItem reusingView:view];
    }
}

- (STFilterItem *)applyAndClose {
//    STFilterItem * filterItem = [STFilterManager sharedManager].currentFilterItem;
    STFilterItem * filterItem = self.items[self.scrolledIndex];

    [_presenter beforeApplyAndClose];

    [self finishAllResources];

    return filterItem;
}

- (void)close; {
    [_presenter beforeClose];

    [self finishAllResources];
}

- (void)closeIfStarted {
    if(self.isStarted){
        [self close];
    }
}

- (void)finishAllResources {
    [_presenter finishAllResources];
    _presenter = nil;

    self.carousel = nil;
}

- (BOOL)isStarted {
    return _presenter !=nil;
}

#pragma mark - CLUT filter operations
- (void)updateDisplayState {
    [self state];
}

- (void)clearFilterCaches {
    [_presenter clearFilterCaches];
}

#pragma mark Carousel

- (void)carouselWillBeginScrollingAnimation:(iCarousel *)carousel; {
    if(!_initializedItemViewRender){
        _initializedItemViewRender = YES;
        [_presenter initialPresentViews:carousel];
    }
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel; {
    [super carouselWillBeginDragging:carousel];
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel; {
    [super carouselDidEndScrollingAnimation:carousel];
}

- (void)carouselDidScroll:(iCarousel *)carousel; {
    [super carouselDidScroll:carousel];

    [self updateDisplayState];

    STFilterItem * filterItem = self.items[self.scrolledIndex];
    [_presenter currentSelectedFilterItem:filterItem];

    if(_blockForCurrentSelectedFilterItemItem){
        _blockForCurrentSelectedFilterItemItem(filterItem);
    }
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if(self.blockForiCarouselOption){
        return self.blockForiCarouselOption(option, value);
    }

    return _presenter ? [_presenter carousel:carousel valueForOption:option withDefault:value] : value;
}

@end