//
// Created by BLACKGENE on 7/20/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMultiSourcingImageProcessor.h"
#import "STMultiSourcingGPUImageComposerProcessor.h"

@class STRasterizingImageSourceItem;


@interface STGIFFDisplayLayerLeifEffect : STMultiSourcingGPUImageComposerProcessor
@property (nonatomic, assign) CGFloat minScaleOfCircle;
@property (nonatomic, assign) CGFloat maxScaleOfCircle;
@property (nonatomic, assign) NSUInteger countOfCirlce;
@property (nonatomic, readwrite) STRasterizingImageSourceItem * maskImageToDivideMultipleSourceImages;
@end