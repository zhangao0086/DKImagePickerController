//
// Created by BLACKGENE on 2014. 9. 16..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface STElieStatusBar : STUIView

// real time state
@property (nonatomic, assign) BOOL focusIsRunnig;
@property (nonatomic, assign) STFaceDistance faceDistance;
@property (atomic, readonly) BOOL faceDistanceIsInAvailableRange;
@property (nonatomic, assign) BOOL visibleBackground;
@property (nonatomic, readonly) BOOL showen;

//special views
@property (nonatomic, readonly) STStandardButton * leftButton;
@property (nonatomic, readonly) STStandardButton * rightButton;

@property (nonatomic, readonly) CGFloat layoutHeight;

+ (STElieStatusBar *)sharedInstance;

- (void)show;

- (void)hide;

- (void)lockShowHide;

- (void)unlockShowHide;

- (void)unlockShowHideAndRevert;

- (void)hideLogo;

- (void)startProgress:(NSString *)message;

- (void)stopProgress;

- (void)success;

- (void)fail;

- (void)fatal;

- (void)message:(NSString *)message;

- (void)message:(NSString *)message showLogoAfterDelay:(BOOL)showLogoAfterDelay;

- (void)setVisibleBackground:(BOOL)visibleBackground animation:(BOOL)animation;

- (void)setVisibleBackground:(BOOL)visibleBackground animateAsSlideTransition:(BOOL)animateAsSlideTransition;

- (void)logo:(BOOL)animation;

+ (CGRect)initialFrame;
@end