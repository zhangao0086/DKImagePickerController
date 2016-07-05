//
// Created by BLACKGENE on 2014. 9. 25..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSObject (STUtil)

@property (nonatomic, readonly) NSString * st_uid;

+ (instancetype)st_cast:(id)from;

+ (NSArray *)st_propertyNames;

+ (SEL)propertySetterSelectorForKeyPath:(NSString *)keypath3;

+ (BOOL)isPropertySetterOverridden:(NSString *)keypath3;

- (void)st_observeFrom:(id)object keypath:(NSString *)keyPath block:(void (^)(id value, __weak id _weakSelf))block;

- (void)st_observeWithInitialFrom:(id)object keypath:(NSString *)keyPath block:(void (^)(id value, __weak id _weakSelf))block;

- (void)st_observe:(NSString *)keyPath block:(void (^)(id value, __weak id _weakSelf))block;

- (void)st_observeWithInitial:(NSString *)keyPath block:(void (^)(id value, __weak id _weakSelf))block;

- (NSString *)whenValueOf:(NSString *)keyPath changed:(void (^)(id value, __weak id _weakSelf))block;

- (void)whenValueOf:(NSString *)keyPath id:(NSString *)identifier changed:(void (^)(id value, __weak id _weakSelf))block;

- (void)whenValueOf:(NSString *)keyPath id:(NSString *)identifier changed:(void (^)(id value, __weak id _weakSelf))block getInitialValue:(BOOL)fetch;

- (void)whenNewValueOnceOf:(NSString *)keyPath changed:(void (^)(id value, __weak id _weakSelf))block;

- (void)whenNewValueOnceOf:(NSString *)keyPath id:(NSString *)identifier changed:(void (^)(id value, __weak id _weakSelf))block;

- (void)whenNewValueOnceOf:(NSString *)keyPath id:(NSString *)identifier timeout:(NSTimeInterval)timeout promise:(NSTimeInterval)promise changed:(void (^)(id value, __weak id _weakSelf))block;

- (void)st_addKeypathListener:(NSString *)keyPath id:(NSString *)identifier newValueBlock:(void (^)(id value, __weak id _weakSelf))block;

- (void)st_fireValueToListenersTask:(NSString *)keyPath id:(NSString *)identifier value:(id)value;

- (id)st_listenerObject:(NSString *)keyPath id:(NSString *)identifier;

- (void)st_removeKeypathListener:(NSString *)keyPath id:(NSString *)identifier;

- (void)st_removeAllKeypathListenersWidthId:(NSString *)identifier;

- (void)st_removeAllKeypathListeners;

- (id)st_cachedObject:(NSString *)key;

- (id)st_cachedObject:(NSString *)key init:(id(^)(void))block;

- (id)st_cachedObject:(NSString *)key domain:(NSString *)domain init:(id(^)(void))block;

- (BOOL)st_clearCachedObject:(NSString *)key;

- (void)st_clearAllCachedObjectInDomain:(NSString *)domain;

- (void)st_cachedObjectKeys:(NSString *)domain keys:(void (^)(NSSet *))block;

- (UIImage *)st_cachedImage:(NSString *)key;

- (UIImage *)st_cachedImage:(NSString *)key init:(UIImage *(^)(void))block;

- (UIImage *)st_cachedImage:(NSString *)key useDisk:(BOOL)useDisk init:(UIImage *(^)(void))block;

- (UIImage *)st_cachedImage:(NSString *)key useDisk:(BOOL)useDisk storeWhenLoad:(BOOL)store init:(UIImage *(^)(void))block;

- (void)st_cacheImage:(UIImage *)image key:(NSString *)key useDisk:(BOOL)useDisk;

- (UIImage *)st_cachedImage:(NSString *)key useDisk:(BOOL)useDisk;

- (BOOL)st_uncacheImage:(NSString *)key fromDisk:(BOOL)fromDisk;

- (BOOL)st_uncacheImage:(NSString *)key;

- (void)st_performAfterDelay:(NSTimeInterval)interval block:(void (^)(void))block;

- (void)st_performOnceAfterDelay:(NSTimeInterval)interval block:(void (^)(void))block;

- (void)st_performOnceAfterDelay:(NSString *)id1 interval:(NSTimeInterval)interval block:(void (^)(void))block;

- (void)st_clearPerformOnceAfterDelay;

- (void)st_clearPerformOnceAfterDelay:(NSString *)id1;

- (void)st_runAsTimerQueue:(void (^)(void))block;

- (UIViewController *)st_rootUVC;

- (CGRect)st_rootFrame;

- (NSUInteger)indexWithDegree:(CGFloat)degree totalDegree:(CGFloat)totalDegree totalCount:(NSUInteger)count;

- (NSUInteger)indexWithDegree:(CGFloat)degree totalCount:(NSUInteger)count;

- (CGFloat)degreeWithCenter:(CGPoint)center location:(CGPoint)location;

- (NSArray *)st_propertyNames;
@end