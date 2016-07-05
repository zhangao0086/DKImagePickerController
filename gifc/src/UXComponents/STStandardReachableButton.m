//
// Created by BLACKGENE on 2015. 7. 24..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <BlocksKit/NSTimer+BlocksKit.h>
#import "STStandardReachableButton.h"
#import "STDrawableLayer.h"
#import "CALayer+STUtil.h"
#import "UIView+STUtil.h"
#import "M13ProgressViewRing.h"
#import "STStandardUI.h"

@implementation STStandardReachableButton {
    STDrawableLayer *_reachingProgressCircle;
    M13ProgressViewRing *_outlineStrokeProgressView;
    NSTimer * _timerForAutoIncreaseOutlineProgress;
    CGFloat _currentTimeOffset;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _thresholdToReach = 1;
        _reachedProgressCirclePadding = 2;
        _reachedProgressCircleColor = [[STStandardUI buttonColorBackgroundOverlay] colorWithAlphaComponent:[STStandardUI alphaForDimmingGhostly]];

        _visibleOutlineProgress = YES;
        _autoVisiblityOutlineProgressViaThresholdToReach = YES;
        _outlineStrokeWidth = 2;

        _bindReachedToSelectedState = YES;

        [self setupDrawableLayers];

        self.outlineStrokeColor = [UIColor whiteColor];
        self.outlineStrokeBackgroundColor = [self.outlineStrokeColor colorWithAlphaComponent:[STStandardUI alphaForDimmingGhostly]];
        self.outlineStrokeWidth = _outlineStrokeWidth;

        [self _setNeedsUpdates];
    }
    return self;
}

- (void)dealloc {
    [self stopAutoIncreasingOutlineProgress];
}

- (void)didCreateContent {
    [super didCreateContent];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self _setNeedsUpdates];
}

- (void)setupDrawableLayers{
    Weaks
    CGFloat paddingIncludesOutlineStrokeWidth = self.outlineStrokeWidth + self.reachedProgressCirclePadding;

    //progress shape
    _reachingProgressCircle = [STDrawableLayer layerWithSize:self.size];
    _reachingProgressCircle.lineWidth = 0;
    _reachingProgressCircle.blockForDraw = ^(CGContextRef ctx) {
        Strongs
        [Sself.reachedProgressCircleColor setFill];

        UIBezierPath* path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(Sself.bounds, paddingIncludesOutlineStrokeWidth /2, paddingIncludesOutlineStrokeWidth /2)];
        [path fill];
    };

    [self.layer insertSublayer:_reachingProgressCircle atIndex:0];
    [_reachingProgressCircle setNeedsDisplay];

    //outline stroke
    _outlineStrokeProgressView = [[M13ProgressViewRing alloc] initWithFrame:self.bounds];
    _outlineStrokeProgressView.showPercentage = NO;
    [self insertSubview:_outlineStrokeProgressView atIndex:0];
}

- (void)setThresholdToReach:(CGFloat)thresholdToReach {
    NSAssert(thresholdToReach>0 && thresholdToReach<=1,@"thresholdToReach>0 && thresholdToReach<=1");
    _thresholdToReach = thresholdToReach;
}

- (void)setReachedProgress:(CGFloat)reachedProgress {
    CGFloat progress = CLAMP(reachedProgress,0,1);
    BOOL changed = _reachedProgress != progress;
    if(changed){
        [self willChangeValueForKey:@keypath(self.reachedProgress)];
        _reachedProgress = CLAMP(reachedProgress,0,1);
        !self.blockForWhenChangeReachedProgress?:self.blockForWhenChangeReachedProgress(self, _reachedProgress, _reached);
        [self didChangeValueForKey:@keypath(self.reachedProgress)];

        BOOL reached = _reachedProgress>=_thresholdToReach;
        if(reached != _reached){
            [self willChangeValueForKey:@keypath(self.reached)];
            _reached = reached;
            !self.blockForWhenChangeReached?:self.blockForWhenChangeReached(self, _reached);
            [self didChangeValueForKey:@keypath(self.reached)];

            //tap animation
            if(_reached && self.animationEnabled){
                [self animateTapCurrent];
            }

            //auto increasing
            if(self.autoIncreasingOutlineProgressDurationWhenAfterReached){
                if(_reached){
                    [self _startAutoIncreasingOutlineProgress:self.autoIncreasingOutlineProgressDurationWhenAfterReached performFirstCycleImmediately:NO resetWhenEnded:NO];
                }else{
                    [self stopAutoIncreasingOutlineProgress];
                }
                self.outlineProgress = 0;
            }
        }

        [self _setNeedsUpdates];
    }
}

