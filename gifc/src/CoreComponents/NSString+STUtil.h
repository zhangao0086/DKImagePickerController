//
// Created by BLACKGENE on 2014. 10. 16..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (STUtil)

- (NSString *)absolutePathFromDocument;

+ (NSString *)documentPath;

- (NSString *)st_onlyNumber;

- (BOOL)st_isNumeric;

- (NSString *)st_add:(NSString *)str;

- (NSString *)st_clearWhitespace;

- (NSString *)st_format:(va_list)argList;

- (BOOL)st_found:(NSString *)str;

- (NSUInteger)st_loc:(NSString *)str;

- (NSUInteger)st_numberOfNewLines;

- (NSString *)bundleFilePath;

- (NSString *)bundleFileAbsolutePath;

- (NSString *)stringByAppendingSuffixOfLastPathComponent:(NSString *)suffix;

- (NSString *)stringByAppendingSuffixOfLastPathComponent:(NSString *)suffix replacingPathExtension:(NSString *)extension;

- (BOOL)isInteger;

- (NSURL *)URLForTemp;

- (NSURL *)URLForTemp:(NSString *)extension;

- (NSURL *)URLForTemp:(NSString *)prefix extension:(NSString *)extension;

- (NSURL *)URLForDocument;

- (NSURL *)URLForDocument:(NSString *)extension;

- (NSURL *)URLForDocument:(NSString *)prefix extension:(NSString *)extension;

- (NSURL *)URL;

- (NSURL *)fileURL;

- (NSURLComponents *)URLComponent;

//result: 'string:'
- (NSURLComponents *)URLSchemeComponent;

//result: 'string://'
- (NSURLComponents *)URLSchemeWithEmptyHost;

- (UIImage *)imageSVG:(CGFloat)sizeWidth;

- (BOOL)isEqualToFileExtension:(NSString *)other;

- (NSString *)matchedSchemeToURL:(NSSet *)schemeSet;

- (BOOL)isSchemeEqualToURL:(NSString *)other;

- (BOOL)isGeneralURL;

- (NSString *)escapeForQuery;

- (NSString *)mimeTypeFromPathExtension;
@end