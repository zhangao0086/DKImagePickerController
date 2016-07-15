//
// Created by BLACKGENE on 7/9/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageLayerItem.h"
#import "STAfterImageLayerEffect.h"
#import "NSString+STUtil.h"
#import "NSArray+STUtil.h"

@interface STAfterImageLayerItem(Private)
@property (nonatomic, readwrite) STAfterImageLayerItem * superlayer;
@end

@implementation STAfterImageLayerItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.scale = 1;
    }
    return self;
}

- (void)setLayers:(NSArray<STAfterImageLayerItem *> *)layers {
    for(STAfterImageLayerItem * layer in layers){
        NSAssert([layer isKindOfClass:[STAfterImageLayerItem class]], @"elements of layers is not STAfterImageLayerItem");
        layer.superlayer = self;
    }
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

- (NSArray *)processPresentableObjects:(NSArray *)presentableObjects {
    Weaks
    NSAssert([[presentableObjects firstObject] isKindOfClass:NSURL.class], @"now support only for NSURL yet.");

    return !self.effect ?
            presentableObjects :
            [presentableObjects mapWithIndex:^id(NSURL *imageUrl, NSInteger indexOfPresentableObject) {
        NSAssert([imageUrl isKindOfClass:NSURL.class], @"only NSURL was allowed.");

        @autoreleasepool {
            NSURL * tempURLToApplyEffect = [[NSString stringWithFormat:@"l_%@_e_%@_f_%d",
                                                                       Wself.uuid,
                                                                       Wself.effect.uuid,
                                                                       indexOfPresentableObject
            ] URLForTemp:@"filter_applied_after_image" extension:@"jpg"];

            if([[NSFileManager defaultManager] fileExistsAtPath:tempURLToApplyEffect.path]){
                //cached
                return tempURLToApplyEffect;

            }else{
                //newly create
                if([UIImageJPEGRepresentation([Wself.effect processEffect:[UIImage imageWithContentsOfFile:imageUrl.path]], 1)
                        writeToURL:tempURLToApplyEffect
                        atomically:NO]){
                    return tempURLToApplyEffect;
                }
            }
            return nil;
        }
    }];
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