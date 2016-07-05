//
// Created by BLACKGENE on 4/29/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STRLMFileWritable <NSObject>
//return saved file path
- (NSString *)createDirectoryInDocument;

- (NSString *)writeFile;

- (BOOL)isFileExist;

- (BOOL)deleteFile;
@end