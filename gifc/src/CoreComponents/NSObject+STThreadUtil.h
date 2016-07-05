//
// Created by BLACKGENE on 2014. 10. 22..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (STThreadUtil)

- (void)st_runAsBackground:(dispatch_block_t)block;

- (void)st_runAsBackgroundWithSelf:(void (^)(id selfObject))block;

- (void)st_runAsHigh:(dispatch_block_t)block;

- (void)st_runAsHighWithSelf:(void (^)(id selfObject))block;

- (void)st_runAsDefault:(dispatch_block_t)block;

- (void)st_runAsDefaultWithSelf:(void (^)(id selfObject))block;

- (void)st_runAsMainQueueAsync:(dispatch_block_t)block;

- (void)st_runAsMainQueue:(dispatch_block_t)block;

- (void)st_runAsMainQueueWithoutDeadlocking:(dispatch_block_t)block;

- (void)st_runAsMainQueueAsyncWithSelf:(void (^)(id selfObject))block;

- (void)st_runAsMainQueueAsyncWithoutDeadlocking:(dispatch_block_t)block;

- (void)st_runAsMainQueueAsyncWithoutDeadlockingWithSelf:(void (^)(id selfObject))block;
@end