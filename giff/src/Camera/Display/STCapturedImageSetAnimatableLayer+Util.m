//
// Created by BLACKGENE on 7/28/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageSetAnimatableLayer+Util.h"
#import "STCapturedImageSet.h"


@implementation STCapturedImageSetAnimatableLayer (Util)
- (NSUInteger)frameCount {
    return self.imageSet.count;
}

@end