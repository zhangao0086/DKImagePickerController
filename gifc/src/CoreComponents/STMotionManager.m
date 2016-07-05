//
// Created by BLACKGENE on 2015. 8. 20..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "NSTimer+BlocksKit.h"
#import "STMotionManager.h"
#import "NSObject+STUtil.h"
#import "NSString+STUtil.h"
#import "NSObject+BNRTimeBlock.h"
#import "NSObject+STThreadUtil.h"
#import "STDefine.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "STUIApplication.h"

#define IntervalForCheckAccelometer .5f

@interface STMotionManager()
@property(atomic, assign) BOOL paused;

@end

@implementation STMotionManager {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.accelerometerUpdateInterval = IntervalForCheckAccelometer;
        _motionOperationQueue = [[NSOperationQueue alloc] init];
        _motionOperationQueue.qualityOfService = NSOperationQualityOfServiceUtility;
    }
    return self;
}

+ (STMotionManager *)sharedManager {
    static STMotionManager *_instance = nil;
    BlockOnce(^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark Device YRotation Detectino - Measure from DeviceMotion
static CMAttitude *initialAttitude = nil;
- (void)startScreenDirectionUpdates {

    if (self.deviceMotionAvailable && !self.isDeviceMotionActive) {
        //FIXME: memory leak.
//        Weaks
//        self.deviceMotionUpdateInterval = .2;
//        [self startDeviceMotionUpdatesToQueue:_motionOperationQueue withHandler:^(CMDeviceMotion *data, NSError *error) {
//            @autoreleasepool {
//                if(!initialAttitude){
//                    initialAttitude = Wself.deviceMotion.attitude;
//                }
//
//                // translate the attitude
//                CMAttitude * att = data.attitude;
//                [att multiplyByInverseOfAttitude:initialAttitude];
//
//                // calculate magnitude of the change from our initial attitude
////            double magnitude = sqrt(pow(att.roll, 2.0f) + pow(att.yaw, 2.0f) + pow(att.pitch, 2.0f));
//                double magnitude = sqrt(pow(att.roll, 2.0f));
////            dd(magnitude);
////              NSLog(@"magnitude %f, rotationRate %f", magnitude, data.rotationRate.y);
//
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [Wself postScreenDirection:magnitude > 1.2];
//                });
//            }
//        }];

        [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueue:self forName:STGlobalUITouchEndNotification usingBlock:^(NSNotification *note, id observer) {
            [observer updateInitialScreenDirectionToCurrent];
        }];
        [STUIApplication sharedApplication].trackingGlobalTouches = YES;
    }
}

- (void)updateInitialScreenDirectionToCurrent {
    @synchronized (self) {
        if(self.isDeviceMotionActive){
            initialAttitude = self.deviceMotion.attitude;
        }
    }
}

- (void)postScreenDirection:(BOOL)screenDirectionIsNowBackward{
    if(screenDirectionIsNowBackward){
        if(!self.screenDirectionIsNowBackward){
            [self willChangeValueForKey:@keypath(self.screenDirectionIsNowBackward)];
            self->_screenDirectionIsNowBackward = YES;
            [self didChangeValueForKey:@keypath(self.screenDirectionIsNowBackward)];
        }
    }else{
        if(self.screenDirectionIsNowBackward){
            [self willChangeValueForKey:@keypath(self.screenDirectionIsNowBackward)];
            self->_screenDirectionIsNowBackward = NO;
            [self didChangeValueForKey:@keypath(self.screenDirectionIsNowBackward)];
        }
    }
}

- (void)stopScreenDirectionUpdates {
    [self stopDeviceMotionUpdates];

    [self postScreenDirection:NO];

    [STUIApplication sharedApplication].trackingGlobalTouches = NO;
    [[NSNotificationCenter defaultCenter] st_removeObserverWithMainQueue:self forName:STGlobalUITouchEndNotification];

//    NSAssert(initialAttitude, @"initialAttitude is must be nil.");
}

#pragma mark Orientation - Measure from accelerometer
- (void)startOrientationUpdates {
    self.paused = NO;

    if(self.accelerometerAvailable && !self.accelerometerActive){
        Weaks
        [self startAccelerometerUpdatesToQueue:_motionOperationQueue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            [Wself updateOrientationFromAccelerometer:accelerometerData];
        }];
    }
}

- (void)pauseOrientationUpdates:(BOOL)fireDefaultsBefore {
    if(self.paused){
       return;
    }

    self.paused = YES;

    [_motionOperationQueue cancelAllOperations];

    //last fire default orientation if needed.
    [self _setOrientationIfChanged:UIDeviceOrientationUnknown
           newInterfaceOrientation:UIInterfaceOrientationPortrait
               newImageOrientation:UIImageOrientationUp];
}

- (void)stopOrientationUpdates:(BOOL)fireDefaultsBeforeSuspending {
    [self pauseOrientationUpdates:fireDefaultsBeforeSuspending];

    [self stopAccelerometerUpdates];
}

- (void)whenInterfaceOrientation:(NSString *)identifier changed:(void(^)(UIInterfaceOrientation orientation))block{
    if(!identifier){
        return;
    }

    [self whenValueOf:@keypath(self.interfaceOrientation) id:identifier changed:!block ? nil : ^(id value, id _weakSelf) {
        block((UIInterfaceOrientation) [value integerValue]);
    }];
}

- (void)updateOrientationFromAccelerometer:(CMAccelerometerData *)accelerometerData{
    // Motion Queue
    CMAcceleration acceleration = accelerometerData.acceleration;

    // Get the current device angle
    CGFloat xx = (CGFloat) -acceleration.x;
    CGFloat yy = (CGFloat) acceleration.y;
    CGFloat z = (CGFloat) acceleration.z;
    CGFloat angle = (CGFloat) atan2(yy, xx);
    CGFloat absoluteZ = (CGFloat)fabs(acceleration.z);

//    NSLog(@"acc - %f %f %f %f %f", acceleration.x, acceleration.y, acceleration.z, angle, absoluteZ);

    UIInterfaceOrientation newInterfaceOrientation = self.interfaceOrientation;
    UIDeviceOrientation newDeviceOrientation = self.deviceOrientation;
    UIImageOrientation  newImageOrientation = self.imageOrientation;


    // ui orientation
    //0.2 <= angle && angle <= 2.8
    //-1.0 <= angle && angle < 0.2
    //-2.0 <= angle && angle < -1.0
    //-2.0 > angle || angle >= 2.8


    // Landscape -> Portrait : sensitivie / Portrait -> Landscape : insensitive
    CGFloat angleOffset = UIInterfaceOrientationIsLandscape(newInterfaceOrientation) || UIDeviceOrientationIsLandscape(newDeviceOrientation) ? 0 : -.1f;

    if(absoluteZ > 0.95f) {
        if (z > 0.0f) {
            newDeviceOrientation = UIDeviceOrientationFaceDown;
        } else {
            newDeviceOrientation = UIDeviceOrientationFaceUp;
        }
        newInterfaceOrientation = UIInterfaceOrientationPortrait;
        newImageOrientation = UIImageOrientationUp;
    }
    else if(angle >= -2.0- angleOffset && angle <= -1.0+ angleOffset) {// (angle >= -2.25 && angle <= -0.75)
        newInterfaceOrientation = UIInterfaceOrientationPortrait;
        newDeviceOrientation = UIDeviceOrientationPortrait;
        newImageOrientation = UIImageOrientationUp;
    }
    else if(angle >= -0.5- angleOffset && angle <= 0.5+ angleOffset) {// (angle >= -0.75 && angle <= 0.75)
        newInterfaceOrientation = UIInterfaceOrientationLandscapeLeft;
        newDeviceOrientation = UIDeviceOrientationLandscapeLeft;
        newImageOrientation = UIImageOrientationLeft;
    }
    else if(angle >= 1.0- angleOffset && angle <= 2.0+ angleOffset) {// (angle >= 0.75 && angle <= 2.25)
        newInterfaceOrientation = UIInterfaceOrientationPortraitUpsideDown;
        newDeviceOrientation = UIDeviceOrientationPortraitUpsideDown;
        newImageOrientation = UIImageOrientationDown;
    }
    else if(angle <= -2.5+ angleOffset || angle >= 2.5- angleOffset) {// (angle <= -2.25 || angle >= 2.25)
        newInterfaceOrientation = UIInterfaceOrientationLandscapeRight;
        newDeviceOrientation = UIDeviceOrientationLandscapeRight;
        newImageOrientation = UIImageOrientationRight;
    }

    [self _setOrientationIfChanged:newDeviceOrientation
           newInterfaceOrientation:newInterfaceOrientation
               newImageOrientation:newImageOrientation];
}

- (void)_setOrientationIfChanged:(UIDeviceOrientation)newDeviceOrientation
         newInterfaceOrientation:(UIInterfaceOrientation)newInterfaceOrientation
             newImageOrientation:(UIImageOrientation)newImageOrientation{

    if(self.paused){
        return;
    }

    if (newDeviceOrientation != self.deviceOrientation) {
        [self _changeDeviceOrientation:newDeviceOrientation];
    }

    if (newInterfaceOrientation != self.interfaceOrientation) {
        [self _changeInterfaceOrientation:newInterfaceOrientation];
    }

    if (newImageOrientation != self.imageOrientation) {
        [self _changeImageOrientation:newImageOrientation];
    }
}

- (void)_changeInterfaceOrientation:(UIInterfaceOrientation)orientation{
    [self willChangeValueForKey:@keypath(self.interfaceOrientation)];
    _interfaceOrientation = orientation;
    [self didChangeValueForKey:@keypath(self.interfaceOrientation)];
}

- (void)_changeDeviceOrientation:(UIDeviceOrientation)orientation{
    [self willChangeValueForKey:@keypath(self.deviceOrientation)];
    _deviceOrientation = orientation;
    [self didChangeValueForKey:@keypath(self.deviceOrientation)];
}

- (void)_changeImageOrientation:(UIImageOrientation)orientation{
    [self willChangeValueForKey:@keypath(self.imageOrientation)];
    _imageOrientation = orientation;
    [self didChangeValueForKey:@keypath(self.imageOrientation)];
}

@end