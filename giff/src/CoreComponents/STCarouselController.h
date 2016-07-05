//
// Created by BLACKGENE on 2014. 9. 30..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iCarousel.h"

@class STFilterPresenterItemView;
@class STPhotoItem;
@class STFilterItem;

@interface STCarouselController : NSObject <iCarouselDataSource, iCarouselDelegate>{
@protected
    iCarousel *_carousel;
}

@property (nonatomic, readonly) NSMutableArray * items;
@property(nonatomic, readonly) NSUInteger scrolledIndex;
@property(nullable, nonatomic, readwrite) iCarousel * carousel;

@property (copy) UIView * (^blockForItemView)(NSInteger index, UIView * view);
@property (copy) CGFloat (^blockForiCarouselOption)(iCarouselOption option, CGFloat value);
@property (nonatomic, assign) CGFloat itemWidth;

- (instancetype)initWithCarousel:(iCarousel *)carousel;

- (void)initItems:(NSMutableArray *)items;

- (void)delegateSelf;

- (UIView *)validateItemView:(NSInteger)index reusingView:(UIView *)view;

- (void)whenDidEndScroll:(void (^)(NSInteger))block;

- (void)whenDidSelected:(void (^)(NSInteger))block;

- (void)whenChangedScrolledIndex:(void (^)(NSInteger))block;
@end