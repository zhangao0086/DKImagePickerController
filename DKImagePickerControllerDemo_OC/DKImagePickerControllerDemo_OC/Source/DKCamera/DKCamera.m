//
//  DKCamera.m
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/7/4.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKCamera.h"






@interface DKCaptureButton : UIButton

@end

@implementation DKCaptureButton

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    self.backgroundColor = [UIColor whiteColor];
    return  YES;
}


- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event   {
    self.backgroundColor = [UIColor whiteColor];
    return  YES;

}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    self.backgroundColor = nil;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event{
    self.backgroundColor = nil;
}

@end

@implementation NSBundle(DKCameraExtension)

+ (NSBundle *)cameraBundle{
    NSString * assetPath = [NSBundle bundleForClass:[DKCameraResource class]].resourcePath;
    
    return [NSBundle bundleWithPath:[assetPath stringByAppendingPathComponent:@"DKCameraResource.bundle"]];
}

@end

@implementation DKCameraResource

+ (UIImage *)imageForResource:(NSString *)name{
    NSBundle * bundle = [NSBundle cameraBundle];
    NSString * imagePath = [bundle pathForResource:name ofType:@"png" inDirectory:@"Images"];
    
    UIImage * image = [UIImage imageWithContentsOfFile:imagePath];
    return  image;
}

+ (UIImage *)cameraCancelImage{
    return [self imageForResource:@"camera_cancel"];
}

+ (UIImage *)cameraFlashOnImage{
    return [self imageForResource:@"camera_flash_on"];
}

+ (UIImage *)cameraFlashAutoImage{
    return [self imageForResource:@"camera_flash_auto"];
}

+ (UIImage *)cameraFlashOffImage{
    return [self imageForResource:@"camera_flash_off"];
}

+ (UIImage *)cameraSwitchImage{
    return [self imageForResource:@"camera_switch"];
}

@end


@interface DKCamera ()

@property (nonatomic, assign) CGFloat beginZoomScale;
@property (nonatomic, assign) CGFloat zoomScale;
@property (nonatomic, assign) BOOL isStopped;
@property (nonatomic, strong) UIView * focusView;
@property (nonatomic, strong) UIView * bottomView;
@property (nonatomic, weak) AVCaptureStillImageOutput * stillImageOutput;
@end

@implementation DKCamera

