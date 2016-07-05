//
// Created by BLACKGENE on 2016. 1. 22..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

// Needs defaults value when failed or can't purchase. Optional.
extern NSString * const STAppProductsKeyValueConfigurationDefaultValueKey;
// Activated state before purchase. Optional.
extern NSString * const STAppProductsKeyValueConfigurationActivationBoolValueKey;
// Needs value when successfully purchased. Optional.
extern NSString * const STAppProductsKeyValueConfigurationPurchasedValueKey;

@interface NSObject (STAppProducts)
/*
 * if return nil via given params, it's not a in-app purchasing target from all.
 *
 * example of implemention

    static NSDictionary * products;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        products = @{
            Product_A : @{
                    @"key_A_of_Product_A" : @{STAppProductsKeyValueConfigurationDefaultValueKey: @"provide defaults If not purchased yet.", STAppProductsKeyValueConfigurationActivationKey: @YES}
                    @"key_B_of_Product_A" : @{STAppProductsKeyValueConfigurationDefaultValueKey: @NO}
            }
            , Product_B : @{
                    @"key_A_of_Product_B" : @NO,
                    @"key_B_of_Product_B" : @"Defined KeyValue containing NSDictionary or DefaultValue itself.",
            }
        };
    });
    return products;
*/
- (NSDictionary *)productsKeyValueConfiguration;

- (NSString *)productIdForKeyPath:(NSString *)keyPath;

- (NSArray *)keyPathsForProductId:(NSString *)productId;

- (id)productDefaultValueForKeyPath:(NSString *)keyPath;

- (id)productPurchasedValueForKeyPath:(NSString *)keyPath;

- (id)productValueForKeyPath:(NSString *)keyPath optionKey:(NSString *)optionKey;

- (BOOL)productActivationForKeyPath:(NSString *)keyPath;

// productId by given value AND keyPath combination, or nil.
- (NSString *)productIdForValue:(id)value forKeyPath:(NSString *)keyPath;

// productId by given targent AND value AND keyPath combination, or nil.
+ (NSString *)productIdForTarget:(id)target value:(id)value forKeyPath:(NSString *)keyPath;

@end