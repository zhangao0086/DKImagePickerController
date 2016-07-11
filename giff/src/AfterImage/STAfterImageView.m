//
// Created by BLACKGENE on 7/8/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageView.h"
#import "STCapturedImageSet.h"
#import "UIView+STUtil.h"
#import "STCapturedImage.h"
#import "NSArray+STUtil.h"
#import "STCapturedImageProtected.h"
#import "STAfterImageLayerItem.h"

@interface STSelectableView(Protected)
- (void)setViewsDisplay;
@end

@implementation STAfterImageView {
    UIView * _afterImageSublayersContainerView;
    STAfterImageItem * _afterImageItem;
}

- (void)setImageSet:(STCapturedImageSet *)imageSet {
    NSAssert(!imageSet || [imageSet.extensionObject isKindOfClass:[STAfterImageItem class]], @"given imageSet did not contain STAfterImageItem in .extensionData");

    //sub set
    if(imageSet) {
        //set - heavy cost
        if (![imageSet isEqual:_imageSet] && [imageSet.extensionObject isKindOfClass:[STAfterImageItem class]]) {
            STCapturedImage * anyImage = [imageSet.images firstObject];
            NSAssert(anyImage.imageUrl, @"STCapturedImage's imageUrl does not exist.");
            NSArray<NSURL *>* imageUrls = [imageSet.images mapWithItemsKeyPath:@keypath(anyImage.fullScreenUrl) orDefaultKeypath:@keypath(anyImage.imageUrl)];

            _afterImageItem = (STAfterImageItem *)imageSet.extensionObject;

            if (!_afterImageSublayersContainerView) {
                _afterImageSublayersContainerView = [[UIView alloc] initWithSize:self.size];
                [self insertSubview:_afterImageSublayersContainerView aboveSubview:_contentView];
            }

            for (STAfterImageLayerItem *layerItem in _afterImageItem.layers) {
                STSelectableView *layerView = [[STSelectableView alloc] initWithSize:_afterImageSublayersContainerView.size];
                layerView.fitViewsImageToBounds = YES;

                //TODO: preheating - 여기서 미리 랜더링된 필터를 temp url에 저장 후 그 url을 보여주는 것도 나쁘지 않을듯
                [_afterImageSublayersContainerView addSubview:layerView];
                [layerView setViews:imageUrls];
            }

            [self setViews:imageUrls];
        }
    }else{
        //clear
        _afterImageItem = nil;
        [self clearViews];
    }

    _imageSet = imageSet;
}

- (void)clearViews {
    if(!_afterImageItem){
        [_afterImageSublayersContainerView st_eachSubviews:^(UIView *view, NSUInteger index) {
            [((STSelectableView *) view) clearViews];
        }];
        [_afterImageSublayersContainerView clearAllOwnedImagesIfNeededAndRemoveFromSuperview:YES];
    }
    [super clearViews];
}

- (void)setViewsDisplay {
    [super setViewsDisplay];

    [_afterImageSublayersContainerView.subviews eachViewsWithIndex:^(UIView *view, NSUInteger index) {
        STSelectableView * layerView = (STSelectableView *) view;
        STAfterImageLayerItem *layerItem = [_afterImageItem.layers st_objectOrNilAtIndex:index];
        NSUInteger layerIndex = self.currentIndex + layerItem.frameIndexOffset;
        BOOL overRanged = layerIndex>=self.count;

        if(overRanged){
            layerView.visible = NO;
        }else{
            layerView.visible = YES;
            layerView.alpha = layerItem.alpha;
            //TODO: render filter
            layerView.currentIndex = layerIndex;
        }
    }];
}


@end