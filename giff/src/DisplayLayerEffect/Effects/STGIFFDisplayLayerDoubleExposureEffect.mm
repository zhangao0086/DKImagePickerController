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
#import "NSObject+BNRTimeBlock.h"
#import "UIView+STUtil.h"
#import "NSArray+STUtil.h"

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

    CGSize sssize = [@[
            [[UIView alloc] initWithSize:CGSizeMake(200, 100)], [[UIView alloc] initWithSize:CGSizeMake(4500, 100)], [[UIView alloc] initWithSize:CGSizeMake(2500, 600)], [[UIView alloc] initWithSize:CGSizeMake(2200, 300)], [[UIView alloc] initWithSize:CGSizeMake(260, 140)]
    ] findMaxSideScalarOfSizeForItemsKeyPath:@"size"];

    ss(sssize);

    sssize = [@[
            [[UIView alloc] initWithSize:CGSizeMake(200, 100)], [[UIView alloc] initWithSize:CGSizeMake(4500, 100)], [[UIView alloc] initWithSize:CGSizeMake(2500, 600)], [[UIView alloc] initWithSize:CGSizeMake(2200, 300)], [[UIView alloc] initWithSize:CGSizeMake(260, 140)]
    ] findMaxSizeByAreaForItemsKeyPath:@"size"];

    ss(sssize);

    __block UIImage * sourceImage = sourceImages[0];

    __block UIImage * resultImage = nil;

    [self ckTime:^{
        sourceImage = [sourceImage scaleToFitSize:CGSizeMakeValue(100)];

        //TODO: 성능을 위해 손실이 최소화되는 크기로 리사이즈 -> 프로세싱 -> 마스킹
        resultImage = [_manager doGrabCut:sourceImage
                   foregroundBound:CGRectInset(CGRectMakeWithSize_AGK(sourceImage.size), 1,1)
                    iterationCount:2];
    }];

    [self ckTime:^{
        resultImage = [resultImage gaussianBlurWithBias:200];
    }];


    return resultImage;
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