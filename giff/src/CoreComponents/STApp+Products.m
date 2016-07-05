//
// Created by BLACKGENE on 2016. 1. 20..
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STApp+Products.h"
#import "M13OrderedDictionary.h"
#import "NSArray+BlocksKit.h"
#import "NSObject+STUtil.h"
#import "NSObject+STAppProducts.h"
#import "STReachabilityManager.h"
#import <StoreKit/StoreKit.h>
#import <AFNetworking/AFHTTPSessionManager.h>

NSString * const STNotificationAppProductRestoreAllSucceed = @"STNotificationAppProductRestoreAllSucceed";
NSString * const STNotificationAppProductRestoreAllFailed = @"STNotificationAppProductRestoreAllFailed";

NSString * const STNotificationAppProductPurchasingSucceed = @"STNotificationAppProductPurchasingSucceed";
NSString * const STNotificationAppProductPurchasingPending = @"STNotificationAppProductPurchasingPending";
NSString * const STNotificationAppProductAlreadyPurchasedAndCancel = @"STNotificationAppProductAlreadyPurchasedAndCancel";
NSString * const STNotificationAppProductPurchasingFailed = @"STNotificationAppProductPurchasingFailed";

NSString *const STNotificationAppProductKVOTargetKeyPathKey = @"STNotificationAppProductKVOTargetKeyPathKey";
NSString *const STNotificationAppProductKVOValueKey = @"STNotificationAppProductKVOValueKey";

NSString *const STNotificationAppProductIdentificationKey = @"STNotificationAppProductIdentificationKey";
NSString *const STNotificationAppProductTimeoutIntervalKey = @"STNotificationAppProductTimeoutIntervalKey";
NSString *const STNotificationAppProductTimeoutIdKey = @"STNotificationAppProductTimeoutIdKey";

NSString *const STAppProductTimeoutIdToAddPayment = @"STAppProductTimeoutIdToAddPayment";
NSString *const STAppProductTimeoutIdToFetchProduct = @"STAppProductTimeoutIdToFetchProduct";
NSString *const STAppProductTimeoutPolicyWifiKey = @"STAppProductTimeoutPolicyWifiKey";
NSString *const STAppProductTimeoutPolicyWWANKey = @"STAppProductTimeoutPolicyWWANKey";

/*
 * optimized only for None-Consume Products
 */

#pragma mark Common
@implementation NSObject (ProductsNetwork)
+ (NSTimeInterval)timeoutIntervalForTimerId:(NSString *)timerId{
    [[STReachabilityManager sharedInstance] activate];
    NSDictionary * timeoutPolicy = [STApp timoutPolicyByTimeoutId];
    NSAssert(timeoutPolicy, @"timeoutPolicy is must not be empty");
    return [timeoutPolicy[timerId][[STReachabilityManager sharedInstance].isConnectedWifi ? STAppProductTimeoutPolicyWifiKey : STAppProductTimeoutPolicyWWANKey] doubleValue];
}

+ (void)purchasingTimeout:(NSString *)id block:(void (^)(void))block{
    NSTimeInterval interval = [self timeoutIntervalForTimerId:id];
    NSAssert(interval, @"interval is must not be 0. Confirm [STApp timoutPolicyByTimeoutId]");
    if(interval){
        [self st_performOnceAfterDelay:id interval:interval block:block];
    }
}

+ (void)cancelPurchasingTimeout:(NSString *)id{
    [self st_clearPerformOnceAfterDelay:id];
}
@end

@implementation STApp (ProductsInfo)
static NSArray *_appProductIds;
+ (NSArray *)appProductIds {
    return _appProductIds && _appProductIds.count ? _appProductIds : nil;
}

+ (BOOL)canTryRestoreAll {
    if([self canPurchase]){
        for(NSString * productId in [self appProductIds]){
            if(![self isPurchasedProduct:productId]){
                return YES;
            }
        }
    }
    return NO;
}

+ (NSDictionary *)timoutPolicyByTimeoutId {
    return @{
            STAppProductTimeoutIdToAddPayment : @{
                    STAppProductTimeoutPolicyWifiKey: @(60 * 3),
                    STAppProductTimeoutPolicyWWANKey: @(60 * 5)
            },
            STAppProductTimeoutIdToFetchProduct : @{
                    STAppProductTimeoutPolicyWifiKey: @(10),
                    STAppProductTimeoutPolicyWWANKey: @(15)
            }
    };
}
@end

#pragma mark ProductItem

@implementation STProductItem
@end

#import "NSObject+BKAssociatedObjects.h"
#import "NSSet+STUtil.h"

@implementation STProductItem (CatalogContentMetadata)

/*
 * scheme
 *

{
    "version" : "1.0",
    APP_VERSION:{
        LANGUAGE_CODE:{
            PRODUCT_ID: {
                key : value
            }
        }
    }
}

 [ example ]

{
    "version" : "1.0",
    "default":{
        "base":{
            "productId" : {
                "localizedTitle": "Title",
                "images" : "http://foobar.com/image.gif"
            }
        },
        "de-DE":{
            ...
        }
    },
    "1.1":{
        "base":{
            "productId" : {
                "localizedTitle": "Title",
                "localizedDescription": "Description",
                "images" : [
                    "http://foobar.com/image.gif",
                    "http://foobar.com/image1.jpg",
                    "http://foobar.com/image2.jpg"
                ]
            }
        },
        "de-DE":{
            ...
        }
    }
}
 */
