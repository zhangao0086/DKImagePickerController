//
// Created by BLACKGENE on 2016. 2. 11..
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STFilterPresenterProductItemView.h"
#import "STFilterItem.h"
#import "UIView+STUtil.h"
#import "TTTAttributedLabel.h"
#import "R.h"
#import "SVGKImage.h"
#import "SVGKImage+STUtil.h"


@implementation STFilterPresenterProductItemView{

}

- (void)setProductIconImageName:(NSString *)productIconImageName {
    _productIconImageName = productIconImageName;
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if(self.targetFilterItem){
        BOOL isProductItem = self.targetFilterItem.type == STFilterTypeITunesProduct;
        if(!_productIconView && isProductItem){
            _productIconView = [SVGKImage UIImageViewNamed:_productIconImageName?:[R ico_cart] withSizeWidth:self.width/1.8f];
            _productIconView.tagName = self.targetFilterItem.productId;
            _productIconView.alpha = [STStandardUI alphaForDimmingWeak];
            [self addSubview:_productIconView];
            [_productIconView centerToParent];
        }
        _productIconView.visible = isProductItem;
    }else{
        [_productIconView clearAllOwnedImagesIfNeededAndRemoveFromSuperview:NO];
        _productIconView = nil;
    }
}


@end