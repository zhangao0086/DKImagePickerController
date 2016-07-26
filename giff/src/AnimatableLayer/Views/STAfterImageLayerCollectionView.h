//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STCapturedImageSetAnimatableLayerSet;

@interface STAfterImageLayerCollectionView : STUIView{
@protected
    UIView * _contentView;
}

@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, readonly) NSArray<STCapturedImageSetAnimatableLayerSet *> * layers;

- (void)appendLayer:(STCapturedImageSetAnimatableLayerSet *)layerItem;

- (void)removeAllLayers;

- (void)setNeedsLayersDisplayAndLayout;
@end