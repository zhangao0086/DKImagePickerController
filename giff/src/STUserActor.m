//
// Created by BLACKGENE on 2014. 12. 14..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import "STUserActor.h"


@implementation STUserActor {
    void (^_whenAction)(NSInteger action, id object);
}

static NSMutableDictionary * _finishBlocks;

+ (STUserActor *)sharedInstance {
    static STUserActor *_instance = nil;
    BlockOnce(^{
        _instance = [[self alloc] init];
        _finishBlocks = [NSMutableDictionary dictionary];
    });
    return _instance;
}

- (void)when:(void (^)(NSInteger action, id object))block; {
    _whenAction = block;
}

- (void)act:(NSInteger)action object:(id)object {
    !_whenAction ?: _whenAction(action, object);
}

- (void)act:(NSInteger)action object:(id)object finishedBlock:(void (^)(NSDictionary *data))block; {
    _finishBlocks[@(action)] = block;
}

- (void)act:(NSInteger)action {
    [self act:action object:nil];
}

- (void)dispatchActionFinished:(NSInteger)action data:(NSDictionary *)data{
    void (^block)(NSDictionary *_data) = _finishBlocks[@(action)];
    if(block){
        block(data);
        [_finishBlocks removeObjectForKey:@(action)];
    }
}

- (void)updateContext{
    [self act:STUserActionSetNeedsContext];
}

@end