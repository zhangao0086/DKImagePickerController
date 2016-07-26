//
// Created by BLACKGENE on 7/8/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STSelectableView.h"
#import "STSelectableCapturedImageSetView.h"
#import "STSegmentedSliderView.h"
#import "STCapturedImageSetAnimatableLayerSetCollectionView.h"

@class STCapturedImageSetAnimatableLayerSet;

@interface STGIFFAnimatableLayerPresentingView : STCapturedImageSetAnimatableLayerSetCollectionView <STSegmentedSliderControlDelegate>
- (void)updateLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet;
@end