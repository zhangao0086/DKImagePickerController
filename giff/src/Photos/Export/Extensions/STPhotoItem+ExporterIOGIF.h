//
// Created by BLACKGENE on 5/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STPhotoItem.h"

extern NSString * const STPhotoItemsGIFsFileNamePrefix;

@class NSGIFRequest;

@interface STPhotoItem (ExporterIOGIF)
@property (nonatomic, readwrite, nullable) NSGIFRequest *exportGIFRequest;
+ (NSURL *)exportingTempFileGIF:(NSURL *)originalURL extension:(NSString *)extension;
- (BOOL)isExportedTempFileGIF;
@end