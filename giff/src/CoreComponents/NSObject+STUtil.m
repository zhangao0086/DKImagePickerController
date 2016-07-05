//
// Created by BLACKGENE on 2014. 9. 25..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import "NSObject+STUtil.h"
#import "NSObject+STThreadUtil.h"
#import "STTimeOperator.h"
#import "NSObject+BKBlockObservation.h"
#import "NSObject+BKAssociatedObjects.h"
#import "NSString+STUtil.h"
#import "PINMemoryCache.h"
#import "M13OrderedDictionary.h"
#import <SDWebImage/SDImageCache.h>

@implementation NSObject (STUtil)

@dynamic st_uid;

BEGIN_DEALLOC_CATEGORY
    [self bk_removeAllAssociatedObjects];
    
END_DEALLOC_CATEGORY

+ (instancetype)st_cast:(id)from {
    if ([from isKindOfClass:self]) {
        return from;
    }
    return nil;
}

- (NSArray *)st_propertyNames {
    return [[self class] st_propertyNames];
}

+ (NSArray *)st_propertyNames {
    unsigned int propertyCount = 0;
    objc_property_t * properties = class_copyPropertyList([self class], &propertyCount);

    NSMutableArray * propertyNames = [NSMutableArray array];
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        [propertyNames addObject:[NSString stringWithUTF8String:name]];
    }
    free(properties);

    return [NSArray arrayWithArray:propertyNames];
}

- (void)st_observeFrom:(id)object keypath:(NSString *)keyPath block:(void(^)(id value, __weak id _weakSelf))block{
    [self observeObject:object property:keyPath withBlock:^(__weak id _self, __weak id _object, id old, id new) {
        if(!old) return;
        !block?:block(new, _self);
    }];
}

- (void)st_observeWithInitialFrom:(id)object keypath:(NSString *)keyPath block:(void(^)(id value, __weak id _weakSelf))block{
    [self observeObject:object property:keyPath withBlock:^(__weak id _self, __weak id _object, id old, id new) {
        !block?:block(new, _self);
    }];
}

- (void)st_observe:(NSString *)keyPath block:(void(^)(id value, __weak id _weakSelf))block{
    [self observeProperty:keyPath withBlock:^(__weak id _self, id old, id new) {
        if(!old) return;
        !block?:block(new, _self);
    }];
}

- (void)st_observeWithInitial:(NSString *)keyPath block:(void(^)(id value, __weak id _weakSelf))block{
    [self observeProperty:keyPath withBlock:^(__weak id _self, id old, id new) {
        !block?:block(new, _self);
    }];
}

- (NSString *)whenValueOf:(NSString *)keyPath changed:(void(^)(id value, __weak id _weakSelf))block{
    NSString * id = [[self st_uid] st_add:keyPath];
    [self whenValueOf:keyPath id:id changed:block];
    return id;
}

- (void)whenValueOf:(NSString *)keyPath id:(NSString *)identifier changed:(void(^)(id value, __weak id _weakSelf))block{
    [self whenValueOf:keyPath id:identifier changed:block getInitialValue:NO];
}

- (void)whenValueOf:(NSString *)keyPath id:(NSString *)identifier changed:(void (^)(id value, __weak id _weakSelf))block getInitialValue:(BOOL)fetch{
    if(block){
        [self st_addKeypathListener:keyPath id:identifier newValueBlock:block];
        if(fetch){
            [self st_fireValueToListenersTask:keyPath id:identifier value:[self valueForKeyPath:keyPath]];
        }
    }else{
        [self st_removeKeypathListener:keyPath id:identifier];
    }
}

- (void)whenNewValueOnceOf:(NSString *)keyPath changed:(void(^)(id value, __weak id _weakSelf))block{
    [self whenNewValueOnceOf:keyPath id:[[self st_uid] st_add:keyPath] changed:block];
}

- (void)whenNewValueOnceOf:(NSString *)keyPath id:(NSString *)identifier changed:(void(^)(id value, __weak id _weakSelf))block{
    [self whenNewValueOnceOf:keyPath id:identifier timeout:0 promise:0 changed:block];
}

