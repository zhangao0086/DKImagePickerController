//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STCapturedImageSetAnimatableLayerSet;

@interface STCapturedImageSetAnimatableLayerSetCollectionView : STUIView{
@protected
    UIView * _contentView;
}

@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, readonly) NSArray<STCapturedImageSetAnimatableLayerSet *> * layerSets;

- (UIView *)itemViewOfLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet;

- (void)appendLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet;

- (void)removeLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet;

- (void)removeAllLayersSets;

- (void)setNeedsLayersDisplayAndLayout;
@end