//
// Created by BLACKGENE on 8/29/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STPhotoItemSource;


@interface STPhotoImporter : NSObject

+ (STPhotoImporter *)sharedImporter;

- (void)startImporting:(void (^)(NSArray<STPhotoItemSource *>*importedPhotoItemSource))block;
@end