//
// Created by BLACKGENE on 7/26/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageSetAnimatableLayer.h"
#import "STCapturedImageSet.h"
#import "STCapturedImage.h"


@implementation STCapturedImageSetAnimatableLayer {
    NSArray<STCapturedImage *> * _originalImagesOfImageSet;
}

- (instancetype)initWithImageSet:(STCapturedImageSet *)imageSet {
    self = [super initWithImageSet:imageSet];
    if (self) {
        _originalImagesOfImageSet = [self.imageSet.images copy];
    }

    return self;
}

- (void)setFrameIndexOffset:(NSInteger)frameIndexOffset {
    BOOL valid = ABS(_frameIndexOffset) < self.frameCount;
    NSAssert(valid,@"ABS frameIndexOffset is lower than frameCount");
    _frameIndexOffset = valid ? frameIndexOffset : 0;

    [self.imageSet.images sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [self indexByFrameIndexOffset:[_originalImagesOfImageSet indexOfObject:obj1]]
                > [self indexByFrameIndexOffset:[_originalImagesOfImageSet indexOfObject:obj2]]
                ? NSOrderedAscending : NSOrderedDescending;
    }];
    NSAssert(_frameIndexOffset!=0 || (_frameIndexOffset==0 && ((STCapturedImage *)self.imageSet.images[0]).index==0),@"frame indexOffset was wrongly mapped.");
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