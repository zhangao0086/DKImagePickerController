//
// Created by BLACKGENE on 2015. 3. 18..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STStandardLayout.h"
#import "STStandardUI.h"

extern NSString * const STStandardButtonsBadgeTextNew;

@interface STStandardUX : NSObject
+ (void)expressDenied:(UIView *)view;

+ (void)startParallaxToViews:(NSArray *)viewsHierachy;

+ (void)stopParallaxToViews:(NSArray *)viewsHierachy;

+ (CGFloat)springBouncinessRelaxed;

+ (void)setAnimationFeelToRelaxedSpring:(id)viewOrLayer;

+ (CGFloat)velocityForStartScrolling;

+ (CGFloat)maxOffsetForPullToGridView;

+ (void)setAnimationFeelsToFastShortSpring:(id)viewOrLayer;

+ (NSObject *)setAnimationFeelToHighTensionSpring:(NSObject *)target;

+ (NSObject *)animateAlphaFadeInFromDimmed:(NSObject *)target;

+ (NSTimeInterval)delayShortForUserRecognize;

+ (NSTimeInterval)delayLongForUserRecognize;

+ (CGFloat)maxMultipleNumberOfFrameHeightByContentHeightToHideControlsWhenScrolling;

+ (void)resolveLongTapDelay:(UILongPressGestureRecognizer *)recognizer;

+ (CGFloat)reachingDistanceForPanning;

+ (CGFloat)reachingVelocityForPanning;

+ (NSString *)revertStateAfterShortDelay:(NSString *)id1 block:(void (^)(void))block;

+ (NSString *)resetAndRevertStateAfterShortDelay:(NSString *)id1 block:(void (^)(void))block;

+ (NSString *)revertStateAfterLongDelay:(NSString *)id1 block:(void (^)(void))block;

+ (NSString *)resetAndRevertStateAfterLongDelay:(NSString *)id1 block:(void (^)(void))block;

+ (void)clearDelay:(NSString *)id1;

+ (void)fireDelay:(NSString *)id1;

+ (BOOL)runningDelay:(NSString *)id1;

+ (void)setupNotificationMessageStyle;

+ (CGFloat)minSystemVolumeForSoundHaptic;

+ (CGFloat)touchForceThresholdToPlayLivePhoto;

+ (void)beginInAppPurchaseTransactions;

+ (void)endInAppPurchaseTransactions;
@end