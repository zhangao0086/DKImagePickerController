//
//  Created by Jesse Andersen on 11/1/12.
//  Copyright (c) 2012 Scribd. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "SCPageView.h"

#import <QuartzCore/QuartzCore.h>

@interface SCPageContainerView : UIView {
    SCPagingDirection _direction;
}

@property (nonatomic, strong) UIView *pageView;
@property (nonatomic, strong) UIView *headerView;

- (id)initWithFrame:(CGRect)frame header:(UIView *)header page:(UIView *)page direction:(SCPagingDirection)direction;

@end

@interface SCPageView () {
    CGFloat _totalMovement;
    SCPageContainerView *_animatingPage;
}

@property (nonatomic, assign) NSUInteger numberOfPages;
@property (nonatomic, weak) SCPageContainerView *activePage;
@property (nonatomic, weak) SCPageContainerView *previousPage;
@property (nonatomic, weak) SCPageContainerView *nextPage;
@property (nonatomic, assign) NSUInteger currentPageNumber;
@property (nonatomic, strong) NSNumber *scrollFinalPosition;
@property (nonatomic, assign) SCPageViewState pageViewState;
@property (nonatomic, strong) UIView *transitionView;
@property (nonatomic, strong) UIView *nextGapView;
@property (nonatomic, strong) UIView *previousGapView;

@end

@implementation SCPageView

static CGFloat const kCancellationTheshold = 20.0f;
static CGFloat const kVelocityThreshold = 1000.0f;

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)_setup {
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.alwaysBounceHorizontal = YES;
    self.alwaysBounceVertical = YES;
    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:0];
    [self.panGestureRecognizer addTarget:self action:@selector(_scHandlePan:)];
    _transitionView = [[UIView alloc] init];
    _transitionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _pagingThresholdPercent = 0.1f;
    _direction = SCPagingDirectionVertical;
    
    _nextGapView = [[UIView alloc] init];
    _previousGapView = [[UIView alloc] init];
    
    [self _configureGapViews];
}

- (id)init {
    if (self = [super init]) {
        [self _setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setup];
    }
    return self;
}

