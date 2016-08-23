//
// Created by BLACKGENE on 7/20/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMultiSourcingImageProcessor.h"
#import "STMultiSourcingGPUImageComposerProcessor.h"

@class STRasterizingImageSourceItem;


@interface STGIFFDisplayLayerLeifSteppingShapeMaskEffect : STMultiSourcingGPUImageComposerProcessor
@property (nonatomic, assign) CGFloat minScaleOfShape;
@property (nonatomic, assign) CGFloat maxScaleOfShape;
@property (nonatomic, assign) NSUInteger countOfShape;
@property (nonatomic, readwrite) STRasterizingImageSourceItem * maskImageForShape;
@end