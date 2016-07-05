//
// Created by BLACKGENE on 2016. 4. 13..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "STApp+Logger.h"
#import "Answers.h"
#import "STApp+Products.h"
#import "NSObject+STUtil.h"

@implementation STApp (Logger)

#pragma mark Purchasing Transactions
+ (void)logTryPurchasing:(NSString *)productId{
    [self logCustomEvent:@"PurchaseTry" name:productId key:nil value:nil attributes:nil];
}

+ (void)logPurchaseSuccess:(SKPaymentTransaction *)transaction {
    [self getProductItemIfNeeded:transaction.payment.productIdentifier fetchedBlock:^(STProductItem *productItem) {
        if(productItem){
            [Answers logPurchaseWithPrice:[NSDecimalNumber decimalNumberWithDecimal:productItem.price.decimalValue]
                                 currency:productItem.priceCurrenyCodeISO4217
                                  success:@1
                                 itemName:productItem.localizedTitle
                                 itemType:productItem.downloadable ? @"D" : @"F"
                                   itemId:transaction.payment.productIdentifier
                         customAttributes:nil];
        }
    }];
}

+ (void)logPurchaseFail:(SKPaymentTransaction *)transaction {
    [self logCustomEvent:@"PurchaseFailed" name:transaction.payment.productIdentifier key:nil value:nil attributes:nil];
}

+ (void)logPurchasingProductExisted:(NSString *)productId {
    [self getProductItemIfNeeded:productId fetchedBlock:^(STProductItem *productItem) {
        NSAssert(productItem, @"PurchasingProductExisted state but productItem is nil. Something wrong.");
        [Answers logCustomEventWithName:@"PurchasingProductExisted"
                       customAttributes:[productItem dictionaryWithValuesForKeys:[productItem st_propertyNames]]];
    }];

}

#pragma mark View Event
+ (void)logUniqueView:(NSString *)domain{
    [self logView:domain name:nil key:nil value:nil attributes:nil];
}

+ (void)logView:(NSString *)domain name:(NSString *)name{
    [self logView:domain name:nil key:nil value:nil attributes:nil];
}

+ (void)logView:(NSString *)domain name:(NSString *)name key:(NSString *)key value:(NSString *)value attributes:(NSDictionary *)dict{
    NSParameterAssert(domain);
    NSParameterAssert(![domain isEqualToString:name]);
    NSParameterAssert(!key || (key && (value || YES)));
    [Answers logContentViewWithName:domain && name ? [NSString stringWithFormat:@"%@_%@",domain,name] : (domain?:@"undefined")
                        contentType:name && key ? [NSString stringWithFormat:@"%@_%@", name, key] : [NSString stringWithFormat:@"%@_%@", domain, key]
                          contentId:key && value ? [NSString stringWithFormat:@"%@_%@", key, value] : nil
                   customAttributes:dict];
}

#pragma mark Click Event
+ (void)logClick:(NSString *)name{
    [self logClick:name key:nil];
}

+ (void)logClick:(NSString *)name key:(NSString *)key{
    [self logClick:name key:key value:nil];
}

+ (void)logClick:(NSString *)name key:(NSString *)key value:(NSString *)value{
    [self logView:@"Click" name:name key:key value:value attributes:nil];
}

#pragma mark Event
+ (void)logCustomEvent:(NSString *)domain name:(NSString *)name key:(NSString *)key value:(NSString *)value attributes:(NSDictionary *)dict{
    NSParameterAssert(domain);
    NSParameterAssert(![domain isEqualToString:name]);
    NSParameterAssert(!key || (key && (value || YES)));

    NSMutableDictionary * attrDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    attrDict[@"locale"] = [[NSLocale autoupdatingCurrentLocale] localeIdentifier]?:@"unknowen";

    [Answers logCustomEventWithName:[@[domain ?: @"nodomain", name ?: @"noname", key ?: @"nokey", value ?: @""] join:@"_"] customAttributes:attrDict];
}

+ (void)logUnique:(NSString *)name{
    [self logEvent:name attributes:nil];
}

+ (void)logEvent:(NSString *)name attributes:(id)values{
    [self logEvent:name key:nil value:nil attributes:values];
}

+ (void)logEvent:(NSString *)name key:(NSString *)key{
    [self logEvent:name key:key value:nil attributes:nil];
}

+ (void)logEvent:(NSString *)name key:(NSString *)key value:(NSString *)value{
    [self logEvent:name key:key value:value attributes:nil];
}

+ (void)logEvent:(NSString *)name key:(NSString *)key value:(NSString *)value attributes:(NSDictionary *)dict{
    [self logCustomEvent:@"Event" name:name key:key value:value attributes:dict];
}

#pragma mark User Flow
+ (void)logQuickPreviewDismissed:(BOOL)didEnteredZoomScrollMode{
    [self logEvent:@"QuickPreviewViewed" key:didEnteredZoomScrollMode ? @"Zoom" : @"Motion"];
}

#pragma mark Error
+ (void)logError:(NSString *)name{
    [self logCustomEvent:@"Error" name:name key:nil value:nil attributes:nil];
}
@end