#pragma mark - UIView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (self.pageViewState == SCPageViewStateTransitionNext || self.pageViewState == SCPageViewStateTransitionPrevious) {
        self.pageViewState = SCPageViewStateTransitionInterrupted;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (self.pageViewState == SCPageViewStateTransitionInterrupted) {
        [self _alignToBestPage];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if (self.pageViewState == SCPageViewStateTransitionInterrupted && self.panGestureRecognizer.state != UIGestureRecognizerStateBegan && self.panGestureRecognizer.state != UIGestureRecognizerStateChanged) {
        [self _alignToBestPage];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
        
    // previous page
    if (self.previousPage) {
        CGSize size = [self _sizeForPage:self.previousPage];
        CGPoint origin;
        CGRect gapFrame = self.previousGapView.frame;
        if (self.direction == SCPagingDirectionVertical) {
            origin = CGPointMake(0.0f, -size.height - self.gapBetweenPages);
            gapFrame.origin = CGPointMake(0.0f, -self.gapBetweenPages);
        } else {
            origin = CGPointMake(-size.width - self.gapBetweenPages, 0.0f);
            gapFrame.origin = CGPointMake(-self.gapBetweenPages, 0.0f);
        }
        self.previousPage.frame = [self _rectWithOrigin:origin size:size];
        self.previousGapView.frame = gapFrame;
    }
    
    // active page
    if (self.activePage) {
        self.activePage.frame = [self _rectWithOrigin:CGPointZero size:[self _sizeForPage:self.activePage]];
    }
    
    // next page
    if (self.nextPage) {
        CGPoint origin;
        CGRect gapFrame = self.nextGapView.frame;
        if (self.direction == SCPagingDirectionVertical) {
            origin = CGPointMake(0.0f, self.activePage.frame.origin.y + self.activePage.frame.size.height + self.gapBetweenPages);
            gapFrame.origin = CGPointMake(0.0f, self.activePage.frame.origin.y + self.activePage.frame.size.height);
        } else {
            origin = CGPointMake(self.activePage.frame.origin.x + self.activePage.frame.size.width + self.gapBetweenPages, 0.0f);
            gapFrame.origin = CGPointMake(self.activePage.frame.origin.x + self.activePage.frame.size.width, 0.0f);
        }
        self.nextPage.frame = [self _rectWithOrigin:origin size:[self _sizeForPage:self.nextPage]];
        self.nextGapView.frame = gapFrame;
    }
    
    CGFloat contentHeight = self.activePage.frame.size.height;
    if (contentHeight < self.bounds.size.height) {
        contentHeight = self.bounds.size.height;
    }
    
    self.contentSize = CGSizeMake(self.bounds.size.width, contentHeight);
}

- (CGSize)_sizeForPage:(UIView *)page {
    CGSize size = self.bounds.size;
    size = [page sizeThatFits:size];
    if (size.width < self.bounds.size.width) {
        size.width = self.bounds.size.width;
    }
    if (size.height < self.bounds.size.height) {
        size.height = self.bounds.size.height;
    }
    return size;
}

- (CGRect)_rectWithOrigin:(CGPoint)origin size:(CGSize)size {
    return CGRectMake(origin.x, origin.y, size.width, size.height);
}

#pragma mark - UIScrollView

- (void)setContentOffset:(CGPoint)contentOffset {
    if (self.direction == SCPagingDirectionVertical) {
        [super setContentOffset:CGPointMake(0.0f, contentOffset.y)];
    } else {
        [super setContentOffset:CGPointMake(contentOffset.x, 0.0f)];
    }
}

#pragma mark - Pan Gesture

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint translate = [pan translationInView:self];
        return [self _validateMovement:translate];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [gestureRecognizer.view isKindOfClass:[SCPageView class]] && [otherGestureRecognizer.view isKindOfClass:[SCPageView class]]) {
        return YES;
    }
    return NO;
}

- (void)_scHandlePan:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translate = [((UIPanGestureRecognizer *)gestureRecognizer) translationInView:self];
        _totalMovement = fabsf(translate.y) + fabsf(translate.x);
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan && (self.pageViewState == SCPageViewStateTransitionNext || self.pageViewState == SCPageViewStateTransitionPrevious)) {
        self.pageViewState = SCPageViewStateTransitionInterrupted;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded && (self.pageViewState == SCPageViewStateResting || self.pageViewState == SCPageViewStateTransitionInterrupted)) {
        [self _alignToBestPage];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && _totalMovement < kCancellationTheshold) {
        // if the total movement of the pan is under a certain threshold, we will see if it should be canceled due to invalid movement.
        // The main purpose of this code is to ensure a vertical pan doesn't trigger when a horizontal should have & vice versa.
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint translate = [pan translationInView:self];
        _totalMovement += fabsf(translate.y) + fabsf(translate.x);
        if (_totalMovement < kCancellationTheshold && ![self _validateMovement:translate]) {
            // if the movement becomes invalid after a short amount of time, cancel it.
            pan.enabled = NO;
            pan.enabled = YES;
        }
    }
}

- (BOOL)_validateMovement:(CGPoint)translate {
    if (self.direction == SCPagingDirectionVertical) {
        return (translate.y == 0 && translate.x == 0) || (translate.y != 0 && ((fabsf(translate.x) / fabsf(translate.y)) < 1.0f));
    } else {
        return (translate.y == 0 && translate.x == 0) || (translate.x != 0 && ((fabsf(translate.y) / fabsf(translate.x)) < 1.0f));
    }
}