+ (void)checkCameraPermission:(void(^)(BOOL granted))handler{
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized) {
        handler(YES);
    }else if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(granted);
            });
        }];
    }else{
        handler(NO);
    }
}
+ (BOOL)isAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}
- (instancetype)init{
    if (self = [super init]) {
        _allowsRotate = NO;
        _showsCameraControls = YES;
        _contentView = [UIView new];
        _captureSession = [AVCaptureSession new];
        _beginZoomScale = 1.0;
        _zoomScale = 1.0;
        _defaultCaptureDevice = DKCameraDeviceSourceRearType;
        _motionManager = [CMMotionManager new];
        _isStopped = NO;
        _bottomView = [UIView new];
    }
    return self;
}
- (void)setShowsCameraControls:(BOOL)showsCameraControls{
    if (_showsCameraControls != showsCameraControls) {
        _showsCameraControls = showsCameraControls;
        self.contentView.hidden = !showsCameraControls;
    }
}
- (void)setCameraOverlayView:(UIView *)cameraOverlayView{
    if (_cameraOverlayView != cameraOverlayView) {
        _cameraOverlayView = cameraOverlayView;
        [self.view addSubview:_cameraOverlayView];
    }
    
    
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode{
    _flashMode = flashMode;
    [self updateFlashButton];
    [self updateFlashMode];
    [self updateFlashModeToUserDefautls:self.flashMode];
    
    
}

- (void)updateFlashModeToUserDefautls:(AVCaptureFlashMode)flashMode{
    [[NSUserDefaults standardUserDefaults] setObject:@(flashMode) forKey:@"DKCamera.flashMode"];
}

- (void)updateFlashMode{
    if (self.currentDevice && self.currentDevice.isFlashAvailable && [self.currentDevice isFlashModeSupported:self.flashMode]) {
        [self.currentDevice lockForConfiguration:nil];
        self.currentDevice.flashMode = self.flashMode;
        [_currentDevice unlockForConfiguration];
    }
}

- (void)updateFlashButton{
    UIImage * flashImage = [self flashImage:self.flashMode];
    [self.flashButton setImage:flashImage forState:UIControlStateNormal];
    [self.flashButton sizeToFit];
    
}


- (UIImage *)flashImage:(AVCaptureFlashMode)flashModel{
    UIImage * image;
    switch (flashModel) {
        case AVCaptureFlashModeAuto:
            image = [DKCameraResource cameraFlashAutoImage];
            break;
        case AVCaptureFlashModeOn:
            image = [DKCameraResource cameraFlashOnImage];
            break;
        case AVCaptureFlashModeOff:
            image = [DKCameraResource cameraFlashOffImage];
        default:
            break;
    }
    return image;
}
- (UIButton *)flashButton{
    if (!_flashButton) {
        _flashButton = [UIButton new];
        [_flashButton addTarget:self action:@selector(switchFlashMode) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _flashButton;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![self.captureSession isRunning]) {
        [self.captureSession startRunning];
        
    }
    
    if (!self.motionManager.isAccelerometerActive) {
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            if (!error) {
                UIDeviceOrientation currentOrientation = [DKCamera toDeviceOrientationFor:accelerometerData.acceleration] != UIDeviceOrientationUnknown ? [DKCamera toDeviceOrientationFor:accelerometerData.acceleration] : self.currentOrientation;
                
                if (self.currentOrientation == UIDeviceOrientationUnknown) {
                    [self initialOriginalOrientationForOrientation];
                    self.currentOrientation = self.originalOrientation;
                }
                
                if (self.currentOrientation != currentOrientation) {
                    self.currentOrientation = currentOrientation;
                    [self updateContentLayoutForCurrentOrientation];
                }
                
            }else{
                NSLog(@"error while update accelerometer:%@",error.localizedDescription);
            }
        }];
        [self updateSession:YES];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDevices];
    [self setupUI];
    [self setupSession];
    
    [self setupMotionManager];
    
    // Do any additional setup after loading the view.
}

- (void)setupMotionManager{
    self.motionManager.accelerometerUpdateInterval = 0.5;
    self.motionManager.gyroUpdateInterval = 0.5;
}
- (void)setupSession{
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    [self setupCurrentDevice];
    
   AVCaptureStillImageOutput * stillImageOutput = [AVCaptureStillImageOutput new];
    if ([self.captureSession canAddOutput:stillImageOutput]) {
        [self.captureSession addOutput:stillImageOutput];
        self.stillImageOutput = stillImageOutput;
    }
    
    if (self.onFaceDetection != nil) {
       AVCaptureMetadataOutput * metadataOutput = [AVCaptureMetadataOutput new];
        [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_queue_create("MetadataOutputQueue",  DISPATCH_QUEUE_CONCURRENT)];
        
        if ([self.captureSession canAddOutput:metadataOutput]) {
            [self.captureSession addOutput:metadataOutput];
            metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
        }
    }
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.view.bounds;
    
    CALayer * rootLayer = self.view.layer;
    rootLayer.masksToBounds = YES;
    [rootLayer insertSublayer:self.previewLayer atIndex:0];
}

#pragma mark -- AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (self.onFaceDetection) {
        self.onFaceDetection(metadataObjects);
    }
}

