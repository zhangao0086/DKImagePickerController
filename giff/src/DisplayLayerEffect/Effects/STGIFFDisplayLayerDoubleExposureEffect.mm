//
// Created by BLACKGENE on 8/17/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerDoubleExposureEffect.h"
#import "GPUImagePicture.h"
#import "STGPUImageOutputComposeItem.h"
#import "UIImage+DisplayLayerEffect.h"
#import "GrabCutManager.h"
#import "NYXImagesKit.h"
#import "UIImage+ResizeMagick.h"

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

@implementation STGIFFDisplayLayerDoubleExposureEffect {
    GrabCutManager * _manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _manager = [[GrabCutManager alloc] init];
    }

    return self;
}


- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {

    UIImage * sourceImage = sourceImages[0];

    return [_manager doGrabCut:sourceImage
               foregroundBound:CGRectInset(CGRectMakeWithSize_AGK(sourceImage.size), sourceImage.size.width/3, sourceImage.size.height/3)
                iterationCount:5];
}


- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
    STGPUImageOutputComposeItem * composeItemB = [STGPUImageOutputComposeItem new];
    composeItemB.source = [[GPUImagePicture alloc] initWithImage:[sourceImages[0] removeEdgeMaskedBackground] smoothlyScaleOutput:NO];

    return @[composeItemB];
}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    return [super composersToProcessSingle:sourceImage];
}

@end