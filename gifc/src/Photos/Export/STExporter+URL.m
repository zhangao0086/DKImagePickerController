//
// Created by BLACKGENE on 15. 9. 2..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STExporter+URL.h"
#import "NSString+STUtil.h"
#import "NSURL+STUtil.h"


@implementation STExporter (URL)

#pragma mark Open App
static NSDictionary * CanOpenApps;

+ (BOOL)canOpenApp {
    @synchronized (CanOpenApps) {
        NSString *key = NSStringFromClass(self.class);
        if([CanOpenApps hasKey:key]){
            return YES;
        }

        NSMutableDictionary * _canOpenApps = [NSMutableDictionary dictionaryWithDictionary:CanOpenApps ? CanOpenApps : @{}];
        BOOL canOpenApp = self.appURL ? [[UIApplication sharedApplication] canOpenURL:self.appURL] : NO;
        if(canOpenApp){
            _canOpenApps[NSStringFromClass(self.class)] = @"can";
        }
        CanOpenApps = _canOpenApps;
        return [CanOpenApps hasKey:key];
    }
}

+ (BOOL)openApp{
    return [self canOpenApp] ? [[UIApplication sharedApplication] openURL:[self appURL]] : NO;
}

+ (NSString *)scheme{
    return nil;
}

+ (NSURL *)appURL{
    if([self appURLString]){
        return [[self appURLString] URL];

    }else if([self scheme]){
        return [[[self scheme] URLSchemeWithEmptyHost] URL];
    }
    return nil;
}

+ (NSURL *)webURL{
    return [[self webURLString] URL];
}

+ (NSString *)appURLString{
    return nil;
}

+ (NSString *)webURLString{
    return nil;
}

- (BOOL)handleOpenURL:(UIApplication *)application url:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;{
    return NO;
}

- (NSURL *)fallbackAppStoreURL; {
    if([self fallbackAppStoreId]){
        return [NSURL URLForAppstoreApp:[self fallbackAppStoreId]];
    }
    return nil;
}

- (NSString *)fallbackAppStoreId; {
    return nil;
}

@end