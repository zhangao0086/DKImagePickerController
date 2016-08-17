//
// Created by BLACKGENE on 8/17/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerDoubleExposureEffect.h"
#import "GPUImagePicture.h"
#import "STGPUImageOutputComposeItem.h"
#import "UIImage+DisplayLayerEffect.h"


@implementation STGIFFDisplayLayerDoubleExposureEffect {

}

- (UIImage *__nullable)processImages:(NSArray<UIImage *> *__nullable)sourceImages {
    UIImage * sourceImage = sourceImages[0];
    return [sourceImage removeEdgeMaskedBackground];
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