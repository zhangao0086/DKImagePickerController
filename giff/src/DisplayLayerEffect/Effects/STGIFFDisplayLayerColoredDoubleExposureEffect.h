//
// Created by BLACKGENE on 8/10/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMultiSourcingImageProcessor.h"
#import "STMultiSourcingGPUImageComposerProcessor.h"


@interface STGIFFDisplayLayerColoredDoubleExposureEffect : STMultiSourcingGPUImageComposerProcessor
@property (nonatomic, readwrite) NSArray<UIColor *> * primary2ColorSet;
@property (nonatomic, readwrite) NSArray<UIColor *> * secondary2ColorSet;

@end