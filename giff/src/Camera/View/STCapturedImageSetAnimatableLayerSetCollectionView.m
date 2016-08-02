//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageSetAnimatableLayerSetCollectionView.h"
#import "STCapturedImageSetAnimatableLayerSet.h"
#import "UIView+STUtil.h"
#import "STSelectableView.h"
#import "NSArray+STUtil.h"

@implementation STCapturedImageSetAnimatableLayerSetCollectionView {
    NSMutableArray * _layerSets;
}

- (void)dealloc {
    _layerSets = nil;
}

- (void)setNeedsLayersDisplayAndLayout {

}

- (void)setCurrentFrameIndex:(NSUInteger)currentFrameIndex {
    _currentFrameIndex = currentFrameIndex;

    [self setNeedsLayersDisplayAndLayout];
}

- (STCapturedImageSetAnimatableLayerSet *)currentLayerSet {
    return [[self layerSets] st_objectOrNilAtIndex:self.currentLayerSetIndex];
}

- (UIView *)currentItemViewOfLayerSet {
    return [self itemViewOfLayerSet:self.currentLayerSet];
}


- (NSArray *)layerSets {
    return _layerSets;
}

- (void)initToAddLayersIfNeeded{
    if(!_contentView){
        _contentView = [[UIView alloc] initWithSize:self.size];
        [self insertSubview:_contentView atIndex:0];
        [_contentView saveInitialLayout];
        _contentView.clipsToBounds = YES;
    }

    if(!_layerSets.count){
        _layerSets = [NSMutableArray array];
    }
}

- (UIView *)itemViewOfLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet {
    NSUInteger index = [_layerSets indexOfObject:layerSet];
    NSAssert(index<NSUIntegerMax, @"given layerSet is not contained.");
    UIView * layersContentView = [[_contentView subviews] st_objectOrNilAtIndex:index];
    NSAssert(layersContentView, @"Not found layersContentView");
    return layersContentView;
}

- (void)appendLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet{
    [self initToAddLayersIfNeeded];

    [_layerSets addObject:layerSet];
    layerSet.index = [_layerSets indexOfObject:layerSet];
}

- (void)removeLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet {
    NSAssert([_layerSets containsObject:layerSet], @"given layer item is not contained in _layers.");

    [_layerSets removeObject:layerSet];

    UIView * layerItemView = [self itemViewOfLayerSet:layerSet];
    if([layerItemView isKindOfClass:STSelectableView.class]){
        [((STSelectableView *) layerItemView) clearViews];
    }else if([layerItemView isKindOfClass:STUIView.class]){
        [((STUIView *) layerItemView) disposeContent];
    }
    [layerItemView clearAllOwnedImagesIfNeededAndRemoveFromSuperview:NO];
}

- (void)removeAllLayersSets{
    for(STCapturedImageSetAnimatableLayerSet * layerSet in _layerSets){
        [self removeLayerSet:layerSet];
    }

//    [_contentView st_eachSubviews:^(UIView *view, NSUInteger index) {
//        if([view isKindOfClass:STSelectableView.class]){
//            [((STSelectableView *) view) clearViews];
//        }else if([view isKindOfClass:STUIView.class]){
//            [((STUIView *) view) disposeContent];
//        }
//    }];
//    [_contentView clearAllOwnedImagesIfNeeded:NO removeSubViews:YES];
//
//    [_layers removeAllObjects];
}
@end