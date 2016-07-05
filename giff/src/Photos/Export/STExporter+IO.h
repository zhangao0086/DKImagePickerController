//
// Created by BLACKGENE on 2015. 2. 12..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STExporter.h"

@class STPhotoItem;
@class STFilterItem;
@class STPhotoItemSource;

@interface STExporter (IO)

+ (UIImage *)buildImage:(STPhotoItem *)item inputImage:(UIImage *)inputImage enhance:(BOOL)enhance;

+ (STPhotoItemSource *)createPhotoItemSourceToExport:(STPhotoItem *)item;

- (void)exportAllDatas:(void (^)(NSArray *datas))completion;

- (void)exportAllDatas:(BOOL)fullResolution completion:(void (^)(NSArray *datas))block;

- (void)exportDatas:(NSArray *)items completion:(void (^)(NSArray *datas))block;

- (void)exportDatas:(NSArray *)items fullResolution:(BOOL)fullResolution completion:(void (^)(NSArray *datas))block;

- (CGFloat)checkDataTotalMegaBytes:(NSArray *)photoItems;

- (BOOL)isRequiredFullResolution;

- (NSString *)preferedExtensionOfTempFile;

- (NSURL *)tempURL:(NSString *)id;

- (NSURL *)tempURL:(NSString *)id extension:(NSString *)extension;

- (void)cleanAllExportedResults;

- (UIImage *)exportImage:(STPhotoItem *)item;

- (UIImage *)exportImage:(STPhotoItem *)item fullResolution:(BOOL)fullResolution;

- (void)exportAllImages:(void (^)(NSArray *images))completion;

- (void)exportAllImages:(BOOL)fullResolution completion:(void (^)(NSArray *images))block;

- (void)exportImages:(NSArray *)items completion:(void (^)(NSArray *images))block;

- (void)exportImages:(NSArray *)items fullResolution:(BOOL)fullResolution completion:(void (^)(NSArray *images))block;

- (NSData *)exportData:(STPhotoItem *)item;

- (NSData *)exportData:(STPhotoItem *)item fullResolution:(BOOL)fullResolution;

- (NSURL *)exportFile:(STPhotoItem *)photo id:(NSString *)id1;

- (void)exportFiles:(NSArray *)items completion:(void (^)(NSArray *imageURLs))block;

- (void)cancelAllExportJobs;

- (void)exportAllFiles:(void (^)(NSArray *imageURLs))block;
@end