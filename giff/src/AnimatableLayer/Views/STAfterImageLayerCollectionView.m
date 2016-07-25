//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageLayerCollectionView.h"
#import "STCapturedImageSetAnimatableLayer.h"
#import "UIView+STUtil.h"
#import "STSelectableView.h"

@implementation STAfterImageLayerCollectionView {
    NSMutableArray * _layers;
}

- (void)dealloc {
    _layers = nil;
}

- (void)setNeedsLayersDisplayAndLayout {

}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    _currentIndex = currentIndex;

    [self setNeedsLayersDisplayAndLayout];
}

- (NSArray *)layers {
    return _layers;
}

- (void)initToAddLayersIfNeeded{
    if(!_layersContainerView){
        _layersContainerView = [[UIView alloc] initWithSize:self.size];
        [self insertSubview:_layersContainerView atIndex:0];
        [_layersContainerView saveInitialLayout];
        _layersContainerView.clipsToBounds = YES;
    }

    if(!_layers.count){
        _layers = [NSMutableArray array];
    }
}

- (void)appendLayer:(STCapturedImageSetAnimatableLayer *)layerItem{
    [self initToAddLayersIfNeeded];

    [_layers addObject:layerItem];
    layerItem.index = [_layers indexOfObject:layerItem];
}

- (void)removeAllLayers{
    [_layersContainerView st_eachSubviews:^(UIView *view, NSUInteger index) {
        if([view isKindOfClass:STSelectableView.class]){
            [((STSelectableView *) view) clearViews];
        }else if([view isKindOfClass:STUIView.class]){
            [((STUIView *) view) disposeContent];
        }
    }];
    [_layersContainerView clearAllOwnedImagesIfNeeded:NO removeSubViews:YES];

    [_layers removeAllObjects];
}
@end