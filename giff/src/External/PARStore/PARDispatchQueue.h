//  PARStore
//  Author: Charles Parnot
//  Licensed under the terms of the BSD License, as specified in the file 'LICENSE-BSD.txt' included with this distribution

#import <Foundation/Foundation.h>

typedef void (^PARDispatchBlock)(void);

// Timer Behaviors
// PARTimerBehaviorCoalesce: subsequent calls can only reduce the time until firing, not extend
// PARTimerBehaviorDelay:    subsequent calls replace the existing time, potentially extending it
typedef NS_ENUM(NSInteger, PARTimerBehavior)
{
    PARTimerBehaviorCoalesce,
    PARTimerBehaviorDelay
};


// Synchronous Dispatch Behaviors = what to do when dispatching synchronously a block and we are already within the queue
// PARDeadlockBehaviorExecute: do not add the block to the queue, execute inline (default)
// PARDeadlockBehaviorSkip:    do not add the block to the queue, drop it silently
// PARDeadlockBehaviorLog:     do not add the block to the queue, log to console
// PARDeadlockBehaviorAssert:  do not add the block to the queue, raise an exception
// PARDeadlockBehaviorBlock:   add the block to the queue, and be damned
typedef NS_ENUM(NSInteger, PARDeadlockBehavior)
{
    PARDeadlockBehaviorExecute,
    PARDeadlockBehaviorSkip,
    PARDeadlockBehaviorLog,
    PARDeadlockBehaviorAssert,
    PARDeadlockBehaviorBlock
};


@interface PARDispatchQueue : NSObject

/// @name Creating Queues
+ (PARDispatchQueue *)globalDispatchQueue;
+ (PARDispatchQueue *)mainDispatchQueue;
+ (PARDispatchQueue *)dispatchQueueWithLabel:(NSString *)label;
+ (PARDispatchQueue *)dispatchQueueWithLabel:(NSString *)label behavior:(PARDeadlockBehavior)behavior;

/// @name Properties
@property (readonly, copy) NSString *label;
@property (readonly) PARDeadlockBehavior deadlockBehavior;

/// @name Utilities
+ (NSString *)labelByPrependingBundleIdentifierToString:(NSString *)suffix;

/// @name Dispatching Blocks
- (void)dispatchSynchronously:(PARDispatchBlock)block;
- (void)dispatchAsynchronously:(PARDispatchBlock)block;
- (BOOL)isCurrentQueue;
- (BOOL)isInCurrentQueueStack;

/// @name Adding and Updating Timers
- (void)scheduleTimerWithName:(NSString *)name timeInterval:(NSTimeInterval)delay behavior:(PARTimerBehavior)behavior block:(PARDispatchBlock)block;
- (void)cancelTimerWithName:(NSString *)name;
- (void)cancelAllTimers;
- (NSUInteger)timerCount; // the returned value cannot be fully trusted, of course

@end


@interface PARBlockOperation : NSObject
+ (PARBlockOperation *)dispatchedOperationWithQueue:(PARDispatchQueue *)queue block:(PARDispatchBlock)block;
- (void)waitUntilFinished;
@end
