//
// Created by Lee on 14. 7. 10..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CMMotionManager.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SMKDetectionCamera.h"

@class STElieCamera;
@class GPUImageFilter;
@class GPUImageView;
@class STCaptureRequest;
@class STOrientationItem;
@class STOrientationItem;
@class STAnimatableCaptureRequest;
@class STCaptureRequest;
@class STPostFocusCaptureRequest;

typedef NS_ENUM(NSInteger, STCameraMode) {
    STCameraModeNotInitialized,
    STCameraModeElie,
    STCameraModeEliePause,
    STCameraModeManual,
    STCameraModeManualExitAndPause,
    STCameraModeManualQuick,
    STCameraModeManualWithElie
};

typedef NS_ENUM(NSInteger, STPostFocusMode) {
    STPostFocusModeNone,
    STPostFocusMode5Points,
    STPostFocusModeFullRange,
    STPostFocusModeVertical3Points,
    STPostFocusMode_count
};

#define DefaultCenterPointOfInterest CGPointMake(.51,.51)
CG_INLINE CGPoint
CGPointOfInterest(CGSize bounds, CGPoint pointInBounds)
{
    return CGPointNearestMax2DecimalPosition(CGPointMake(pointInBounds.y / bounds.height, 1.0f - (pointInBounds.x / bounds.width)));
}
CG_INLINE CGPoint
CGPointInBoundFromPointOfInterest(CGSize bounds, CGPoint pointOfInterestFromCamera)
{
    return CGPointNearestMax2DecimalPosition(CGPointMake((1.0f - pointOfInterestFromCamera.y) * bounds.width, pointOfInterestFromCamera.x * bounds.height));
}

CG_INLINE CGPoint
CGPointOfInterestInBound(CGSize bounds, CGPoint pointOfInterestFromCamera)
{
    CGPoint pointInBound = CGPointInBoundFromPointOfInterest(bounds, pointOfInterestFromCamera);
    return CGPointNearestMax2DecimalPosition(CGPointMake(pointInBound.x/bounds.width,pointInBound.y/bounds.height));
}

extern CGFloat const STElieCameraCurrentImageMaxSidePixelSize_FullDimension;
extern CGFloat const STElieCameraCurrentImageMaxSidePixelSize_OptimalFullScreen;
extern CGFloat const STElieCameraCurrentImageMaxSidePixelSize_ThumbnailPreview;

@interface STElieCamera : SMKDetectionCamera
//camera func
@property(nonatomic, getter=isFocusAdjusted, readonly) BOOL focusAdjusted;
@property(nonatomic, getter=isFocusLocked, readonly) BOOL focusRequestLocked;
@property(nonatomic, getter=isExposureAdjusted, readonly) BOOL exposureAdjusted;
@property(nonatomic, getter=isExposureRequestLocked, readonly) BOOL exposureRequestLocked;
@property(nonatomic, assign) CGFloat exposureBias;
@property(nonatomic, readonly) CGFloat maxAdjustingExposureBias;
@property(nonatomic, readonly) CGFloat minAdjustingExposureBias;
@property(nonatomic, assign) CGFloat zoomFactor;
@property(nonatomic, readonly) CGFloat zoomFactorNormalized;
@property(nonatomic, assign) CGFloat maxZoomFactor;
@property(atomic, readonly) BOOL changingFacingCamera;
@property(nonatomic, getter=isCapturing, readonly) BOOL capturing;
@property(nonatomic, readonly) CGFloat outputVerticalRatio;
@property(nonatomic, assign) float torchLight;

//detection
@property(atomic, readonly) BOOL faceDetectionStarted;
@property(nonatomic, getter=isMotionIdled, readonly) BOOL motionIdled;
@property(nonatomic, readonly) CGPoint pointNormalizedOfMotionDetected;
@property(nonatomic, assign) CGFloat preferredIntensityOfMotionDetection;
@property(nonatomic, readonly) CGFloat intensityOfMotionDetection;

//Abilities
@property(nonatomic, assign) BOOL enabledBacklightCare;

//utility
@property NSInteger exifOrientation;

+ (STElieCamera *)initSharedInstanceWithSessionPreset:(NSString *)preset position:(AVCaptureDevicePosition)position;

+ (STElieCamera *)sharedInstance;

+ (void)setMode:(STCameraMode)mode;

+ (STCameraMode)mode;

- (CGSize)outputScreenSize;

- (CGRect)outputScreenRect;

- (CGRect)outputRect:(CGRect)rect;

