//
// Created by BLACKGENE on 2015. 2. 12..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STExporter.h"

@class STPhotoItem;

@interface STExporter (Config)
- (NSString *)iconImageName;

- (NSString *)logoImageName;

- (UIColor *)iconImageBackgroundColor;

+ (NSString *)iconImageName:(STExportType)type;

+ (NSString *)logoImageName:(STExportType)type;

+ (UIColor *)iconImageBackgroundColor:(STExportType)type;

+ (instancetype)exporterBlank;

+ (instancetype)exporterWithType:(STExportType)type;

+ (Class)exporterClassWithType:(STExportType)type;

+ (BOOL)isAllowedByCurrentApplicationState:(STExportType)type;

+ (BOOL)isAllowedFullResolution:(STExportType)type;

+ (BOOL)isShouldWaitUsersInteraction:(STExportType)type;

+ (NSUInteger)allowedCount:(STExportType)type;

+ (NSString *)localizedPromotionMessageWhenSent;
@end