#pragma mark Image Urls
- (void)loadMetadata:(NSString *)url refresh:(BOOL)refresh completion:(void (^)(NSDictionary *))completionBlock{
    Weaks

    [[_productMetaDataLoader operationQueue] cancelAllOperations];

#if DEBUG
    refresh = YES;
#endif

    if(completionBlock){
        [self.class loadMetadata:url refresh:refresh success:^(NSURLSessionDataTask *operation, id responseObject) {
            Strongs
            // static instance can be nil.
            if (!Sself) {
                NSAssert(NO, @"self is nil.");
                return;
            }

            //check data
            if(!responseObject){
                oo(@"[!] Not found valid metadata.");
                return;
            }

            //check data type
            if (![responseObject isKindOfClass:NSDictionary.class]) {
                NSAssert(NO, @"responseObject is not json dictionary.");
                return;
            }

            NSDictionary *root = ((NSDictionary *)responseObject);

            //check version
            NSDictionary *versionDataSet = root[[STApp appVersion]];
            if(!versionDataSet && !(versionDataSet = root[@"default"])){
                oo(@"[!] Not found default dataSet.");
                return;
            }

            //check language
            NSDictionary *languageDataSet = nil;
            for(NSString * languageCode in @[[STApp languageCode], [STApp languageCodeExcludingRegion], [STApp baseLanguageCode], [STApp baseLanguageCodeExcludingRegion], @"base"]){
                if(versionDataSet[languageCode] || versionDataSet[[languageCode lowercaseString]]){
                    languageDataSet = versionDataSet[languageCode];
                    break;
                }
            }
            if(!languageDataSet){
                oo(@"[!] Not found dataSet for language.");
                return;
            }

            //check product id
            NSDictionary *productDataSet = languageDataSet[Sself.productIdentifier];
            if (!productDataSet) {
                oo(([NSString stringWithFormat:@"[i] Not found productIdentifier. - %@", Sself.productIdentifier]))
                return;
            }

            [Sself setMetadataAsValuesForKey:productDataSet];

            completionBlock(productDataSet);

        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            oo(@"[!]WARNING : fail to load imageurls");
            completionBlock(nil);

        } parameters:@{
                @"build" : [STApp buildVersion],
                @"force" : refresh ? [@([NSDate date].timeIntervalSince1970) stringValue] : @""
        }];
    }
}

- (void)loadCatalogImages:(BOOL)refresh completion:(void (^)(NSArray *))completionBlock{
    [self loadCatalogImagesFromUrl:[[self class] metadataUrlForProductContents] refresh:refresh completion:completionBlock];
}

- (void)loadCatalogImagesFromUrl:(NSString *)url refresh:(BOOL)refresh completion:(void (^)(NSArray *))completionBlock{
    void(^returnImageUrls)(NSDictionary *) = ^(NSDictionary *data) {
        if(data){
            NSArray * imageUrls = [self.class catalogImageUrlsFromMetadata:data];
            if(imageUrls && imageUrls.count){
                !completionBlock?:completionBlock(imageUrls);
            }
        }
    };

    if(self.metadata){
        returnImageUrls(self.metadata);
    }else{
        [self loadMetadata:url refresh:refresh completion:!completionBlock ? nil : returnImageUrls];
    }
}

#pragma mark Metadata from url
static NSString * _metadataUrlForProductContents;
+ (void)registerMetadataUrlForProductContents:(NSString *)url {
    BlockOnce(^{
        _metadataUrlForProductContents = url;
    });
}

+ (NSString *)metadataUrlForProductContents {
    return _metadataUrlForProductContents;
}

#pragma mark Metadata from dict
static NSDictionary * _localMetadataUrlForProductContents;
+ (void)registerLocalMetadataUrlForProductContents:(NSDictionary *)data {
    _localMetadataUrlForProductContents = data;
}

+ (NSDictionary *)localMetadataForProductContentsBy:(NSString *)productId{
    return _localMetadataUrlForProductContents[productId];
}

+ (NSArray *)catalogImageUrlsFromMetadata:(NSDictionary *)data{
    if(data){
        id imagesURLs = data[@"images"];
        if (!imagesURLs) {
            NSAssert(NO, @"imageurls not found");
            return nil;
        }

        if ([imagesURLs isKindOfClass:NSArray.class]) {
            return imagesURLs;

        } else if ([imagesURLs isKindOfClass:NSString.class]) {
            return @[imagesURLs];

        } else {
            NSAssert(NO, @"wrong imageurls data format. Only supports NSArray, NSString");
        }
    }
    return nil;
}

#pragma metadata values
DEFINE_ASSOCIATOIN_KEY(kMetadata)
- (void)setMetadataAsValuesForKey:(NSDictionary *)metadata{
    //unsetting metadata is not allowed
    if(metadata){
        [self bk_associateValue:metadata withKey:kMetadata];

        //set value only intersected values
        for(NSString * key in [[NSSet setWithArray:[self st_propertyNames]] st_intersectsSet:[NSSet setWithArray:metadata.allKeys]]){
            [self setValue:metadata[key] forKey:key];
        }
    }
}

