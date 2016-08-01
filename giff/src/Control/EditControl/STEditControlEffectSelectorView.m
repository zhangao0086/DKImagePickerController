//
// Created by BLACKGENE on 8/1/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STEditControlEffectSelectorView.h"
#import "iCarousel.h"
#import "UIView+STUtil.h"
#import "STCarouselHolder.h"
#import "STCarouselHolderController.h"
#import "STGIFFDisplayLayerEffectItem.h"
#import "STGIFFDisplayLayerChromakeyEffect.h"
#import "STGIFFDisplayLayerJanneEffect.h"
#import "STGIFFDisplayLayerLeifEffect.h"
#import "STGIFFDisplayLayerColorizeEffect.h"
#import "STGIFFDisplayLayerFrameSwappingColorizeBlendEffect.h"
#import "UIImage+STUtil.h"


@implementation STEditControlEffectSelectorView {
    STCarouselHolderController * _carouselController;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _carouselController = [[STCarouselHolderController alloc] initWithCarousel:[[iCarousel alloc] initWithSize:self.size]];
    }
    return self;
}

- (void)createContent {
    [super createContent];

    CGFloat itemWidth = self.height;
    STCarouselHolder * carouselHolder = [[STCarouselHolder alloc] init];
    carouselHolder.itemWidth = self.height;
    carouselHolder.centerItemWhenSelected = YES;
    [carouselHolder.items addObjectsFromArray:@[
            [STGIFFDisplayLayerEffectItem itemWithClass:STGIFFDisplayLayerLeifEffect.class imageName:@"effect_thumb.png"]
            , [STGIFFDisplayLayerEffectItem itemWithClass:STGIFFDisplayLayerChromakeyEffect.class imageName:@"effect_thumb.png"]
            , [STGIFFDisplayLayerEffectItem itemWithClass:STGIFFDisplayLayerJanneEffect.class imageName:@"effect_thumb.png"]
            , [STGIFFDisplayLayerEffectItem itemWithClass:STGIFFDisplayLayerColorizeEffect.class imageName:@"effect_thumb.png"]
            , [STGIFFDisplayLayerEffectItem itemWithClass:STGIFFDisplayLayerFrameSwappingColorizeBlendEffect.class imageName:@"effect_thumb.png"]
    ]];

    carouselHolder.blockForItemView = ^UIView *(iCarousel *carousel, NSInteger index, UIView *view, STGIFFDisplayLayerEffectItem * item) {
        if(!view){
            UIImageView * newview = [[UIImageView alloc] initWithImage:[UIImage imageBundled:item.imageName]];
            newview.size = CGSizeMakeValue(itemWidth);
            view = newview;
        }
        return view;
    };

    _carouselController.holder = carouselHolder;

    [self addSubview:_carouselController.carousel];

    [_carouselController.carousel centerToParent];
}


@end