//
// Created by BLACKGENE on 7/13/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STSelectableView.h"

@class STCapturedImageSetDisplayLayer;

@interface STAfterImageLayerView : STSelectableView
@property (nonatomic, readwrite, nullable) STCapturedImageSetDisplayLayer *layerItem;
@end