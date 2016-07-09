//
// Created by BLACKGENE on 7/9/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "STAfterImageLayerItem.h"


@implementation STAfterImageLayerItem {

}

NSString * const kAlpha = @"kAlpha";
- (void)setAlpha:(CGFloat)alpha {
    _alpha = alpha;
    [self setValue:@(alpha) forKey:kAlpha];
}

NSString * const kFrameIndexOffset = @"kFrameIndexOffset";
- (void)setFrameIndexOffset:(NSInteger)frameIndexOffset {
    _frameIndexOffset = frameIndexOffset;
    [self setValue:@(frameIndexOffset) forKey:kAlpha];
}

NSString * const kFilterId = @"kFilterId";
- (void)setFilterId:(NSString *)filterId {
    _filterId = filterId;
    [self setValue:filterId forKey:kFilterId];
}

- (instancetype)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        NSParameterAssert(!!data[kAlpha]);
        NSParameterAssert(!!data[kFrameIndexOffset]);
        NSParameterAssert(!!data[kFilterId]);
        self.alpha = [data[kAlpha] floatValue];
        self.frameIndexOffset = [data[kFrameIndexOffset] integerValue];
        self.filterId = data[kFilterId];
    }
    return self;
}

+ (instancetype)itemWithData:(NSDictionary *)data {
    return [[self alloc] initWithData:data];
}

@end