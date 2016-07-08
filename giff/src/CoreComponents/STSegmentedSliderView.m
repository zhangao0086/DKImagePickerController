//
//  STSegmentedSliderControl.m
//  Betify
//
//  Created by Alok on 28/06/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import <BlocksKit/NSArray+BlocksKit.h>
#import "STSegmentedSliderView.h"
#import "UIView+STUtil.h"
#import "CAShapeLayer+STUtil.h"

@implementation STSegmentedSliderView {
    UIView *_segmentationViewContainer;
    NSMutableArray *_centerPositions;
    NSInteger _numberOfPoints;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];

        _thumbView = [self makeThumbView];
        _thumbView.frame = CGRectModified_AGK(self.bounds, ^CGRect(CGRect rect) {
            rect.size = CGSizeMake(rect.size.height, rect.size.height);
            return rect;
        });

        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        [_backgroundView.layer addSublayer:[[CAShapeLayer roundRect:self.bounds.size color:[UIColor whiteColor]] clearLineWidth]];

        _segmentationViewContainer = [[UIView alloc] initWithFrame:self.bounds];
        _segmentationViewContainer.opaque = NO;

        _allowMoveThumbAsSlide = YES;
        _centerPositions = [NSMutableArray array];

        self.fitViewsImageToBounds = NO;
        self.allowSelectAsSlide = NO;
        self.allowSelectAsTap = NO;
        self.allowMoveThumbAsTap = YES;
        self.allowMoveThumbAsSlide = YES;
        self.touchInsidePolicy = STUIViewTouchInsidePolicyContentInside;
    }
    return self;
}

- (void)setDelegateSlider:(id <STSegmentedSliderControlDelegate>)delegateSlider; {
    _delegateSlider = delegateSlider;

    id bg = nil;

    if(self.blockForCreateBackgroundPresentableObject){
        bg = self.blockForCreateBackgroundPresentableObject(self.bounds);
    }else if([self.delegateSlider respondsToSelector:@selector(createBackgroundView:)]){
        bg = [self.delegateSlider createBackgroundView:self.bounds];
    }else if([self.delegateSlider respondsToSelector:@selector(createBackgroundLayer:)]){
        bg = [self.delegateSlider createBackgroundLayer:self.bounds];
    }

    if(bg){
        [_backgroundView removeFromSuperview];
        _backgroundView = [UIView st_createViewFromPresentableObject:bg];
        [self insertSubview:_backgroundView belowSubview:_segmentationViewContainer];
    }
}

- (void)createContent; {
    [super createContent];

    [self addSubview:_segmentationViewContainer];
    [self insertSubview:_thumbView aboveSubview:_segmentationViewContainer];
}

- (void)layoutSubviews; {
    [super layoutSubviews];

    [self updatePositionPoints];
}

- (void)clearViews; {
    [super clearViews];

    [self clearSegmentationViews];
}

- (NSUInteger)count; {
    return [super count]==0 ? self.segmentationViews.count : [super count];
}

#pragma mark impl.

- (void)setSegmentationViews:(NSArray *)segmentationViews; {
    [self setSegmentationViewAsPresentableObject:segmentationViews];
}

- (NSArray *)segmentationViews; {
    return _segmentationViewContainer.subviews;
}

- (void)setSegmentationViewAsPresentableObject:(NSArray *)presentableObjects {
    if(_segmentationViewContainer.subviews.count){
        [self clearSegmentationViews];
    }

    [self setNumberOfPoints:presentableObjects.count];

    [presentableObjects eachWithIndex:^(id object, NSUInteger index) {
        UIView *itemView = [UIView st_createViewFromPresentableObject:object];
        itemView.bounds = _thumbView.bounds;
        itemView.center = [self.centerPositions[index] CGPointValue];
        [_segmentationViewContainer addSubview:itemView];
    }];

    [self setGestures];
    [self moveToIndexWithNoAnimation:self.currentIndex];
}

- (void)clearSegmentationViews {
    [[_segmentationViewContainer subviews] bk_each:^(id obj) {
        UIView * view = obj;
        [view whenTap:nil];
        [view removeFromSuperview];
    }];
    [self whenPan:nil];
}

- (void)setAllowMoveThumbAsTap:(BOOL)allowMoveThumbAsTap; {
    _allowMoveThumbAsTap = allowMoveThumbAsTap;

    [self setTap];
}

- (void)setAllowMoveThumbAsSlide:(BOOL)allowMoveThumbAsSlide; {
    _allowMoveThumbAsSlide = allowMoveThumbAsSlide;

    _thumbView.userInteractionEnabled = allowMoveThumbAsSlide;

    [self setPan];
}

- (UIView *)makeThumbView {
    if([self.delegateSlider respondsToSelector:@selector(createThumbView)]){
        _contentView.visible = NO;
        return [self.delegateSlider createThumbView];
    }
    return _contentView;
}

- (CGSize) thumbViewSize{
    return CGSizeMake(self.boundsHeight, self.boundsHeight);
}

- (CGFloat) halfOfThumbViewSize{
    return [self thumbViewSize].width*.5f;
}

- (void)setThumbViewCenter:(CGPoint)p {
    [self setThumbViewCenter:p completion:nil];
}

- (void)setThumbViewCenter:(CGPoint)p completion:(void (^)(void))block{
    [self setThumbViewCenter:p animation:_movingThumbAnimationEnabled completion:block];
}

