//
// Created by BLACKGENE on 7/9/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageSetDisplayLayerSet.h"
#import "STMultiSourcingImageProcessor.h"
#import "NSArray+STUtil.h"
#import "STCapturedImageSet.h"
#import "STCapturedImageSetDisplayLayer.h"

@interface STCapturedImageSetDisplayLayerSet(Private)
@property (nonatomic, readwrite) STCapturedImageSetDisplayLayerSet * superlayer;
@end

@implementation STCapturedImageSetDisplayLayerSet


- (instancetype)initWithLayers:(NSArray *)layers {
    self = [super init];
    if (self) {
        self.layers = layers;
    }

    return self;
}

+ (instancetype)setWithLayers:(NSArray *)layers {
    return [[self alloc] initWithLayers:layers];
}

- (void)setLayers:(NSArray *)layers {
    if(layers.count){
        STCapturedImageSetDisplayLayer * layer0 = [layers firstObject];
        NSArray * arrayOfImageSetsCount = [layers mapWithItemsKeyPath:@keypath(layer0.imageSet.count)];
        NSAssert(layers.count == [[NSCountedSet setWithArray:arrayOfImageSetsCount] countForObject:@(layer0.imageSet.count)],
                @"all source image set's of Layer count is must be same");
        _layers = layers;
    }else{
        _layers = nil;
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        self.layers = [decoder decodeObjectForKey:@keypath(self.layers)];
        self.effect = [decoder decodeObjectForKey:@keypath(self.effect)];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.layers forKey:@keypath(self.layers)];
    [encoder encodeObject:self.effect forKey:@keypath(self.effect)];
}
 

@end