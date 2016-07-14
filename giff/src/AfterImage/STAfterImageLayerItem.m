//
// Created by BLACKGENE on 7/9/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageLayerItem.h"
#import "STAfterImageLayerEffect.h"

@implementation STAfterImageLayerItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.scale = 1;
    }
    return self;
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
        self.alpha = [decoder decodeFloatForKey:@keypath(self.alpha)];
        self.scale = [decoder decodeFloatForKey:@keypath(self.scale)];
        self.frameIndexOffset = [decoder decodeIntegerForKey:@keypath(self.frameIndexOffset)];
        self.effect = [decoder decodeObjectForKey:@keypath(self.effect)];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.layers forKey:@keypath(self.layers)];
    [encoder encodeFloat:self.alpha forKey:@keypath(self.alpha)];
    [encoder encodeFloat:self.scale forKey:@keypath(self.scale)];
    [encoder encodeInteger:self.frameIndexOffset forKey:@keypath(self.frameIndexOffset)];
    [encoder encodeObject:self.effect forKey:@keypath(self.effect)];
}
@end