//
// Created by BLACKGENE on 7/9/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageLayerItem.h"

@implementation STAfterImageLayerItem {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.scale = 1;
    }
    return self;
}

- (void)setScale:(CGFloat)scale {
    NSAssert(scale<1,@"scale must be higer than 1");
    _scale = scale;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        self.alpha = [decoder decodeFloatForKey:@keypath(self.alpha)];
        self.scale = [decoder decodeFloatForKey:@keypath(self.scale)];
        self.frameIndexOffset = [decoder decodeIntegerForKey:@keypath(self.frameIndexOffset)];
        self.filterId = [decoder decodeObjectForKey:@keypath(self.filterId)];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeFloat:self.alpha forKey:@keypath(self.alpha)];
    [encoder encodeFloat:self.scale forKey:@keypath(self.scale)];
    [encoder encodeInteger:self.frameIndexOffset forKey:@keypath(self.frameIndexOffset)];
    [encoder encodeObject:self.filterId forKey:@keypath(self.filterId)];
}
@end