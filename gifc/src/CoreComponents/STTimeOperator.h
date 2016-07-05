//
// Created by BLACKGENE on 2015. 1. 14..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface STTimeOperator : NSObject

+ (NSString *)st_performOnceAfterDelay:(NSTimeInterval)interval block:(void (^)(void))block;

+ (NSString *)st_performOnceAfterDelay:(NSString *)id interval:(NSTimeInterval)interval block:(void (^)(void))block;

+ (BOOL)st_fire:(NSString *)id1;

+ (BOOL)st_isPerforming:(NSString *)id1;

+ (BOOL)st_cancelPerformOnceAfterDelay:(NSString *)id1;

+ (void)st_clearPerformOnceAfterDelay:(NSString *)id1;

+ (void)st_clearAllPerformOnceAfterDelay;

+ (STTimeOperator *)instance;

- (void)cancelAll;

- (void)flushAll;

- (void)addOperation:(void (^)(void))block;

- (void)addOperation:(NSTimeInterval)flushAfterDelay block:(void (^)(void))block;
@end