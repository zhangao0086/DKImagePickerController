//
// Created by BLACKGENE on 2015. 3. 23..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STUIView.h"

@protocol STExpandableViewDelegate;

@interface STExpandableView : STUIView
@property (nonatomic, weak) NSObject<STExpandableViewDelegate> *delegate;
@property (nonatomic, readonly) BOOL isExpanded;
@property (nonatomic, readonly) NSArray * itemViews;
@property (nonatomic, assign) BOOL expandEnabled;
@property (nonatomic, assign) CGFloat expandingAnimationDuration;
@property (nonatomic, assign) NSTimeInterval expandingItemViewsInterval;
@property (nonatomic, assign) CGFloat distanceCenterToCenterBetweenItems;
@property (nonatomic, readwrite) NSSet * viewsNotShowing;
@property (copy) void (^blockForWillExpand)(BOOL animation);
@property (copy) void (^blockForDidExpanded)(void);
@property (copy) void (^blockForWillRetract)(BOOL animation);
@property (copy) void (^blockForDidRetracted)(void);
@property (copy) CGAffineTransform (^blockForCustomTransformToEachCenterPoint)(UIView *view, NSUInteger index);

- (void)addItemView:(UIView *)view;
- (void)removeItemView:(UIView *)view;
- (void)removeAllItemViews;
- (UIView *)itemViewAtIndex:(NSUInteger)index;
- (NSInteger)count;
- (void)expand;
- (void)expand:(BOOL)animation;
- (void)retract;
- (void)retract:(BOOL)animation;
- (void)animateWithExpanding:(void (^)(void))animations completion:(void (^)(BOOL finished))completion delay:(NSTimeInterval)delay;
@end

@protocol STExpandableViewDelegate <NSObject>
@optional
- (void)didExpand:(STExpandableView *)radialMenu;
- (void)didRetract:(STExpandableView *)radialMenu;
@end