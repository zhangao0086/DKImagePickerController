//
// Created by BLACKGENE on 2014. 10. 13..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NHBalancedFlowLayout.h"
#import "STPhotoItem.h"

@class STPhotoItem;
@class STPhotoSelector;
@class STThumbnailGridView;
@class STThumbnailGridViewCell;

@protocol STThumbnailGridViewDelegate <NSObject>
@optional
- (void)beganPerformedPullToRefresh:(UIScrollView *)scrollView;

- (void)didCancelPullToRefresh:(UIScrollView *)scrollView;

- (void)performmingPullToRefresh:(UIScrollView *)scrollView;

- (void)didPerformedPullToRefresh:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)didScrolledToLastPosition:(STThumbnailGridView *)scrollView;
@end

@interface STThumbnailGridView : UICollectionView <NHBalancedFlowLayoutDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, readwrite) id<STThumbnailGridViewDelegate> gridViewDelegate;
@property (atomic, readonly) NSMutableArray * items;
@property (nonatomic, assign) STPhotoViewType type;
@property(nonatomic, readonly) NSUInteger scrolledIndex;
@property (nonatomic, readonly) BOOL scrolledLast;
@property (nonatomic, assign) BOOL enabledCellAnimations;

- (void)setType:(STPhotoViewType)type;

- (void)representPhotoItemOfAllVisibleCells:(BOOL)disposeUnVisibles;

- (void)updateViewsByScrolled;

- (void)deselectAll;

- (void)selectPhotoItemAtIndex:(NSUInteger)index1;

- (void)selectPhotoItem:(STPhotoItem *)item;

- (void)deselectPhotoItemAtIndex:(NSUInteger)index1;

- (void)deselectPhotoItem:(STPhotoItem *)item;

- (STPhotoItem *)photoItemForIndexPath:(NSIndexPath *)path;

- (NSIndexPath *)indexPathForPhotoItem:(STPhotoItem *)item;

- (NSArray *)indexPathsForPhotoItems:(NSArray *)items;

- (STThumbnailGridViewCell *)cellForIndex:(NSUInteger)index;

- (STThumbnailGridViewCell *)cellForPhotoItem:(STPhotoItem *)item;

- (void)scrollToTop;

- (void)scrollTo:(NSUInteger)index;

- (void)scrollTo:(NSUInteger)index animated:(BOOL)animated;

- (CGFloat)currentPullingDistanceRatio;

- (void)whenDidBatchUpdated:(void(^)(BOOL finished))block;
@end