//
// Created by BLACKGENE on 2014. 9. 30..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import "STFilterItem.h"
#import "UIColor+STColorUtil.h"
#import "NSString+STUtil.h"

@interface STFilterItem ()

@property (nonatomic, strong, readwrite) NSString *filePathForCLUT;
@property (nonatomic, strong, readwrite) NSString *fileNameForCLUT;

@end

@implementation STFilterItem

- (id)init; {
    self = [super init];
    if (self) {
        _label = @"default";
        _representativeColor = [STStandardUI defaultFilterRepresentationColor];
        _provider = @"stellselie";
        _type = STFilterTypeDefault;
    }
    return self;
}

- (id)initWithCLUTFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        self.filePathForCLUT = filePath;
        self.fileNameForCLUT = [filePath lastPathComponent];
        [self parseWithCLUTFileName:self.fileNameForCLUT];
        [self initProductId];
        _source = STFilterSourceCLUT;
    }
    return self;
}

- (void)setType:(STFilterType)type {
    _type = type;
    NSAssert((self.isProduct && self.productId) || !self.isProduct,@"must provide productId if type is STFilterTypeITunesProduct or STFilterTypeExternalProduct");
}

#pragma mark Product
NSMutableDictionary * ProductIdByType;
+ (void)registerProductIdByType:(NSDictionary *)typeProductsKeyValue{
    ProductIdByType = [typeProductsKeyValue mutableCopy];
}

- (BOOL)isProduct{
    switch (_type){
        case STFilterTypeITunesProduct:
        case STFilterTypeExternalProduct:
            return YES;
        default:
            return NO;
    }
}

- (void)initProductId{
    if(ProductIdByType && self.isProduct){
        NSParameterAssert([ProductIdByType[@(_type)] isKindOfClass:NSString.class]);
        _productId = ProductIdByType[@(_type)];
    }
}

- (void)parseWithCLUTFileName:(NSString *)fileName{
    // # format : {index}_{representativeColor}_{uid/uid_short}_{type}_{tag}.png

    NSArray *filterInfo = [fileName componentsSeparatedByString:@"_"];
    NSUInteger numberOfInfo = [filterInfo count];

    NSAssert(filterInfo.count>=4, @"filterInfo format : {index}_{representativeColor}_{uid/uid_short}_{type}_{tag}?.png");

    if (numberOfInfo > 0) {
        _indexOfColor = (NSUInteger) [filterInfo[0] integerValue];
    }

    if (numberOfInfo > 1) {
        _representativeColor = [UIColor colorWithRGBHexString:[NSString stringWithFormat:@"#%@", filterInfo[1]]];
        _representativeColor = [_representativeColor multiplyColorWithHue:1.f saturation:3.f brightness:1.f alpha:1.f];
    }

    if (numberOfInfo > 2) {
        _uid = filterInfo[2];
        _uid_short = (id) [filterInfo[2] substringToIndex:6];
    }

    if (numberOfInfo > 3) {
        _type = (STFilterType) [filterInfo[3] unsignedIntValue];
    }

    if (numberOfInfo > 4) {
        self.tag = filterInfo[4];
    }
}

- (NSString *)uid; {
    return _uid ? _uid : (_uid = [[NSUUID UUID] UUIDString]);
}

- (NSString *)uid_short; {
    return _uid_short ? _uid_short : (_uid_short = [self.uid substringToIndex:6]);
}

- (NSString *)makeFilterCacheKey:(STPhotoItem *)targetItem; {
    return [self.uid_short st_add:targetItem.imageId];
}

- (BOOL)deprecated{
    return NO;
}


@end