- (void)_setNeedsUpdates {
    _reachingProgressCircle.scaleXYValue = AGKRemapAndClamp(_reachedProgress,0,1,_reachedMinimumProgressToDisplayScale,1);
    _reachingProgressCircle.hidden = _reached || _reachedProgress < _reachedMinimumProgressToDisplayScale;

    if(self.count>1 && self.bindReachedProgressToCurrentIndex){
        self.currentIndex = (NSUInteger) floorf(AGKRemapAndClamp(_reachedProgress, 0, 1, 0, self.count-1));
    }

    if(self.bindReachedToSelectedState){
        self.selectedState = _reached;
    }

    //outline progress
    BOOL visibleOutlineProgress = _visibleOutlineProgress;
    if(visibleOutlineProgress && _autoVisiblityOutlineProgressViaThresholdToReach){
        visibleOutlineProgress = _reached;
    }

    _outlineStrokeProgressView.visible = visibleOutlineProgress;
    if(visibleOutlineProgress){
        CGFloat scaleValue = 1-(((_outlineStrokeWidth+self.reachedProgressCirclePadding)*2)/self.boundsWidth);
        if(self.animateSelectedViewScaleIfVisibleOutlineProgress){
            self.currentButtonView.spring.scaleXYValue = scaleValue;
            self.backgroundView.spring.scaleXYValue = scaleValue;
        }else{
            self.currentButtonView.scaleXYValue = scaleValue;
            self.backgroundView.scaleXYValue = scaleValue;
        }
    }else{
        self.currentButtonView.scaleXYValue = 1;
        self.backgroundView.scaleXYValue = 1;
    }
}

#pragma mark style

- (void)setReachedProgressCirclePadding:(CGFloat)reachedProgressCirclePadding {
    _reachedProgressCirclePadding = reachedProgressCirclePadding;
    [_reachingProgressCircle setNeedsDisplay];
    [self _setNeedsUpdates];
}

- (void)setReachedProgressCircleColor:(UIColor *)reachedProgressCircleColor {
    _reachedProgressCircleColor = reachedProgressCircleColor;
    [_reachingProgressCircle setNeedsDisplay];
}

- (void)setOutlineStrokeColor:(UIColor *)outlineStrokeColor {
    _outlineStrokeProgressView.primaryColor = outlineStrokeColor;
}

- (UIColor *)outlineStrokeBackgroundColor {
    return _outlineStrokeProgressView.secondaryColor;
}

- (void)setOutlineStrokeBackgroundColor:(UIColor *)outlineStrokeBackgroundColor {
    _outlineStrokeProgressView.secondaryColor = outlineStrokeBackgroundColor;
}

- (UIColor *)outlineStrokeColor {
    return _outlineStrokeProgressView.primaryColor;
}

- (void)setOutlineStrokeWidth:(CGFloat)outlineStrokeWidth {
    _outlineStrokeProgressView.progressRingWidth = _outlineStrokeProgressView.backgroundRingWidth = _outlineStrokeWidth = outlineStrokeWidth;
}

- (void)setOutlineProgress:(CGFloat)outlineProgress {
    //when initially set outline progress without reachedProgress
    if(_outlineProgress==0 && outlineProgress>0 && self.reachedProgress==0 && self.reachedProgress!=self.thresholdToReach){
        self.reachedProgress = self.thresholdToReach;
    }
    _outlineProgress = outlineProgress;
    [_outlineStrokeProgressView setProgress:_outlineProgress animated:_animateOutlineProgress];
}

