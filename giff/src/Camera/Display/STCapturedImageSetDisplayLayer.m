//
// Created by BLACKGENE on 7/26/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageSetDisplayLayer.h"
#import "STCapturedImageSet.h"


@implementation STCapturedImageSetDisplayLayer {

}
- (instancetype)initWithImageSet:(STCapturedImageSet *)imageSet {
    self = [super init];
    if (self) {
        _imageSet = imageSet;
    }

    return self;
}

+ (instancetype)layerWithImageSet:(STCapturedImageSet *)imageSet {
    return [[self alloc] initWithImageSet:imageSet];
}

@end