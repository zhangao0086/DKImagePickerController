//
// Created by BLACKGENE on 2016. 1. 7..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMotionScrollView.h"

@class PHAsset;
@class STLivePhotoView;

@interface STMotionScrollLivePhotoView : STMotionScrollView

@property (readwrite, nonatomic, weak, nullable) PHAsset  *assetAsLivePhoto;
@property (readonly, nonatomic, nullable) STLivePhotoView *contentLivePhotoView;

@end