//
// Created by BLACKGENE on 2014. 9. 11..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import "STCarouselHolderController.h"
#import "STItem.h"
#import "STCarouselHolder.h"

@implementation STCarouselHolderController {
}

- (instancetype)initWithCarousel:(iCarousel *)carousel withHolder:(STCarouselHolder *)holder; {
    self = [super initWithCarousel:carousel];
    if (self) {
        self.holder = holder;

        carousel.delegate = self;
        carousel.dataSource = self;
    }
    return self;
}

- (void)setHolder:(STCarouselHolder *)holder; {
    if([holder isEqual:_holder]){
        return;
    }

    _holder = holder;

    if(!self.carousel.delegate){
        self.carousel.delegate = self;
    }

    if(!self.carousel.dataSource){
        self.carousel.dataSource = self;
    }else{
        [self.carousel reloadData];
    }

    [self setCarouselProperty];
}

- (NSMutableArray *)items; {
    return _holder.items;
}

- (void)reloadItems{
    [self initItems:_holder.items];
    [self.carousel reloadData];
}

- (void)setCarouselProperty {
    if(self.carousel.type != _holder.type){
        self.carousel.type  = _holder.type;
    }
    if(self.carousel.vertical != _holder.vertical){
        self.carousel.vertical  = _holder.vertical;
    }
    if(self.carousel.centerItemWhenSelected != _holder.centerItemWhenSelected){
        self.carousel.centerItemWhenSelected  = _holder.centerItemWhenSelected;
    }
}

#pragma mark Events

- (UIView *)validateItemView:(NSInteger)index reusingView:(UIView *)view; {
    NSAssert(index<_holder.items.count, @"validateItemView' index must be lower than _holder.items.count");

    STItem * item = _holder.items[index];
    return _holder.blockForItemView(self.carousel, index, view, item);
}

#pragma mark -
#pragma mark iCarousel methods
- (CGFloat)carouselItemWidth:(iCarousel *)carousel; {
    return [_holder itemWidth];
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return [[_holder items] count];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if(_holder.blockForiCarouselOption){
        return [_holder blockForiCarouselOption](carousel, option, value);
    }else{
        return value;
    }
}

- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform; {
    NSAssert(_holder.type==iCarouselTypeCustom, @"type must be 'iCarouselTypeCustom'");
    if(_holder.blockForiCarouselCustomTransfrom){
        return [_holder blockForiCarouselCustomTransfrom](carousel, offset, transform);
    }else{
        return transform;
    }
}


@end