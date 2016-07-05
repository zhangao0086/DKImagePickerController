//
// Created by BLACKGENE on 2014. 9. 11..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCarouselController.h"

@class STCarouselHolder;

@interface STCarouselHolderController : STCarouselController

@property (nonatomic, readwrite) STCarouselHolder *holder;

- (instancetype)initWithCarousel:(iCarousel *)carousel withHolder:(STCarouselHolder *)holder;

- (void)reloadItems;

@end