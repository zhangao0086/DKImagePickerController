//
// Created by BLACKGENE on 7/8/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageItem.h"
#import "STAfterImageLayerItem.h"


@implementation STAfterImageItem {

}

NSString * const kUuid = @"kUuid";
- (void)setUuid:(NSString *)uuid {
    _uuid = uuid;
    [self setValue:uuid forKey:kUuid];
}

NSString * const kLayers = @"kLayers";
- (void)setLayers:(NSArray *)layers {
#if DEBUG
    for(id element in layers){
        NSAssert([element isKindOfClass:[STAfterImageLayerItem class]], @"elements of layers is not STAfterImageLayerItem");
    }
#endif
    _layers = layers;
    [self setValue:layers forKey:kLayers];
}

- (instancetype)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        NSParameterAssert(!!data[kUuid]);
        NSParameterAssert(!!data[kLayers]);
        self.uuid = data[kUuid];
        self.layers = data[kLayers];
    }
    return self;
}

+ (instancetype)itemWithData:(NSDictionary *)data {
    return [[self alloc] initWithData:data];
}

@end