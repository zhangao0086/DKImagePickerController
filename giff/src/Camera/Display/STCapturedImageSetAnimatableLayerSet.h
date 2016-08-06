//
// Created by BLACKGENE on 7/18/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCapturedImageSetDisplayLayerSet.h"


@interface STCapturedImageSetAnimatableLayerSet : STCapturedImageSetDisplayLayerSet
@property (nonatomic, assign) NSInteger frameIndexOffset;
@property (nonatomic, readonly) NSUInteger frameCount;
@end