- (UIButton *)cameraSwitchButton{
    if (!_cameraSwitchButton) {
        _cameraSwitchButton = [UIButton new];
        [_cameraSwitchButton addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
        [_cameraSwitchButton setImage:[DKCameraResource cameraSwitchImage] forState:UIControlStateNormal];
        [_cameraSwitchButton sizeToFit];
    }
    return _cameraSwitchButton;
}

- (UIButton *)captureButton{
    if (!_captureButton) {
        CGFloat bottomViewHeight = 70;
        _captureButton = [DKCaptureButton new];
        [_captureButton addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
        CGSize size = CGSizeMake(bottomViewHeight, bottomViewHeight);
        CGSize newSize = CGSizeApplyAffineTransform(size, CGAffineTransformMakeScale(0.9, 0.9));
        _captureButton.bounds = CGRectMake(0, 0, newSize.width, newSize.height);
        _captureButton.layer.cornerRadius = _captureButton.bounds.size.height / 2;
        _captureButton.layer.borderColor = [UIColor whiteColor].CGColor;
        
        _captureButton.layer.borderWidth = 2;
        _captureButton.layer.masksToBounds = YES;
    }
    return _captureButton;
}
- (void)setupUI{
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.contentView];
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.contentView.frame = self.view.bounds;
    
    CGFloat bottomViewHeight = 70;
    self.bottomView.frame = CGRectMake(0, _contentView.bounds.size.height - bottomViewHeight, _contentView.bounds.size.width, bottomViewHeight);
    self.bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    
    [self.contentView addSubview:self.bottomView];
    
    self.cameraSwitchButton.frame = CGRectMake(_bottomView.bounds.size.width - self.cameraSwitchButton.bounds.size.width - 15, ( self.bottomView.bounds.size.height - self.cameraSwitchButton.bounds.size.height ) / 2, self.cameraSwitchButton.frame.size.width, self.cameraSwitchButton.frame.size.height);
    self.cameraSwitchButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleBottomMargin;
    
    
    [self.bottomView addSubview:self.cameraSwitchButton];
    
    self.captureButton.center = CGPointMake(self.bottomView.bounds.size.width / 2, self.bottomView.bounds.size.height / 2);
    self.captureButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.bottomView addSubview:self.captureButton];
    
    
    UIButton * cancelButton = [UIButton new];
    [cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:[DKCameraResource cameraCancelImage] forState:UIControlStateNormal];
    [cancelButton sizeToFit];
    cancelButton.frame = CGRectMake(self.contentView.bounds.size.width - cancelButton.bounds.size.width - 15, 25, cancelButton.frame.size.width, cancelButton.frame.size.height);
    cancelButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.contentView addSubview:cancelButton];
    
    self.flashButton.frame = CGRectMake(5, 15, self.flashButton.frame.size.width, self.flashButton.frame.size.height);
    [self.contentView addSubview:self.flashButton];
    
    [self.contentView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoom:)]];
    
    [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFocus:)]];
    
    
    
    
    
    
    
    
}
- (void)setupDevices{
    NSArray<AVCaptureDevice *> * devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice * device in devices) {
        if (device.position == AVCaptureDevicePositionBack) {
            self.captureDeviceRear = device;
        }
        if (device.position == AVCaptureDevicePositionFront) {
            self.captureDeviceFront = device;
        }
    }
    
    switch (self.defaultCaptureDevice) {
        case DKCameraDeviceSourceFrontType:
            self.currentDevice = self.captureDeviceFront?:self.captureDeviceRear;
            break;
        case DKCameraDeviceSourceRearType:
            self.currentDevice = self.captureDeviceRear?:self.captureDeviceFront;
        default:
            break;
    }
}

- (void)startSession{
    self.isStopped = NO;
    if (!self.captureSession.isRunning) {
        [self.captureSession startRunning];
    }
}

- (void)stopSession{
    [self pauseSession];
    [self.captureSession stopRunning];
}
- (void)pauseSession{
    self.isStopped = YES;
    [self updateSession:NO];
}

- (void)updateSession:(BOOL)isEnable{
    if (!self.isStopped || (self.isStopped && isEnable)) {
        self.previewLayer.connection.enabled = isEnable;
    }
}

- (void)dismiss{
    if (self.didCancel) {
        self.didCancel();
    }
}


