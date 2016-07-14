//
// Created by BLACKGENE on 7/14/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STAfterImageLayerEffect.h"

@interface STAfterImageLayersColorEffect : STAfterImageLayerEffect
@property (nonatomic, assign) CGFloat intensity;
@property (nonatomic, readwrite) UIColor * color;

- (instancetype)initWithColor:(UIColor *)color;

+ (instancetype)effectWithColor:(UIColor *)color;

@end