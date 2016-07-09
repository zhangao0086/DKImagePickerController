//
// Created by BLACKGENE on 7/8/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STAfterImageItem;
@class STCapturedImageSet;

@interface STAfterImageView : STUIView
@property (nonatomic, readwrite) STCapturedImageSet * imageSet;
@end