- (void)setVisibleOutlineProgress:(BOOL)visibleOutlineProgress {
    _visibleOutlineProgress = visibleOutlineProgress;
    [self _setNeedsUpdates];
}

- (void)setAutoVisiblityOutlineProgressViaThresholdToReach:(BOOL)autoVisiblityOutlineProgressViaThresholdToReach {
    _autoVisiblityOutlineProgressViaThresholdToReach = autoVisiblityOutlineProgressViaThresholdToReach;
    [self _setNeedsUpdates];
}

- (void)setReachedMinimumProgressToDisplayScale:(CGFloat)reachedMinimumProgressToDisplayScale {
    _reachedMinimumProgressToDisplayScale = reachedMinimumProgressToDisplayScale;
    [self _setNeedsUpdates];
}

- (void)startAutoIncreasingOutlineProgress:(NSTimeInterval)autoIncreasingOutlineProgressDuration performFirstCycleImmediately:(BOOL)start{
    [self startAutoIncreasingOutlineProgress:autoIncreasingOutlineProgressDuration performFirstCycleImmediately:start resetWhenEnded:NO];
}

- (void)startAutoIncreasingOutlineProgress:(NSTimeInterval)autoIncreasingOutlineProgressDuration performFirstCycleImmediately:(BOOL)start resetWhenEnded:(BOOL)reset{
    NSAssert(!self.autoIncreasingOutlineProgressDurationWhenAfterReached, @"Not allowed startAutoIncreasingOutlineProgress when already setted 'autoIncreasingOutlineProgressDurationWhenAfterReached == YES'");
    [self _startAutoIncreasingOutlineProgress:autoIncreasingOutlineProgressDuration performFirstCycleImmediately:start resetWhenEnded:reset];
}

- (void)setBindReachedToSelectedState:(BOOL)bindReachedToSelectedState {
    _bindReachedToSelectedState = bindReachedToSelectedState;
    [self _setNeedsUpdates];
}

- (void)setBindReachedProgressToCurrentIndex:(BOOL)bindReachedProgressToCurrentIndex {
    _bindReachedProgressToCurrentIndex = bindReachedProgressToCurrentIndex;
    [self _setNeedsUpdates];
}


- (void)_startAutoIncreasingOutlineProgress:(NSTimeInterval)autoIncreasingOutlineProgressDuration performFirstCycleImmediately:(BOOL)start resetWhenEnded:(BOOL)reset{
    NSAssert(autoIncreasingOutlineProgressDuration>0, @"autoIncreasingOutlineProgressDuration is musy be higher than 0");

    CGFloat cycleUnit = .05;

    Weaks
    void(^block)(NSTimer *) = ^(NSTimer *timer) {
        Strongs
        Sself->_currentTimeOffset+=cycleUnit;
        CGFloat progress = AGKRemapToZeroOne(Sself->_currentTimeOffset,0, (CGFloat) autoIncreasingOutlineProgressDuration);

        Wself.outlineProgress = progress;

        if(Sself->_currentTimeOffset >= autoIncreasingOutlineProgressDuration){
            [Wself stopAutoIncreasingOutlineProgress];
            if(reset){
                Wself.outlineProgress = 0;
            }
        }
    };

    _timerForAutoIncreaseOutlineProgress = [NSTimer bk_timerWithTimeInterval:cycleUnit block:block repeats:YES];

    [[NSRunLoop currentRunLoop] addTimer:_timerForAutoIncreaseOutlineProgress forMode:NSRunLoopCommonModes];

    if(start){
        block(_timerForAutoIncreaseOutlineProgress);
    }
}

- (void)stopAutoIncreasingOutlineProgress {
    _currentTimeOffset = 0;
    [_timerForAutoIncreaseOutlineProgress invalidate];
    _timerForAutoIncreaseOutlineProgress = nil;
}

- (BOOL)isAutoIncreasingOutlineProgressStarting {
    return [_timerForAutoIncreaseOutlineProgress isValid];
}


@end