- (void)setThumbViewCenter:(CGPoint)point animation:(BOOL)animation completion:(void (^)(void))block{
    if(animation){
        Weaks
        [NSObject animate:^{
            Strongs
            Sself->_thumbView.easeInEaseOut.center = point;

        } completion:^(BOOL finished) {
            Strongs
            if(finished && [Sself->_thumbView pop_animationKeys].count==0){
                if(block) block();
            }
        }];

    }else{

//        if([[_thumbView pop_animationKeys] count])
//            [_thumbView pop_removeAllAnimations];

        _thumbView.center = point;

        if(block) block();
    }
}

#pragma mark User touch
- (void)setGestures{
    [self setTap];
    [self setPan];
}

- (void(^)(UIGestureRecognizer *, UIGestureRecognizerState, CGPoint))getGestureBlock {
    CGPoint leftMargin = CGPointMake([self halfOfThumbViewSize], [self halfOfThumbViewSize]);
    CGPoint rightMargin = CGPointMake(self.right-[self halfOfThumbViewSize], [self halfOfThumbViewSize]);
    __block CGFloat offset = 0;

    return ^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        CGPoint loc = [sender locationInView:self];
        loc.y = _thumbView.center.y;

        BOOL stateChanged = UIGestureRecognizerStateChanged == [sender state];

        if ((loc.x >= leftMargin.x) && (loc.x <= rightMargin.x)) {
            [self setThumbViewCenter:loc animation:NO completion:nil];
        }
        else if (loc.x <= leftMargin.x) {
            [self setThumbViewCenter:leftMargin animation:NO completion:nil];
        }
        else if (loc.x >= rightMargin.x) {
            [self setThumbViewCenter:rightMargin animation:NO completion:nil];
        }

        if (stateChanged) {
            offset = loc.x - _thumbView.center.x;
            super.currentIndex = (NSUInteger) [self currentNeedsIndex:offset];
        }

        if ([sender state] == UIGestureRecognizerStateEnded) {
            self.currentIndex = (NSUInteger) [self currentNeedsIndex:offset];
            [self dispatchSelected];
            [self setNeedsDisplay];
            offset = 0;
        }

    };
}

- (void)setTap{

    [self whenTap:!_allowMoveThumbAsTap ? nil : [self getGestureBlock]];
}

- (void)setPan {

    [self whenPan: !_allowMoveThumbAsSlide ? nil : [self getGestureBlock]].delaysTouchesBegan = YES;
}

- (NSInteger)currentNeedsIndex:(CGFloat)directionOffset {
    CGFloat criticalPointMargin = _thumbView.boundsWidth/3;
    CGFloat positionFloor = _centerPositions.count * (_thumbView.left / self.boundsWidth);
    CGFloat positionNextFloor = _centerPositions.count * ((_thumbView.centerX) / self.boundsWidth);
    CGFloat positionPrevFloor = _centerPositions.count * ((_thumbView.left-_thumbView.boundsWidthHalf) / self.boundsWidth);

    NSInteger needsIndex = (NSInteger)( (directionOffset ==0 ? positionFloor : (directionOffset >0 ? positionNextFloor : positionPrevFloor)) + .5);

    if(directionOffset ==0){
        return needsIndex;
    }else if(directionOffset >0){
        return MIN(_centerPositions.count - 1, needsIndex);
    }else{
        return MAX(0, needsIndex);
    }
}

- (void)setCurrentIndex:(NSUInteger)index {
    BOOL changed = self.currentIndex != index;

    [super setCurrentIndex:index];
    
    if ([_centerPositions count] > index) {
        Weaks
        [self setThumbViewCenter:[[_centerPositions objectAtIndex:index] CGPointValue] completion:^{
            Strongs
            if (changed && [Sself->_delegateSlider respondsToSelector:@selector(didSlide:withSelectedIndex:)]) {
                [Sself->_delegateSlider didSlide:Sself withSelectedIndex:index];
            }
        }];
        [self setNeedsDisplay];
    }
}

- (void)moveToIndexWithNoAnimation:(NSInteger)index {
    BOOL enabled = self.movingThumbAnimationEnabled;
    self.movingThumbAnimationEnabled = NO;
    [self setCurrentIndex:index];
    self.movingThumbAnimationEnabled = enabled;
}

#pragma mark -
#pragma mark Getters

- (NSArray *)centerPositions; {
    return _centerPositions;
}

- (void)setNumberOfPoints:(NSInteger)numberOfPoints  {
//    NSAssert(numberOfPoints>2, @"setNumberOfPointsWithDefaultState must be higher than 2");
//
//    NSInteger minNumberOfPoints = (self.currentIndex + 1) > 2 ? (self.currentIndex + 1) : 2;
//
//    if (numberOfPoints < minNumberOfPoints) {
//        _numberOfPoints = minNumberOfPoints;
//    } else {
//        _numberOfPoints = numberOfPoints;
//    }

    _numberOfPoints = numberOfPoints;

    [self updatePositionPoints];
}

- (void)updatePositionPoints{
    [_centerPositions removeAllObjects];

    CGFloat paddingHorizontal = self.boundsHeightHalf - _thumbView.boundsHeightHalf;

    CGFloat halfSize = [self halfOfThumbViewSize];

    for (int i = 0; i < _numberOfPoints; i++) {
        [_centerPositions addObject:[NSValue valueWithCGPoint:CGPointMake((paddingHorizontal + halfSize) + (i * ((self.boundsWidth - (halfSize + paddingHorizontal) * 2)) / (_numberOfPoints>1 ? _numberOfPoints - 1 : 1) ), self.boundsHeightHalf)]];
    }

    [_segmentationViewContainer st_eachSubviews:^(UIView *view, NSUInteger index) {
        view.center = [_centerPositions[index] CGPointValue];
    }];
}

@end