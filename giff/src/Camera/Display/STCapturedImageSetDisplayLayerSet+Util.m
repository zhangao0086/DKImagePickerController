//
// Created by BLACKGENE on 7/28/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImageSetDisplayLayerSet+Util.h"
#import "STCapturedImageSetDisplayLayer.h"


@implementation STCapturedImageSetDisplayLayerSet (Util)

- (STCapturedImageSet *)firstImageSet {
    return [[[self layers] firstObject] imageSet];
}

@end