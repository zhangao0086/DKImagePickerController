//
// Created by BLACKGENE on 2014. 12. 14..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface STUserActor : NSObject
+ (STUserActor *)sharedInstance;

- (void)when:(void (^)(NSInteger action, id object))block;

- (void)act:(NSInteger)action object:(id)object;

- (void)act:(NSInteger)action object:(id)object finishedBlock:(void(^)(NSDictionary * metadata))block;

- (void)act:(NSInteger)action;

- (void)dispatchActionFinished:(NSInteger)action data:(NSDictionary *)data;

- (void)updateContext;
@end