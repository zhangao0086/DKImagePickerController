//
//  DKCamera.h
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/7/4.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>


@interface NSBundle(DKCameraExtension)
+ (NSBundle *)cameraBundle;
@end


@interface DKCameraResource : NSObject

+ (UIImage *)imageForResource:(NSString *)name;
+ (UIImage *)cameraCancelImage;
+ (UIImage *)cameraFlashOnImage;
+ (UIImage *)cameraFlashAutoImage;
+ (UIImage *)cameraFlashOffImage;
+ (UIImage *)cameraSwitchImage;

@end

typedef enum : NSUInteger {
    DKCameraDeviceSourceFrontType,
    DKCameraDeviceSourceRearType,
} DKCameraDeviceSourceType;


@interface DKCamera : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, copy) void(^didCancel)();
@property (nonatomic, copy) void (^didFinishCapturingImage)(UIImage * image);
@property (nonatomic, copy) void(^onFaceDetection)(NSArray<AVMetadataFaceObject *>*faces);
@property (nonatomic, strong) UIView * cameraOverlayView;
@property (nonatomic, assign) AVCaptureFlashMode flashMode;
@property (nonatomic, strong) UIButton * flashButton;
@property (nonatomic, assign) BOOL allowsRotate;
@property (nonatomic, assign) BOOL showsCameraControls;
@property (nonatomic, strong) UIView * contentView;
@property (nonatomic, strong) AVCaptureSession * captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * previewLayer;
@property (nonatomic, assign) DKCameraDeviceSourceType defaultCaptureDevice;
@property (nonatomic, strong) AVCaptureDevice * currentDevice;
@property (nonatomic, strong) AVCaptureDevice * captureDeviceFront;
@property (nonatomic, strong) AVCaptureDevice * captureDeviceRear;
@property (nonatomic, assign) UIDeviceOrientation originalOrientation;
@property (nonatomic, assign) UIDeviceOrientation currentOrientation;
@property (nonatomic, strong) CMMotionManager * motionManager;
@property (nonatomic, strong) UIButton * cameraSwitchButton;
@property (nonatomic, strong) UIButton * captureButton;
@property (nonatomic, assign) BOOL shouldAutorotate;
+ (BOOL)isAvailable;
+ (void)checkCameraPermission:(void(^)(BOOL granted))handler;

@end
