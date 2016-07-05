//
// Created by BLACKGENE on 2016. 1. 22..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <BlocksKit/NSObject+BKAssociatedObjects.h>
#import "NSObject+STAppProducts.h"

NSString * const STAppProductsKeyValueConfigurationDefaultValueKey = @"STAppProductsKeyValueConfigurationDefaultValueKey";
NSString * const STAppProductsKeyValueConfigurationActivationBoolValueKey = @"STAppProductsKeyValueConfigurationActivationKey";
NSString * const STAppProductsKeyValueConfigurationPurchasedValueKey = @"STAppProductsKeyValueConfigurationPurchasedValueKey";

@implementation NSObject (STAppProducts)

+ (NSString *)productIdForTarget:(id)target value:(id)value forKeyPath:(NSString *)keyPath {
    //default : ignore given value
    return [target productIdForKeyPath:keyPath];
}

- (NSString *)productIdForValue:(id)value forKeyPath:(NSString *)keyPath {
    return [self.class productIdForTarget:self value:value forKeyPath:keyPath];
}

- (NSDictionary *)productsKeyValueConfiguration {
    return nil;
}

- (NSString *)productIdForKeyPath:(NSString *)keyPath {
    NSDictionary *products = [self productsKeyValueConfiguration];
    if(!products){
        return nil;
    }

    DEFINE_ASSOCIATOIN_KEY(kProductIdForKeyPath);
    BlockOnce(^{
        [self bk_associateValue:[NSMutableDictionary dictionary] withKey:kProductIdForKeyPath];
    });

    //already touched.
    NSMutableDictionary * productIdByKeypath = [self bk_associatedValueForKey:kProductIdForKeyPath];
    NSString *touchedProductId = productIdByKeypath[keyPath];
    if(touchedProductId){
        return touchedProductId;
    }

    //touching new
    for (NSString *productId in products) {
        NSDictionary *productKVSet = products[productId];
        if (!!(productKVSet[keyPath])) {
            return (productIdByKeypath[keyPath] = productId);
        }
    }
    return nil;
}

- (NSArray *)keyPathsForProductId:(NSString *)productId{
    id productDataSet = [self productsKeyValueConfiguration][productId];
    NSAssert(productDataSet ? [productDataSet isKindOfClass:NSDictionary.class] : YES,@"productDataSet is must be dictionary.");
    return ((NSDictionary *)productDataSet).allKeys;
}

- (id)productDefaultValueForKeyPath:(NSString *)keyPath{
    return [self productValueForKeyPath:keyPath optionKey:STAppProductsKeyValueConfigurationDefaultValueKey];
}

- (id)productPurchasedValueForKeyPath:(NSString *)keyPath{
    // priority : 1. STAppProductsKeyValueConfigurationPurchasedValueKey > 2. STAppProductsKeyValueConfigurationDefaultValueKey > 3. nil
    return [self productValueForKeyPath:keyPath optionKey:STAppProductsKeyValueConfigurationPurchasedValueKey]?:[self productDefaultValueForKeyPath:keyPath];
}

- (id)productValueForKeyPath:(NSString *)keyPath optionKey:(NSString *)optionKey {
    NSString * productId = [self productIdForKeyPath:keyPath];
    if(productId){
        id configValueByKeypath = [self productsKeyValueConfiguration][productId][keyPath];
        BOOL isValidDictValue = [configValueByKeypath isKindOfClass:NSDictionary.class];
        if(isValidDictValue){
            NSAssert(optionKey,
                    ([NSString stringWithFormat:@"Optional Key : Type of value for provided keypath '%@' from productsKeyValueConfiguration must be a dictionary which already contains 'optionKey'.", keyPath]));

            return ((NSDictionary *) configValueByKeypath)[optionKey];
        }else{

            return configValueByKeypath;
        }
    }
    return nil;
}

- (BOOL)productActivationForKeyPath:(NSString *)keyPath{
    NSString * productId = [self productIdForKeyPath:keyPath];
    if(productId){
        id productsConfigObjectByKeypath = [self productsKeyValueConfiguration][productId][keyPath];
        if([productsConfigObjectByKeypath isKindOfClass:NSDictionary.class] &&
                [[((NSDictionary *) productsConfigObjectByKeypath) allKeys] containsObject:STAppProductsKeyValueConfigurationActivationBoolValueKey]){

            return [((NSDictionary *) productsConfigObjectByKeypath)[STAppProductsKeyValueConfigurationActivationBoolValueKey] boolValue];
        }else{

            return NO;
        }
    }
    return YES;
}

@end