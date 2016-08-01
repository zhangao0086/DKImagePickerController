//
// Created by BLACKGENE on 7/14/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMultiSourcingImageProcessor.h"

@interface STGIFFDisplayLayerColorizeEffect : STMultiSourcingImageProcessor
@property (nonatomic, assign) CGFloat intensity;
@property (nonatomic, readwrite) UIColor * color;

- (instancetype)initWithColor:(UIColor *)color;

+ (instancetype)effectWithColor:(UIColor *)color;

@end