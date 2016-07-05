//
// Created by BLACKGENE on 2015. 1. 4..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSURL (STUtil)
+ (NSURL *)URLForAppstoreApp:(NSString *)id1;

+ (NSURL *)URLForAppstoreWeb:(NSString *)id1;

- (NSString *)appStoreId;

- (BOOL)excludeFromBackup;

- (NSString *)primaryMimeType;

- (NSURL *)st_query:(NSDictionary *)dict;

- (BOOL)isMailtoURL;

- (BOOL)isSMSURL;

- (CGSize)st_sizeOfImage;

- (NSURLComponents *)URLComponent;
@end