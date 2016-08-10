//
// Created by BLACKGENE on 8/1/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerEffectItem.h"


@implementation STGIFFDisplayLayerEffectItem {

}
- (instancetype)initWithClassName:(NSString *)className imageName:(NSString *)imageName {
    self = [super init];
    if (self) {
        self.className = className;
        self.imageName = imageName;
    }

    return self;
}

+ (instancetype)itemWithClassName:(NSString *)className imageName:(NSString *)imageName {
    return [[self alloc] initWithClassName:className imageName:imageName];
}

+ (instancetype)itemWithClass:(Class)classObj titleImageName:(NSString *)imageName {
    return [self itemWithClassName:NSStringFromClass(classObj) imageName:imageName];
}


@end