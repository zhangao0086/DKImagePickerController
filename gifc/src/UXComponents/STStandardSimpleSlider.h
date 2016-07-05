//
// Created by BLACKGENE on 15. 5. 21..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M13ProgressViewBorderedSlider.h"


@interface STStandardSimpleSlider : M13ProgressViewBorderedSlider
@property (nonatomic, assign) BOOL shouldSwitchDisplayWhenActivated;
@property (nonatomic, readwrite, nullable) UIView * iconViewOfMinimumSide;
@property (nonatomic, readwrite, nullable) UIView * iconViewOfMaximumSide;
@property (copy) void(^whenChangeActiveState)(STStandardSimpleSlider * __weak weakSelf, BOOL active);
@end