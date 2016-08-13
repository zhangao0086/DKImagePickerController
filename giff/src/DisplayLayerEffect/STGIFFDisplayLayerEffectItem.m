//
// Created by BLACKGENE on 8/1/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerEffectItem.h"


@implementation STGIFFDisplayLayerEffectItem {

}

- (instancetype)initWithClassName:(NSString *)className imageName:(NSString *)imageName valuesForKeysToApply:(NSDictionary *)valuesForKeysToApply {
    self = [super init];
    if (self) {
        self.className = className;
        self.imageName = imageName;
        self.valuesForKeysToApply = valuesForKeysToApply;
    }

    return self;
}

+ (instancetype)itemWithClassName:(NSString *)className imageName:(NSString *)imageName valuesForKeysToApply:(NSDictionary *)valuesForKeysToApply {
    return [[self alloc] initWithClassName:className imageName:imageName valuesForKeysToApply:valuesForKeysToApply];
}


+ (instancetype)itemWithClass:(Class)classObj imageName:(NSString *)imageName {
    return [self itemWithClass:classObj imageName:imageName valuesForKeysToApply:nil];
}

+ (instancetype)itemWithClass:(Class)classObj imageName:(NSString *)imageName valuesForKeysToApply:(NSDictionary *)valuesForKeysToApply{
    return [self itemWithClassName:NSStringFromClass(classObj) imageName:imageName valuesForKeysToApply:valuesForKeysToApply];
}


@end