- (void)takePicture{
   AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusDenied) {
        return;
    }
    
    if (self.stillImageOutput && !self.stillImageOutput.isCapturingStillImage) {
        self.captureButton.enabled = NO;
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
           AVCaptureConnection * connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
            
            if (connection) {
                connection.videoOrientation = [DKCamera toAVCaptureVideoOrientation:self.currentOrientation];
                connection.videoScaleAndCropFactor = self.zoomScale;
                [_stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                    if (!error) {
                      NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                        
                        UIImage * takenImage = [UIImage imageWithData:imageData];
                        if (self.didFinishCapturingImage && imageData && takenImage) {
                            CGRect outputRect = [self.previewLayer metadataOutputRectOfInterestForRect:self.previewLayer.bounds];
                            
                            CGImageRef takenCGImage = takenImage.CGImage;
                            CGFloat width = CGImageGetWidth(takenCGImage);
                            CGFloat height = CGImageGetHeight(takenCGImage);
                            
                            CGRect cropRect = CGRectMake(outputRect.origin.x * width, outputRect.origin.y * height, outputRect.size.width * width, outputRect.size.height * height);
                            
                            CGImageRef cropCGImage = CGImageCreateWithImageInRect(takenCGImage, cropRect);
                            
                            UIImage * cropTakenImage = [UIImage imageWithCGImage:cropCGImage scale:1 orientation:takenImage.imageOrientation];
                            self.didFinishCapturingImage(cropTakenImage);
                            self.captureButton.enabled = YES;
                        }
                    }else{
                        NSLog(@"error while capturing still image %@", error.localizedDescription);
                    }

                }];
            }
        });
    }
}

- (void)handleZoom:(UIPinchGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.beginZoomScale = self.zoomScale;
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        self.zoomScale = MIN(4.0, MAX(1.0, self.beginZoomScale * gesture.scale));
        [CATransaction begin];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.zoomScale, self.zoomScale)];
        [CATransaction commit];
    }
}

- (void)handleFocus:(UITapGestureRecognizer *)gesture{
    if (self.currentDevice && self.currentDevice.isFocusPointOfInterestSupported) {
        CGPoint touchPoint = [gesture locationInView:self.view];
        [self focusAtTouchPoint:touchPoint];
    }
}

