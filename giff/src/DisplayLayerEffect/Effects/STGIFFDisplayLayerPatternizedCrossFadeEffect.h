//
// Created by BLACKGENE on 8/13/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STGIFFDisplayLayerProcessingComposersEffect.h"


@interface STGIFFDisplayLayerPatternizedCrossFadeEffect : STGIFFDisplayLayerProcessingComposersEffect
@property (nonatomic, readwrite) NSString * patternImageName;
@property (nonatomic, assign) CGFloat scaleOfFadingImage;
@end