- (void)whenNewValueOnceOf:(NSString *)keyPath
                        id:(NSString *)identifier
                   timeout:(NSTimeInterval)timeout
                   promise:(NSTimeInterval)promise
                   changed:(void(^)(id value, __weak id _weakSelf))block{

    NSAssert(!(timeout>0 && promise>0) || (timeout==0 && promise==0), @"timeout, promise interval must be Zero for both, or only one.");

    NSString * timeoutId = [@"KeypathObserver_timeout_" stringByAppendingFormat:@"%@_%@",keyPath, identifier];
    NSString * promiseId = [@"KeypathObserver_promise_" stringByAppendingFormat:@"%@_%@",keyPath, identifier];

    Weaks
    void(^clear)(void) = ^{
        [Wself st_clearPerformOnceAfterDelay:timeoutId];
        [Wself st_clearPerformOnceAfterDelay:promiseId];
        [Wself st_removeKeypathListener:keyPath id:identifier];
    };

    //timeout
    if(timeout>0){
        [self st_performOnceAfterDelay:timeoutId interval:timeout block:^{
            clear();
        }];
    }else{
        [self st_clearPerformOnceAfterDelay:timeoutId];
    }

    //promise
    if(promise>0){
        [self st_performOnceAfterDelay:promiseId interval:promise block:^{
            clear();
            block([Wself valueForKeyPath:keyPath], Wself);
        }];
    }else{
        [self st_clearPerformOnceAfterDelay:promiseId];
    }

    if(block){
        if([self st_listenerObject:keyPath id:identifier]){
            [self st_removeKeypathListener:keyPath id:identifier];
        }
        [self st_addKeypathListener:keyPath id:identifier newValueBlock:^(id value, id _weakSelf) {
            clear();
            block(value, _weakSelf);
        }];
    }else{
        clear();
    }
}

- (void)st_addKeypathListener:(NSString *)keyPath id:(NSString *)identifier newValueBlock:(void(^)(id value, __weak id _weakSelf))block{
    [self bk_addObserverForKeyPath:keyPath identifier:identifier options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
        block(change[NSKeyValueChangeNewKey], obj);
    }];
}

- (void)st_fireValueToListenersTask:(NSString *)keyPath id:(NSString *)identifier value:(id)value{
    @synchronized (self) {
        id _BKObserverObject = [self st_listenerObject:keyPath id:identifier];
        if([_BKObserverObject respondsToSelector:@selector(task)]){
            Weaks
            void (^task)(id, NSDictionary *) = [_BKObserverObject performSelector:@selector(task)];
            if(task){
                task(Wself, @{NSKeyValueChangeNewKey : value ? value : [NSNull null]});
            }
        }
    }
}

- (id)st_listenerObject:(NSString *)keyPath id:(NSString *)identifier{
    @synchronized (self) {
        if([self respondsToSelector:@selector(bk_observerBlocks)]){
            NSDictionary * observers = [[self performSelector:@selector(bk_observerBlocks)] copy];
            if([observers hasKey:identifier]){
                id _BKObserverObject = observers[identifier];

                if(keyPath && [_BKObserverObject respondsToSelector:@selector(keyPaths)]){
                    NSArray * keypaths = (NSArray *)[[_BKObserverObject performSelector:@selector(keyPaths)] copy];
                    return [keypaths includes:keyPath] ? _BKObserverObject : nil;

                }else{
                    return _BKObserverObject;
                }
            }
        }
        return nil;
    }
}

- (void)st_removeKeypathListener:(NSString *)keyPath id:(NSString *)identifier{
    [self bk_removeObserverForKeyPath:keyPath identifier:identifier];
}

- (void)st_removeAllKeypathListenersWidthId:(NSString *)identifier{
    [self bk_removeObserversWithIdentifier:identifier];
}

- (void)st_removeAllKeypathListeners{
    [self bk_removeAllBlockObservers];
}

#pragma mark cache Object
- (id)st_cachedObject:(NSString *)key{
    return [self st_cachedObject:key init:nil];
}

- (id)st_cachedObject:(NSString *)key init:(id(^)(void))block{
    return [self st_cachedObject:key domain:nil init:block];
}

