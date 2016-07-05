//
// Created by BLACKGENE on 2014. 10. 22..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import "NSObject+STThreadUtil.h"


@implementation NSObject (STThreadUtil)

- (void)st_runAsBackground:(dispatch_block_t)block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
}

- (void)st_runAsBackgroundWithSelf:(void(^)(id selfObject))block{
    typeof(self) __weak weakSelf = self;
    [self st_runAsBackground:^{
        block(weakSelf);
    }];
}

- (void)st_runAsHigh:(dispatch_block_t)block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), block);
}

- (void)st_runAsHighWithSelf:(void(^)(id selfObject))block{
    typeof(self) __weak weakSelf = self;
    [self st_runAsHigh:^{
        typeof(weakSelf) _self = weakSelf;
        block(_self);
    }];
}

- (void)st_runAsDefault:(dispatch_block_t)block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

- (void)st_runAsDefaultWithSelf:(void(^)(id selfObject))block{
    typeof(self) __weak weakSelf = self;
    [self st_runAsDefault:^{
        block(weakSelf);
    }];
}

- (void)st_runAsMainQueueAsync:(dispatch_block_t)block{
    dispatch_async(dispatch_get_main_queue(), block);
}

- (void)st_runAsMainQueue:(dispatch_block_t)block{
    dispatch_sync(dispatch_get_main_queue(), block);
}

- (void)st_runAsMainQueueWithoutDeadlocking:(dispatch_block_t)block{
    if ([NSThread isMainThread]){
        block();
    }
    else{
        [self st_runAsMainQueue:block];
    }
}

- (void)st_runAsMainQueueAsyncWithSelf:(void(^)(id selfObject))block{
    typeof(self) __weak weakSelf = self;
    [self st_runAsMainQueueAsync:^{
        block(weakSelf);
    }];
}

- (void)st_runAsMainQueueAsyncWithoutDeadlocking:(dispatch_block_t)block{
    if ([NSThread isMainThread]){
        block();
    }
    else{
        [self st_runAsMainQueueAsync:block];
    }
}

- (void)st_runAsMainQueueAsyncWithoutDeadlockingWithSelf:(void(^)(id selfObject))block{
    if ([NSThread isMainThread]){
        Weaks
        block(Wself);
    }
    else{
        [self st_runAsMainQueueAsyncWithSelf:block];
    }
}

@end