- (NSDictionary *)metadata {
    return (NSDictionary *)[self bk_associatedValueForKey:kMetadata];
}


#pragma mark common
static AFHTTPSessionManager * _productMetaDataLoader;
+ (AFHTTPSessionManager *)loadMetadata:(NSString *)url refresh:(BOOL)expireCache success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure parameters:(NSDictionary *)parameters{
    if(!_productMetaDataLoader){
        _productMetaDataLoader = [AFHTTPSessionManager manager];
    }
    [[_productMetaDataLoader operationQueue] cancelAllOperations];

    _productMetaDataLoader = [[AFHTTPSessionManager alloc] init];
    _productMetaDataLoader.responseSerializer = [AFJSONResponseSerializer serializer];
    _productMetaDataLoader.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",@"text/javascript",@"text/plain"]];
    if(expireCache){
        _productMetaDataLoader.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    }

    if(success){
        [_productMetaDataLoader GET:url parameters:parameters progress:nil success:success failure:failure];
    }
    return _productMetaDataLoader;
}

+ (void)disposeMetadata {
    [[_productMetaDataLoader operationQueue] cancelAllOperations];
    _productMetaDataLoader = nil;
}
@end

#pragma mark IAP mode
#if ST_IAP //why can't work __has_include(<StoreKit/StoreKit.h>)

#import "RMStore.h"
#import "RMStoreUserDefaultsPersistence.h"
#import "STTimeOperator.h"

/*
 *  STProductItem
 */
@interface SKProduct (LocalizedPrice)
- (NSString *)localizedPrice;
@end

@implementation SKProduct (LocalizedPrice)
- (NSString*)localizedPrice
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    return [numberFormatter stringFromNumber:self.price];
}
@end

@interface STProductItem(Private)
@end

@implementation STProductItem(Private)

#pragma mark make ProductItem
- (instancetype)initWithProduct:(SKProduct *)product {
    self = [super init];
    if (self) {
        //proxy
        _price = [NSDecimalNumber decimalNumberWithDecimal:product.price.decimalValue];
        _priceLocaleIdentifier = product.priceLocale.localeIdentifier;
        _localizedDescription = product.localizedDescription;
        _localizedTitle = product.localizedTitle;
        _localizedPrice = product.localizedPrice;
        _productIdentifier = product.productIdentifier;
        _downloadable = product.downloadable;
        _downloadContentLengths = product.downloadContentLengths?:@[];
        _downloadContentVersion = product.downloadContentVersion?:@"";
        //extended
        _priceCurrenyCodeISO4217 = [product.priceLocale objectForKey:NSLocaleCurrencyCode];
        _priceCurrenySymbol = [product.priceLocale displayNameForKey:NSLocaleCurrencySymbol value:_priceCurrenyCodeISO4217];
        NSParameterAssert(self.productIdentifier);
    }
    return self;
}

+ (instancetype)itemWithProduct:(SKProduct *)product {
    return [[self alloc] initWithProduct:product];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *, id> *)keyedValues {
    NSString * productIdentifier = self.productIdentifier;
    [super setValuesForKeysWithDictionary:keyedValues];
    NSParameterAssert(self.productIdentifier);
    NSAssert(!productIdentifier || [self.productIdentifier isEqualToString:productIdentifier],@"Setting a different productIdentifier is not allowed.");
}

+ (instancetype)itemWithDictionary:(NSDictionary *)dictionary {
    return [[self alloc] initWithDictionary:dictionary];
}

- (NSDictionary *)dictionary {
    return [self dictionaryWithValuesForKeys:[self st_propertyNames]];
}

- (BOOL)isEqualToItem:(STProductItem *)productItem{
    for(NSString * key in [productItem st_propertyNames]){
        if(![[productItem valueForKey:key] isEqualToValue:[self valueForKey:key]]){
            return NO;
        }
    }
    return YES;
}
@end

/*
 * RMStore
 */
NSString* const RMStoreTransactionsUserDefaultsKey;

@interface RMStore()
- (void)addProduct:(SKProduct*)product;
@end

/*
 * RMStoreUserDefaultsPersistence
 */
@interface RMStoreUserDefaultsPersistence()
- (void)setTransactions:(NSArray *)transactions forProductIdentifier:(NSString *)productIdentifier;
- (NSUserDefaults *)userDefaults;
@end

/*
 * Extends : RMStoreUserDefaultsPersistence
 */
@interface STRMStoreUserDefaultsPersistence : RMStoreUserDefaultsPersistence
@property (nonatomic, readonly) NSSet *purchasedProductIdentifiersToReadFast;
@end

@implementation STRMStoreUserDefaultsPersistence

- (instancetype)init {
    self = [super init];
    if (self) {
        [self updatePurchasedProductIdentifiers];
    }
    return self;
}

- (void)updatePurchasedProductIdentifiers{
    _purchasedProductIdentifiersToReadFast = self.purchasedProductIdentifiers;
}

- (void)removeTransactions {
    [super removeTransactions];
    [self updatePurchasedProductIdentifiers];
}

