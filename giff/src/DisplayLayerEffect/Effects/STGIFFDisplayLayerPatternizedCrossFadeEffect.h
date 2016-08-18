//
// Created by BLACKGENE on 8/13/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMultiSourcingGPUImageComposerProcessor.h"


@interface STGIFFDisplayLayerPatternizedCrossFadeEffect : STMultiSourcingGPUImageComposerProcessor
@property (nonatomic, readwrite) NSString * patternImageName;
@property (nonatomic, assign) CGAffineTransform transformFadingImage;
@end