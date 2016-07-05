//
// Created by BLACKGENE on 2016. 2. 2..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STProductItem;
@class M13OrderedDictionary;

@interface STProductCatalogContentView : STUIView
@property (nonatomic, readonly) UIView *iconImageViewContainer;

- (void)setProductItem:(STProductItem *)productItem;

- (void)setProductIconImages:(M13OrderedDictionary *)imageResources;
@end