- (id)st_cachedObject:(NSString *)key domain:(NSString *)domain init:(id(^)(void))block{
    NSParameterAssert(key);
    if(domain){
        key = [domain st_add:key];
    }
    id obj = [[PINMemoryCache sharedCache] objectForKey:key];
    if(!obj && block){
        obj = block();
        [[PINMemoryCache sharedCache] setObject:obj forKey:key];
    }
    return obj;
}

- (BOOL)st_clearCachedObject:(NSString *)key{
    return [self st_clearCachedObject:key domain:nil];
}

- (BOOL)st_clearCachedObject:(NSString *)key domain:(NSString *)domain{
    NSParameterAssert(key);
    if(domain){
        key = [domain st_add:key];
    }
    if([[PINMemoryCache sharedCache] objectForKey:key]){
        [[PINMemoryCache sharedCache] removeObjectForKey:key];
        return YES;
    }
    return NO;
}

- (void)st_clearAllCachedObjectInDomain:(NSString *)domain {
    NSParameterAssert(domain);
    [self st_cachedObjectKeys:domain keys:^(NSSet *set) {
        for (id obj in set) {
            [[PINMemoryCache sharedCache] removeObjectForKey:obj];
        }
    }];
}

- (void)st_cachedObjectKeys:(NSString *)domain keys:(void(^)(NSSet *))block{
    NSParameterAssert(domain);
    NSParameterAssert(block);

    __block NSMutableSet * set = [NSMutableSet set];
    Weaks
    [[PINMemoryCache sharedCache] enumerateObjectsWithBlock:^(PINMemoryCache *cache, NSString *key, id object) {
        if([key containsString:domain]) {
            [set addObject:key];
        }
    } completionBlock:^(PINMemoryCache *cache) {
        [Wself st_runAsMainQueueAsyncWithSelf:^(id selfObject) {
            block([set copy]);
            set = nil;
        }];
    }];
}

#pragma mark cache Image
static BOOL _SDImageCacheShouldCacheImagesInMemory;
static BOOL _isBeganSDImageCacheDiskCacheOnlyContext;
- (void)_beginSDImageCacheDiskCacheOnlyContext{
    _SDImageCacheShouldCacheImagesInMemory = [SDImageCache sharedImageCache].shouldCacheImagesInMemory;
    [SDImageCache sharedImageCache].shouldCacheImagesInMemory = NO;
    _isBeganSDImageCacheDiskCacheOnlyContext = YES;
}

- (void)_endSDImageCacheDiskCacheOnlyContext{
    if(_isBeganSDImageCacheDiskCacheOnlyContext){
        [SDImageCache sharedImageCache].shouldCacheImagesInMemory = _SDImageCacheShouldCacheImagesInMemory;
        _isBeganSDImageCacheDiskCacheOnlyContext = NO;
    }
}

- (UIImage *)st_cachedImage:(NSString *)key{
    return [self st_cachedImage:key init:nil];
}

- (UIImage *)st_cachedImage:(NSString *)key init:(UIImage *(^)(void))block{
    return [self st_cachedImage:key useDisk:NO init:block];
}

- (UIImage *)st_cachedImage:(NSString *)key useDisk:(BOOL)useDisk init:(UIImage *(^)(void))block{
    return [self st_cachedImage:key useDisk:useDisk storeWhenLoad:YES init:block];
}

- (UIImage *)st_cachedImage:(NSString *)key useDisk:(BOOL)useDisk storeWhenLoad:(BOOL)store init:(UIImage *(^)(void))block{
    NSParameterAssert(key);
    @autoreleasepool {
        UIImage * img = [self st_cachedImage:key useDisk:useDisk];

        //create
        if(!img && block){
            img = block();

            if(store){
                [self st_cacheImage:img key:key useDisk:useDisk];
            }
        }
        return img;
    }
}

- (void)st_cacheImage:(UIImage *)image key:(NSString *)key useDisk:(BOOL)useDisk;{
    !useDisk?:[self _beginSDImageCacheDiskCacheOnlyContext];
    [[SDImageCache sharedImageCache] storeImage:image forKey:key toDisk:useDisk];
    [self _endSDImageCacheDiskCacheOnlyContext];
}