- (void)setTransactions:(NSArray *)transactions forProductIdentifier:(NSString *)productIdentifier {
    [super setTransactions:transactions forProductIdentifier:productIdentifier];
    [self updatePurchasedProductIdentifiers];
}

- (void)removeTransactionsForProductIdentifiers:(NSArray *)productIdentifiers{
    NSUserDefaults *defaults = [self userDefaults];
    NSDictionary *purchases = [defaults objectForKey:RMStoreTransactionsUserDefaultsKey] ? : @{};
    NSMutableDictionary *updatedPurchases = [NSMutableDictionary dictionaryWithDictionary:purchases];
    [updatedPurchases removeObjectsForKeys:productIdentifiers];
    [defaults setObject:updatedPurchases forKey:RMStoreTransactionsUserDefaultsKey];
    [defaults synchronize];
}
@end

/*
 * Base implementation
 */
@implementation STApp (Products)

#pragma mark Persistence
+ (STRMStoreUserDefaultsPersistence *)_persistor{
    static STRMStoreUserDefaultsPersistence * _persistor;
    BlockOnce(^{
        [RMStore defaultStore].transactionPersistor = _persistor = [[STRMStoreUserDefaultsPersistence alloc] init];
    })
    return _persistor;
}

+ (BOOL)canPurchase{
    return [RMStore canMakePayments];
}

//slow / verbose
+ (BOOL)isPurchasedProductWithTransactions:(NSString*)productId;{
    return [self._persistor isPurchasedProductOfIdentifier:productId];
}

//fast / check only id.
+ (BOOL)isPurchasedProduct:(NSString*)productId;{
    return productId ? [[self._persistor purchasedProductIdentifiersToReadFast] containsObject:productId] : YES;
}

+ (BOOL)isPurchasedKeyValueProduct:(id)target forKeyPath:(NSString *)keypath;{
    return [self isPurchasedProduct:[target productIdForKeyPath:keypath]];
}

+ (BOOL)needsPurchaseKeyValueProduct:(id)target forKeyPath:(NSString *)keypath;{
    NSString * productId = [target productIdForKeyPath:keypath];
    return productId && ![self isPurchasedProduct:productId];
}

+ (BOOL)isPurchasedOrActivatedKeyValueProduct:(id)target forKeyPath:(NSString *)keypath {
    return [self isPurchasedKeyValueProduct:target forKeyPath:keypath] || [target productActivationForKeyPath:keypath];
}

#pragma mark Products
+ (void)loadProducts:(NSArray *)productsIds {
    [self loadProducts:productsIds lazyLoadWhenRequest:YES performAfterRestore:NO];
}

+ (void)loadProducts:(NSArray *)productsIds lazyLoadWhenRequest:(BOOL)lazy performAfterRestore:(BOOL)restore {
    if(restore){
        Weaks
        [self restoreAllProductIfNeeded:^(NSArray *transactions) {
            [Wself _loadProducts:productsIds lazyLoadWhenRequest:lazy];
        }                       failure:nil];

    }else{
        [self _loadProducts:productsIds lazyLoadWhenRequest:lazy];
    }
}

+ (void)_migrateProductsIfNeeded:(NSArray *)productsIds{
    NSParameterAssert(productsIds);
    NSMutableSet *newProducts = (NSMutableSet *) [[NSSet setWithArray:productsIds] mutableCopy];
    NSMutableSet * purchased = (NSMutableSet *) [[self._persistor purchasedProductIdentifiers] mutableCopy];

    //deprecated product ids
    [purchased minusSet:newProducts];
    NSSet *deprecatedProductsIds = purchased;

    if(deprecatedProductsIds.count){
        NSLog(@"[!] WARNING: Deprecated following keys : %@", deprecatedProductsIds.allObjects);
        [self._persistor removeTransactionsForProductIdentifiers:deprecatedProductsIds.allObjects];
        for(NSString * id in deprecatedProductsIds.allObjects){
            [self _removeProductItem:id];
        }
    }
}

+ (NSSet *)_targetProductIdsToRequest:(NSArray *)neededProductsIds {
    NSParameterAssert(neededProductsIds);
    NSMutableSet * requested = (NSMutableSet *) [[NSSet setWithArray:neededProductsIds] mutableCopy];
    NSMutableSet * purchased = (NSMutableSet *) [[self._persistor purchasedProductIdentifiers] mutableCopy];

    //exclude already purchased items.
    [requested minusSet:purchased];

    return requested;
}

+ (void)_loadProducts:(NSArray *)productsIds lazyLoadWhenRequest:(BOOL)lazy {
    _appProductIds = productsIds;

    [self _migrateProductsIfNeeded:productsIds];

    if(!lazy){
        [self _getProductIfNeeded:nil fetchedBlock:nil];
    }
}

+ (SKProduct *)_getProductIfNeeded:(NSString *)productId fetchedBlock:(void (^)(SKProduct *succeedProduct))block{
    return [self _getProductIfNeeded:productId forceReload:NO fetchedBlock:block];
}

