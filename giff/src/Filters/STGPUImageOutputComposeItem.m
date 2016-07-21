//
// Created by BLACKGENE on 7/21/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGPUImageOutputComposeItem.h"
#import "GPUImageTwoInputFilter.h"

@implementation STGPUImageOutputComposeItem
- (instancetype)initWithSource:(GPUImageOutput *)source composer:(GPUImageTwoInputFilter *)composer {
    self = [super init];
    if (self) {
        self.source = source;
        self.composer = composer;
    }

    return self;
}

+ (instancetype)itemWithSource:(GPUImageOutput *)source composer:(GPUImageTwoInputFilter *)composer {
    return [[self alloc] initWithSource:source composer:composer];
}


@end