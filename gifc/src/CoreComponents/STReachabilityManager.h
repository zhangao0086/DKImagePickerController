//
// Created by BLACKGENE on 2015. 2. 16..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface STReachabilityManager : NSObject
@property (nonatomic, readonly) BOOL isConnectedWifi;

+ (STReachabilityManager *)sharedInstance;

- (void)activate;

- (void)reactivate;

- (void)deactivate;
@end