- (void)_alignToBestPage {
    CGFloat velocity;
    CGFloat top = 0.0f;
    CGFloat bottom;
    CGFloat pagingThreshold = [self _pagingThreshold];
    CGFloat contentOffset;
    CGPoint velocityPoint = [self.panGestureRecognizer velocityInView:self];
    if (self.direction == SCPagingDirectionVertical) {
        velocity = velocityPoint.y;
        bottom = self.activePage.frame.size.height - self.bounds.size.height;
        contentOffset = self.contentOffset.y;
    } else {
        velocity = velocityPoint.x;
        bottom = self.activePage.frame.size.width - self.bounds.size.width;
        contentOffset = self.contentOffset.x;
    }
    
    if ((contentOffset < (top - pagingThreshold) || velocity > kVelocityThreshold) && self.previousPage && velocity > 0) {
        self.pageViewState = SCPageViewStateTransitionPrevious;
    } else if ((contentOffset > (bottom + pagingThreshold) || velocity < -kVelocityThreshold) && self.nextPage && velocity < 0) {
        self.pageViewState = SCPageViewStateTransitionNext;
    } else if (self.pageViewState == SCPageViewStateTransitionInterrupted && contentOffset < top) {
        [self setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
    } else if (self.pageViewState == SCPageViewStateTransitionInterrupted && contentOffset > bottom) {
        CGPoint origin = self.direction == SCPagingDirectionVertical ? CGPointMake(0.0f, bottom) : CGPointMake(bottom, 0.0f);
        [self setContentOffset:origin animated:YES];
    }
}

- (CGFloat)_pagingThreshold {
    CGFloat result;
    if (self.direction == SCPagingDirectionVertical) {
        result = self.bounds.size.height * self.pagingThresholdPercent;
    } else {
        result = self.bounds.size.width * self.pagingThresholdPercent;
    }
    
    if (self.pagingThresholdMinimum > 0.0f && result < self.pagingThresholdMinimum) {
        result = self.pagingThresholdMinimum;
    }
    
    return result;
}

#pragma mark - Page Loading

- (void)reloadData {
    if ([self.pageDelegate respondsToSelector:@selector(numberOfPagesInPageView:)]) {
        self.numberOfPages = [self.pageDelegate numberOfPagesInPageView:self];
    } else {
        self.numberOfPages = 0;
    }
    self.activePage = nil;
    BOOL hadPrevious = self.previousPage != nil;
    BOOL hadNext = self.nextPage != nil;
    self.previousPage = nil;
    self.nextPage = nil;
    if (_currentPageNumber > _numberOfPages - 1) {
        _currentPageNumber = _numberOfPages - 1;
    }
    [self _loadCurrentPage];
    if (hadNext) {
        [self _loadNextPage];
    }
    if (hadPrevious) {
        [self _loadPreviousPage];
    }
}

#pragma mark - Properties

- (void)setNumberOfPages:(NSUInteger)numberOfPages {
    if (numberOfPages != _numberOfPages) {
        _numberOfPages = numberOfPages;
        if ([self.pageDelegate respondsToSelector:@selector(pageView:didChangeNumberOfPagesTo:)]) {
            [self.pageDelegate pageView:self didChangeNumberOfPagesTo:_numberOfPages];
        }
    }
}

- (void)setCurrentPageNumber:(NSUInteger)currentPageNumber animated:(BOOL)animated fast:(BOOL)fastAnimation {
    if (currentPageNumber != _currentPageNumber) {
        [self _transitionToPageNumber:currentPageNumber animated:animated fast:fastAnimation];
    }
}

- (void)setCurrentPageNumber:(NSUInteger)currentPageNumber {
    [self _setCurrentPageNumber:currentPageNumber force:NO];
}

- (void)_setCurrentPageNumber:(NSUInteger)currentPageNumber force:(BOOL)force {
    if (currentPageNumber != _currentPageNumber || force) {
        _currentPageNumber = currentPageNumber;
        if ([self.pageDelegate respondsToSelector:@selector(pageView:didChangeCurrentPageNumberTo:)]) {
            [self.pageDelegate pageView:self didChangeCurrentPageNumberTo:_currentPageNumber];
        }
    }
}

#pragma mark - Page Transitioning

static CGFloat const fastAnimationSpeed = 0.15f;
static CGFloat const slowAnimationSpeed = 0.3f;
static CGFloat const baseAnimationDelay = 0.15f;
static CGFloat const delayIncrementAmount = 0.025f;

- (void)_transitionToPageNumber:(NSUInteger)pageNumber animated:(BOOL)animated fast:(BOOL)fastAnimation {
    self.previousPage = nil;
    self.nextPage = nil;
    
    if (animated) {
        BOOL isForward = pageNumber > self.currentPageNumber;
        if (fastAnimation) {
            [self _animatePage:pageNumber isFoward:isForward duration:fastAnimationSpeed finalPage:pageNumber delay:baseAnimationDelay];
        } else {
            CGFloat pageJump = abs(self.currentPageNumber - pageNumber);
            CGFloat duration = (animated ? (pageJump > 1 ? fastAnimationSpeed : slowAnimationSpeed) : 0.0f);
            if (isForward) {
                [self _animatePage:pageNumber isFoward:isForward duration:duration finalPage:pageNumber delay:0.0f];
            } else {
                [self _animatePage:pageNumber isFoward:isForward duration:duration finalPage:pageNumber delay:0.0f];
            }
        }
    } else {
        self.activePage = [self _loadPageNumber:pageNumber];
        [self _setCurrentPageNumber:pageNumber force:YES];
    }
}

- (void)_animatePage:(NSUInteger)pageIter isFoward:(BOOL)isForward duration:(CGFloat)duration finalPage:(NSUInteger)finalPage delay:(CGFloat)delay {
    _currentPageNumber = pageIter;
    SCPageContainerView *next = [self _loadPageNumber:pageIter];
    SCPageContainerView *previous = _animatingPage ?: _activePage;
    _animatingPage = next;
    _activePage = nil;
    if (next) {
        CGRect frame = self.bounds;
        if (self.direction == SCPagingDirectionHorizontal) {
            frame.origin.x = isForward ? (frame.size.width + self.gapBetweenPages) : (-frame.size.width - self.gapBetweenPages);
        } else {
            frame.origin.y = isForward ? (frame.size.height + self.gapBetweenPages) : (-frame.size.height - self.gapBetweenPages);
        }
        next.frame = frame;
        [self addSubview:next];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
                CGRect frame = previous.frame;
                if (self.direction == SCPagingDirectionHorizontal) {
                    frame.origin.x = isForward ? (-frame.size.width - self.gapBetweenPages) : (frame.size.width + self.gapBetweenPages);
                } else {
                    frame.origin.y = isForward ? (-frame.size.height - self.gapBetweenPages) : (frame.size.height + self.gapBetweenPages);
                }
                previous.frame = frame;
                next.frame = CGRectMake(0.0f, 0.0f, next.frame.size.width, next.frame.size.height);
            } completion:^(BOOL finished) {
                [previous removeFromSuperview];
                if (_animatingPage == next) {
                    self.activePage = next;
                    [self _setCurrentPageNumber:finalPage force:YES];
                    _animatingPage = nil;
                }
            }];
        });
    }
}

