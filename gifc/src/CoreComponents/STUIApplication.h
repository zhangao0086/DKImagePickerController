//
// Created by BLACKGENE on 15. 10. 5..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const STGlobalUITouchEndNotification;

@interface STUIApplication : UIApplication
@property (nonatomic, assign) BOOL trackingGlobalTouches;
@property (nonatomic, assign) BOOL hasBeenReceivedMemoryWarning;

+ (instancetype)sharedApplication;
@end