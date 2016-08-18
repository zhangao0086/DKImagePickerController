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
#import "GPUImageGaussianBlurFilter.h"
#import "GPUImageContrastFilter.h"
#import "GPUImageContrastFilter+STGPUImageFilter.h"
#import "GPUImageMaskFilter.h"
#import "GPUImageSaturationFilter.h"
#import "GPUImageSaturationFilter+STGPUImageFilter.h"
#import "GPUImageBrightnessFilter.h"
#import "GPUImageBrightnessFilter+STGPUImageFilter.h"

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
    __block UIImage * sourceImage = sourceImages[0];


//    return [sourceImage removeEdgeMaskedBackground];

    __block UIImage * maskingImage = nil;

    [self ckTime:^{
        sourceImage = [sourceImage scaleToFitSize:CGSizeMakeValue(100)];

        //TODO: 성능을 위해 손실이 최소화되는 크기로 리사이즈 -> 프로세싱 -> 마스킹
        maskingImage = [_manager doGrabCut:sourceImage
                   foregroundBound:CGRectInset(CGRectMakeWithSize_AGK(sourceImage.size), 1,1)
                    iterationCount:2];
    }];

    CGFloat minSide = CGSizeMinSide([sourceImages findSizeByMinSideLengthForItemsKeyPath:@"size"]);

    ss(maskingImage.size);

    [self ckTime:^{
        GPUImagePicture * gpuImagePicture = [[GPUImagePicture alloc] initWithImage:maskingImage smoothlyScaleOutput:YES];

        GPUImageGaussianBlurFilter * blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
        blurFilter.blurRadiusInPixels = 1;
        [gpuImagePicture addTarget:blurFilter];

        [blurFilter useNextFrameForImageCapture];
        [gpuImagePicture processImage];
        maskingImage = [blurFilter imageFromCurrentFramebuffer];

        maskingImage = [maskingImage scaleToFitSize:CGSizeMakeValue(minSide)];

        UIGraphicsBeginImageContextWithOptions(maskingImage.size, NO, 3);
        [maskingImage drawInRect:CGRectMake(0, 0, maskingImage.size.width, maskingImage.size.height)];
        UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        maskingImage = imageCopy;

    }];

    ss(maskingImage.size);

//    return maskingImage;
    //TODO downscale되는 문제 수정(redraw하면 되지 않을까?)
    NSMutableArray * composers = [NSMutableArray array];

    STGPUImageOutputComposeItem * maskingComposeItem = [[STGPUImageOutputComposeItem alloc] init];
    [maskingComposeItem setSourceAsImage:maskingImage];
    maskingComposeItem.composer = [[GPUImageMaskFilter alloc] init];
    [composers addObject:maskingComposeItem];

    STGPUImageOutputComposeItem * composeItem0 = [[STGPUImageOutputComposeItem alloc] init];
    [composeItem0 setSourceAsImage:sourceImage];
    [composers addObject:composeItem0];

    return [self processComposers:[composers reverse]];

    return maskingImage;
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