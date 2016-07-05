//
// Created by BLACKGENE on 2015. 8. 20..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>


@interface STMotionManager : CMMotionManager
@property(atomic, readonly, nullable) NSOperationQueue *motionOperationQueue;

+ (STMotionManager *)sharedManager;

#pragma mark ScreenDirectionBackward;
@property(atomic, readonly) BOOL screenDirectionIsNowBackward;

- (void)startScreenDirectionUpdates;

- (void)updateInitialScreenDirectionToCurrent;

- (void)stopScreenDirectionUpdates;

#pragma mark Orientation
@property(atomic, readonly) UIImageOrientation imageOrientation;
@property(atomic, readonly) UIDeviceOrientation deviceOrientation;
@property(atomic, readonly) UIInterfaceOrientation interfaceOrientation;

- (void)startOrientationUpdates;

- (void)pauseOrientationUpdates:(BOOL)fireDefaultsBefore;

- (void)stopOrientationUpdates:(BOOL)fireDefaultsBefore;

- (void)whenInterfaceOrientation:(NSString *)identifier changed:(void (^)(UIInterfaceOrientation orientation))block;
@end