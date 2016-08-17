//
// Created by BLACKGENE on 8/10/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMultiSourcingImageProcessor.h"
#import "STGIFFDisplayLayerProcessingComposersEffect.h"


@interface STGIFFDisplayLayerAfterImagePopStarEffect : STGIFFDisplayLayerProcessingComposersEffect
@property (nonatomic, readwrite) NSArray<UIColor *> * colors;
@end