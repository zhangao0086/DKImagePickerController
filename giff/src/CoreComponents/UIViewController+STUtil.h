//
// Created by BLACKGENE on 2016. 3. 15..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STKeyBoardStatusInfo : NSObject
@property (nonatomic, readonly) CGRect frameBegin;
@property (nonatomic, readonly) CGRect frameEnd;
@property (nonatomic, readonly) NSTimeInterval animationDuration;
@property (nonatomic, readonly) NSUInteger animationCurve;
@property (nonatomic, readonly, getter=isLocal) BOOL local;

- (instancetype)initWithFrameBegin:(CGRect)frameBegin frameEnd:(CGRect)frameEnd animationDuration:(NSTimeInterval)animationDuration animationCurve:(NSUInteger)animationCurve local:(BOOL)local;

+ (instancetype)infoWithFrameBegin:(CGRect)frameBegin frameEnd:(CGRect)frameEnd animationDuration:(NSTimeInterval)animationDuration animationCurve:(NSUInteger)animationCurve local:(BOOL)local;
@end


@interface UIViewController (STUtil)
- (void)whenChangeKeyBoardStatus:(id)observer didShow:(void (^)(STKeyBoardStatusInfo *showInfo))didShow willHide:(void (^)(STKeyBoardStatusInfo *hideInfo))willHide;

- (void)removeAllChangeKeyBoardStatusObservations:(id)observer;
@end