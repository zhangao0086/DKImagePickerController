//
//  SMKDetectorView.m
//  Smerk
//
//  Created by teejay on 1/22/14.
//  Copyright (c) 2014 Smerk. All rights reserved.
//

#import "SMKDetectionCamera_private.h"
#import "SMKDetectionCamera+BufferHandler.h"
#import "SMKDetectionCamera+MetadataHandler.h"
#import "SMKDetectionCamera+BlockDelegate.h"


@implementation SMKDetectionCamera

- (void)beginDetecting:(SMKDetectionOptions)options
          withDelegate:(id<SMKDetectionDelegate>)delegate
             codeTypes:(NSArray *)machineCodeTypesOrNil;
{
    @try {

        [self ensureStabilityOfOptionsViaAsserts:options
                                    withDelegate:delegate
                                       codeTypes:machineCodeTypesOrNil];

        self.detectionDelegate = delegate;

        if (options & kFaceFeatures) {
            self.delegate = self;

            NSDictionary *detectorOptions = @{CIDetectorAccuracy : CIDetectorAccuracyLow};
            self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
        } else {
            [self stopDetectionOfTypes:kFaceFeatures];
        }

        if (options & kFaceMetaData) {
            [self.captureSession removeOutput:self.faceOutput];

            self.faceOutput = [[AVCaptureMetadataOutput alloc] init];
            [self.faceOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            [self.captureSession addOutput:self.faceOutput];
            [self.faceOutput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
        } else {
            [self stopDetectionOfTypes:kFaceMetaData];
        }

        if (options & kMachineReadableMetaData) {
            [self.captureSession removeOutput:self.codeOutput];

            self.codeOutput = [[AVCaptureMetadataOutput alloc] init];
            [self.codeOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            [self.captureSession addOutput:self.codeOutput];
            [self.codeOutput setMetadataObjectTypes:machineCodeTypesOrNil];
        } else {
            [self stopDetectionOfTypes:kMachineReadableMetaData];
        }

        if (options & kMachineAndFaceMetaData) {
            [self.captureSession removeOutput:self.mixedOutput];

            self.mixedOutput = [[AVCaptureMetadataOutput alloc] init];
            [self.mixedOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            [self.captureSession addOutput:self.mixedOutput];
            [self.mixedOutput setMetadataObjectTypes:[machineCodeTypesOrNil arrayByAddingObject:AVMetadataObjectTypeFace]];
        } else {
            [self stopDetectionOfTypes:kMachineAndFaceMetaData];
        }

    }@finally {}
}

- (void)beginDetecting:(SMKDetectionOptions)options
             codeTypes:(NSArray *)machineCodeTypesOrNil
    withDetectionBlock:(SMKDetectionBlock)detectionBlock
{
    [self beginDetecting:options withDelegate:self codeTypes:machineCodeTypesOrNil];
    self.detectBlock = detectionBlock;
}

- (void)stopDetectionOfTypes:(SMKDetectionOptions)options
{
    if (options & kFaceFeatures) {
        self.delegate = nil;
    }
    
    if (options & kFaceMetaData) {
        [self.captureSession removeOutput:self.faceOutput];
        self.faceOutput = nil;
    }
    
    if (options & kMachineReadableMetaData) {
        [self.captureSession removeOutput:self.codeOutput];
        self.codeOutput = nil;
    }
    
    if (options & kMachineAndFaceMetaData) {
        [self.captureSession removeOutput:self.mixedOutput];
        self.mixedOutput = nil;
    }
}

- (void)stopAllDetection
{
    [self stopDetectionOfTypes:kMachineReadableMetaData | kFaceMetaData | kFaceFeatures | kMachineAndFaceMetaData];
}


#pragma mark Asserts
- (void)ensureStabilityOfOptionsViaAsserts:(SMKDetectionOptions)options
                              withDelegate:(id<SMKDetectionDelegate>)delegate
                                 codeTypes:(NSArray *)machineCodeTypesOrNil
{
    
    NSAssert(!(options & kFaceMetaData && options & kMachineReadableMetaData), @"Do not use both kFaceMetaData && kMachineReadableMetaData, instead use kMachineAndFaceMetaData");
    NSAssert(!(options & kFaceMetaData && options & kMachineAndFaceMetaData), @"Do not use kFaceMetaData with kMachineAndFaceMetaData, just use kMachineAndFaceMetaData");
    NSAssert(!(options & kMachineAndFaceMetaData && options & kMachineReadableMetaData), @"Do not use kMachineReadableMetaData with kMachineAndFaceMetaData, just use kMachineAndFaceMetaData");
    
    if (options & kFaceMetaData) {
        NSAssert([delegate respondsToSelector:@selector(detectorWillOuputFaceMetadata:)], @"Your detection delegate must respond to detectorWillOuputFaceMetadata: in order to detect kFaceMetadata");
    }
    
    if (options & kMachineReadableMetaData) {
        NSAssert([delegate respondsToSelector:@selector(detectorWillOuputMachineReadableMetadata:)], @"Your detection delegate must respond to detectorWillOuputMachineReadableMetadata: in order to detect kMachineReadableMetaData");
        NSAssert(machineCodeTypesOrNil.count, @"If you'd like to track machine codes, you need to supply an array of types to track");
    }
    
    if (options & kMachineAndFaceMetaData) {
        NSAssert([delegate respondsToSelector:@selector(detectorWillOuputMachineAndFaceMetadata:)], @"Your detection delegate must respond to detectorWillOuputMachineAndFaceMetadata: in order to detect kMachineAndFaceMetaData");
        NSAssert(machineCodeTypesOrNil.count, @"If you'd like to track machine codes, you need to supply an array of types to track");
    }
    
    if (options & kFaceFeatures) {
        NSAssert([delegate respondsToSelector:@selector(detectorWillOuputFaceFeatures:inClap:)], @"Your detection delegate must respond to detectorWillOutputFaceFeatures:inClap: in order to detect kFaceFeatures");
    }
    
}

@end
