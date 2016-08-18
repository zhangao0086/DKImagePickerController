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
#import "UIImage+STUtil.h"
#import "NSArray+STUtil.h"
#import "STGIFFDisplayLayerEffectsManager.h"


@implementation STEditControlEffectSelectorView {
    STCarouselHolderController * _carouselController;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _carouselController = [[STCarouselHolderController alloc] initWithCarousel:[[iCarousel alloc] initWithSize:self.size]];
        _currentSelectedEffectItem = [[STGIFFDisplayLayerEffectsManager sharedManager].effects st_objectOrNilAtIndex:_carouselController.scrolledIndex];
    }
    return self;
}

- (void)createContent {
    [super createContent];

    CGFloat itemWidth = self.height;
    STCarouselHolder * carouselHolder = [[STCarouselHolder alloc] init];
    carouselHolder.itemWidth = self.height;
    carouselHolder.centerItemWhenSelected = YES;
    [carouselHolder.items addObjectsFromArray:[STGIFFDisplayLayerEffectsManager sharedManager].effects];

    carouselHolder.blockForItemView = ^UIView *(iCarousel *carousel, NSInteger index, UIView *view, STGIFFDisplayLayerEffectItem * item) {
        UIImage * image = [UIImage imageBundledCache:item.imageName];
        if(!view){
            UIImageView * newview = [[UIImageView alloc] init];
            newview.size = CGSizeMakeValue(itemWidth);
            view = newview;
        }
        ((UIImageView *)view).image = image;
        return view;
    };

//    carouselHolder.blockForiCarouselCustomTransfrom = ^CATransform3D(iCarousel *carousel, CGFloat offset, CATransform3D baseTransform) {
////        [carousel.delegate carousel:carousel valueForOption:iCarouselOptionSpacing withDefault:0]
//        return CATransform3DMakeTranslation(offset * itemWidth - offset, 0, 0);
//    };

    carouselHolder.blockForiCarouselOption = ^CGFloat(iCarousel *carousel, iCarouselOption option, CGFloat defaultValue) {
        switch (option){
            case iCarouselOptionSpacing:
                return defaultValue * 1.15f;
            default:
                return defaultValue;
        }
    };

    _carouselController.carousel.decelerationRate = 0.8f;
    _carouselController.carousel.bounceDistance = .5f;

    _carouselController.holder = carouselHolder;

    [_carouselController whenDidSelected:^(NSInteger i) {

        STGIFFDisplayLayerEffectItem * effectItem = [_carouselController.items st_objectOrNilAtIndex:i];
        if(![effectItem isEqual:_currentSelectedEffectItem]){
            [self willChangeValueForKey:@keypath(self.currentSelectedEffectItem)];
            _currentSelectedEffectItem = [_carouselController.items st_objectOrNilAtIndex:i];
            [self didChangeValueForKey:@keypath(self.currentSelectedEffectItem)];
        }
    }];

    [_carouselController whenChangedScrolledIndex:^(NSInteger i) {

    }];

    [_carouselController whenDidEndScroll:^(NSInteger i) {

    }];

    [self addSubview:_carouselController.carousel];


    _carouselController.carousel.x = 0;
    //FIXME: 왜 이렇게 해야 맞는지 모르겠음 projection때문인가
//    _carouselController.carousel.y = -itemWidth;
}


@end