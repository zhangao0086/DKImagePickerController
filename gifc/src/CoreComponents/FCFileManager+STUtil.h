//
// Created by BLACKGENE on 2015. 11. 21..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCFileManager.h"

@interface FCFileManager (STUtil)
+ (BOOL)removeFilesInDirectoryAtPath:(NSString *)path withFilePrefix:(NSString *)filePrefix;

+ (BOOL)removeFilesInDirectoryAtPath:(NSString *)path withFilePrefix:(NSString *)filePrefix deep:(BOOL)deep;
@end