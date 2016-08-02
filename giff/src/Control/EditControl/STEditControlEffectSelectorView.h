//
// Created by BLACKGENE on 8/1/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STCarouselHolderController;
@class STGIFFDisplayLayerEffectItem;


@interface STEditControlEffectSelectorView : STUIView
@property (nonatomic, readonly) STGIFFDisplayLayerEffectItem * currentSelectedEffectItem;
@property (nonatomic, readonly) BOOL selectedEffectItemHasChanging;
@end