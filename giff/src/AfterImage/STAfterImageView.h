//
// Created by BLACKGENE on 7/8/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STSelectableView.h"
#import "STSelectableCapturedImageSetView.h"
#import "STSegmentedSliderView.h"

@interface STAfterImageView : STUIView <STSegmentedSliderControlDelegate>
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, readonly) NSArray<STAfterImageLayerItem *> * layers;

- (void)appendLayer:(STAfterImageLayerItem *)layerItem;

- (void)removeAllLayers;
@end