//
// Created by BLACKGENE on 7/26/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCapturedImageSetDisplayLayer.h"


@interface STCapturedImageSetAnimatableLayer : STCapturedImageSetDisplayLayer
@property (nonatomic, readonly) NSUInteger frameCount;
//storing attributes
@property (nonatomic, assign) NSInteger frameIndexOffset;

- (NSUInteger)indexByFrameIndexOffset:(NSUInteger)index;
@end