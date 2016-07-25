//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STEditControlFrameEditView.h"
#import "STEditControlFrameEditItemView.h"
#import "UIView+STUtil.h"
#import "STCapturedImageSetDisplayLayer.h"
#import "STCapturedImageSetAnimatableLayer.h"


@implementation STEditControlFrameEditView {

}

- (void)setNeedsLayersDisplayAndLayout {
    [super setNeedsLayersDisplayAndLayout];

    [_contentView st_eachSubviews:^(UIView *view, NSUInteger index) {
        STEditControlFrameEditItemView * editItemView = (STEditControlFrameEditItemView *)view;
        editItemView.y = index*editItemView.height;
    }];
}


- (void)appendLayer:(STCapturedImageSetAnimatableLayer *)layerItem {
    [super appendLayer:layerItem];

    //layer

    for(STCapturedImageSet *imageSet in layerItem.sourceImageSets){
        STEditControlFrameEditItemView * editItemView = [[STEditControlFrameEditItemView alloc] initWithSize:CGSizeMake(self.width, self.height/2)];
        editItemView.imageSet = imageSet;
        editItemView.backgroundColor = [UIColor orangeColor];
        [_contentView addSubview:editItemView];
    }

    [self setNeedsLayersDisplayAndLayout];
}

- (void)removeAllLayers {
    [_contentView st_eachSubviews:^(UIView *view, NSUInteger index) {
        ((STEditControlFrameEditItemView *)view).imageSet = nil;
    }];

    [super removeAllLayers];
}


@end