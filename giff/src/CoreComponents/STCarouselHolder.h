//
// Created by BLACKGENE on 2014. 9. 18..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iCarousel.h"

@class STItem;
@class iCarousel;

@interface STCarouselHolder : NSObject
@property (nonatomic, readonly) NSMutableArray * items;
@property (nonatomic, readwrite) CGFloat itemWidth;
@property (nonatomic, readwrite) iCarouselType type;
@property (nonatomic, readwrite) BOOL vertical;
@property (nonatomic, readwrite) BOOL centerItemWhenSelected;

@property (copy) UIView * (^blockForItemView)(iCarousel * carousel, NSInteger index, UIView * view, id item);
@property (copy) CGFloat (^blockForiCarouselOption)(iCarousel * carousel, iCarouselOption option, CGFloat defaultValue);
@property (copy) CATransform3D (^blockForiCarouselCustomTransfrom)(iCarousel * carousel, CGFloat offset, CATransform3D baseTransform);

@end
