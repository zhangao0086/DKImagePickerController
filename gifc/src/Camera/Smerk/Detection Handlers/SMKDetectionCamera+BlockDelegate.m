//
//  SMKDetectionCamera+BlockDelegate.m
//  Smerk
//
//  Created by teejay on 1/25/14.
//  Copyright (c) 2014 Smerk. All rights reserved.
//

#import "SMKDetectionCamera+BlockDelegate.h"
#import "SMKDetectionCamera_private.h"

@implementation SMKDetectionCamera (BlockDelegate)

- (void)detectorWillOuputFaceFeatures:(NSArray *)faceFeatureObjects inClap:(CGRect)clap
{
    self.detectBlock(kFaceFeatures, faceFeatureObjects, clap);
}

- (void)detectorWillOuputFaceMetadata:(NSArray *)faceMetadataObjects
{
    self.detectBlock(kFaceMetaData, faceMetadataObjects, CGRectZero);
}

- (void)detectorWillOuputMachineReadableMetadata:(NSArray *)machineReadableMetadataObjects
{
    self.detectBlock(kMachineReadableMetaData, machineReadableMetadataObjects, CGRectZero);
}

- (void)detectorWillOuputMachineAndFaceMetadata:(NSArray *)mixedMetadataObjects
{
    self.detectBlock(kMachineAndFaceMetaData, mixedMetadataObjects, CGRectZero);
}

@end
