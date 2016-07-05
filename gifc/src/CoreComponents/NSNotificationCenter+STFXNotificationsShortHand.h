//
// Created by BLACKGENE on 2014. 9. 25..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (STFXNotificationsShortHand)

+ (NSNotificationCenter *)get;

- (void)st_addObserverWithMainQueue:(id)observer forName:(NSString *)name usingBlock:(void (^)(NSNotification *note, id observer))block;

- (void)st_addObserverWithMainQueueOnlyOnce:(id)observer forName:(NSString *)name usingBlock:(void (^)(NSNotification *note, id observer))block;

- (void)st_addObserverWithMainQueueOnlyOnce:(id)observer forName:(NSString *)name timout:(NSTimeInterval)timeout usingBlock:(void (^)(NSNotification *note, id observer))block;

- (void)st_removeObserverWithMainQueue:(id)observer forName:(NSString *)name;

- (void)st_postNotificationName:(NSString *)aName;
@end