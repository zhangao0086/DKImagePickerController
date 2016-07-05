//
// Created by BLACKGENE on 2016. 1. 8..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITouchLongPressGestureRecognizer : UILongPressGestureRecognizer
@property (nonatomic, readonly) BOOL touchInside;
@property (nonatomic, readonly) UITouch * touch;
@property (nonatomic, readonly) UIEvent * event;
@end