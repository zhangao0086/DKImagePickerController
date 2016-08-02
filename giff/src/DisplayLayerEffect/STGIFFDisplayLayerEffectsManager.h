//
// Created by BLACKGENE on 8/1/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STCapturedImageSetDisplayLayerSet;
@class STCapturedImageSet;
@class STCapturedImageSetAnimatableLayerSet;
@class STMultiSourcingImageProcessor;
@class STGIFFDisplayLayerEffectItem;


@interface STGIFFDisplayLayerEffectsManager : NSObject
+ (STGIFFDisplayLayerEffectsManager *)sharedManager;

- (NSArray <STGIFFDisplayLayerEffectItem *> *)effects;

- (STCapturedImageSetAnimatableLayerSet *)createLayerSetFrom:(STCapturedImageSet *)imageSet withEffect:(NSString *)classString;

- (STMultiSourcingImageProcessor *)acquireLayerEffect:(NSString *)classString forLayerSet:(STCapturedImageSetAnimatableLayerSet *)layerSet;

- (void)prepareLayerEffectFrom:(STCapturedImageSet *)sourceImageSet forLayerSet:(STCapturedImageSetDisplayLayerSet *)layerSet;
@end