//
// Created by BLACKGENE on 2015. 2. 16..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Reachability/Reachability.h>
#import "STReachabilityManager.h"


@implementation STReachabilityManager {
    Reachability* _reach;
}

+ (STReachabilityManager *)sharedInstance {
    static STReachabilityManager *_instance = nil;
    BlockOnce(^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)observeReachability{
    @synchronized (_reach) {
        @try {
            Weaks
            if(!_reach){
                _reach = [Reachability reachabilityWithHostname:@"www.google.com"];
                _reach.reachableOnWWAN = NO;
                _reach.reachableBlock = ^(Reachability*reach){
                    Strongs
                    Sself->_isConnectedWifi = [reach isReachableViaWiFi];
                };
                _reach.unreachableBlock = ^(Reachability*reach){
                    Strongs
                    Sself->_isConnectedWifi = NO;
                };
            }

            [_reach startNotifier];
        }@finally {}
    }
}

- (void)activate{
    [self observeReachability];
}

- (void)reactivate{
    [self deactivate];
    [self activate];
}

- (void)deactivate{
    [_reach stopNotifier];
    _isConnectedWifi = NO;
    _reach = nil;
}

@end