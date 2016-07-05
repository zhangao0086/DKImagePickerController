//
// Created by BLACKGENE on 5/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STExporter.h"

@class NSGIFRequest;

@interface STExporter (ConfigGIF)
- (BOOL)isAllowedToExportGIF;

+ (BOOL)isAllowedToExportGIF:(STExportType)type;

- (NSArray *)photoItemsCanExportGIF;

- (BOOL)shouldExportGIF;

+ (BOOL)canExportGIF:(STPhotoItem *)photo;

+ (NSGIFRequest *)createRequestExportGIF:(STPhotoItem *)item;

+ (BOOL)shouldExportGIF:(NSArray<STPhotoItem *> *)photoItems;
@end