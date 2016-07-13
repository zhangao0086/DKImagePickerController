//
// Created by BLACKGENE on 7/13/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STSelectableView.h"

@class STAfterImageLayerItem;

@interface STAfterImageLayerView : STSelectableView
@property (nonatomic, readwrite, nullable) STAfterImageLayerItem *layerItem;
@end