+ (SKProduct *)_getProductIfNeeded:(NSString *)productId forceReload:(BOOL)reload fetchedBlock:(void (^)(SKProduct *succeedProduct))block{
    Weaks
    SKProduct * product = nil;

    //phase 1 : RMStore
    if(!reload){
        product = [[RMStore defaultStore] productForIdentifier:productId];
        if(product){
            NSAssert([self _productItemDictForId:productId], @"productItem not be nil");
            !block?:block(product);
            return product;
        }
    }

    //phase 2 : request to remote
    NSSet * targetProductIds = [self _targetProductIdsToRequest:!productId || [_appProductIds containsObject:productId] ? _appProductIds : [_appProductIds arrayByAddingObjectsFromArray:@[productId]]];
    //TODO: temporary holding (11 MAR 2016)
//    [self purchasingTimeout:STAppProductTimeoutIdToFetchProduct block:^{
//        !block ?: block(nil);
//    }];

    [[RMStore defaultStore] requestProducts:targetProductIds success:^(NSArray *_products, NSArray *invalidProductIdentifiers) {
        //cancel timeout
        [Wself cancelPurchasingTimeout:STAppProductTimeoutIdToFetchProduct];

        NSArray * availableProducts = [_products bk_reject:^BOOL(SKProduct * obj) {
            return [invalidProductIdentifiers containsObject:obj.productIdentifier];
        }];
        //NSArray * availableProducts = [[NSSet setWithArray:_products] st_minusSet:[NSSet setWithArray:invalidProductIdentifiers]].allObjects;

        SKProduct *targetProduct;
        //persist products
        for(SKProduct *newProduct in availableProducts){
            if([newProduct.productIdentifier isEqualToString:productId]){
                targetProduct = newProduct;
            }

            if(reload || ![Wself _productItemDictForId:newProduct.productIdentifier]){
                [Wself _saveProductItem:newProduct synchronize:[availableProducts indexOfObject:newProduct] + 1 == availableProducts.count];
            }
        }

        //result
        !block?:block(targetProduct);

    } failure:^(NSError *error) {
        //cancel timeout
        [Wself cancelPurchasingTimeout:STAppProductTimeoutIdToFetchProduct];

        !block?:block(nil);
    }];

    return nil;
}

#pragma mark SKProductItem
+ (STProductItem * )getProductItemIfNeeded:(NSString *)productId fetchedBlock:(void (^)(STProductItem *productItem))block{
    return [self getProductItemIfNeeded:productId reload:NO fetchedBlock:block];
}

+ (STProductItem *)getProductItemIfNeeded:(NSString *)productId reload:(BOOL)reload fetchedBlock:(void (^)(STProductItem *productItem))block {
    NSParameterAssert(productId);
    if(!productId){
        !block?:block(nil);
        return nil;
    }

    if(!reload){
        STProductItem * item = [self _productInfoItemForId:productId];
        if(item){
            block(item);
            return item;
        }
    }

    NSAssert(block, @"You already performed async fetch. But not found preloaded ProductItem. It is something wrong. Confirm this.");
    Weaks
    [self _getProductIfNeeded:productId fetchedBlock:^(SKProduct *succeedProduct) {
        //TODO: test reload?
        !block?:block(succeedProduct ? [Wself _saveProductItem:succeedProduct synchronize:YES] : nil);
    }];

    return nil;
}

NSString *const STAppProductsInfoUserDefaultsKey = @"STAppProductsInfoUserDefaultsKey";
+ (void)_removeAllProductItems
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:STAppProductsInfoUserDefaultsKey];
    [defaults synchronize];
}

+ (NSMutableDictionary *)_productItemsDict {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:STAppProductsInfoUserDefaultsKey] mutableCopy]?: [@{} mutableCopy];
}

+ (NSDictionary *)_productItemDictForId:(NSString *)productId{
    return [self _productItemsDict][productId];
}

+ (STProductItem *)_productInfoItemForId:(NSString *)productId{
    NSDictionary * infoDict = [self _productItemDictForId:productId];
    if(infoDict){
        STProductItem * productItem = [STProductItem itemWithDictionary:infoDict];
        NSAssert([productId isEqualToString:productItem.productIdentifier],@"given productId must be same as productItem.productIdentifier");
        return productItem;
    }
    return nil;
}

+ (void)_removeProductItem:(NSString *)productId{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *productsDict = [self _productItemsDict];
    [productsDict removeObjectForKey:productId];
    [defaults setObject:productsDict forKey:STAppProductsInfoUserDefaultsKey];
    [defaults synchronize];
}

+ (STProductItem *)_saveProductItem:(SKProduct *)product synchronize:(BOOL)synchronize{
    NSParameterAssert(product);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *productsDict = [self _productItemsDict];

    STProductItem * productItem = [STProductItem itemWithProduct:product];
    productsDict[product.productIdentifier] = [productItem dictionary];
    [defaults setObject:productsDict forKey:STAppProductsInfoUserDefaultsKey];

    if(synchronize){
        [defaults synchronize];
    }
    return productItem;
}

#pragma mark Dispose
+ (void)disposeAllTransactions {
    [[self _persistor] removeTransactions];
}

#pragma Notifications
+ (void)_postNotificationForPurchasingProcess:(NSString *)productId name:(NSString *)name{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:[self setObjectToPostNotification:@{STNotificationAppProductIdentificationKey : productId}]];
}