- (UIImage *)st_cachedImage:(NSString *)key useDisk:(BOOL)useDisk;{
    if(useDisk){
        [self _beginSDImageCacheDiskCacheOnlyContext];
        UIImage * cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
        [self _endSDImageCacheDiskCacheOnlyContext];
        return cachedImage;
    }

    return [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
}

- (BOOL)st_uncacheImage:(NSString *)key fromDisk:(BOOL)fromDisk;{
    if([[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key]){
        BOOL shouldCacheImagesInMemory = [SDImageCache sharedImageCache].shouldCacheImagesInMemory;
        [SDImageCache sharedImageCache].shouldCacheImagesInMemory = YES;
        [[SDImageCache sharedImageCache] removeImageForKey:key fromDisk:fromDisk];
        [SDImageCache sharedImageCache].shouldCacheImagesInMemory = shouldCacheImagesInMemory;
        return YES;
    }
    return NO;
}

- (BOOL)st_uncacheImage:(NSString *)key{
    return [self st_uncacheImage:key fromDisk:NO];
}

#pragma mark Timer
- (void)st_performAfterDelay:(NSTimeInterval)interval block:(void (^)(void))block; {
    [self st_performOnceAfterDelay:nil interval:interval block:block];
}

- (void)st_performOnceAfterDelay:(NSTimeInterval)interval block:(void (^)(void))block; {
    [self st_performOnceAfterDelay:self.st_uid interval:interval block:block];
}

- (void)st_performOnceAfterDelay:(NSString *)id1 interval:(NSTimeInterval)interval block:(void (^)(void))block{
    [STTimeOperator st_performOnceAfterDelay:id1 interval:interval block:block];
}

- (void)st_clearPerformOnceAfterDelay{
    [STTimeOperator st_clearPerformOnceAfterDelay:self.st_uid];
}

- (void)st_clearPerformOnceAfterDelay:(NSString *)id{
    [STTimeOperator st_clearPerformOnceAfterDelay:id];
}

- (void)st_runAsTimerQueue:(void (^)(void))block; {
    [self st_performOnceAfterDelay:nil interval:0 block:block];
}

#pragma mark Sys Util

DEFINE_ASSOCIATOIN_KEY(kObjectUid)
- (NSString *)st_uid {
    @synchronized (self) {
        id __uid = [self bk_associatedValueForKey:kObjectUid];
        if(!__uid){
            NSString * uid = [NSString stringWithFormat:@"%p", self];
            [self bk_associateValue:uid withKey:kObjectUid];
            return uid;
        }
        return __uid;
    }
}

- (UIViewController *)st_rootUVC {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

- (CGRect)st_rootFrame {
    return [self st_rootUVC].view.frame;
}

#pragma mark Geom

- (NSUInteger)indexWithDegree:(CGFloat)degree totalDegree:(CGFloat)totalDegree totalCount:(NSUInteger)count{
    NSUInteger numberOfItems = count;

    CGFloat angle = (totalDegree / (CGFloat)numberOfItems);
    CGFloat point = roundf((degree - (angle / 2.f)) / angle);

    NSUInteger itemIndex;
    if (point < 0) {
        itemIndex = (NSUInteger)(numberOfItems + point);
    }
    else {
        itemIndex = (NSUInteger)point;
    }

    itemIndex = MIN(itemIndex, (numberOfItems - 1));

    return itemIndex;
}


- (NSUInteger)indexWithDegree:(CGFloat)degree totalCount:(NSUInteger)count
{
    return [self indexWithDegree:degree totalDegree:360 totalCount:count];
}

- (CGFloat)degreeWithCenter:(CGPoint)center location:(CGPoint)location
{
    CGFloat dx = location.x - center.x;
    CGFloat dy = location.y - center.y;

    CGFloat radian = atan2f(dy, dx);

    return AGKRadiansToDegrees((CGFloat) (radian + M_PI_2));
}

#pragma mark KVO
+ (SEL)propertySetterSelectorForKeyPath:(NSString *)keypath{
    return NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [[keypath substringToIndex:1] capitalizedString], [keypath substringFromIndex:1]]);
}

+ (BOOL)isPropertySetterOverridden:(NSString *)keypath{
    return isInstanceMethodOverridden(self, [self propertySetterSelectorForKeyPath:keypath]);
}

@end