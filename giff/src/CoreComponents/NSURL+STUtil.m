//
// Created by BLACKGENE on 2015. 1. 4..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import "NSURL+STUtil.h"
#import "NSURLComponents+STUtil.h"
#import "NSString+STUtil.h"


@implementation NSURL (STUtil)

#pragma mark scheme
- (BOOL)isMailtoURL {
    return [[self scheme] isEqualToString:@"mailto"];
}

- (BOOL)isSMSURL {
    return [[self scheme] isEqualToString:@"sms"];
}

#pragma mark utils
- (CGSize)st_sizeOfImage
{
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)self, NULL);
    if (imageSource == NULL) {
        return CGSizeZero;
    }
    CGFloat width = 0.0f, height = 0.0f;
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    
    
    if (imageProperties != NULL) {
        CFNumberRef widthNum  = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
        if (widthNum != NULL) {
            CFNumberGetValue(widthNum, kCFNumberCGFloatType, &width);
        }
        //TODO: kCGImagePropertyOrientation 적용
        CFNumberRef heightNum = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
        if (heightNum != NULL) {
            CFNumberGetValue(heightNum, kCFNumberCGFloatType, &height);
        }

        CFRelease(imageProperties);
    }
    CFRelease(imageSource);
    return CGSizeMake(width, height);
}

- (NSURLComponents *)URLComponent{
    return [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
}

- (NSURL *)st_query:(NSDictionary *)dict{
    NSURLComponents * components = [self URLComponent];
    [components st_query:dict];
    return [components URL];
}

+ (NSURL *)URLForAppstoreApp:(NSString *)id{
    NSParameterAssert(id);
    return [[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/apple-store/id%@?mt=8", id] URL];
}

+ (NSURL *)URLForAppstoreWeb:(NSString *)id{
    NSParameterAssert(id);
    return [[NSString stringWithFormat:@"http://itunes.apple.com/app/apple-store/id%@?mt=8", id] URL];
}

- (NSString *)appStoreId{
    BOOL containsHost = [[NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", @"itunes.apple.com"] evaluateWithObject:[self host]];
    BOOL containsId = [[self lastPathComponent] hasPrefix:@"id"];
    BOOL isAppstoreURL = containsHost && containsId;
    if(isAppstoreURL){
        return [[self lastPathComponent] substringFromIndex:@"id".length];
    }
    return nil;
}

- (BOOL)excludeFromBackup{
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:self.path];
    NSAssert(exist, @"file does not exists. create file first.");
    if(exist){
        NSError *error;
        [self setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
        return error == nil;
    }
    return NO;
}

#pragma mark mimetypes

- (NSString *)primaryMimeType{
    NSString * ext = [self pathExtension];
    if([ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"]){
        return @"image/jpeg";

    }else if([ext isEqualToString:@"gif"]){
        return @"image/gif";
    }

    return nil;
}

@end