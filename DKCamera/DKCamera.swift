//
//  DKCamera.swift
//  DKCameraDemo
//
//  Created by ZhangAo on 15/8/30.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

public class DKCameraPassthroughView: UIView {
    public override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitTestingView = super.hitTest(point, withEvent: event)
        return hitTestingView == self ? nil : hitTestingView
    }
}

public class DKCamera: UIViewController {
    
    public class func checkCameraPermission(handler: (granted: Bool) -> Void) {
        func hasCameraPermission() -> Bool {
            return AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .Authorized
        }
        
        func needsToRequestCameraPermission() -> Bool {
            return AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .NotDetermined
        }
        
        hasCameraPermission() ? handler(granted: true) : (needsToRequestCameraPermission() ?
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { granted in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    hasCameraPermission() ? handler(granted: true) : handler(granted: false)
                })
            }) : handler(granted: false))
    }
    
    public var didCancel: (() -> Void)?
    public var didFinishCapturingImage: ((image: UIImage) -> Void)?
    
    public var cameraOverlayView: UIView? {
        didSet {
            if let cameraOverlayView = cameraOverlayView {
                self.view.addSubview(cameraOverlayView)
            }
        }
    }
    
    /// The flashModel will to be remembered to next use.
    public var flashMode:AVCaptureFlashMode! {
        didSet {
            self.updateFlashButton()
            self.updateFlashMode()
            self.updateFlashModeToUserDefautls(self.flashMode)
        }
    }
    
    public class func isAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    
    /// Determines whether or not the rotation is enabled.
    public var allowsRotate = false
    
    public let captureSession = AVCaptureSession()
    public var previewLayer: AVCaptureVideoPreviewLayer!
    private var beginZoomScale: CGFloat = 1.0
    private var zoomScale: CGFloat = 1.0
    
    public var currentDevice: AVCaptureDevice?
    public var captureDeviceFront: AVCaptureDevice?
    public var captureDeviceBack: AVCaptureDevice?
    private weak var stillImageOutput: AVCaptureStillImageOutput?
    
    public var contentView = UIView()
    
    public var originalOrientation: UIDeviceOrientation!
    public var currentOrientation: UIDeviceOrientation!
    public let motionManager = CMMotionManager()
    
    public lazy var flashButton: UIButton = {
        let flashButton = UIButton()
        flashButton.addTarget(self, action: #selector(DKCamera.switchFlashMode), forControlEvents: .TouchUpInside)
        
        return flashButton
    }()
    public var cameraSwitchButton: UIButton!
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupDevices()
        self.setupUI()
        self.beginSession()
        
        self.setupMotionManager()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.captureSession.running {
            self.captureSession.startRunning()
        }
        
        if !self.motionManager.accelerometerActive {
            self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { accelerometerData, error in
                if error == nil {
                    let currentOrientation = accelerometerData!.acceleration.toDeviceOrientation() ?? self.currentOrientation
                    if self.originalOrientation == nil {
                        self.initialOriginalOrientationForOrientation()
                        self.currentOrientation = self.originalOrientation
                    }
                    if let currentOrientation = currentOrientation where self.currentOrientation != currentOrientation {
                        self.currentOrientation = currentOrientation
                        self.updateContentLayoutForCurrentOrientation()
                    }
                } else {
                    print("error while update accelerometer: \(error!.localizedDescription)", terminator: "")
                }
            })
        }
        
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.originalOrientation == nil {
            self.contentView.frame = self.view.bounds
            self.previewLayer.frame = self.view.bounds
        }
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.captureSession.stopRunning()
        self.motionManager.stopAccelerometerUpdates()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    public func setupDevices() {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
        
        for device in devices {
            if device.position == .Back {
                self.captureDeviceBack = device
            }
            
            if device.position == .Front {
                self.captureDeviceFront = device
            }
        }
        
        self.currentDevice = self.captureDeviceBack ?? self.captureDeviceFront
    }
    
    let bottomView = UIView()
    
    public func setupUI() {
        self.view.backgroundColor = UIColor.blackColor()
        self.view.addSubview(self.contentView)
        self.contentView.backgroundColor = UIColor.clearColor()
        self.contentView.frame = self.view.bounds
        
        let bottomViewHeight: CGFloat = 70
        bottomView.bounds.size = CGSize(width: contentView.bounds.width, height: bottomViewHeight)
        bottomView.frame.origin = CGPoint(x: 0, y: contentView.bounds.height - bottomViewHeight)
        bottomView.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
        bottomView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        contentView.addSubview(bottomView)
        
        // switch button
        let cameraSwitchButton: UIButton = {
            let cameraSwitchButton = UIButton()
            cameraSwitchButton.addTarget(self, action: #selector(DKCamera.switchCamera), forControlEvents: .TouchUpInside)
            cameraSwitchButton.setImage(DKCameraResource.cameraSwitchImage(), forState: .Normal)
            cameraSwitchButton.sizeToFit()
            
            return cameraSwitchButton
        }()
        
        cameraSwitchButton.frame.origin = CGPoint(x: bottomView.bounds.width - cameraSwitchButton.bounds.width - 15,
                                                  y: (bottomView.bounds.height - cameraSwitchButton.bounds.height) / 2)
        cameraSwitchButton.autoresizingMask = [.FlexibleLeftMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        bottomView.addSubview(cameraSwitchButton)
        self.cameraSwitchButton = cameraSwitchButton
        
        // capture button
        let captureButton: UIButton = {
            
            class DKCaptureButton: UIButton {
                private override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
                    self.backgroundColor = UIColor.whiteColor()
                    return true
                }
                
                private override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
                    self.backgroundColor = UIColor.whiteColor()
                    return true
                }
                
                private override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
                    self.backgroundColor = nil
                }
                
                private override func cancelTrackingWithEvent(event: UIEvent?) {
                    self.backgroundColor = nil
                }
            }
            
            let captureButton = DKCaptureButton()
            captureButton.addTarget(self, action: #selector(DKCamera.takePicture), forControlEvents: .TouchUpInside)
            captureButton.bounds.size = CGSizeApplyAffineTransform(CGSize(width: bottomViewHeight,
                height: bottomViewHeight), CGAffineTransformMakeScale(0.9, 0.9))
            captureButton.layer.cornerRadius = captureButton.bounds.height / 2
            captureButton.layer.borderColor = UIColor.whiteColor().CGColor
            captureButton.layer.borderWidth = 2
            captureButton.layer.masksToBounds = true
            
            return captureButton
        }()
        
        captureButton.center = CGPoint(x: bottomView.bounds.width / 2, y: bottomView.bounds.height / 2)
        captureButton.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin]
        bottomView.addSubview(captureButton)
        
        // cancel button
        let cancelButton: UIButton = {
            let cancelButton = UIButton()
            cancelButton.addTarget(self, action: #selector(DKCamera.dismiss), forControlEvents: .TouchUpInside)
            cancelButton.setImage(DKCameraResource.cameraCancelImage(), forState: .Normal)
            cancelButton.sizeToFit()
            
            return cancelButton
        }()
        
        cancelButton.frame.origin = CGPoint(x: contentView.bounds.width - cancelButton.bounds.width - 15, y: 25)
        cancelButton.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin]
        contentView.addSubview(cancelButton)
        
        self.flashButton.frame.origin = CGPoint(x: 5, y: 15)
        contentView.addSubview(self.flashButton)
        
        contentView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(DKCamera.handleZoom(_:))))
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DKCamera.handleFocus(_:))))
    }
    
    // MARK: - Callbacks
    
    internal func dismiss() {
        self.didCancel?()
    }
    
    public func takePicture() {
        let authStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        if authStatus == .Denied {
            return
        }
        
        if let stillImageOutput = self.stillImageOutput {
            self.stillImageOutput = nil // Just taking only one image.
            
            dispatch_async(dispatch_get_global_queue(0, 0), {
                let connection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
                if connection == nil {
                    return
                }
                
                connection.videoOrientation = self.currentOrientation.toAVCaptureVideoOrientation()
                connection.videoScaleAndCropFactor = self.zoomScale
                
                stillImageOutput.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { (imageDataSampleBuffer, error: NSError?) -> Void in
                    
                    if error == nil {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                        
                        if let didFinishCapturingImage = self.didFinishCapturingImage, takenImage = UIImage(data: imageData) {
                            
                            let outputRect = self.previewLayer.metadataOutputRectOfInterestForRect(self.previewLayer.bounds)
                            let takenCGImage = takenImage.CGImage
                            let width = CGFloat(CGImageGetWidth(takenCGImage))
                            let height = CGFloat(CGImageGetHeight(takenCGImage))
                            let cropRect = CGRectMake(outputRect.origin.x * width, outputRect.origin.y * height, outputRect.size.width * width, outputRect.size.height * height)
                            
                            let cropCGImage = CGImageCreateWithImageInRect(takenCGImage, cropRect)
                            let cropTakenImage = UIImage(CGImage: cropCGImage!, scale: 1, orientation: takenImage.imageOrientation)
                            
                            didFinishCapturingImage(image: cropTakenImage)
                        }
                    } else {
                        print("error while capturing still image: \(error!.localizedDescription)", terminator: "")
                    }
                })
            })
        }
        
    }
    
    // MARK: - Handles Zoom
    
    public func handleZoom(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Began {
            self.beginZoomScale = self.zoomScale
        } else if gesture.state == .Changed {
            self.zoomScale = min(4.0, max(1.0, self.beginZoomScale * gesture.scale))
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.025)
            self.previewLayer.setAffineTransform(CGAffineTransformMakeScale(self.zoomScale, self.zoomScale))
            CATransaction.commit()
        }
    }
    
    // MARK: - Handles Focus
    
    public func handleFocus(gesture: UITapGestureRecognizer) {
        if let currentDevice = self.currentDevice where currentDevice.focusPointOfInterestSupported {
            let touchPoint = gesture.locationInView(self.view)
            self.focusAtTouchPoint(touchPoint)
        }
    }
    
    // MARK: - Handles Switch Camera
    
    internal func switchCamera() {
        self.currentDevice = self.currentDevice == self.captureDeviceBack ?
            self.captureDeviceFront : self.captureDeviceBack
        
        self.setupCurrentDevice()
    }
    
    // MARK: - Handles Flash
    
    internal func switchFlashMode() {
        switch self.flashMode! {
        case .Auto:
            self.flashMode = .Off
        case .On:
            self.flashMode = .Auto
        case .Off:
            self.flashMode = .On
        }
    }
    
    public func flashModeFromUserDefaults() -> AVCaptureFlashMode {
        let rawValue = NSUserDefaults.standardUserDefaults().integerForKey("DKCamera.flashMode")
        return AVCaptureFlashMode(rawValue: rawValue)!
    }
    
    public func updateFlashModeToUserDefautls(flashMode: AVCaptureFlashMode) {
        NSUserDefaults.standardUserDefaults().setInteger(flashMode.rawValue, forKey: "DKCamera.flashMode")
    }
    
    public func updateFlashButton() {
        struct FlashImage {
            
            static let images = [
                AVCaptureFlashMode.Auto : DKCameraResource.cameraFlashAutoImage(),
                AVCaptureFlashMode.On : DKCameraResource.cameraFlashOnImage(),
                AVCaptureFlashMode.Off : DKCameraResource.cameraFlashOffImage()
            ]
            
        }
        let flashImage: UIImage = FlashImage.images[self.flashMode]!
        
        self.flashButton.setImage(flashImage, forState: .Normal)
        self.flashButton.sizeToFit()
    }
    
    // MARK: - Capture Session
    
    public func beginSession() {
        self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        self.setupCurrentDevice()
        
        let stillImageOutput = AVCaptureStillImageOutput()
        if self.captureSession.canAddOutput(stillImageOutput) {
            self.captureSession.addOutput(stillImageOutput)
            self.stillImageOutput = stillImageOutput
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.previewLayer.frame = self.view.bounds
        
        let rootLayer = self.view.layer
        rootLayer.masksToBounds = true
        rootLayer.insertSublayer(self.previewLayer, atIndex: 0)
    }
    
    public func setupCurrentDevice() {
        if let currentDevice = self.currentDevice {
            
            if currentDevice.flashAvailable {
                self.flashButton.hidden = false
                self.flashMode = self.flashModeFromUserDefaults()
            } else {
                self.flashButton.hidden = true
            }
            
            for oldInput in self.captureSession.inputs as! [AVCaptureInput] {
                self.captureSession.removeInput(oldInput)
            }
            
            let frontInput = try? AVCaptureDeviceInput(device: self.currentDevice)
            if self.captureSession.canAddInput(frontInput) {
                self.captureSession.addInput(frontInput)
            }
            
            try! currentDevice.lockForConfiguration()
            if currentDevice.isFocusModeSupported(.ContinuousAutoFocus) {
                currentDevice.focusMode = .ContinuousAutoFocus
            }
            
            if currentDevice.isExposureModeSupported(.ContinuousAutoExposure) {
                currentDevice.exposureMode = .ContinuousAutoExposure
            }
            
            currentDevice.unlockForConfiguration()
        }
    }
    
    public func updateFlashMode() {
        if let currentDevice = self.currentDevice
            where currentDevice.flashAvailable && currentDevice.isFlashModeSupported(self.flashMode) {
            try! currentDevice.lockForConfiguration()
            currentDevice.flashMode = self.flashMode
            currentDevice.unlockForConfiguration()
        }
    }
    
    public func focusAtTouchPoint(touchPoint: CGPoint) {
        
        func showFocusViewAtPoint(touchPoint: CGPoint) {
            
            struct FocusView {
                static let focusView: UIView = {
                    let focusView = UIView()
                    let diameter: CGFloat = 100
                    focusView.bounds.size = CGSize(width: diameter, height: diameter)
                    focusView.layer.borderWidth = 2
                    focusView.layer.cornerRadius = diameter / 2
                    focusView.layer.borderColor = UIColor.whiteColor().CGColor
                    
                    return focusView
                }()
            }
            FocusView.focusView.transform = CGAffineTransformIdentity
            FocusView.focusView.center = touchPoint
            self.view.addSubview(FocusView.focusView)
            UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.1,
                                       options: .CurveEaseInOut, animations: { () -> Void in
                                        FocusView.focusView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6)
            }) { (Bool) -> Void in
                FocusView.focusView.removeFromSuperview()
            }
        }
        
        if self.currentDevice == nil || self.currentDevice?.flashAvailable == false {
            return
        }
        
        let focusPoint = self.previewLayer.captureDevicePointOfInterestForPoint(touchPoint)
        
        showFocusViewAtPoint(touchPoint)
        
        if let currentDevice = self.currentDevice {
            try! currentDevice.lockForConfiguration()
            currentDevice.focusPointOfInterest = focusPoint
            currentDevice.exposurePointOfInterest = focusPoint
            
            currentDevice.focusMode = .ContinuousAutoFocus
            
            if currentDevice.isExposureModeSupported(.ContinuousAutoExposure) {
                currentDevice.exposureMode = .ContinuousAutoExposure
            }
            
            currentDevice.unlockForConfiguration()
        }
        
    }
    
    // MARK: - Handles Orientation
    
    public override func shouldAutorotate() -> Bool {
        return false
    }
    
    public func setupMotionManager() {
        self.motionManager.accelerometerUpdateInterval = 0.5
        self.motionManager.gyroUpdateInterval = 0.5
    }
    
    public func initialOriginalOrientationForOrientation() {
        self.originalOrientation = UIApplication.sharedApplication().statusBarOrientation.toDeviceOrientation()
        if let connection = self.previewLayer.connection {
            connection.videoOrientation = self.originalOrientation.toAVCaptureVideoOrientation()
        }
    }
    
    public func updateContentLayoutForCurrentOrientation() {
        let newAngle = self.currentOrientation.toAngleRelativeToPortrait() - self.originalOrientation.toAngleRelativeToPortrait()
        
        if self.allowsRotate {
            var contentViewNewSize: CGSize!
            let width = self.view.bounds.width
            let height = self.view.bounds.height
            if UIDeviceOrientationIsLandscape(self.currentOrientation) {
                contentViewNewSize = CGSize(width: max(width, height), height: min(width, height))
            } else {
                contentViewNewSize = CGSize(width: min(width, height), height: max(width, height))
            }
            
            UIView.animateWithDuration(0.2) {
                self.contentView.bounds.size = contentViewNewSize
                self.contentView.transform = CGAffineTransformMakeRotation(newAngle)
            }
        } else {
            let rotateAffineTransform = CGAffineTransformRotate(CGAffineTransformIdentity, newAngle)
            
            UIView.animateWithDuration(0.2) {
                self.flashButton.transform = rotateAffineTransform
                self.cameraSwitchButton.transform = rotateAffineTransform
            }
        }
    }
    
}

