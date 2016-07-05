//
// Created by BLACKGENE on 2015. 1. 14..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <BlocksKit/NSTimer+BlocksKit.h>
#import "STTimeOperator.h"
#import "NSObject+STUtil.h"


@implementation STTimeOperator {
    NSOperationQueue *_queue;
    NSMutableArray *operations;
    NSTimer *_timer;
}

static NSMutableDictionary *dic;

+ (NSString *)st_performOnceAfterDelay:(NSTimeInterval)interval block:(void (^)(void))block; {
    return [self st_performOnceAfterDelay:[self.class st_uid] interval:interval block:block];
}

+ (NSString *)st_performOnceAfterDelay:(NSString *)id interval:(NSTimeInterval)interval block:(void (^)(void))block; {
    @synchronized (self) {
        BlockOnce(^{
            dic = [NSMutableDictionary dictionary];
        });
        id?:(id=[[NSUUID UUID] UUIDString]);

        [self st_cancelPerformOnceAfterDelay:id];

        dic[id] = [NSTimer bk_scheduledTimerWithTimeInterval:interval block:^(NSTimer *timer) {
            block();
            [dic removeObjectForKey:id];
        } repeats:NO];

        return id;
    }
}

+ (BOOL)st_fire:(NSString *)id{
    @synchronized (self) {
        if(dic){
            NSTimer *t = dic[id];
            if(t && t.valid){
                [t fire];
                return YES;
            }
        }
        return NO;
    }
}

+ (BOOL)st_isPerforming:(NSString *)id{
    @synchronized (self) {
        return [dic hasKey:id];
    }
}

+ (BOOL)st_cancelPerformOnceAfterDelay:(NSString *)id {
    @synchronized (self) {
        if(dic){
            NSTimer *t = dic[id];
            if(t && t.valid){
                [t invalidate];
                return YES;
            }
        }
        return NO;
    }
}

+ (void)st_clearPerformOnceAfterDelay:(NSString *)id {
    @synchronized (self) {
        if([self st_cancelPerformOnceAfterDelay:id]){
            [dic removeObjectForKey:id];
        }
    }
}

+ (void)st_clearAllPerformOnceAfterDelay {
    @synchronized (self) {
        for(NSString * id in [dic allKeys]){
            [self st_clearPerformOnceAfterDelay:id];
        }
        [dic removeAllObjects];
    }
}

+ (STTimeOperator *)instance {
    static STTimeOperator *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}

- (void)cancelAll {
    [_queue cancelAllOperations];
    [operations removeAllObjects];
}

- (void)flushAll {
    for(NSOperation * op in operations){
          [_queue addOperation:op];
    }
    [operations removeAllObjects];
}

- (void)addOperation:(void (^)(void))block{
    _queue = [NSOperationQueue currentQueue];
    if(!operations){
        operations = [NSMutableArray array];
    }

    NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:block];
    if(operations.count>0){
        [operation addDependency:[operations last]];
    }
    [operations addObject:operation];
}

- (void)addOperation:(NSTimeInterval)flushAfterDelay block:(void (^)(void))block{
    [self addOperation:block];

    Weaks
    [_timer invalidate];
    _timer = [NSTimer bk_scheduledTimerWithTimeInterval:flushAfterDelay block:^(NSTimer *timer) {
        [Wself flushAll];
    } repeats:NO];
}

@end