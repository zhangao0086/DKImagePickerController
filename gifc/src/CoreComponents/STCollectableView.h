//
// Created by BLACKGENE on 2015. 3. 13..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "STSelectableView.h"
#import "STRadialView.h"

@interface STCollectableView : STSelectableView <STExpandableViewDelegate>
@property (nonatomic, assign) BOOL fitCollectableViewsImageToBounds;
@property (nonatomic, assign) BOOL excludeCurrentSelectedCollectableWhenExpand;
@property (nonatomic, assign) BOOL allowSelectCollectableAsBubblingTapGesture;
@property (nonatomic, readonly) STRadialView *collectableView;

- (id)initWithFrame:(CGRect)frame views:(NSArray *)presentableObjects radialItems:(NSArray *)radialMenuItemPresentableObjects;

- (void)setViews:(NSArray *)presentableObjects radialItemPresentableObjects:(NSArray *)radialMenuItemPresentableObjects;

- (void)setViews:(NSArray *)presentableObjects radialItemViews:(NSArray *)views;

- (void)setCollectableViews:(NSArray *)views;

- (void)clearCollectableViews;

- (BOOL)isExpanded;

- (void)expand;

- (void)expand:(BOOL)animation;

- (void)retract;

- (void)retract:(BOOL)animation;

- (void)setUserInteractionToSelectCollectables;

- (void)setCollectableViewsFromPresentableObjects:(NSArray *)presentableObjects;
@end