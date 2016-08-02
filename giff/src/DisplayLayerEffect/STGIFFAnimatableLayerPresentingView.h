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
@class STGIFFDisplayLayerEffectItem;

@interface STGIFFAnimatableLayerPresentingView : STCapturedImageSetAnimatableLayerSetCollectionView <STSegmentedSliderControlDelegate>

- (void)updateAllLayersOfLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet;

- (void)updateCurrentLayerOfLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet;


- (void)updateEffectToAllLayersOfCurrentLayerSet:(STGIFFDisplayLayerEffectItem *)effectItem;
@end