#pragma mark - Pages

- (void)setPreviousPage:(SCPageContainerView *)previousPage {
    if (previousPage != _previousPage) {
        [_previousPage removeFromSuperview];
        _previousPage = previousPage;
        if (_previousPage) {
            self.previousGapView.hidden = NO;
            [self addSubview:_previousPage];
            [self setNeedsLayout];
        } else {
            self.previousGapView.hidden = YES;
        }
    }
}

- (void)setActivePage:(SCPageContainerView *)activePage {
    if (activePage != _activePage) {
        [_activePage removeFromSuperview];
        _activePage = activePage;
        if (_activePage) {
            [self addSubview:_activePage];
            [self setNeedsLayout];
            if ([self.pageDelegate respondsToSelector:@selector(pageDidBecomeActive:page:pageView:)]) {
                [self.pageDelegate pageDidBecomeActive:self.currentPageNumber page:_activePage pageView:self];
            }
        }
    }
}

- (void)setNextPage:(SCPageContainerView *)nextPage {
    if (nextPage != _nextPage) {
        [_nextPage removeFromSuperview];
        _nextPage = nextPage;
        if (_nextPage) {
            self.nextGapView.hidden = NO;
            [self addSubview:_nextPage];
            [self setNeedsLayout];
        } else {
            self.nextGapView.hidden = YES;
        }
    }
}

