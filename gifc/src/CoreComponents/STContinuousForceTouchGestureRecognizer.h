//
//  STContinuousForceTouchGestureRecognizer.h
//
//  Created by Daniel Fogg on 9/29/15. (https://github.com/foggzilla/DFContinuousForceTouchGestureRecognizer)
//  Copyright © 2015 Daniel Fogg. All rights reserved.
//
//  Modified and renamed by metasmile 8/1/16 (https://github.com/stellarstep/STCodeBundle)

#import <UIKit/UIKit.h>
#import "UITouchLongPressGestureRecognizer.h"

@class STContinuousForceTouchGestureRecognizer;

@protocol STContinuousForceTouchDelegate <NSObject>

// Force touch was recognized according to the thresholds set by baseForceTouchPressure, triggeringForceTouchPressure, and forceTouchDelay
- (void) forceTouchRecognized:(STContinuousForceTouchGestureRecognizer *)recognizer;

@optional

// Force touch movement happening. This is only called if forceTouchDidStartWithForce had been called previously
- (void)forceTouchRecognizer:(STContinuousForceTouchGestureRecognizer *)recognizer didMoveWithForce:(CGFloat)force maxForce:(CGFloat)maxForce;

// Force touch was cancelled. This is only called if forceTouchDidStartWithForce had been called previously
- (void)forceTouchRecognizer:(STContinuousForceTouchGestureRecognizer *)recognizer didCancelWithForce:(CGFloat)force maxForce:(CGFloat)maxForce;

// Force touch ended. This is only called if forceTouchDidStartWithForce had been called previously
- (void)forceTouchRecognizer:(STContinuousForceTouchGestureRecognizer *)recognizer didEndWithForce:(CGFloat)force maxForce:(CGFloat)maxForce;

// Force touch timed out. See notes about the timeout property below. This is only called if forceTouchDidStartWithForce had been called previously
- (void) forceTouchDidTimeout:(STContinuousForceTouchGestureRecognizer *)recognizer;

@end

@interface STContinuousForceTouchGestureRecognizerDelegator : NSObject
@property (copy) void (^didTimeout)(STContinuousForceTouchGestureRecognizer * recognizer);
@property (copy) void (^didMoveWithForce)(STContinuousForceTouchGestureRecognizer * recognizer, CGFloat force, CGFloat maxForce);
@property (copy) void (^didCancelWithForce)(STContinuousForceTouchGestureRecognizer * recognizer, CGFloat force, CGFloat maxForce);
@property (copy) void (^didEndWithForce)(STContinuousForceTouchGestureRecognizer * recognizer, CGFloat force, CGFloat maxForce);

- (instancetype)initWithDidTimeout:(void (^)(STContinuousForceTouchGestureRecognizer *))didTimeout didMoveWithForce:(void (^)(STContinuousForceTouchGestureRecognizer *, CGFloat, CGFloat))didMoveWithForce didCancelWithForce:(void (^)(STContinuousForceTouchGestureRecognizer *, CGFloat, CGFloat))didCancelWithForce didEndWithForce:(void (^)(STContinuousForceTouchGestureRecognizer *, CGFloat, CGFloat))didEndWithForce;

+ (instancetype)delegatorWithDidTimeout:(void (^)(STContinuousForceTouchGestureRecognizer *))didTimeout didMoveWithForce:(void (^)(STContinuousForceTouchGestureRecognizer *, CGFloat, CGFloat))didMoveWithForce didCancelWithForce:(void (^)(STContinuousForceTouchGestureRecognizer *, CGFloat, CGFloat))didCancelWithForce didEndWithForce:(void (^)(STContinuousForceTouchGestureRecognizer *, CGFloat, CGFloat))didEndWithForce;

@end

@interface STContinuousForceTouchGestureRecognizer : UITouchLongPressGestureRecognizer

// The lowest pressuare at which a force touch will begin to be detected,
//      anything lower is a normal press and will not trigger force touch logic
// Defaults to 1.0f on a scale from 0.0f to 6.667f;
@property(nonatomic, assign) CGFloat baseForceTouchPressure;

// The pressure at which a force touch will be triggered
// Defaults to 2.5f on a scale from 0.0f to 6.667f;
@property(nonatomic, assign) CGFloat triggeringForceTouchPressure;

// The delay in seconds after which, if the baseForceTouchPressure or greater is
//      still being applied will recognize the force touch
// Defaults to 0.5f (half a second)
@property(nonatomic, assign) CGFloat forceTouchDelay;

// The timeout in seconds after which will fail the gesture recognizer. It fires only if a touch event
//      is not received again after forceTouchDidStartWithForce or forceTouchDidMoveWithForce is called.
//
// When this occurs forceTouchDidTimeout is called and the state is set to UIGestureRecognizerStateFailed.
// Defaults to 1.5f;
//
// This comes in handy when you have a view inside a scroll view and the if the user drags to scroll the
//      view this gesture recognizer will not get its touchesCancelled or touchesEnded methods called
@property(nonatomic, assign) CGFloat timeout;

// Set this delegate to get continuous feedback on pressure changes
@property(nonatomic, weak) id<STContinuousForceTouchDelegate> forceTouchDelegate;

@property(nonatomic, weak) STContinuousForceTouchGestureRecognizerDelegator * forceTouchDelegator;


@end
