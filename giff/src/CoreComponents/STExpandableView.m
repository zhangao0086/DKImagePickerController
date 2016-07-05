//
// Created by BLACKGENE on 2015. 3. 23..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STExpandableView.h"
#import "UIView+STUtil.h"
#import "NSSet+STUtil.h"

@implementation STExpandableView {
    NSMutableArray * _menuItemViews;
}

#pragma mark Initalizer

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (void)dealloc; {
    [self removeAllItemViews];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _menuItemViews = [NSMutableArray new];
        [self setToDefault];
    }
    return self;
}

- (void)setToDefault{
    _expandEnabled = YES;
    _distanceCenterToCenterBetweenItems = 0;
    _expandingItemViewsInterval = 0;
    _expandingAnimationDuration = 0.4;
}

//- (void)setNeedsDisplay; {
//    [super setNeedsDisplay];
//
//    NSInteger i = 0;
//    for (UIView *subView in _menuItemViews) {
//        if([self.viewsNotShowing containsObject:subView]){
//            subView.visible = NO;
//            subView.transform = CGAffineTransformIdentity;
//        }else{
//            subView.visible = YES;
//            subView.transform = [self _transformForItemViewAtIndex:i];
//            i++;
//        }
//    }
//}

- (void)didMoveToSuperview; {
    [super didMoveToSuperview];
    [self setNeedsDisplay];
}

#pragma mark Gesture Recognizers
- (void)setExpandEnabled:(BOOL)expandEnabled; {
    _expandEnabled = expandEnabled;

     if(!expandEnabled && _isExpanded){
        [self retract:NO];
    }
}

- (void)expand {
    [self expand:YES];
}

- (void)expand:(BOOL)animation {
    if(!self.expandEnabled){
        return;
    }

    if(_isExpanded){
        return;
    }

    void (^completion)(BOOL) = ^(BOOL finished) {
        !_blockForDidExpanded ?: _blockForDidExpanded();

        if ([self.delegate respondsToSelector:@selector(didExpand:)]) {
            [self.delegate didExpand:self];
        }
    };


    !_blockForWillExpand ?: _blockForWillExpand(animation);

    NSInteger i = 0;
    for (UIView *subView in _menuItemViews) {

        if([self.viewsNotShowing containsObject:subView]){
            subView.visible = NO;
            subView.transform = CGAffineTransformIdentity;

        }else{
            subView.visible = YES;
            if(animation){
                subView.alpha = 0;
                subView.transform = CGAffineTransformIdentity;
                Weaks
                [self animateWithExpanding:^{
                    subView.alpha = 1;
                    subView.transform = [Wself _transformForItemViewAtIndex:i];
                }               completion:completion delay:Wself.expandingItemViewsInterval * i];
            }else{
                subView.alpha = 1;
                subView.transform = [self _transformForItemViewAtIndex:i];
                if(i==_menuItemViews.count-1){
                    completion(YES);
                }
            }

            i++;
        }
    }

    _isExpanded = YES;

    [self setNeedsDisplay];
}

- (void)retract {
    [self retract:YES];
}

- (void)retract:(BOOL)animation {
    if(!self.expandEnabled){
        return;
    }

    if(!_isExpanded){
        return;
    }

    void (^completion)(BOOL) = ^(BOOL finished) {
        !_blockForDidRetracted ?: _blockForDidRetracted();

        if ([self.delegate respondsToSelector:@selector(didRetract:)]) {
            [self.delegate didRetract:self];
        }
    };

    !_blockForWillRetract ?:_blockForWillRetract(animation);

    NSInteger i = 0;
    for (UIView *subView in _menuItemViews) {
        if(animation){
            [self animateWithExpanding:^{
                subView.transform = CGAffineTransformIdentity;
                subView.alpha = 0;
            } completion:completion delay:self.expandingItemViewsInterval * i];

        }else{
            subView.alpha = 0;
            subView.transform = CGAffineTransformIdentity;
            if(i==_menuItemViews.count-1){
                completion(YES);
            }
        }
        i++;
    }

    _isExpanded = NO;
}

#pragma mark Popout Views
- (void)setViewsNotShowing:(NSSet *)viewsNotShowing {
    NSAssert(!_menuItemViews || (!viewsNotShowing || [viewsNotShowing st_minusSet:[NSSet setWithArray:_menuItemViews]].count==0), @"given viewsNotShowing must be containing by _menuItemViews");
    _viewsNotShowing = viewsNotShowing;
}

- (void)addItemView:(UIView *)view {
    [_menuItemViews addObject:view];

    [self insertSubview:view atIndex:0];

    view.alpha = 0;
    [view centerToParent];

    if(view){
        _expandEnabled = YES;
    }
}

- (void)removeItemView:(UIView *)view {
    [_menuItemViews removeObject:view];
    [view removeFromSuperview];
}

- (void)removeAllItemViews {
    for(UIView * itemView in _menuItemViews){
        [itemView removeFromSuperview];
    }
    [_menuItemViews removeAllObjects];
}

- (NSArray *)itemViews {
    return _menuItemViews;
}

- (NSInteger)count{
    return [_menuItemViews count];
}

- (UIView *)itemViewAtIndex:(NSUInteger)index; {
    NSParameterAssert(index < _menuItemViews.count);

    if(_menuItemViews && _menuItemViews.count){
        return _menuItemViews[index];
    }
    return nil;
}

- (CGAffineTransform)_transformForItemViewAtIndex: (NSInteger) index {
    UIView *itemView = [self itemViewAtIndex:index];
    return self.blockForCustomTransformToEachCenterPoint ? self.blockForCustomTransformToEachCenterPoint(itemView, index) : [self transformForItemViewAtIndex:itemView index:index];
}

- (CGAffineTransform)transformForItemViewAtIndex:(UIView *)itemView index:(NSInteger) index {
    return CGAffineTransformIdentity;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    if (CGRectContainsPoint(self.bounds, point)) {
        return true;
    }
    for (UIView *subView in _menuItemViews) {
        if (CGRectContainsPoint(subView.frame, point)) {
            return true;
        }
    }
    return false;
}

#pragma mark Utils
- (void)animateWithExpanding:(void (^)(void))animations completion:(void (^)(BOOL finished))completion delay:(NSTimeInterval)delay{
    [UIView animateWithDuration:self.expandingAnimationDuration
                          delay:delay
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.4
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:animations
                     completion:completion];
}
@end
