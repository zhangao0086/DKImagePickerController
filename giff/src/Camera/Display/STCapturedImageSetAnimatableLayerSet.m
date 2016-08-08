//
// Created by BLACKGENE on 7/18/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageSetAnimatableLayerSet.h"
#import "STCapturedImageSet.h"
#import "STCapturedImageSetDisplayLayer.h"
#import "NSArray+STUtil.h"
#import "STCapturedImageSetAnimatableLayer.h"

@implementation STCapturedImageSetAnimatableLayerSet

- (void)setLayers:(NSArray *)layers {
    [self updateFrameCountAndRemapLayers:layers];
    super.layers = layers;
}

- (void)updateFrameCountAndRemapLayers:(NSArray *)layers{
    NSArray * sortedLayers = [layers sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(STCapturedImageSetDisplayLayer * layer1, STCapturedImageSetDisplayLayer * layer2) {
        return layer1.imageSet.count > layer2.imageSet.count ? NSOrderedDescending : NSOrderedSame;
    }];

    _frameCount = [[sortedLayers lastObject] imageSet].count;

    for(STCapturedImageSetAnimatableLayer * layer in sortedLayers){
        //perform remap
        NSArray * remappedArray = [[layer imageSet].images arrayByInterpolatingRemappedCount:_frameCount];
        [[layer imageSet].images removeAllObjects];
        [[layer imageSet].images addObjectsFromArray:remappedArray];
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        self.frameIndexOffset = [decoder decodeIntegerForKey:@keypath(self.frameIndexOffset)];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeInteger:self.frameIndexOffset forKey:@keypath(self.frameIndexOffset)];
}

@end