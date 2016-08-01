//
// Created by BLACKGENE on 8/1/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STCapturedImageSetDisplayLayerSet;
@class STCapturedImageSet;
@class STCapturedImageSetAnimatableLayerSet;


@interface STGIFFDisplayLayerEffectsManager : NSObject
+ (STGIFFDisplayLayerEffectsManager *)sharedManager;

- (STCapturedImageSetAnimatableLayerSet *)createLayerSetFrom:(STCapturedImageSet *)imageSet effectClass:(NSString *)classString;

- (void)prepareLayerEffect:(STCapturedImageSetDisplayLayerSet *)layerSet sourceSet:(STCapturedImageSet *)sourceSet;
@end