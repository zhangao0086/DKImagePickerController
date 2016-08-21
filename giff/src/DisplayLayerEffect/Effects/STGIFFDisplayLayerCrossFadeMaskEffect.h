//
// Created by BLACKGENE on 8/13/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMultiSourcingGPUImageComposerProcessor.h"

@class STRasterizingImageSourceItem;


@interface STGIFFDisplayLayerCrossFadeMaskEffect : STMultiSourcingGPUImageComposerProcessor
@property (nonatomic, readwrite) STRasterizingImageSourceItem * maskImageSource;
@property (nonatomic, assign) BOOL invertMaskImage;
@property (nonatomic, assign) CGAffineTransform transformFadingImage;
@end