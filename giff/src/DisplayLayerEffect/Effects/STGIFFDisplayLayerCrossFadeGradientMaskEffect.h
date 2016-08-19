//
// Created by BLACKGENE on 8/19/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMultiSourcingImageProcessor.h"

typedef NS_ENUM(NSInteger, CrossFadeGradientMaskEffectStyle) {
    CrossFadeGradientMaskEffectStyleLinearVertical,
    CrossFadeGradientMaskEffectStyleLinearHorizontal,
    CrossFadeGradientMaskEffectStyleRadial
};

@interface STGIFFDisplayLayerCrossFadeGradientMaskEffect : STMultiSourcingImageProcessor
@property (nonatomic, assign) CrossFadeGradientMaskEffectStyle style;
@end