+ (NSDictionary *)setObjectToPostNotification:(NSDictionary *) dict{
    static NSDictionary * objectToPostNotification;
    if(!dict){
        return objectToPostNotification;
    }

    if(objectToPostNotification){
        NSMutableDictionary * _objectToPostNotification = [NSMutableDictionary dictionaryWithDictionary:objectToPostNotification];
        [_objectToPostNotification addEntriesFromDictionary:dict];
        objectToPostNotification = _objectToPostNotification;
    }else{
        objectToPostNotification = dict;
    }

    return objectToPostNotification;
}

#pragma mark Restoring
+ (void)restoreAllProductIfNeeded:(void (^)(NSArray *transactions))successBlock failure:(void (^)(NSError *error))failureBlock{
    Weaks
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions){
        NSArray * restoredTransactions = [transactions bk_select:^BOOL(SKPaymentTransaction * transaction) {
            if(SKPaymentTransactionStateRestored == transaction.transactionState){
                [[Wself _persistor] persistTransaction:transaction];
                return YES;
            }
            return NO;
        }];

        if(restoredTransactions.count){
            !successBlock?:successBlock(restoredTransactions);
            [[NSNotificationCenter defaultCenter] postNotificationName:STNotificationAppProductRestoreAllSucceed object:nil];
        }else{
            !failureBlock?:failureBlock(nil);
            [[NSNotificationCenter defaultCenter] postNotificationName:STNotificationAppProductRestoreAllFailed object:nil];
        }
    } failure:^(NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:STNotificationAppProductRestoreAllFailed object:nil];
        !failureBlock?:failureBlock(error);
    }];
}

#pragma Buying
+ (BOOL)checkOrBuyProductIfNeeded:(NSString *)productId
                          success:(void (^)(SKPaymentTransaction *transaction))successBlock
                          failure:(void (^)(SKPaymentTransaction *transaction, NSError *error))failureBlock
                        existence:(void(^)(void))alreadyPurchasedBlock
                         buyerUID:(NSString *)buyerUID {

    if([self isPurchasedProduct:productId]){
        /*
         * cancel
         */
        !alreadyPurchasedBlock ?: alreadyPurchasedBlock();
        [self _postNotificationForPurchasingProcess:productId name:STNotificationAppProductAlreadyPurchasedAndCancel];
        return YES;
    }

    /*
     * pending
     */
    [self _postNotificationForPurchasingProcess:productId name:STNotificationAppProductPurchasingPending];

    Weaks
    //TODO: temporary holding (11 MAR 2016)
//    [self purchasingTimeout:STAppProductTimeoutIdToAddPayment block:^{
//        !failureBlock ?: failureBlock(nil, nil);
//        //time out add payment
//        [STApp setObjectToPostNotification:@{
//                STNotificationAppProductTimeoutIdKey: STAppProductTimeoutIdToAddPayment,
//                STNotificationAppProductTimeoutIntervalKey: [@([self timeoutIntervalForTimerId:STAppProductTimeoutIdToAddPayment]) stringValue]
//        }];
//        [Wself _postNotificationForPurchasingProcess:productId name:STNotificationAppProductPurchasingFailed];
//    }];

    [self _getProductIfNeeded:productId fetchedBlock:^(SKProduct *succeedProduct) {
        if (succeedProduct) {
            NSAssert([succeedProduct.productIdentifier isEqualToString:productId], @"succeedProduct.productIdentifier must equal to given productId.");

            [[RMStore defaultStore] addPayment:succeedProduct.productIdentifier success:^(SKPaymentTransaction *transaction) {
                //clear timeout
                [Wself cancelPurchasingTimeout:STAppProductTimeoutIdToAddPayment];

                //response for transaction

                if(transaction.transactionState == SKPaymentTransactionStatePurchased || transaction.transactionState == SKPaymentTransactionStateRestored){
                    /*
                     * success
                     */
                    !successBlock?:successBlock(transaction);
                    [Wself _postNotificationForPurchasingProcess:productId name:STNotificationAppProductPurchasingSucceed];

                }else{
                    !failureBlock?:failureBlock(transaction, nil);
                    [Wself _postNotificationForPurchasingProcess:productId name:STNotificationAppProductPurchasingFailed];
                }

            } failure:^(SKPaymentTransaction *transaction, NSError *error) {
                [Wself cancelPurchasingTimeout:STAppProductTimeoutIdToAddPayment];

                !failureBlock?:failureBlock(transaction, error);
                [Wself _postNotificationForPurchasingProcess:productId name:STNotificationAppProductPurchasingFailed];
            }];

        } else {
            [Wself cancelPurchasingTimeout:STAppProductTimeoutIdToAddPayment];

            !failureBlock ?: failureBlock(nil, nil);
            [Wself _postNotificationForPurchasingProcess:productId name:STNotificationAppProductPurchasingFailed];
        }
    }];

    return NO;
}

+ (BOOL)checkOrBuyProductIfNeeded:(NSString *)productId
                          success:(void (^)(SKPaymentTransaction *transaction))successBlock
                          failure:(void (^)(SKPaymentTransaction *transaction, NSError *error))failureBlock
                        existence:(void(^)(void))alreadyPurchasedBlock {
    return [self checkOrBuyProductIfNeeded:productId success:successBlock failure:failureBlock existence:alreadyPurchasedBlock buyerUID:nil];
}

