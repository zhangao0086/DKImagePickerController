//
// Created by BLACKGENE on 2015. 10. 8..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STUIApplication.h"

extern NSString * const STShortcutItemTypeEditLastPhoto;
extern NSString * const STShortcutItemTypeCaptureAsFullRange;
extern NSString * const STShortcutItemTypeCaptureAsMultiPoint;
extern NSString * const STShortcutItemTypeOpenAlbum;

@interface STUIApplication (QuickAction)

+ (NSString *)shortcutItemSVGImageNameByType:(NSString *)type;

- (void)launchFromNeededShortcutItemType:(NSString *)itemType completionHandler:(void (^)(BOOL succeeded))completionHandler;

- (void)launchFromNeededShortcutItemIfPossible:(UIApplicationShortcutItem *)item completionHandler:(void (^)(BOOL succeeded))completionHandler;

@end