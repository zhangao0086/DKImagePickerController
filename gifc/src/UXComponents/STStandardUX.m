//
// Created by BLACKGENE on 2015. 3. 18..
// Copyright (c) 2015 stells. All rights reserved.
//


#import <SCViewShaker/UIView+Shake.h>
#import "STTimeOperator.h"
#import "STStandardUX.h"
#import "NSObject+STUtil.h"

NSString * const STStandardButtonsBadgeTextNew = @"N";

@implementation STStandardUX {

}

#pragma mark Expression to User
+ (void)expressDenied:(UIView *)view{
    [view shakeWithOptions:kDefaultShakeOptions force:.09 duration:.8 iterationDuration:0.08 completionHandler:nil];
}

#pragma mark Special Effects
#define STEP_DEPTH_Parallax 5
#define MAX_STEP_DEPTH_Parallax 8

#define MIN_DEPTH_Parallax 7
#define MAX_DEPTH_Parallax (MIN_DEPTH_Parallax+(STEP_Da EPTH_Parallax*MAX_STEP_DEPTH_Parallax))

+ (void) startParallaxToViews:(NSArray *)viewsHierachy {
    //FIXME: memory leak..
//    NSAssert(viewsHierachy && viewsHierachy.count>0, @"Must filled array");
//    [self _startParallaxToViews:viewsHierachy depth:0];
}

+ (void)_startParallaxToViews:(NSArray *)viewsHierachy depth:(NSUInteger)depth {
    //FIXME: memory leak..
//    NSAssert(viewsHierachy && viewsHierachy.count>0, @"Must filled array");
//
//    Weaks
//    [viewsHierachy eachWithIndex:^(id object, NSUInteger index) {
//        if([object isKindOfClass:UIView.class]){
//            ((UIView *)object).parallaxIntensity = MIN_DEPTH_Parallax + (STEP_DEPTH_Parallax * depth);
//        }
//
//        if([object isKindOfClass:NSArray.class]){
//            [Wself.class _startParallaxToViews:object depth:depth+1];
//        }
//    }];
}

+ (void)stopParallaxToViews:(NSArray *)viewsHierachy {
    //FIXME: memory leak..
//    Weaks
//    [viewsHierachy eachWithIndex:^(id object, NSUInteger index) {
//        if([object isKindOfClass:UIView.class]){
//            ((UIView *)object).parallaxIntensity = 0;
//        }
//
//        if([object isKindOfClass:NSArray.class]){
//            [Wself.class stopParallaxToViews:object];
//        }
//    }];
}

#pragma mark Animation
+ (CGFloat)springBouncinessRelaxed; {
    return 10;
}

+ (void)setAnimationFeelToRelaxedSpring:(id)viewOrLayer{
    if(!viewOrLayer){
        return;
    }

    NSAssert([viewOrLayer isKindOfClass:UIView.class] || [viewOrLayer isKindOfClass:CALayer.class], @"must be CALayer or UIView");
    [viewOrLayer setPop_springBounciness:[self.class springBouncinessRelaxed]];
}

+ (void)setAnimationFeelsToFastShortSpring:(id)viewOrLayer{
    if(!viewOrLayer){
        return;
    }

    NSAssert([viewOrLayer isKindOfClass:UIView.class] || [viewOrLayer isKindOfClass:CALayer.class], @"must be CALayer or UIView");
    [viewOrLayer setPop_duration:.2];
}

+ (NSObject *)setAnimationFeelToHighTensionSpring:(NSObject *)target{
    target.pop_springBounciness = 11;
    target.pop_springSpeed = 14;
    return target;
}

+ (NSObject *)animateAlphaFadeInFromDimmed:(NSObject *)target{
    if([target isKindOfClass:UIView.class]){
        ((UIView *)target).alpha = .1;
        ((UIView *)target).easeInEaseOut.duration = .6;
        ((UIView *)target).easeInEaseOut.alpha = 1;
    }else if([target isKindOfClass:CALayer.class]){
        ((CALayer *)target).opacity = .1;
        ((CALayer *)target).easeInEaseOut.duration = .6;
        ((CALayer *)target).easeInEaseOut.opacity = 1;
    }
    return target;
}

#pragma mark Scroll
+ (CGFloat)velocityForStartScrolling {
    return 13;
}

+ (CGFloat)maxOffsetForPullToGridView {
    return 50;
}

+ (NSTimeInterval)delayShortForUserRecognize {
    return 1.5f;
}

+ (NSTimeInterval)delayLongForUserRecognize {
    return 3;
}

+ (CGFloat)maxMultipleNumberOfFrameHeightByContentHeightToHideControlsWhenScrolling {
    return 3;
}

#pragma mark Gesture
+ (void)resolveLongTapDelay:(UILongPressGestureRecognizer *) recognizer{
    recognizer.minimumPressDuration = [STApp isInSimulator] ? 0.5 : 0.15;
    recognizer.delaysTouchesBegan = YES;
}

+ (CGFloat)reachingDistanceForPanning {
    return 100;
}

+ (CGFloat)reachingVelocityForPanning {
    return 640;
}

#pragma mark Timer
+ (NSString *)revertStateAfterShortDelay:(NSString *)id block:(void (^)(void))block{
    return [STTimeOperator st_performOnceAfterDelay:id interval:[self.class delayShortForUserRecognize] block:block];
}

+ (NSString *)resetAndRevertStateAfterShortDelay:(NSString *)id block:(void (^)(void))block{
    [STTimeOperator st_clearPerformOnceAfterDelay:id];
    return [self.class revertStateAfterShortDelay:id block:block];
}

+ (NSString *)revertStateAfterLongDelay:(NSString *)id block:(void (^)(void))block{
    return [STTimeOperator st_performOnceAfterDelay:id interval:[self.class delayLongForUserRecognize] block:block];
}

+ (NSString *)resetAndRevertStateAfterLongDelay:(NSString *)id block:(void (^)(void))block{
    [STTimeOperator st_clearPerformOnceAfterDelay:id];
    return [self.class revertStateAfterLongDelay:id block:block];
}

+ (void)clearDelay:(NSString *)id{
    [STTimeOperator st_clearPerformOnceAfterDelay:id];
}

+ (void)fireDelay:(NSString *)id{
    [STTimeOperator st_fire:id];
}

+ (BOOL)runningDelay:(NSString *)id{
    return [STTimeOperator st_isPerforming:id];
}

#pragma mark NotificationMessage
+ (void)setupNotificationMessageStyle{
    // Use a custom design file
}


#pragma mark Haptic
+ (CGFloat)minSystemVolumeForSoundHaptic {
    return .5;
}

#pragma mark LivePhoto
+ (CGFloat)touchForceThresholdToPlayLivePhoto;{
    return 4;
}

#pragma mark In-App Purchase Transactions
+ (void)beginInAppPurchaseTransactions{
    Weaks
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:.4 animations:^{
        [Wself st_rootUVC].view.alpha = [STStandardUI alphaForDimmingWeak];
    }];
}

+ (void)endInAppPurchaseTransactions{
    Weaks
    [UIView animateWithDuration:.3 animations:^{
        [Wself st_rootUVC].view.alpha = 1;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}
@end
