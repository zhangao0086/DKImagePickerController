//
// Created by BLACKGENE on 8/13/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMultiSourcingGPUImageComposerProcessor.h"


@interface STGIFFDisplayLayerCrossFadeMaskEffect : STMultiSourcingGPUImageComposerProcessor
@property (nonatomic, readonly) NSArray<STGPUImageOutputComposeItem *> * composerItemsOfSourceImages;
@property (nonatomic, readwrite) NSString * maskImageName;
@property (nonatomic, readwrite) UIImage * maskImage;
@property (nonatomic, assign) BOOL invertMaskImage;
@property (nonatomic, assign) CGAffineTransform transformFadingImage;
@end