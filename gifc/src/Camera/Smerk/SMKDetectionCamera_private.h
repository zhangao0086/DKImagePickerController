//
//  SMKDetectorView_private.h
//  Smerk
//
//  Created by teejay on 1/22/14.
//  Copyright (c) 2014 Smerk. All rights reserved.
//

#import "GPUImage.h"
#import "SMKDetectionCamera.h"

/**
 *  These methods are defined as private because you shouldn't need to modify them for basic detection.
 *  For more advanced detection, feel free to modify these variables and this class as you wish, but I may not be able to help you resolve issues with those changes.
 */

@interface SMKDetectionCamera ()

@property (weak) id<SMKDetectionDelegate> detectionDelegate;
@property (copy) SMKDetectionBlock detectBlock;

//Properties relating to kFaceFeatures
@property NSArray *coreImageFaceFeatures;
@property CIDetector *faceDetector;
@property CGRect clap;
@property NSInteger idleCount;
@property BOOL processingInProgress;

//Properties relating to kFaceMetadata
@property AVCaptureMetadataOutput *faceOutput;

//Properties relating to kMachineReadableMetaData
@property AVCaptureMetadataOutput *codeOutput;

//Properties relating to kMachineAndFaceMetaData
@property AVCaptureMetadataOutput *mixedOutput;

@end


