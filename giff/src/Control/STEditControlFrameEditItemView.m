//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STEditControlFrameEditItemView.h"
#import "STCapturedImageSet.h"
#import "STCapturedImageSetDisplayLayer.h"
#import "STCapturedImageSetAnimatableLayer.h"


@implementation STEditControlFrameEditItemView {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }

    return self;
}


- (void)setLayerItem:(STCapturedImageSetAnimatableLayer *)layerItem {
    _layerItem = layerItem;

}


- (void)createContent {
    [super createContent];

}

- (void)disposeContent {

    _layerItem = nil;
    [super disposeContent];
}


@end