//
// Created by BLACKGENE on 2015. 7. 3..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"


@interface STOrientationItem : STItem
@property (nonatomic, assign) UIDeviceOrientation deviceOrientation;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, assign) UIImageOrientation imageOrientation;

- (instancetype)initWithDeviceOrientation:(UIDeviceOrientation)deviceOrientation interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation imageOrientation:(UIImageOrientation)imageOrientation;

+ (instancetype)itemWith:(UIDeviceOrientation)deviceOrientation interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation imageOrientation:(UIImageOrientation)imageOrientation;

@end