- (void)focusAtTouchPoint:(CGPoint)touchPoint{
    if (self.currentDevice == nil || self.currentDevice.isFlashAvailable == NO) {
        return;
    }
    CGPoint focusPoint = [self.previewLayer captureDevicePointOfInterestForPoint:touchPoint];
    [self showFocusViewAtPoint:touchPoint];
    
    if (self.currentDevice) {
        [self.currentDevice lockForConfiguration:nil];
        self.currentDevice.focusPointOfInterest = focusPoint;
        self.currentDevice.exposurePointOfInterest = focusPoint;
        
        self.currentDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        
        if ([self.currentDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            self.currentDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        
        [self.currentDevice unlockForConfiguration];
    }
    
    
    

}

- (void)showFocusViewAtPoint:(CGPoint)touchPoint{
    
    
    self.focusView.transform = CGAffineTransformIdentity;
    self.focusView.center = touchPoint;
    
    [self.view addSubview:self.focusView];
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1.1 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.focusView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
    } completion:^(BOOL finished) {
        [self.focusView removeFromSuperview];
    } ];
    
    
}
- (UIView *)focusView{
    if (!_focusView) {
        _focusView = [UIView new];
        CGFloat diameter = 100.0;
        _focusView.bounds = CGRectMake(0, 0, diameter, diameter);
        _focusView.layer.borderWidth = 2;
        _focusView.layer.cornerRadius = diameter / 2;
        _focusView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return _focusView;
}


- (void)switchCamera{
    self.currentDevice = self.currentDevice == self.captureDeviceRear ? self.captureDeviceFront : self.captureDeviceRear;
    [self setupCurrentDevice];
    
}

- (void)setupCurrentDevice{
    if (self.currentDevice){
        if (self.currentDevice.isFlashAvailable) {
            self.flashButton.hidden = NO;
            self.flashMode = [self flashModeFromUserDefaults];
            
            
        }else{
            self.flashButton.hidden = YES;
        }
        
        for (AVCaptureInput * oldInput in self.captureSession.inputs) {
            [self.captureSession removeInput:oldInput];
        }
        
        AVCaptureDeviceInput * frontInput =  [AVCaptureDeviceInput deviceInputWithDevice:self.currentDevice error:nil];
        
        if ([self.captureSession canAddInput:frontInput]) {
            [self.captureSession addInput:frontInput];
        }
        
        [self.currentDevice lockForConfiguration:nil];
        if ([self.currentDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            self.currentDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        
        if ([self.currentDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            self.currentDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        
        
        [self.currentDevice unlockForConfiguration];
        
    }
}

- (AVCaptureFlashMode)flashModeFromUserDefaults{
   AVCaptureFlashMode rawValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"DKCamera.flashMode"];
    return rawValue;
}

+ (AVCaptureVideoOrientation)toAVCaptureVideoOrientation:(UIDeviceOrientation)orientation{
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeRight;
            break;
        default:
            return AVCaptureVideoOrientationPortrait;
            break;
    }
}

- (void)switchFlashMode{
    switch (self.flashMode) {
        case AVCaptureFlashModeAuto:
            self.flashMode = AVCaptureFlashModeOff;
            break;
        case AVCaptureFlashModeOn:
            self.flashMode = AVCaptureFlashModeAuto;
            break;
        case AVCaptureFlashModeOff:
            self.flashMode = AVCaptureFlashModeOn;
            break;
        default:
            break;
    }
}

-(void)    captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
                    from:(AVCaptureConnection *)connection
{
    if (self.onFaceDetection) {
        self.onFaceDetection(metadataObjects);
    }
}

- (BOOL)shouldAutorotate{
    return NO;
}


- (void)initialOriginalOrientationForOrientation{
    self.originalOrientation = [DKCamera toDeviceOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    if (self.previewLayer.connection) {
        self.previewLayer.connection.videoOrientation = [DKCamera toAVCaptureVideoOrientation:self.originalOrientation];
    }
}

- (void)updateContentLayoutForCurrentOrientation{
    CGFloat newAngle = [DKCamera toAngleRelativeToPortrait:self.currentOrientation] - [DKCamera toAngleRelativeToPortrait:self.originalOrientation];
    
    if (self.allowsRotate) {
        CGSize contentViewNewSize;
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = self.view.bounds.size.height;
        if (UIDeviceOrientationIsLandscape(self.currentOrientation)) {
            contentViewNewSize = CGSizeMake(MAX(width, height), MIN(width, height));
        }else{
            contentViewNewSize = CGSizeMake(MIN(width, height), MAX(width, height));
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.contentView.bounds = CGRectMake(0, 0, contentViewNewSize.width, contentViewNewSize.height);
            self.contentView.transform = CGAffineTransformMakeRotation(newAngle);
        }];
    }else{
      CGAffineTransform rotateAffineTransform = CGAffineTransformRotate(CGAffineTransformIdentity, newAngle);
        [UIView animateWithDuration:0.2 animations:^{
            self.flashButton.transform = rotateAffineTransform;
            self.cameraSwitchButton.transform = rotateAffineTransform;
        }];
    }
}

+ (UIDeviceOrientation)toDeviceOrientation:(UIInterfaceOrientation)orientation{
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return UIDeviceOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIDeviceOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return UIDeviceOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return UIDeviceOrientationLandscapeRight;
            break;
        default:
            return UIDeviceOrientationPortrait;
            break;
    }
}

+ (CGFloat)toAngleRelativeToPortrait:(UIDeviceOrientation)orientation{
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            return 0;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            return M_PI;
            break;
        case UIDeviceOrientationLandscapeRight:
            return -M_PI_2;
            break;
        case UIDeviceOrientationLandscapeLeft:
            return M_PI_2;
            break;
        default:
            return 0.0;
            break;
    }
}


+ (UIDeviceOrientation)toDeviceOrientationFor:(CMAcceleration)acceleration{
    if (acceleration.x >= 0.75) {
        return UIDeviceOrientationLandscapeRight;
    }else if (acceleration.x <= -0.75){
        return UIDeviceOrientationLandscapeLeft;
    }else if (acceleration.y <= -0.75){
        return UIDeviceOrientationPortrait;
    }else if (acceleration.y >= 0.75){
        return UIDeviceOrientationPortraitUpsideDown;
    }else{
        return UIDeviceOrientationUnknown;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
