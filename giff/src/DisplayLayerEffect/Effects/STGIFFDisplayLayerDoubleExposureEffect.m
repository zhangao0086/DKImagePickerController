//
// Created by BLACKGENE on 8/17/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFFDisplayLayerDoubleExposureEffect.h"


@implementation STGIFFDisplayLayerDoubleExposureEffect {

}

- (NSArray *)composersToProcessMultiple:(NSArray<UIImage *> *__nullable)sourceImages {
    return [super composersToProcessMultiple:sourceImages];
}

- (NSArray *)composersToProcessSingle:(UIImage *)sourceImage {
    return [super composersToProcessSingle:sourceImage];
}

@end