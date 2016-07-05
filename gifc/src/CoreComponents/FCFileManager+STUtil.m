//
// Created by BLACKGENE on 2015. 11. 21..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "FCFileManager+STUtil.h"

@interface FCFileManager (Private)
+(NSString *)absolutePath:(NSString *)path;
+(BOOL)removeItemsAtPaths:(NSArray *)paths error:(NSError **)error;
+(NSString *)absoluteDirectoryForPath:(NSString *)path;
@end

@implementation FCFileManager (STUtil)

+(BOOL)removeFilesInDirectoryAtPath:(NSString *)path withFilePrefix:(NSString *)filePrefix
{
    return [self removeFilesInDirectoryAtPath:path withFilePrefix:filePrefix deep:NO];
}

+(BOOL)removeFilesInDirectoryAtPath:(NSString *)path withFilePrefix:(NSString *)filePrefix deep:(BOOL)deep
{
    NSArray * subpaths = [self listFilesInDirectoryAtPath:path deep:deep];
    NSArray * targetFilePaths = [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSString *subpath = (NSString *)evaluatedObject;
        return ([[subpath lastPathComponent] hasPrefix:filePrefix] || [subpath isEqualToString:filePrefix]);
    }]];

    return [self removeItemsAtPaths:targetFilePaths error:nil];
}

@end