//
// Created by BLACKGENE on 5/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STExporter.h"

@interface STExporter (IOGIF)
+ (void)exportGIFsFromPhotoItems:(BOOL)export photoItems:(NSArray<STPhotoItem *> *)items progress:(void (^)(CGFloat))progressBlock completion:(void (^)(NSArray *gifURLs, NSArray *succeedItems, NSArray *errorItems))completionBlock;

- (void)exportGIF:(STPhotoItem *)photo completion:(void (^)(NSURL *gifURL))block;

- (void)exportGIF:(STPhotoItem *)photo forceReload:(BOOL)reload completion:(void (^)(NSURL *gifURL))block;

- (void)exportGIFs:(NSArray *)items progress:(void (^)(NSURL *gifURL, STPhotoItem *item, NSUInteger count, NSUInteger total))progressblock completion:(void (^)(NSArray *gifURLs, NSArray * succeedItems, NSArray *errorItems))block;

- (void)exportGIFs:(NSArray *)items processChunk:(NSUInteger)chunkSize forceReload:(BOOL)reload progress:(void (^)(NSURL *gifURL, STPhotoItem *item,  NSUInteger count, NSUInteger total))progressblock completion:(void (^)(NSArray *gifURLs, NSArray * succeedItems, NSArray *errorItems))block;
@end