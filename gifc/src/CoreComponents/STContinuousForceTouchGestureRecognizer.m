//
//  STContinuousForceTouchGestureRecognizer.m
//
//  Created by Daniel Fogg on 9/29/15. (https://github.com/foggzilla/DFContinuousForceTouchGestureRecognizer)
//  Copyright © 2015 Daniel Fogg. All rights reserved.
//
//  Modified and renamed by metasmile 8/1/16 (https://github.com/stellarstep/STCodeBundle)

#import "STContinuousForceTouchGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

static CGFloat const kForceTouchBaseDefaultPressureThreshold = 1.0f;
static CGFloat const kForceTouchDefaultTriggerPressureThreshold = 2.5f;
static CGFloat const kForceTouchDefaultDelay = 0.5f;
static CGFloat const kDefaultTouchTimeout = 1.5f;


@interface STContinuousForceTouchGestureRecognizer ()

@property(nonatomic, assign) NSTimeInterval gestureStartTime;
@property(nonatomic, assign) BOOL forceTouchFired;
@property(nonatomic, assign) BOOL forceTouchInitialTouchDetect;
@property(nonatomic, assign) NSInteger initialForce;
@property(nonatomic, strong) NSTimer* forceTouchTimedTrigger;

// Its possible that the touches end will never get called if the view is scrolled
//      inside a scroll view, so timeout the end of the gesture
@property(nonatomic, strong) NSTimer* lastMovedTimeoutTimer;

@end

@implementation STContinuousForceTouchGestureRecognizerDelegator
- (instancetype)initWithDidTimeout:(void (^)(STContinuousForceTouchGestureRecognizer *))didTimeout didMoveWithForce:(void (^)(STContinuousForceTouchGestureRecognizer *, CGFloat, CGFloat))didMoveWithForce didCancelWithForce:(void (^)(STContinuousForceTouchGestureRecognizer *, CGFloat, CGFloat))didCancelWithForce didEndWithForce:(void (^)(STContinuousForceTouchGestureRecognizer *, CGFloat, CGFloat))didEndWithForce {
    self = [super init];
    if (self) {
        self.didTimeout = didTimeout;
        self.didMoveWithForce = didMoveWithForce;
        self.didCancelWithForce = didCancelWithForce;
        self.didEndWithForce = didEndWithForce;
    }

    return self;
}

+ (instancetype)delegatorWithDidTimeout:(void (^)(STContinuousForceTouchGestureRecognizer *))didTimeout didMoveWithForce:(void (^)(STContinuousForceTouchGestureRecognizer *, CGFloat, CGFloat))didMoveWithForce didCancelWithForce:(void (^)(STContinuousForceTouchGestureRecognizer *, CGFloat, CGFloat))didCancelWithForce didEndWithForce:(void (^)(STContinuousForceTouchGestureRecognizer *, CGFloat, CGFloat))didEndWithForce {
    return [[self alloc] initWithDidTimeout:didTimeout didMoveWithForce:didMoveWithForce didCancelWithForce:didCancelWithForce didEndWithForce:didEndWithForce];
}


@end

@implementation STContinuousForceTouchGestureRecognizer

- (instancetype) init {
    self = [super init];
    if(self) {
        [self commonCFTInit];
    }
    return self;
}

- (instancetype) initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if(self) {
        [self commonCFTInit];
    }
    return self;
}

- (void) commonCFTInit {
    self.baseForceTouchPressure = kForceTouchBaseDefaultPressureThreshold;
    self.triggeringForceTouchPressure = kForceTouchDefaultTriggerPressureThreshold;
    self.forceTouchDelay = kForceTouchDefaultDelay;
    self.timeout = kDefaultTouchTimeout;
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    _forceTouchInitialTouchDetect = NO;
    self.state = UIGestureRecognizerStatePossible;
    
//    for(UITouch* aTouch in touches) {
//        NSLog(@"Began Force: %f of %f", aTouch.force, aTouch.maximumPossibleForce);
//    }
    
    UITouch* aTouch = touches.anyObject;
    
    if(aTouch.force > kForceTouchBaseDefaultPressureThreshold) {
        [self forceTouchStartedWithTouch:aTouch];
    }
    
    [self startMovedTimeoutTimer];
}

- (void)reset {
    [super reset];
    
    _forceTouchFired = NO;
    _gestureStartTime = 0;
    _initialForce = 0.0f;
    [self endForceTouchTimer];
    
    // Do NOT reset this state or the timeout logic will not function since reset can be called before the timeout fires
    //[self endMovedTimeoutTimer];
    //_forceTouchInitialTouchDetect = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    [self endMovedTimeoutTimer];
    [self endForceTouchTimer];
    
//    for(UITouch* aTouch in touches) {
//        NSLog(@"Cancelled Force: %f of %f", aTouch.force, aTouch.maximumPossibleForce);
//    }
    
    UITouch* aTouch = touches.anyObject;
    if(_forceTouchDelegate && _forceTouchInitialTouchDetect && [_forceTouchDelegate respondsToSelector:@selector(forceTouchRecognizer:didCancelWithForce:maxForce:)]) {
        [_forceTouchDelegate forceTouchRecognizer:self didCancelWithForce:aTouch.force maxForce:aTouch.maximumPossibleForce];
    }

    !self.forceTouchDelegator.didCancelWithForce ?: self.forceTouchDelegator.didCancelWithForce(self, aTouch.force, aTouch.maximumPossibleForce);
    
    _forceTouchInitialTouchDetect = NO;
    _forceTouchFired = NO;
    
     self.state = UIGestureRecognizerStateFailed;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    [self endMovedTimeoutTimer];
    [self endForceTouchTimer];
    
//    for(UITouch* aTouch in touches) {
//        NSLog(@"End Force: %f of %f", aTouch.force, aTouch.maximumPossibleForce);
//    }
    
    UITouch* aTouch = touches.anyObject;
    if(_forceTouchInitialTouchDetect) {
        self.state = UIGestureRecognizerStateRecognized;
        if(_forceTouchDelegate && [_forceTouchDelegate respondsToSelector:@selector(forceTouchRecognizer:didEndWithForce:maxForce:)]) {
            [_forceTouchDelegate forceTouchRecognizer:self didEndWithForce:aTouch.force maxForce:aTouch.maximumPossibleForce];
        }
        
        !self.forceTouchDelegator.didEndWithForce ?: self.forceTouchDelegator.didEndWithForce(self, aTouch.force, aTouch.maximumPossibleForce);
        
    } else {
        self.state = UIGestureRecognizerStateCancelled;
    }

    _forceTouchInitialTouchDetect = NO;
    _forceTouchFired = NO;
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self endMovedTimeoutTimer];
    
    [super touchesMoved:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateFailed) {
        return;
    }
    
    // Do NOT set this state or other recognizers such as tap or long press won't trigger
    //self.state = UIGestureRecognizerStateChanged;
    
    CGPoint pointInView = [touches.anyObject locationInView:self.view];
