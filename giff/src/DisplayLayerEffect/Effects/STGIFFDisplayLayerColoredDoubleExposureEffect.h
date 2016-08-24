//
// Created by BLACKGENE on 8/10/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMultiSourcingImageProcessor.h"
#import "STMultiSourcingGPUImageComposerProcessor.h"


typedef NS_ENUM(NSInteger, ColoredDoubleExposureEffectColorBlendingStyle) {
    ColoredDoubleExposureEffectBlendingStyleTwoColors,
    ColoredDoubleExposureEffectBlendingStyleSolid
};

@interface STGIFFDisplayLayerColoredDoubleExposureEffect : STMultiSourcingGPUImageComposerProcessor
@property (nonatomic, assign) ColoredDoubleExposureEffectColorBlendingStyle style;
@property (nonatomic, readwrite) NSArray<UIColor *> * primary2ColorSet;
@property (nonatomic, readwrite) NSArray<UIColor *> * secondary2ColorSet;

@end