#pragma mark Utils - KVO
static BOOL _beganContextSetValuesToPurchase;

+ (void)beginSetValuesContextForTransactionsIfNeeded {
    _beganContextSetValuesToPurchase = YES;
}

+ (void)endSetValuesContextForTransactions {
    _beganContextSetValuesToPurchase = NO;
}

+ (BOOL)isBeganSetValuesContextToPurchase {
    return _beganContextSetValuesToPurchase;
}

+ (BOOL)setValue:(id)target value:(id)value forKeyPath:(NSString *)keyPath forProductId:(NSString *)id defaultValue:(id)defaultValue{
    return [self setValue:target value:value forKeyPath:keyPath forProductId:id defaultValue:defaultValue valuesForProduct:nil];
}

+ (BOOL)setValue:(id)target value:(id)value forKeyPath:(NSString *)keyPath forProductId:(NSString *)id defaultValue:(id)defaultValue valuesForProduct:(NSSet *)valuesForProduct {
    return [self setValue:target value:value forKeyPath:keyPath forProductId:id defaultValue:defaultValue valuesForProduct:nil kVOProxyTarget:nil];
}

+ (BOOL)setValue:(id)target value:(id)value forKeyPath:(NSString *)keyPath forProductId:(NSString *)id defaultValue:(id)defaultValue valuesForProduct:(NSSet *)valuesForProduct kVOProxyTarget:(id)kvoTarget;{
    NSParameterAssert(target);
    NSParameterAssert(defaultValue);
    NSParameterAssert(keyPath);
    NSParameterAssert(id);

    BOOL purchased = [self isPurchasedProduct:id];

    BOOL needsNewPurchaing = _beganContextSetValuesToPurchase
            && !purchased
            && (valuesForProduct.count ? [valuesForProduct containsObject:value] : YES);

    BOOL notifiyValueChanged = _beganContextSetValuesToPurchase || ![[target valueForKeyPath:keyPath] isEqual:value];
    !notifiyValueChanged ?:[kvoTarget willChangeValueForKey:keyPath];

    if(needsNewPurchaing){
        [self setObjectToPostNotification:@{
                STNotificationAppProductKVOTargetKeyPathKey : keyPath,
                STNotificationAppProductKVOValueKey : value
        }];

        [self checkOrBuyProductIfNeeded:id success:^(SKPaymentTransaction *transaction) {
            [target setValue:value forKeyPath:keyPath];
            !notifiyValueChanged ?: [kvoTarget didChangeValueForKey:keyPath];

        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
            [target setValue:defaultValue forKeyPath:keyPath];
            !notifiyValueChanged ?: [kvoTarget didChangeValueForKey:keyPath];

        } existence:nil];

    }else{
        [target setValue:purchased ? value : defaultValue forKeyPath:keyPath];
        !notifiyValueChanged ?:[kvoTarget didChangeValueForKey:keyPath];
    }

    return purchased;
}

#pragma mark Utils - KVO
+ (BOOL)selectByValue:(NSString *)productId
        selectedValue:(id)selectedValue
         defaultValue:(id)defaultValue
              compare:(BOOL (^)(id selectedValue, id defaultValue))compareBlock
           completion:(void (^)(id resultValue, BOOL success))block{

    return [self selectByValue:productId selectedValue:selectedValue defaultValue:defaultValue compare:compareBlock completion:block delayAfterPurchase:.5];
}

+ (BOOL)selectByValue:(NSString *)productId
        selectedValue:(id)selectedValue
         defaultValue:(id)defaultValue
              compare:(BOOL (^)(id selectedValue, id defaultValue))compareBlock
           completion:(void (^)(id resultValue, BOOL success))block
   delayAfterPurchase:(NSTimeInterval)delayAfterPurchase {

    NSParameterAssert(selectedValue);
    Weaks
    if(productId){
        NSAssert(compareBlock, @"If you want to select with purchaging product by value, must set a block to compare them.");
    }

#define STAPP_Products_selectByValue_success !block?:block(selectedValue, YES);
#define STAPP_Products_selectByValue_fail !block?:block(defaultValue, NO);

    BOOL productAvailable = YES;
    if(productId && compareBlock && compareBlock(selectedValue, defaultValue)){
        //purchasing target
        productAvailable = [self checkOrBuyProductIfNeeded:productId success:^(SKPaymentTransaction *transaction) {
            [Wself st_performOnceAfterDelay:delayAfterPurchase block:^{
                STAPP_Products_selectByValue_success
            }];

        } failure:^(SKPaymentTransaction *transaction, NSError *error) {
            [Wself st_performOnceAfterDelay:delayAfterPurchase block:^{
                STAPP_Products_selectByValue_fail
            }];
        } existence:^{
            STAPP_Products_selectByValue_success
        }];

    }else{
        //not needed to purchase
        STAPP_Products_selectByValue_success
    }

    return productAvailable;
}
@end

#else

