//
// Created by BLACKGENE on 7/26/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageSetAnimatableLayer.h"
#import "STCapturedImageSet.h"


@implementation STCapturedImageSetAnimatableLayer {

}
- (void)setFrameIndexOffset:(NSInteger)frameIndexOffset {
    BOOL valid = ABS(_frameIndexOffset) < self.frameCount;
    NSAssert(valid,@"ABS frameIndexOffset is lower than frameCount");
    _frameIndexOffset = valid ? frameIndexOffset : 0;
}

- (NSUInteger)frameCount {
    return self.imageSet.count;
}

- (NSUInteger)indexByFrameIndexOffset:(NSUInteger)index{
    NSInteger const offset = self.frameIndexOffset;
    NSInteger const count = self.frameCount;

    NSUInteger indexOfDisplay = index;
    if(offset>0){
        indexOfDisplay = index >= offset ? (index - offset) : count - (offset - index);
    }else if(offset<0) {
        indexOfDisplay = index >= (count + offset) ? (index - offset) - count : (NSUInteger) -(offset - index);
    }
    return indexOfDisplay;
}

@end