//
// Created by BLACKGENE on 8/19/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMultiSourcingImageProcessor.h"
#import "STMultiSourcingGPUImageComposerProcessor.h"

typedef NS_ENUM(NSInteger, CrossFadeGradientMaskEffectStyle) {
    CrossFadeGradientMaskEffectStyleLinearVertical,
    CrossFadeGradientMaskEffectStyleLinearHorizontal,
    CrossFadeGradientMaskEffectStyleRadial
};

@interface STGIFFDisplayLayerCrossFadeGradientMaskEffect : STMultiSourcingGPUImageComposerProcessor
@property (nonatomic, assign) CrossFadeGradientMaskEffectStyle style;
@property (nullable, copy) NSArray<NSNumber *> *locations;
@property (nonatomic, assign) BOOL automaticallyMatchUpColors;

+ (UIImage *)crossFadingGradientMaskImageByStyle:(CrossFadeGradientMaskEffectStyle)style size:(CGSize)size locations:(NSArray<NSNumber *> *)locations;
@end