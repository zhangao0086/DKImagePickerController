//
//  SMKDetectorView.h
//  Smerk
//
//  Created by teejay on 1/22/14.
//  Copyright (c) 2014 Smerk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImageStillCamera.h"

/**
 *  Options to define what you'd like to detect with your camera.
 */
typedef NS_OPTIONS(NSUInteger, SMKDetectionOptions) {
    /**
     *  This will output CIFaceFeatures using a CIDetector.
     */
    kFaceFeatures               = 1 << 0,
    /**
     *  This will output AVMetadataFaceObjects using AVCaptureMetadataOutput
     */
    kFaceMetaData               = 1 << 1,
    /**
     *  This will output AVMetadataMachineReadableCodeObjects using AVCaptureMetadataOutput
     */
    kMachineReadableMetaData    = 1 << 2,
    
    /**
     *  This will allow you to output both kMachineReadableMetaData and kFaceMetaData
     */
    kMachineAndFaceMetaData     = 1 << 3
};


/**
 *  Delegate protocol for notification of detection or lack there of, ie: detectorWillOutputFaceFeatures may return an empty faceFeatureObjects array.
 */
@protocol SMKDetectionDelegate <NSObject>

@optional

/**
 *  Callback for kFaceFeatures option.
 *
 *  @param faceFeatureObjects           Array containing CIFaceFeature objects, or empty array if none detected.
 *  @param clap                         Use in conjunction with current device orientation to translate CIFaceFeatures to bounds in presenter being displayed to user.
 *
 *                                      See GPUImage's Filter Showcase or Apple's SquareCamDemo for examples of this.
 */
- (void)detectorWillOuputFaceFeatures:(NSArray *)faceFeatureObjects inClap:(CGRect)clap;
/**
 *  Callback for kFaceMetadata option
 *
 *  @param faceMetadataObjects          Array containing face metadata objects, or empty array if none detected.
 */
- (void)detectorWillOuputFaceMetadata:(NSArray *)faceMetadataObjects;
/**
 *  Callback for kMachineReadableMetaData option
 *
 *  @param machineReadableMetadataObjects          Array containing machine readable metadata objects, or empty array if none detected.
 */
- (void)detectorWillOuputMachineReadableMetadata:(NSArray *)machineReadableMetadataObjects;

/**
 *  Callback for kMachineReadableMetaData option
 *
 *  @param mixedMetadataObjects                    Array containing mixed AVMetadataObjects both face and machine readable, or empty array if none detected.
 */
- (void)detectorWillOuputMachineAndFaceMetadata:(NSArray *)mixedMetadataObjects;

@end


/**
 *  If you prefer blocks over delegates, this is the block you will need to implement.
 *
 *  @param detectionType                This will signify the type of object stored in the detectedObjects array.
 *  @param detectedObjects              Objects detected, or empty array signifying no detection was possible.
 *  @param clapOrRectZero               Clap will only be returned for kFaceFeatures, use in conjunction with current device orientation to translate CIFaceFeatures 
 *                                      to bounds in presenter being displayed to user. See GPUImage's Filter Showcase or Apple's SquareCamDemo for examples of this.
 *                                      Will otherwise be CGRectZero.
 *
 */
typedef void (^SMKDetectionBlock)(SMKDetectionOptions detectionType, NSArray *detectedObjects, CGRect clapOrRectZero);

//Init as you would a regular GPUImageVideoCamera
@interface SMKDetectionCamera : GPUImageStillCamera

/**
 *  After initializing as you would a GPUImageVideoCupdateFaceMetadataTrackingViewWithObjectsamera or GPUImageStillCamera, call this method to begin detection
 *
 *  @param options               Types of objects to detect, can be used as joined or of options, ie: kFaceFeatures | kFaceMetaData will detect both 
 *                               features and metadata.
 *
 *  @param delegate              Delegate interested in receiving features as they are output
 *  @param machineCodeTypesOrNil For kMachineReadableMetaData, you must supply a type of machine code to detect ie: AVMetadataObjectTypeQRCode
 *
 *  All possible values for machineCodeTypesOrNil are defined here: https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVMetadataMachineReadableCodeObject_Class/Reference/Reference.html
 */
- (void)beginDetecting:(SMKDetectionOptions)options
          withDelegate:(id<SMKDetectionDelegate>)delegate
             codeTypes:(NSArray *)machineCodeTypesOrNil;


/**
 *  After initializing as you would a GPUImageVideoCamera or GPUImageStillCamera, call this method to begin detection
 *
 *  @param options               Types of objects to detect, can be used as joined or of options, ie: kFaceFeatures | kFaceMetaData will detect both
 *                               features and metadata.
 *
 *  @param delegate              Delegate interested in receiving features as they are output
 *  @param machineCodeTypesOrNil For kMachineReadableMetaData, you must supply a type of machine code to detect ie: AVMetadataObjectTypeQRCode
 *
 *  All possible values for machineCodeTypesOrNil are defined here: https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVMetadataMachineReadableCodeObject_Class/Reference/Reference.html
 */
- (void)beginDetecting:(SMKDetectionOptions)options
             codeTypes:(NSArray *)machineCodeTypesOrNil
    withDetectionBlock:(SMKDetectionBlock)detectionBlock;

/**
 *  Turn off specific detection types.
 *
 *  @param options               SMKDetectionOptions object/s, can be used as joined or of options, ie: kFaceFeatures | kFaceMetaData will turn off both.
 */
- (void)stopDetectionOfTypes:(SMKDetectionOptions)options;

/**
 *  Will stop all forms of detection, but will not stop camera capture, to stop camera capture, use usual GPUImageVideoCamera methods.
 */
- (void)stopAllDetection;

@end
