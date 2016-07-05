//
// Created by BLACKGENE on 2016. 1. 29..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STStandardButton;
@class STProductItem;
@class STProductCatalogContentView;
@class M13OrderedDictionary;

@interface STProductCatalogView : STUIView

@property (nonatomic, readonly) STProductItem *productItem;
@property (nonatomic, readonly) M13OrderedDictionary *productIconImages;
@property (nonatomic, readonly) STStandardButton *closeButton;
@property (nonatomic, readonly) STStandardButton *purchaseButton;
@property (nonatomic, readonly) STStandardButton *restoreButton;
@property (nonatomic, readonly) STProductCatalogContentView *contentView;

+ (void)openWith:(STStandardButton *)targetItemButton
       productId:(NSString *)productId
      iconImages:(M13OrderedDictionary *)images
        willOpen:(void (^)(STProductCatalogView *, STProductItem *))willOpenBlock
         didOpen:(void (^)(STProductCatalogView *, STProductItem *))didOpenBlock
           tried:(void (^)(void))tried
       purchased:(void (^)(NSString *purchasedProductId))purchasedBlock
          failed:(void (^)(NSString *failedProductId))failedBlock
       willClose:(void (^)(BOOL))willCloseBlock
        didClose:(void (^)(BOOL))closedBlock;
@end