+ (CGFloat)outputVerticalRatioDefault;

- (BOOL)changeFacingCamera:(BOOL)toFront completion:(void (^)(BOOL changed))block;

- (void)startFaceDetectionWithBlock:(void (^)(NSArray * detectedObjects))block;

- (void)startFaceDetection:(id <SMKDetectionDelegate>)target1;

- (void)stopFaceDetection;

- (void)whenChangedRunnigStatus:(void (^)(BOOL running))block;

- (void)capture:(STCaptureRequest *)request;

- (void)captureAnimatable:(STAnimatableCaptureRequest *)request;

- (void)capturePostFocusing:(STPostFocusCaptureRequest *)request;

- (void)lockRendering;

- (void)unlockRendering;

- (GPUImageRotationMode)GPUImageInputRotation:(UIInterfaceOrientation)orientation;

- (UIImageOrientation)imageOrientationFromCurrentOutputOrientation;

- (void)startMotionDetection:(CGFloat)intensity withGyro:(BOOL)withGyro detectionBlock:(void (^)(CGPoint motionCentroid, CGFloat motionIntensity, CMTime frameTime, CMGyroData * gyroData))block;

- (void)stopMotionDetection;

- (void)startLuminosityDetection:(NSString *)id detectionBlock:(void (^)(CGFloat luminosity, CMTime frameTime))block;

- (BOOL)isRunningLuminosityDetection:(NSString *)id;

- (void)stopLuminosityDetection:(NSString *)id;

- (BOOL)startMonitoringSubjectAreaDidChanged;

- (BOOL)stopMonitoringSubjectAreaDidChanged;

- (void)addSubjectAreaChangeMonitor:(id)target block:(void (^)(void))block;

- (void)removeSubjectAreaChangeMonitor:(id)target;

- (BOOL)resetFocusExposure;

- (void)cancelRequestFocus;

- (BOOL)requestSingleFocus:(CGRect)previewRect pointInRect:(CGPoint)point completion:(void (^)(void))block;

- (BOOL)requestContinuousFocus:(CGRect)previewRect pointInRect:(CGPoint)point completion:(void (^)(void))block;

- (BOOL)requestContinuousFocus:(CGRect)previewRect pointInRect:(CGPoint)point syncWithExposure:(BOOL)sync completion:(void (^)(void))block;

- (BOOL)requestContinuousFocusWithCenter:(BOOL)syncWithExposure completion:(void (^)(void))block;

- (BOOL)requestFocus:(CGRect)previewRect pointInRect:(CGPoint)point continuous:(BOOL)continuous syncWithExposure:(BOOL)sync completion:(void (^)(void))block;

- (BOOL)requestSingleFocus:(CGRect)previewRect pointInRect:(CGPoint)point syncWithExposure:(BOOL)sync completion:(void (^)(void))block;

- (BOOL)requestExposure:(CGRect)previewRect pointInRect:(CGPoint)point continuous:(BOOL)continuous completion:(void (^)(void))block;

- (BOOL)requestExposureToFace:(CGRect)previewRect faceFrame:(CGRect)faceRect facePoint:(CGPoint)facePoint continuous:(BOOL)continuous completion:(void (^)(void))block;

- (void)lockRequestFocus;

- (void)lockRequestFocusAndUnlockAfterTime:(NSTimeInterval)seconds;

- (void)unlockRequestFocus;

- (BOOL)requestExposureToVirtualCenterFace:(BOOL)continuous completion:(void (^)(void))block;

- (void)lockRequestExposure;

- (void)lockRequestExposureAndUnlockAfterTime:(NSTimeInterval)seconds;

- (void)unlockRequestExposure;

- (void)lockExposure;

- (void)unlockExposure;

- (void)setFlashMode:(AVCaptureFlashMode)mode;

- (void)setZoomFactorSmoothly:(CGFloat)factor;

- (UIImage *)currentImage;

- (UIImage *)currentImage:(GPUImageOutput <GPUImageInput> *)needsOutput;

- (UIImage *)currentImageAsFullResolution:(GPUImageOutput <GPUImageInput> *)needsOutput;

- (UIImage *)currentImageAsThumbnailPreview;

- (UIImage *)currentImage:(GPUImageOutput <GPUImageInput> *)needsOutput maxSidePixelSizeOfOutput:(CGFloat)maxSidePixelSizeOfOutput;

- (BOOL)isPositionBack;

- (BOOL)isPositionFront;

- (void)activateLLBoostMode;

- (void)deactivateLLBoostMode;

@end