NSString * const AssertionMessageNotAllowingAsyncBlocks = @"Not allowed all blocks and asynchronized design to get state of product in None-IAP mode. Use immediately returned value instead";

@implementation STApp (Products)

+ (BOOL)canPurchase{
    return NO;
}

+ (BOOL)isPurchasedProductWithTransactions:(NSString *)productId {
    return YES;
}

+ (BOOL)isPurchasedProduct:(NSString *)productId {
    return YES;
}

+ (BOOL)isPurchasedKeyValueProduct:(id)target forKeyPath:(NSString *)keypath3 {
    return YES;
}

+ (BOOL)needsPurchaseKeyValueProduct:(id)target forKeyPath:(NSString *)keypath3 {
    return NO;
}

+ (void)loadProducts:(NSArray *)productsIds {

}

+ (void)loadProducts:(NSArray *)productsIds lazyLoadWhenRequest:(BOOL)lazy performAfterRestore:(BOOL)restore {

}

+ (STProductItem *)getProductItemIfNeeded:(NSString *)productId fetchedBlock:(void (^)(STProductItem *productItem))block{
    return [self getProductItemIfNeeded:productId reload:NO fetchedBlock:block];
}

+ (STProductItem *)getProductItemIfNeeded:(NSString *)productId reload:(BOOL)reload fetchedBlock:(void (^)(STProductItem *productItem))block{
    !block?:block(nil);
    return nil;
}

+ (void)disposeAllTransactions {

}

+ (void)restoreAllProductIfNeeded:(void (^)(NSArray *transactions))successBlock failure:(void (^)(NSError *error))failureBlock {
    NSAssert(!successBlock, AssertionMessageNotAllowingAsyncBlocks);
    NSAssert(!failureBlock, AssertionMessageNotAllowingAsyncBlocks);
}

+ (void)restoreProductIfNeeded:(void (^)(NSArray *transactions))successBlock failure:(void (^)(NSError *error))failureBlock {
    NSAssert(!successBlock, AssertionMessageNotAllowingAsyncBlocks);
    NSAssert(!failureBlock, AssertionMessageNotAllowingAsyncBlocks);
}

+ (BOOL)checkOrBuyProductIfNeeded:(NSString *)productId success:(void (^)(SKPaymentTransaction *transaction))successBlock failure:(void (^)(SKPaymentTransaction *transaction, NSError *error))failureBlock existence:(void (^)(void))alreadyPurchasedBlock buyerUID:(NSString *)buyerUID{
    NSAssert(!successBlock, AssertionMessageNotAllowingAsyncBlocks);
    NSAssert(!failureBlock, AssertionMessageNotAllowingAsyncBlocks);
    NSAssert(!alreadyPurchasedBlock, AssertionMessageNotAllowingAsyncBlocks);
    return YES;
}

+ (BOOL)checkOrBuyProductIfNeeded:(NSString *)productId
                          success:(void (^)(SKPaymentTransaction *transaction))successBlock
                          failure:(void (^)(SKPaymentTransaction *transaction, NSError *error))failureBlock
                        existence:(void(^)(void))alreadyPurchasedBlock {
    return [self checkOrBuyProductIfNeeded:productId success:successBlock failure:failureBlock existence:alreadyPurchasedBlock buyerUID:nil];
}

+ (BOOL)isPurchasedOrActivatedKeyValueProduct:(id)target forKeyPath:(NSString *)keypath3 {
    return YES;
}

+ (void)beginSetValuesContextForTransactionsIfNeeded {

}

+ (void)endSetValuesContextForTransactions {

}

+ (BOOL)isBeganSetValuesContextToPurchase {
    return NO;
}

+ (BOOL)setValue:(id)target value:(id)value forKeyPath:(NSString *)keyPath forProductId:(NSString *)id1 defaultValue:(id)defaultValue {
    return YES;
}

+ (BOOL)setValue:(id)target value:(id)value forKeyPath:(NSString *)keyPath forProductId:(NSString *)id1 defaultValue:(id)defaultValue valuesForProduct:(NSSet *)valuesForProduct {
    return YES;
}

+ (BOOL)setValue:(id)target value:(id)value forKeyPath:(NSString *)keyPath forProductId:(NSString *)id1 defaultValue:(id)defaultValue valuesForProduct:(NSSet *)valuesForProduct kVOProxyTarget:(id)kvoTarget {
    return YES;
}

+ (BOOL)selectByValue:(NSString *)productId selectedValue:(id)selectedValue defaultValue:(id)defaultValue compare:(BOOL (^)(id selectedValue, id defaultValue))compareBlock completion:(void (^)(id resultValue, BOOL success))block {
    return [self selectByValue:productId selectedValue:selectedValue defaultValue:defaultValue compare:compareBlock completion:block delayAfterPurchase:0];
}

+ (BOOL)selectByValue:(NSString *)productId selectedValue:(id)selectedValue defaultValue:(id)defaultValue compare:(BOOL (^)(id selectedValue, id defaultValue))compareBlock completion:(void (^)(id resultValue, BOOL success))block delayAfterPurchase:(NSTimeInterval)delayAfterPurchase {
    !compareBlock?:compareBlock(selectedValue,defaultValue);
    !block?:block(selectedValue, YES);
    return YES;
}
@end

#endif

