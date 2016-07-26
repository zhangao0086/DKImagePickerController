//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCapturedImageSetAnimatableLayerSetCollectionView.h"
#import "STSegmentedSliderView.h"


@interface STEditControlFrameEditView : STCapturedImageSetAnimatableLayerSetCollectionView <STSegmentedSliderControlDelegate>
@property (nonatomic, readonly) NSUInteger maxNumberOfLayersOfLayerSet;
@end