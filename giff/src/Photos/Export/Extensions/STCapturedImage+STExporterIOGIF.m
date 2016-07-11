//
// Created by BLACKGENE on 7/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImage+STExporterIOGIF.h"
#import "BlocksKit.h"


@implementation STCapturedImage (STExporterIOGIF)

DEFINE_ASSOCIATOIN_KEY(kFrameImageURLToExportGIF)

- (NSURL *)frameImageURLToExportGIF {
    return [self bk_associatedValueForKey:kFrameImageURLToExportGIF];
}

- (void)setFrameImageURLToExportGIF:(NSURL *)frameImageURLToExportGIF {
    [self bk_associateValue:frameImageURLToExportGIF withKey:kFrameImageURLToExportGIF];
}

@end