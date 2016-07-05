//
//  SMKDetectorView+MetadataHandler.m
//  Smerk
//
//  Created by teejay on 1/25/14.
//  Copyright (c) 2014 Smerk. All rights reserved.
//

#import "SMKDetectionCamera+MetadataHandler.h"

@implementation SMKDetectionCamera (MetadataHandler)

- (void)    captureOutput:(AVCaptureOutput *)captureOutput
 didOutputMetadataObjects:(NSArray *)metadataObjects
           fromConnection:(AVCaptureConnection *)connection
{
    if (captureOutput == self.faceOutput) {
        [self.detectionDelegate detectorWillOuputFaceMetadata:metadataObjects];
    }
    
    if (captureOutput == self.codeOutput) {
        [self.detectionDelegate detectorWillOuputMachineReadableMetadata:metadataObjects];
    }
    
    if (captureOutput == self.mixedOutput) {
        [self.detectionDelegate detectorWillOuputMachineAndFaceMetadata:metadataObjects];
    }
}


@end
