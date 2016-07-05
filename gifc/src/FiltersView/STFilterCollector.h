//
// Created by BLACKGENE on 2014. 9. 30..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCarouselController.h"
#import "GPUImageView.h"

@protocol STFilterPresenterDelegate;
@class STFilterPresenterBase;

@interface STFilterCollectorState : NSObject
@property (nonatomic, readonly) GPUImageFillModeType fillMode;
@property (nonatomic, readonly) NSUInteger numberOfFilters;
@property (nonatomic, readonly) NSUInteger currentFocusedFilterIndex;
@property (nonatomic, readonly) NSUInteger numberOfGroups;
@property (nonatomic, readonly) NSUInteger currentFocusedGroupIndex;
@property (nonatomic, readonly) NSArray * currentFocusedGroupItems;
@property (nonatomic, readonly) STFilterItem *currentFocusedFilterItem;
@property (nonatomic, readonly) STFilterItem *defaultFilterItem;
@end

@interface STFilterCollector : STCarouselController

@property (nonatomic, readwrite) STPhotoItem * targetPhotoItem;
@property (nonatomic, readwrite) STFilterPresenterBase <STFilterPresenterDelegate> * presenter;
@property (nonatomic, readonly) STFilterCollectorState *state;
@property (copy) STFilterPresenterItemView * (^blockForFilterItemView)(NSInteger index, STFilterItem * filterItem, UIView * view);
@property (copy) void(^blockForCurrentSelectedFilterItemItem)(STFilterItem *);

- (void)initFiltersIncludeDefault;

- (void)initFiltersExcludeDefault;

- (void)startForImage:(STPhotoItem *)targetPhoto with:(iCarousel *)carousel;

- (void)startForAnimatableImage:(STPhotoItem *)targetPhoto with:(iCarousel *)carousel;

- (void)startForLive:(iCarousel *)carousel;

- (void)reloadGroup:(NSUInteger)indexOfGroup;

- (void)reload;

- (void)layoutVisibleItems:(BOOL)layoutOnlyVisibleViews;

- (STFilterItem *)applyAndClose;

- (void)close;

- (void)closeIfStarted;

- (BOOL)isStarted;

- (void)updateDisplayState;

- (void)clearFilterCaches;
@end