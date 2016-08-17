//
// Created by BLACKGENE on 7/21/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGPUImageOutputComposeItem.h"
#import "GPUImageTwoInputFilter.h"
#import "GPUImagePicture.h"

@implementation STGPUImageOutputComposeItem
- (instancetype)initWithSource:(GPUImageOutput *)source composer:(GPUImageTwoInputFilter *)composer {
    self = [super init];
    if (self) {
        self.source = source;
        self.composer = composer;
    }

    return self;
}

- (instancetype)initWithSource:(GPUImageOutput *)source {
    self = [super init];
    if (self) {
        self.source = source;
    }

    return self;
}

- (void)setFilters:(NSArray<GPUImageOutput <GPUImageInput> *> *)filters {
#if DEBUG
    for(id filter in filters){
        NSAssert(![filter isKindOfClass:GPUImageTwoInputFilter.class],@"GPUImageTwoInputFilter does not allowed.");
    }
#endif
    _filters = filters;

}


+ (instancetype)itemWithSource:(GPUImageOutput *)source {
    return [[self alloc] initWithSource:source];
}


+ (instancetype)itemWithSource:(GPUImageOutput *)source composer:(GPUImageTwoInputFilter *)composer {
    return [[self alloc] initWithSource:source composer:composer];
}

- (instancetype)setSourceAsImage:(UIImage *)image {
    self.source = [[GPUImagePicture alloc] initWithCGImage:[image CGImage]];
    return self;
}

@end