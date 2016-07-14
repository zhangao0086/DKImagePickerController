//
// Created by BLACKGENE on 7/8/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageLayerItem.h"
#import "STAfterImageItem.h"

@implementation STAfterImageItem {

}

- (void)setLayers:(NSArray<STAfterImageLayerItem *> *)layers {
#if DEBUG
    for(id element in layers){
        NSAssert([element isKindOfClass:[STAfterImageLayerItem class]], @"elements of layers is not STAfterImageLayerItem");
    }
#endif
    _layers = layers;
}

- (instancetype)initWithLayers:(NSArray *)layers {
    self = [super init];
    if (self) {
        self.layers = layers;
    }
    return self;
}

+ (instancetype)itemWithLayers:(NSArray *)layers {
    return [[self alloc] initWithLayers:layers];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        self.layers = [decoder decodeObjectForKey:@keypath(self.layers)];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.layers forKey:@keypath(self.layers)];
}


@end