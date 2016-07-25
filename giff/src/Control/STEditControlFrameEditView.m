//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STEditControlFrameEditView.h"
#import "STEditControlFrameEditItemView.h"
#import "UIView+STUtil.h"


@implementation STEditControlFrameEditView {

}

- (void)setNeedsLayersDisplayAndLayout {
    [super setNeedsLayersDisplayAndLayout];

    [_layersContainerView st_eachSubviews:^(UIView *view, NSUInteger index) {
        STEditControlFrameEditItemView * editItemView = (STEditControlFrameEditItemView *)view;
        editItemView.y = index*editItemView.height;

    }];
}


- (void)appendLayer:(STCapturedImageSetAnimatableLayer *)layerItem {
    [super appendLayer:layerItem];

    //layer

    STEditControlFrameEditItemView * editItemView = [[STEditControlFrameEditItemView alloc] initWithSize:CGSizeMake(self.width, self.height/2)];
    editItemView.layerItem = layerItem;
    editItemView.backgroundColor = [UIColor orangeColor];

    [_layersContainerView addSubview:editItemView];

    [self setNeedsLayersDisplayAndLayout];
}

@end