//
// Created by BLACKGENE on 15. 5. 11..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STDrawableLayer.h"


@interface STViewFinderPointLayer : STDrawableLayer
@property (nonatomic, assign) CGFloat exposureIntensityValue;

- (void)startFocusing;

- (void)finishFocusing;

- (void)finishFocusingWithLocked;

- (void)setOutterCicleFill:(BOOL)fill;

- (void)startPointer;

- (void)stopPointer;

- (void)startExposure;

- (void)finishExposure;
@end