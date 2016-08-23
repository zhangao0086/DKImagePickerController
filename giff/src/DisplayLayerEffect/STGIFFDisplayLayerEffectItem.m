//
// Created by BLACKGENE on 8/1/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerEffectItem.h"
#import "STMultiSourcingImageProcessor.h"


@implementation STGIFFDisplayLayerEffectItem {

}

- (instancetype)initWithClass:(Class)classObj imageName:(NSString *)imageName valuesForKeysToApply:(NSDictionary *)valuesForKeysToApply {
    self = [super init];
    if (self) {
        NSAssert([classObj isKindOfClass:STMultiSourcingImageProcessor.class], @"Class must be a kind of STMultiSourcingImageProcessor");
        _classObj = classObj;

        BOOL respondsMaxSupportedNumberOfSourceImages = [classObj respondsToSelector:@selector(maxSupportedNumberOfSourceImages)];
        NSAssert(respondsMaxSupportedNumberOfSourceImages, @"Class must implement maxSupportedNumberOfSourceImages");
        _maxSupportedNumberOfSourceImages = respondsMaxSupportedNumberOfSourceImages ? [classObj maxSupportedNumberOfSourceImages] : [STMultiSourcingImageProcessor maxSupportedNumberOfSourceImages];

        self.imageName = imageName;
        self.valuesForKeysToApply = valuesForKeysToApply;
    }

    return self;
}

+ (instancetype)itemWithClass:(Class)classObj imageName:(NSString *)imageName {
    return [self itemWithClass:classObj imageName:imageName valuesForKeysToApply:nil];
}

+ (instancetype)itemWithClass:(Class)classObj imageName:(NSString *)imageName valuesForKeysToApply:(NSDictionary *)valuesForKeysToApply{
    return [[self alloc] initWithClass:classObj imageName:imageName valuesForKeysToApply:valuesForKeysToApply];
}


@end