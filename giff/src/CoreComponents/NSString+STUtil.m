//
// Created by BLACKGENE on 2014. 10. 16..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "NSString+STUtil.h"
#import "NSURLComponents+STUtil.h"
#import "NSURL+STUtil.h"
#import "SVGKImage.h"
#import "SVGKImage+STUtil.h"
#import "BlocksKit.h"
#import "NSArray+STUtil.h"


@implementation NSString (STUtil)

- (NSString *)st_onlyNumber {
    return [[self componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
}

-(BOOL)st_isNumeric{
    return !![[[NSNumberFormatter alloc] init] numberFromString:self];
}

- (NSString *)st_add:(NSString *)str{
    if(!str){
        return self;
    }
    NSMutableString * _str = [self mutableCopy];
    [_str appendString:str];
    return _str;
}

- (NSString *)st_clearWhitespace{
    return [[self componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
}

- (NSString *)st_format:(va_list)argList{
    return [[NSString alloc] initWithFormat:self, argList];
}

- (BOOL)st_found:(NSString *)str{
    return [self rangeOfString:str].location != NSNotFound;
}

- (NSUInteger)st_loc:(NSString *)str{
    return [self rangeOfString:str].location;
}

- (NSUInteger)st_numberOfNewLines {
    return [[self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] count];
}

- (NSString *)bundleFilePath{
    return [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], self];
}

- (NSString *)bundleFileAbsolutePath{
    return [NSString stringWithFormat:@"%@/%@", [[[NSBundle mainBundle] bundleURL] absoluteString], self];
}

- (NSString *)stringByAppendingSuffixOfLastPathComponent:(NSString *)suffix{
    return [self stringByAppendingSuffixOfLastPathComponent:suffix replacingPathExtension:nil];
}

- (NSString *)stringByAppendingSuffixOfLastPathComponent:(NSString *)suffix
                                  replacingPathExtension:(NSString *)extension{

    return [[self stringByDeletingLastPathComponent]
            stringByAppendingPathComponent:[[[[self lastPathComponent]
                    stringByDeletingPathExtension]
                    stringByAppendingString:suffix]
                    stringByAppendingPathExtension:extension ?: self.pathExtension]];
}

- (BOOL)isInteger{
    NSScanner* scan = [NSScanner scannerWithString:self];
    NSInteger val;
    return [scan scanInteger:&val] && [scan isAtEnd];
}

- (NSURL *)URLForTemp{
    return [self URLForTemp:nil extension:nil];
}

- (NSURL *)URLForTemp:(NSString *)extension{
    return [self URLForTemp:nil extension:extension];
}

- (NSURL *)URLForTemp:(NSString *)prefix extension:(NSString *)extension{
    NSURL * url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:prefix ? [prefix st_add:self] : self]];
    return extension.length ? [url URLByAppendingPathExtension:extension] : url;
}

- (NSURL *)URLForDocument{
    return [self URLForDocument:nil extension:nil];
}

- (NSURL *)URLForDocument:(NSString *)extension{
    return [self URLForDocument:nil extension:extension];
}

- (NSURL *)URLForDocument:(NSString *)prefix extension:(NSString *)extension{
    NSURL * url = [NSURL fileURLWithPath:[[self.class documentPath] stringByAppendingPathComponent:prefix ? [prefix st_add:self] : self]];
    return extension && extension.length ? [url URLByAppendingPathExtension:extension] : url;
}

- (NSString *)absolutePathFromDocument{
    return [[self.class documentPath] stringByAppendingPathComponent:self];
}

+ (NSString *)documentPath{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) st_objectOrNilAtIndex:0];
}

- (NSURL *)URL{
    return [NSURL URLWithString:self];
}

- (NSURL *)fileURL{
    return [NSURL fileURLWithPath:self];
}

- (NSURLComponents *)URLComponent{
    return [[self URL] URLComponent];
}

- (NSURLComponents *)URLSchemeComponent {
    NSURLComponents * components = [[NSURLComponents alloc] init];
    components.scheme = self;
    return components;
}

- (NSURLComponents *)URLSchemeWithEmptyHost {
    return [[self URLSchemeComponent] st_host:@""];
}


- (UIImage *)imageSVG:(CGFloat)sizeWidth{
    return [SVGKImage UIImageNamed:self withSizeWidth:sizeWidth];
}

- (BOOL)isEqualToFileExtension:(NSString *)extension {
    return [[NSURL URLWithString:self].pathExtension isEqualToString:extension];
}

- (NSString *)matchedSchemeToURL:(NSSet *)schemeSet {
    return [schemeSet bk_match:^BOOL(NSString * scheme) {
        return [self isSchemeEqualToURL:scheme];
    }];
}

- (BOOL)isSchemeEqualToURL:(NSString *)scheme {
    NSString * _scheme = [NSURL URLWithString:self].scheme;
    if(_scheme){
        return [_scheme isEqualToString:scheme];
    }
    return NO;
}

- (BOOL)isGeneralURL{
    NSURL * url = [NSURL URLWithString:self];
    return url.scheme && url.host;
}

- (NSString *)escapeForQuery{
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (NSString *)mimeTypeFromPathExtension {
    if (![[NSFileManager defaultManager] fileExistsAtPath:self]) {
        return nil;
    }
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[self pathExtension], NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!mimeType) {
        return @"application/octet-stream";
    }
    NSString * _mimeType = (__bridge_transfer NSString*)mimeType;
    return _mimeType;
}

- (NSString *)extensionFromUTI:(CFStringRef)uti{
    return (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension);
}

@end