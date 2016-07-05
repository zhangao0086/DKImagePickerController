//
// Created by BLACKGENE on 2015. 3. 13..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <BlocksKit/NSArray+BlocksKit.h>
#import "STCollectableView.h"
#import "UIView+STUtil.h"
#import "NSArray+STUtil.h"

@implementation STCollectableView {
    STRadialView *_collectableView;
}

- (instancetype)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {
        self.touchInsidePolicy = STUIViewTouchInsidePolicyContentInside;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame views:(NSArray *)presentableObjects radialItems:(NSArray *)radialMenuItemPresentableObjects
{
    if ([self initWithFrame:frame])
    {
        [self setViews:presentableObjects radialItemPresentableObjects:radialMenuItemPresentableObjects];
    }
    return self;
}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    super.currentIndex = currentIndex;
    [self setNeedsViewsNotShowingExcludeTargetsToExpand];
}

- (void)setViews:(NSArray *)presentableObjects radialItemPresentableObjects:(NSArray *)radialMenuItemPresentableObjects {
    [self setViews:presentableObjects];
    [self setCollectableViewsFromPresentableObjects:radialMenuItemPresentableObjects];
}

- (void)setViews:(NSArray *)presentableObjects radialItemViews:(NSArray *)views {
    [self setViews:presentableObjects];
    [self setCollectableViews:views];
    [self.collectableView expand:NO];
    [self setNeedsDisplay];
}

- (void)setCollectableViewsFromPresentableObjects:(NSArray *)presentableObjects {
    [self setCollectableViews:[presentableObjects bk_map:^id(id obj) {
        UIView * view = [UIView st_createViewFromPresentableObject:obj];
        return view;
    }]];
    [self setNeedsDisplay];
}

- (void)setCollectableViews:(NSArray *)views {
    [self clearCollectableViews];

    if(![self.collectableView superview]){
        [self insertSubview:self.collectableView belowSubview:_contentView];
    }

    [views bk_each:^(id object) {
        [self.collectableView addItemView:object];
    }];

    self.collectableView.delegate = self;
}

- (void)clearCollectableViews {
    [_collectableView retract:NO];
    [_collectableView removeAllItemViews];
    _collectableView.delegate = nil;
    _collectableView.blockForDidExpanded = nil;
    _collectableView.blockForWillRetract = nil;
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];

    Weaks
    if(self.fitCollectableViewsImageToBounds){
        [self.collectableView.itemViews eachViewsWithIndex:^(UIView *view, NSUInteger index) {
            view.contentMode = UIViewContentModeScaleAspectFit;
            view.size = self.size;
            [view centerToParent];
        }];
    }
    [self.collectableView setNeedsDisplay];
}

- (void)setUserInteractionToSelectCollectables {
    NSAssert(self.collectableView.itemViews.count, @"itemView's count of collectableView must be > 0");
    self.allowSelectAsTap = NO;
    self.allowSelectAsSlide = NO;

    Weaks
    void(^collectableTapped)(NSUInteger index) = ^(NSUInteger index) {
        Wself.currentIndex = index;
        [Wself dispatchSelected];
        [Wself retract];
    };
    [self.collectableView.itemViews eachViewsWithIndex:^(UIView *_view, NSUInteger index) {
        _view.userInteractionEnabled = YES;
        if(Wself.allowSelectCollectableAsBubblingTapGesture){
            [_view whenLongTapAsTapDownUp:nil changed:nil ended:^(UILongPressGestureRecognizer *sender, CGPoint location) {
                collectableTapped(index);
            }];
        }else{
            [_view whenTapped:^{
                collectableTapped(index);
            }];
        }
    }];

    void(^buttonViewTapped)(void) = ^(void) {
        if(Wself.isExpanded){
            [Wself retract];
        }else{
            [Wself expand];
        }
    };
    if(self.allowSelectCollectableAsBubblingTapGesture){
        [self whenLongTapAsTapDownUp:nil changed:nil ended:^(UILongPressGestureRecognizer *sender, CGPoint location) {
            buttonViewTapped();
        }];
    }else{
        [self whenTapped:^{
            buttonViewTapped();
        }];
    }
}

- (STRadialView *)collectableView; {
    return _collectableView ? _collectableView : (_collectableView = [[STRadialView alloc] initWithFrame:self.bounds]);
}

- (void)setExcludeCurrentSelectedCollectableWhenExpand:(BOOL)excludeCurrentSelectedCollectableWhenExpand {
    _excludeCurrentSelectedCollectableWhenExpand = excludeCurrentSelectedCollectableWhenExpand;
    [self setNeedsViewsNotShowingExcludeTargetsToExpand];
}

- (BOOL)setNeedsViewsNotShowingExcludeTargetsToExpand{
    self.collectableView.viewsNotShowing = nil;

    if(self.excludeCurrentSelectedCollectableWhenExpand){
        if(self.collectableView.count<2){
            return NO;

        }else{
            UIView * targetView = [self.collectableView itemViewAtIndex:self.currentIndex];
            if(![self.collectableView.viewsNotShowing containsObject:targetView]){
                self.collectableView.viewsNotShowing = [NSSet setWithObject:targetView];
            }
        }
    }
    return YES;
}

- (BOOL)isExpanded{
    return self.collectableView.isExpanded;
}

- (void)expand{
    [self expand:YES];
}

- (void)expand:(BOOL)animation{
    if([self setNeedsViewsNotShowingExcludeTargetsToExpand]){

        [self.collectableView expand:animation];
    }
}

- (void)retract{
    [self.collectableView retract];
}

- (void)retract:(BOOL)animation{
    [self.collectableView retract:animation];
}

- (void)clearViews; {
    [self clearCollectableViews];
    [super clearViews];
}

- (void)dealloc; {
    [_collectableView removeFromSuperview];
    _collectableView = nil;
}

#pragma mark delegate
- (void)didRetract:(STExpandableView *)view; {
}

- (void)didExpand:(STExpandableView *)view; {
}

#pragma mark Auto rotation

- (__typed_collection(NSArray,UIView *))targetViewsForChangingTransformFromOrientation {
    if(self.autoOrientationOnlySelectableViews){
        if(self.isExpanded){
            return @[_contentView, _collectableView];
        }else{
            return @[_contentView];
        }
    }
    return [super targetViewsForChangingTransformFromOrientation];
}

@end