#pragma mark - Page Loading

- (void)_loadCurrentPage {
    if (self.numberOfPages > 0 && self.currentPageNumber < self.numberOfPages) {
        self.activePage = [self _loadPageNumber:self.currentPageNumber];
    }
}

- (void)_loadPreviousPage {
    if (self.numberOfPages > 1 && self.currentPageNumber > 0) {
        self.previousPage = [self _loadPageNumber:self.currentPageNumber-1];
    }
}

- (void)_loadNextPage {
    if (self.numberOfPages > 1 && self.currentPageNumber < self.numberOfPages - 1) {
        self.nextPage = [self _loadPageNumber:self.currentPageNumber+1];
    }
}

- (SCPageContainerView *)_loadPageNumber:(NSUInteger)pageNumber {
    UIView *page;
    if ([self.pageDelegate respondsToSelector:@selector(pageForPageNumber:inPageView:)]) {
        page = [self.pageDelegate pageForPageNumber:pageNumber inPageView:self];
    }
    
    UIView *header;
    if ([self.pageDelegate respondsToSelector:@selector(headerViewForPageNumber:inPageView:)]) {
        header = [self.pageDelegate headerViewForPageNumber:pageNumber inPageView:self];
    }
    
    SCPageContainerView *result =  [[SCPageContainerView alloc] initWithFrame:self.bounds header:header page:page direction:self.direction];
    result.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return result;
}

#pragma mark - State

