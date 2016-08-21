//
// Created by BLACKGENE on 8/19/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMultiSourcingGPUImageComposerProcessor.h"

@class STRasterizingImageSourceItem;


@interface STGIFFDisplayLayerJulieCockburnEffect : STMultiSourcingGPUImageComposerProcessor
@property (nonatomic, readwrite) STRasterizingImageSourceItem * maskedImageSource;
@end