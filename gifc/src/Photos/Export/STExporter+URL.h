//
// Created by BLACKGENE on 15. 9. 2..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STExporter.h"

@interface STExporter (URL)

+ (NSString *)scheme;

+ (BOOL)canOpenApp;

+ (BOOL)openApp;

+ (NSURL *)appURL;

+ (NSURL *)webURL;

+ (NSString *)appURLString;

+ (NSString *)webURLString;

- (BOOL)handleOpenURL:(UIApplication *)application url:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

- (NSURL *)fallbackAppStoreURL;

- (NSString *)fallbackAppStoreId;
@end

@protocol STExporterSocialURLProtocol <NSObject>
@required
+ (NSString *)appURLStringWithUserName:(NSString *)userName;
+ (NSString *)webURLStringWithUserName:(NSString *)userName;
@optional
+ (NSString *)appURLStringWithHashtagName:(NSString *)hashtag;
+ (NSString *)webURLStringWithHashtagName:(NSString *)hashtag;
@end