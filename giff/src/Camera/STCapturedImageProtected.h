//
// Created by BLACKGENE on 4/30/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCapturedImage.h"

@interface STCapturedImage()
@property (nonatomic, readwrite) NSURL * thumbnailUrl;
@property (nonatomic, readwrite) NSURL * fullScreenUrl;
@property (nonatomic, assign) CGSize pixelSize;

@property (nonatomic, assign) UIInterfaceOrientation capturedInterfaceOrientation;
@property (nonatomic, assign) UIImageOrientation capturedImageOrientation;
@property (nonatomic, assign) UIDeviceOrientation capturedDeviceOrientation;
@end