//
// Created by BLACKGENE on 15. 5. 12..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STDrawableLayer.h"


@interface STExposurePointLayer : STDrawableLayer
@property (nonatomic, assign) CGFloat exposureIntensityValue;
- (void)startExposure;

- (void)finishExposure;
@end