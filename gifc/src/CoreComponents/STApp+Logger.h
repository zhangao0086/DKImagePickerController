//
// Created by BLACKGENE on 2016. 4. 13..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STApp.h"

@class SKPaymentTransaction;

@interface STApp (Logger)
+ (void)logTryPurchasing:(NSString *)productId;

+ (void)logPurchaseSuccess:(SKPaymentTransaction *)transaction;

+ (void)logPurchaseFail:(SKPaymentTransaction *)transaction;

+ (void)logPurchasingProductExisted:(NSString *)productId;

+ (void)logClick:(NSString *)name;

+ (void)logClick:(NSString *)name key:(NSString *)key;

+ (void)logClick:(NSString *)name key:(NSString *)key value:(NSString *)value;

+ (void)logQuickPreviewDismissed:(BOOL)didEnteredZoomScrollMode;

+ (void)logUnique:(NSString *)name;

+ (void)logEvent:(NSString *)name attributes:(id)values;

+ (void)logEvent:(NSString *)name key:(NSString *)key;

+ (void)logEvent:(NSString *)name key:(NSString *)key value:(NSString *)value;

+ (void)logError:(NSString *)productId;
@end