//
// Created by BLACKGENE on 7/19/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCapturedImageSetDisplayableMultiSourceProcessor.h"


@interface STGIFFDisplayLayerFrameSwappingColorizeBlendEffect : STCapturedImageSetDisplayableMultiSourceProcessor
@property (nonatomic, assign) NSInteger frameIndexOffset;
@property (nonatomic, assign) CGFloat alpha;
@end