//    NSLog(@"view_pt(%f,%f)", pointInView.x, pointInView.y);
    if(![self.view pointInside:pointInView withEvent:event]) {
        self.state = UIGestureRecognizerStateFailed;
        UITouch* aTouch = touches.anyObject;
        if(_forceTouchDelegate && _forceTouchInitialTouchDetect && [_forceTouchDelegate respondsToSelector:@selector(forceTouchRecognizer:didEndWithForce:maxForce:)]) {
            [_forceTouchDelegate forceTouchRecognizer:self didEndWithForce:aTouch.force maxForce:aTouch.maximumPossibleForce];
        }

        !self.forceTouchDelegator.didEndWithForce ?: self.forceTouchDelegator.didEndWithForce(self, aTouch.force, aTouch.maximumPossibleForce);
        
        return;
    }
    
    UITouch* aTouch = touches.anyObject;
    
//    NSLog(@"Moved Force: %f of %f", aTouch.force, aTouch.maximumPossibleForce);
    
    if(_forceTouchInitialTouchDetect) {
        [self forceTouchUpdatedWithTouch:aTouch];
    } else if(aTouch.force > 1.0f) {
        [self forceTouchStartedWithTouch:aTouch];
    }
    
    [self startMovedTimeoutTimer];
}

- (void) forceTouchStartedWithTouch:(UITouch*) touch {
    _forceTouchInitialTouchDetect = YES;
    _initialForce = touch.force;
    
    // Only start the force touch logic if the pressure is above the baseForceTouchPressure pressure
    if(_initialForce > self.baseForceTouchPressure) {
        [self startForceTouchTimer];
    }
}

- (void) startMovedTimeoutTimer {
    [self endMovedTimeoutTimer];
    _lastMovedTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeout target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
}

- (void) endMovedTimeoutTimer {
    if(_lastMovedTimeoutTimer) {
        [_lastMovedTimeoutTimer invalidate];
        _lastMovedTimeoutTimer = nil;
    }
}

- (void) startForceTouchTimer {
    [self endForceTouchTimer];
    _forceTouchTimedTrigger = [NSTimer scheduledTimerWithTimeInterval:self.forceTouchDelay target:self selector:@selector(forceTouchFired:) userInfo:nil repeats:NO];
}

- (void) endForceTouchTimer {
    if(_forceTouchTimedTrigger) {
        [_forceTouchTimedTrigger invalidate];
        _forceTouchTimedTrigger = nil;
    }
}

- (void) forceTouchUpdatedWithTouch:(UITouch*) touch {

    // Its possible that the user started their tap below the baseForceTouchPressure pressure threshold and then
    //      increased their pressure to trigger a force touch.
    // If that happened then start the force touch detection
    if(_initialForce < self.triggeringForceTouchPressure && touch.force >= self.triggeringForceTouchPressure && !_forceTouchFired) {
        [self forceTouchFired:self];
    }
    
    if(_forceTouchDelegate && [_forceTouchDelegate respondsToSelector:@selector(forceTouchRecognizer:didMoveWithForce:maxForce:)]) {
        [_forceTouchDelegate forceTouchRecognizer:self didMoveWithForce:touch.force maxForce:touch.maximumPossibleForce];
    }

    !self.forceTouchDelegator.didMoveWithForce ?: self.forceTouchDelegator.didMoveWithForce(self, touch.force, touch.maximumPossibleForce);
}

- (void) timeout:(id)sender {
    self.state = UIGestureRecognizerStateFailed;
    if(_forceTouchDelegate && _forceTouchInitialTouchDetect && [_forceTouchDelegate respondsToSelector:@selector(forceTouchDidTimeout:)]) {
        [_forceTouchDelegate forceTouchDidTimeout:self];
    }

    !self.forceTouchDelegator.didTimeout ?: self.forceTouchDelegator.didTimeout(self);
}

- (void) forceTouchFired:(id)sender {
    _forceTouchFired = YES;
    
    [self endMovedTimeoutTimer];
    [self endForceTouchTimer];
    
    // Do NOT set this state to UIGestureRecognizerStateRecognized or the recognizer will reset and
    //      force pressure updates will cease.
    // Instead use a delegate callback to signify that the desired force touch gesture was performed
    //      and keep the events streaming with pressure updates
    //self.state = UIGestureRecognizerStateRecognized;
    
    if(_forceTouchDelegate) {
        [_forceTouchDelegate forceTouchRecognized:self];
    }
}

@end
