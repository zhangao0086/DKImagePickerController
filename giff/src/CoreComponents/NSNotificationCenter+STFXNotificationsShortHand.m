//
// Created by BLACKGENE on 2014. 9. 25..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "FXNotifications.h"
#import "NSObject+STUtil.h"
#import "NSString+STUtil.h"


@implementation NSNotificationCenter (STFXNotificationsShortHand)

- (void)st_addObserverWithMainQueue:(id)observer forName:(NSString *)name usingBlock:(void (^)(NSNotification *note, id observer))block {
    NSParameterAssert(observer);
    NSParameterAssert(name);
    NSParameterAssert(block);

    [[NSNotificationCenter defaultCenter] addObserver:observer forName:name object:nil queue:[NSOperationQueue mainQueue] usingBlock:block];
}

- (void)st_addObserverWithMainQueueOnlyOnce:(id)observer forName:(NSString *)name usingBlock:(void (^)(NSNotification *note, id observer))block {
    [self st_addObserverWithMainQueueOnlyOnce:observer forName:name timout:0 usingBlock:block];
}

- (void)st_addObserverWithMainQueueOnlyOnce:(id)observer forName:(NSString *)name timout:(NSTimeInterval)timeout usingBlock:(void (^)(NSNotification *note, id observer))block {
    Weaks
    WeakObject(observer) weakobserver = observer;

    //timeout
    NSString * timeoutId = [@"NSNotificationCenter_timeout_" st_add:name];
    if(timeout>0){
        [self st_performOnceAfterDelay:timeoutId interval:timeout block:^{
            [Wself st_removeObserverWithMainQueue:weakobserver forName:name];
        }];
    }

    //add observer
    [self st_addObserverWithMainQueue:observer forName:name usingBlock:^(NSNotification *_note, id _observer) {
        [Wself st_clearPerformOnceAfterDelay:timeoutId];
        [Wself st_removeObserverWithMainQueue:_observer forName:name];
        block(_note, _observer);
    }];
}

- (void)st_removeObserverWithMainQueue:(id)observer forName:(NSString *)name {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:name object:nil];
}

- (void)st_postNotificationName:(NSString *)aName {
    [self postNotificationName:aName object:nil];
}

+ (NSNotificationCenter *) get{
    return [NSNotificationCenter defaultCenter];
}
@end