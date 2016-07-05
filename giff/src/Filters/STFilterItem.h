//
// Created by BLACKGENE on 2014. 9. 30..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STPhotoItem.h"
#import "STFilter.h"

typedef NS_OPTIONS(NSUInteger, STFilterType) {
    STFilterTypeUndefined = 0,
    STFilterTypeDefault = 1,
    STFilterTypeITunesProduct = 2,
    STFilterTypeExternalProduct = 3
};

typedef NS_OPTIONS(NSUInteger, STFilterSource) {
    STFilterSourceBlank,
    STFilterSourceCLUT
};

@interface STFilterItem : STItem{
@protected
    NSString *_uid;
    NSString *_uid_short;
    UIColor *_representativeColor;
    NSString *_filePathForCLUT;
    NSString *_fileNameForCLUT;
}

@property (nonatomic, readonly) STFilterSource source;
//info
@property (nonatomic, readonly) NSUInteger indexOfColor;
@property (nonatomic, assign) BOOL deprecated;
@property (nonatomic, readonly) UIColor *representativeColor;
@property (nonatomic, readonly) NSString *uid;
@property (nonatomic, readonly) NSString *uid_short;
@property (nonatomic, assign) STFilterType type;
@property (nonatomic, readwrite) NSString *tag;
@property (nonatomic, readwrite) NSString *provider;
//lut
@property (nonatomic, readonly) NSString *filePathForCLUT;
@property (nonatomic, readonly) NSString *fileNameForCLUT;
@property (nonatomic, readwrite) NSString *label;
//product
@property (nonatomic, readonly) NSString * productId;

- (id)initWithCLUTFilePath:(NSString *)filePath;

+ (void)registerProductIdByType:(NSDictionary *)typeProductsKeyValue;

- (NSString *)makeFilterCacheKey:(STPhotoItem *)targetItem;
@end