// MARK: - Utilities

public extension UIInterfaceOrientation {
    
    func toDeviceOrientation() -> UIDeviceOrientation {
        switch self {
        case .Portrait:
            return .Portrait
        case .PortraitUpsideDown:
            return .PortraitUpsideDown
        case .LandscapeRight:
            return .LandscapeLeft
        case .LandscapeLeft:
            return .LandscapeRight
        default:
            return .Portrait
        }
    }
}

public extension UIDeviceOrientation {
    
    func toAVCaptureVideoOrientation() -> AVCaptureVideoOrientation {
        switch self {
        case .Portrait:
            return .Portrait
        case .PortraitUpsideDown:
            return .PortraitUpsideDown
        case .LandscapeRight:
            return .LandscapeLeft
        case .LandscapeLeft:
            return .LandscapeRight
        default:
            return .Portrait
        }
    }
    
    func toInterfaceOrientationMask() -> UIInterfaceOrientationMask {
        switch self {
        case .Portrait:
            return .Portrait
        case .PortraitUpsideDown:
            return .PortraitUpsideDown
        case .LandscapeRight:
            return .LandscapeLeft
        case .LandscapeLeft:
            return .LandscapeRight
        default:
            return .Portrait
        }
    }
    
    func toAngleRelativeToPortrait() -> CGFloat {
        switch self {
        case .Portrait:
            return 0
        case .PortraitUpsideDown:
            return CGFloat(M_PI)
        case .LandscapeRight:
            return CGFloat(-M_PI_2)
        case .LandscapeLeft:
            return CGFloat(M_PI_2)
        default:
            return 0
        }
    }
    
}

