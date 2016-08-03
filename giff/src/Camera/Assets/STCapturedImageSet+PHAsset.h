//
// Created by BLACKGENE on 8/3/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCapturedImageSet.h"

@class PHAsset;

@interface STCapturedImageSet (PHAsset)

+ (BOOL)createFromAsset:(PHAsset *)asset completion:(void (^)(STCapturedImageSet *imageSet))block;
@end