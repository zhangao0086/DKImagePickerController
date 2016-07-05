//
// Created by BLACKGENE on 2016. 1. 20..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"
#import "STApp.h"

@class SKPaymentTransaction;

extern NSString * const STNotificationAppProductRestoreAllSucceed;
extern NSString * const STNotificationAppProductRestoreAllFailed;

extern NSString * const STNotificationAppProductPurchasingSucceed;
extern NSString * const STNotificationAppProductPurchasingPending;
extern NSString * const STNotificationAppProductPurchasingFailed;

extern NSString *const STNotificationAppProductKVOTargetKeyPathKey;
extern NSString *const STNotificationAppProductIdentificationKey;
extern NSString *const STNotificationAppProductKVOValueKey;

extern NSString *const STNotificationAppProductIdentificationKey;
extern NSString *const STNotificationAppProductTimeoutIntervalKey;
extern NSString *const STNotificationAppProductTimeoutIdKey;

extern NSString *const STAppProductTimeoutIdToAddPayment;
extern NSString *const STAppProductTimeoutIdToFetchProduct;
extern NSString *const STAppProductTimeoutPolicyWifiKey;
extern NSString *const STAppProductTimeoutPolicyWWANKey;

#pragma mark ProductItem
@interface STProductItem : STItem
//proxy
@property(nonatomic, readonly) NSDecimalNumber *price;
@property(nonatomic, readonly) NSString *localizedDescription;
@property(nonatomic, readonly) NSString *localizedTitle;
@property(nonatomic, readonly) NSString *localizedPrice;
@property(nonatomic, readonly) NSString *productIdentifier;
@property(nonatomic, readonly, getter=isDownloadable) BOOL downloadable;
@property(nonnull, nonatomic, readonly) NSArray<NSNumber *> *downloadContentLengths;
@property(nonnull, nonatomic, readonly) NSString *downloadContentVersion;
//extended
@property(nonatomic, readonly) NSString *priceLocaleIdentifier;
@property(nonatomic, readonly) NSString *priceCurrenyCodeISO4217;
@property(nonatomic, readonly) NSString *priceCurrenySymbol;
@end

#pragma mark ProductItem - CatalogContentMetadata
@interface STProductItem (CatalogContentMetadata)
+ (void)registerMetadataUrlForProductContents:(NSString *)url;

+ (NSString *)metadataUrlForProductContents;

+ (void)registerLocalMetadataUrlForProductContents:(NSDictionary *)data;

+ (NSDictionary *)localMetadataForProductContentsBy:(NSString *)productId;

+ (NSArray *)catalogImageUrlsFromMetadata:(NSDictionary *)data;

- (void)loadMetadata:(NSString *)url refresh:(BOOL)refresh completion:(void (^)(NSDictionary *))completionBlock;

- (void)loadCatalogImages:(BOOL)refresh completion:(void (^)(NSArray *))completionBlock;

- (void)loadCatalogImagesFromUrl:(NSString *)url refresh:(BOOL)refresh completion:(void (^)(NSArray *))completionBlock;

- (void)setMetadataAsValuesForKey:(NSDictionary *)metadata;

- (NSDictionary *)metadata;
@end

#pragma mark ProductsInfo
@interface STApp (ProductsInfo)
+ (NSArray *)appProductIds;

+ (BOOL)canTryRestoreAll;

+ (NSDictionary *)timoutPolicyByTimeoutId;
@end

#pragma mark STApp - Products
@interface STApp (Products)

+ (BOOL)canPurchase;

+ (BOOL)isPurchasedProductWithTransactions:(NSString *)productId;

+ (BOOL)isPurchasedProduct:(NSString *)productId;

+ (BOOL)isPurchasedKeyValueProduct:(id)target forKeyPath:(NSString *)keypath3;

+ (BOOL)needsPurchaseKeyValueProduct:(id)target forKeyPath:(NSString *)keypath3;

+ (void)loadProducts:(NSArray *)productsIds;

+ (void)loadProducts:(NSArray *)productsIds lazyLoadWhenRequest:(BOOL)lazy performAfterRestore:(BOOL)restore;

+ (void)disposeAllTransactions;

+ (void)restoreAllProductIfNeeded:(void (^)(NSArray *transactions))successBlock failure:(void (^)(NSError *error))failureBlock;

+ (STProductItem *)getProductItemIfNeeded:(NSString *)productId fetchedBlock:(void (^)(STProductItem *productItem))block;

+ (STProductItem *)getProductItemIfNeeded:(NSString *)productId reload:(BOOL)reload fetchedBlock:(void (^)(STProductItem *productItem))block;

+ (BOOL)checkOrBuyProductIfNeeded:(NSString *)productId
                          success:(void (^)(SKPaymentTransaction *transaction))successBlock
                          failure:(void (^)(SKPaymentTransaction *transaction, NSError *error))failureBlock
                        existence:(void (^)(void))alreadyPurchasedBlock
                         buyerUID:(NSString *)buyerUID;

+ (BOOL)checkOrBuyProductIfNeeded:(NSString *)productId
                          success:(void (^)(SKPaymentTransaction *transaction))successBlock
                          failure:(void (^)(SKPaymentTransaction *transaction, NSError *error))failureBlock
                        existence:(void (^)(void))alreadyPurchasedBlock;

+ (BOOL)isPurchasedOrActivatedKeyValueProduct:(id)target forKeyPath:(NSString *)keypath;

+ (void)beginSetValuesContextForTransactionsIfNeeded;

+ (void)endSetValuesContextForTransactions;

+ (BOOL)isBeganSetValuesContextToPurchase;

+ (BOOL)setValue:(id)target value:(id)value forKeyPath:(NSString *)keyPath forProductId:(NSString *)id1 defaultValue:(id)defaultValue;

+ (BOOL)setValue:(id)target value:(id)value forKeyPath:(NSString *)keyPath forProductId:(NSString *)id1 defaultValue:(id)defaultValue valuesForProduct:(NSSet *)valuesForProduct;

+ (BOOL)setValue:(id)target value:(id)value forKeyPath:(NSString *)keyPath forProductId:(NSString *)id1 defaultValue:(id)defaultValue valuesForProduct:(NSSet *)valuesForProduct kVOProxyTarget:(id)kvoTarget;

+ (BOOL)selectByValue:(NSString *)productId selectedValue:(id)selectedValue defaultValue:(id)defaultValue compare:(BOOL (^)(id selectedValue, id defaultValue))compareBlock completion:(void (^)(id resultValue, BOOL success))block;

+ (BOOL)selectByValue:(NSString *)productId selectedValue:(id)selectedValue defaultValue:(id)defaultValue compare:(BOOL (^)(id selectedValue, id defaultValue))compareBlock completion:(void (^)(id resultValue, BOOL success))block delayAfterPurchase:(NSTimeInterval)delayAfterPurchase;
@end