- (void)setPageViewState:(SCPageViewState)pageViewState {
    if (pageViewState != _pageViewState) {
        SCPageViewState previous;        
        if (pageViewState == SCPageViewStateTransitionNextImmediately || pageViewState == SCPageViewStateTransitionPreviousImmediately) {
            previous = pageViewState;
            _pageViewState = SCPageViewStateResting;
        } else {
            previous = _pageViewState;
            _pageViewState = pageViewState;
        }
        
        switch (_pageViewState) {
            case SCPageViewStateResting: {
                [self.transitionView removeFromSuperview];
                SCPageContainerView *active = self.activePage;
                if (previous == SCPageViewStateTransitionPrevious || previous == SCPageViewStateTransitionPreviousImmediately) {
                    active = self.previousPage;
                    _previousPage = nil;
                    self.nextPage = nil;
                    self.currentPageNumber -= 1;
                } else if (previous == SCPageViewStateTransitionNext || previous == SCPageViewStateTransitionNextImmediately) {
                    active = self.nextPage;
                    _nextPage = nil;
                    self.previousPage = nil;
                    self.currentPageNumber += 1;
                } else {
                    self.previousPage = nil;
                    self.nextPage = nil;
                }
                self.activePage = active;
                self.scrollFinalPosition = nil;
                self.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
                break;
            }
            case SCPageViewStateTransitionNext: {
                self.transitionView.frame = self.bounds;
                [self addSubview:self.transitionView];
                if (self.direction == SCPagingDirectionVertical) {
                    self.scrollFinalPosition = @(self.activePage.frame.size.height);
                    [self setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, self.nextPage.frame.size.height, 0.0f)];
                    if (self.contentOffset.y < [self.scrollFinalPosition floatValue]) {
                        [self setContentOffset:CGPointMake(0.0f, [self.scrollFinalPosition floatValue]) animated:YES];
                    }
                } else {
                    self.scrollFinalPosition = @(self.activePage.frame.size.width);
                    [self setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, self.nextPage.frame.size.width)];
                    if (self.contentOffset.x < [self.scrollFinalPosition floatValue]) {
                        [self setContentOffset:CGPointMake([self.scrollFinalPosition floatValue], 0.0f) animated:YES];
                    }
                }
                break;
            }
            case SCPageViewStateTransitionPrevious: {
                self.transitionView.frame = self.bounds;
                [self addSubview:self.transitionView];
                if (self.direction == SCPagingDirectionVertical) {
                    self.scrollFinalPosition = @(-self.previousPage.frame.size.height);
                    [self setContentInset:UIEdgeInsetsMake(self.previousPage.frame.size.height, 0.0f, 0.0f, 0.0f)];
                    if (self.contentOffset.y > [self.scrollFinalPosition floatValue]) {
                        [self setContentOffset:CGPointMake(0.0f, [self.scrollFinalPosition floatValue]) animated:YES];
                    }
                } else {
                    self.scrollFinalPosition = @(-self.previousPage.frame.size.width);
                    [self setContentInset:UIEdgeInsetsMake(0.0f, self.previousPage.frame.size.width, 0.0f, 0.0f)];
                    if (self.contentOffset.x > [self.scrollFinalPosition floatValue]) {
                        [self setContentOffset:CGPointMake([self.scrollFinalPosition floatValue], 0.0f) animated:YES];
                    }
                }
                break;
            } case SCPageViewStateTransitionInterrupted: {
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Configuration

- (void)setDirection:(SCPagingDirection)direction {
    if (direction != _direction) {
        _direction = direction;
        [self _configureGapViews];
        [self setNeedsLayout];
    }
}

- (void)setGapBetweenPages:(CGFloat)gapBetweenPages {
    if (gapBetweenPages != _gapBetweenPages) {
        // sanitize the value
        if (gapBetweenPages < 0.0f) {
            _gapBetweenPages = 0.0f;
        } else {
            _gapBetweenPages = floorf(gapBetweenPages);
        }
        [self _configureGapViews];
        [self setNeedsLayout];
    }
}

#pragma mark - Gap Views

- (void)_configureGapViews {
    if (self.gapBetweenPages > 0.0f) {
        [self addSubview:self.nextGapView];
        [self addSubview:self.previousGapView];
        if (self.direction == SCPagingDirectionHorizontal) {
            self.nextGapView.frame = CGRectMake(0.0f, 0.0f, self.gapBetweenPages, self.bounds.size.height);
            self.nextGapView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        } else {
            self.nextGapView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.gapBetweenPages);
            self.nextGapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        }
        self.previousGapView.frame = self.nextGapView.frame;
        self.previousGapView.autoresizingMask = self.nextGapView.autoresizingMask;
    } else {
        [self.nextGapView removeFromSuperview];
        [self.previousGapView removeFromSuperview];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {        
        CGPoint offsetPoint = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        
        // adjust the transition view
        if (self.transitionView.superview) {
            CGRect frame = self.transitionView.frame;
            frame.origin = offsetPoint;
            self.transitionView.frame = frame;
        }
        
        CGFloat offset;
        CGFloat selfBoundsSize;
        CGFloat activePageSize;
        if (self.direction == SCPagingDirectionVertical) {
            offset = offsetPoint.y;
            selfBoundsSize = self.bounds.size.height;
            activePageSize = self.activePage.frame.size.height;
        } else {
            offset = offsetPoint.x;
            selfBoundsSize = self.bounds.size.width;
            activePageSize = self.activePage.frame.size.width;
        }
        
        // make the header view of the active page stickyickyicky
        if (self.activePage.headerView) {
            CGFloat origin = (offset > 0) && (!self.nextPage || offset <= (activePageSize - selfBoundsSize)) ? fabsf(offset) : 0.0f;
            CGRect frame = self.activePage.headerView.frame;
            frame.origin = (self.direction == SCPagingDirectionVertical) ? CGPointMake(0.0f, origin) : CGPointMake(origin, 0.0f);
            self.activePage.headerView.frame = frame;
        }
        
        // previous page shiat
        if (self.pageViewState == SCPageViewStateTransitionPrevious && offset == [self.scrollFinalPosition floatValue]) {
            self.pageViewState = SCPageViewStateResting;
        } else if (self.pageViewState == SCPageViewStateResting && offset < 0 && self.previousPage == nil && self.currentPageNumber > 0) {
            [self _loadPreviousPage];
        } else if (self.pageViewState == SCPageViewStateResting && offset > 0 && self.previousPage) {
            self.previousPage = nil;
        }
        
        // next page shiat
        if (self.pageViewState == SCPageViewStateTransitionNext && offset == [self.scrollFinalPosition floatValue]) {
            self.pageViewState = SCPageViewStateResting;
        } else if (self.pageViewState == SCPageViewStateResting && (offset + selfBoundsSize) > activePageSize && self.nextPage == nil) {
            [self _loadNextPage];
        } else if (self.pageViewState == SCPageViewStateResting && (offset + selfBoundsSize) < activePageSize && self.nextPage) {
            self.nextPage = nil;
        }
        
        if (self.pageViewState == SCPageViewStateTransitionInterrupted) {
            if (offset >= 0 && offset <= (activePageSize - selfBoundsSize)) {
                self.pageViewState = SCPageViewStateResting;
            } else if (offset > activePageSize && self.currentPageNumber < (self.numberOfPages - 1)) {
                // If the user manages to pan completely past the active page, transition to the next page
                self.pageViewState = SCPageViewStateTransitionNextImmediately;
            } else if (offset < -activePageSize && self.currentPageNumber > 0) {
                // If the user manages to pane completely past the active page, tranisition to the prev page
                self.pageViewState = SCPageViewStateTransitionPreviousImmediately;
            }
        }
    }
}

@end

@implementation SCPageContainerView

- (id)initWithFrame:(CGRect)frame header:(UIView *)header page:(UIView *)page direction:(SCPagingDirection)direction {
    if (self = [super initWithFrame:frame]) {
//        self.clipsToBounds = YES;
        _direction = direction;
        self.headerView = header;
        header.clipsToBounds = YES;
        frame = header.frame;
        frame.origin = CGPointZero;
        frame.size = _direction == SCPagingDirectionVertical ? CGSizeMake(self.bounds.size.width, header.frame.size.height) : CGSizeMake(header.frame.size.width, self.bounds.size.height);
        header.frame = frame;
        header.autoresizingMask = _direction == SCPagingDirectionVertical ? UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin : UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:header];
        
        self.pageView = page;
        frame = page.frame;
        if (_direction == SCPagingDirectionVertical) {
            frame.origin = CGPointMake(0.0f, header.frame.size.height);
            frame.size = CGSizeMake(self.bounds.size.width, self.bounds.size.height - header.frame.size.height);
        } else {
            frame.origin = CGPointMake(header.frame.size.width, 0.0f);
            frame.size = CGSizeMake(self.bounds.size.width - header.frame.size.width, self.bounds.size.height);
        }
        page.frame = frame;
        page.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:page];
        
        [self bringSubviewToFront:header];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize pageSize = [self.pageView sizeThatFits:size];
    if (_direction == SCPagingDirectionVertical) {
        return CGSizeMake(size.width, pageSize.height + self.headerView.frame.size.height);
    } else {
        return CGSizeMake(pageSize.width + self.headerView.frame.size.width, size.height);
    }
}

- (void)layoutSubviews {
    if (_direction == SCPagingDirectionVertical) {
        self.pageView.frame = CGRectMake(0.0f, self.headerView.frame.size.height, self.bounds.size.width, self.bounds.size.height - self.headerView.frame.size.height);
    } else {
        self.pageView.frame = CGRectMake(self.headerView.frame.size.width, 0.0f, self.bounds.size.width - self.headerView.frame.size.width, self.bounds.size.height);
    }
}

@end