public extension CMAcceleration {
    func toDeviceOrientation() -> UIDeviceOrientation? {
        if self.x >= 0.75 {
            return .LandscapeRight
        } else if self.x <= -0.75 {
            return .LandscapeLeft
        } else if self.y <= -0.75 {
            return .Portrait
        } else if self.y >= 0.75 {
            return .PortraitUpsideDown
        } else {
            return nil
        }
    }
}

// MARK: - Rersources

public extension NSBundle {
    
    class func cameraBundle() -> NSBundle {
        let assetPath = NSBundle(forClass: DKCameraResource.self).resourcePath!
        return NSBundle(path: (assetPath as NSString).stringByAppendingPathComponent("DKCameraResource.bundle"))!
    }
    
}

public class DKCameraResource {
    
    public class func imageForResource(name: String) -> UIImage {
        let bundle = NSBundle.cameraBundle()
        let imagePath = bundle.pathForResource(name, ofType: "png", inDirectory: "Images")
        let image = UIImage(contentsOfFile: imagePath!)
        return image!
    }
    
    class func cameraCancelImage() -> UIImage {
        return imageForResource("camera_cancel")
    }
    
    class func cameraFlashOnImage() -> UIImage {
        return imageForResource("camera_flash_on")
    }
    
    class func cameraFlashAutoImage() -> UIImage {
        return imageForResource("camera_flash_auto")
    }
    
    class func cameraFlashOffImage() -> UIImage {
        return imageForResource("camera_flash_off")
    }
    
    class func cameraSwitchImage() -> UIImage {
        return imageForResource("camera_switch")
    }
    
}

