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

public class DKCamera: UIViewController {

    public var didCancelled: (() -> Void)?
    public var didFinishCapturingImage: ((image: UIImage) -> Void)?
    
    public var cameraOverlayView: UIView?
    public var flashModel:AVCaptureFlashMode! {
        didSet {
            self.updateFlashButton()
            self.updateFlashMode()
            self.updateFlashModelToUserDefautls(self.flashModel)
        }
    }
    
    public class func isAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var currentDevice: AVCaptureDevice?
    private var captureDeviceFront: AVCaptureDevice?
    private var captureDeviceBack: AVCaptureDevice?
    
    private var currentOrientation = UIInterfaceOrientation.Portrait
    private let motionManager = CMMotionManager()
    
    private lazy var flashButton: UIButton = {
        let flashButton = UIButton()
        flashButton.addTarget(self, action: "switchFlashMode", forControlEvents: .TouchUpInside)
        
        return flashButton
    }()
    private var cameraSwitchButton: UIButton!
    
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
            self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: { (accelerometerData, error) -> Void in
                if error == nil {
                    self.outputAccelertionData(accelerometerData.acceleration)
                } else {
                    println("error while update accelerometer: \(error!.localizedDescription)")
                }
            })
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
    
    private func setupDevices() {
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
    
    private func setupUI() {
        self.view.backgroundColor = UIColor.blackColor()
        let contentView = self.view

        if let cameraOverlayView = self.cameraOverlayView {
            self.view.addSubview(cameraOverlayView)
        }
        
        let bottomView = UIView()
        let bottomViewHeight: CGFloat = 70
        bottomView.bounds.size = CGSize(width: contentView.bounds.width, height: bottomViewHeight)
        bottomView.frame.origin = CGPoint(x: 0, y: contentView.bounds.height - bottomViewHeight)
        bottomView.autoresizingMask = .FlexibleWidth | .FlexibleTopMargin
        bottomView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        contentView.addSubview(bottomView)
        
        // switch button
        let cameraSwitchButton: UIButton = {
            let cameraSwitchButton = UIButton()
            cameraSwitchButton.addTarget(self, action: "switchCamera", forControlEvents: .TouchUpInside)
            cameraSwitchButton.setImage(DKCameraResource.cameraSwitchImage(), forState: .Normal)
            cameraSwitchButton.sizeToFit()
            
            return cameraSwitchButton
        }()
        
        cameraSwitchButton.frame.origin = CGPoint(x: bottomView.bounds.width - cameraSwitchButton.bounds.width - 15,
            y: (bottomView.bounds.height - cameraSwitchButton.bounds.height) / 2)
        cameraSwitchButton.autoresizingMask = .FlexibleLeftMargin | .FlexibleTopMargin | .FlexibleBottomMargin
        bottomView.addSubview(cameraSwitchButton)
        self.cameraSwitchButton = cameraSwitchButton
        
        // capture button
        let captureButton: UIButton = {
            
            class CaptureButton: UIButton {
                private override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
                    self.backgroundColor = UIColor.whiteColor()
                    return true
                }
                
                private override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
                    self.backgroundColor = UIColor.whiteColor()
                    return true
                }
                
                private override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
                    self.backgroundColor = nil
                }
                
                private override func cancelTrackingWithEvent(event: UIEvent?) {
                    self.backgroundColor = nil
                }
            }
            
            let captureButton = CaptureButton()
            captureButton.addTarget(self, action: "takePicture", forControlEvents: .TouchUpInside)
            captureButton.bounds.size = CGSizeApplyAffineTransform(CGSize(width: bottomViewHeight,
                height: bottomViewHeight), CGAffineTransformMakeScale(0.9, 0.9))
            captureButton.layer.cornerRadius = captureButton.bounds.height / 2
            captureButton.layer.borderColor = UIColor.whiteColor().CGColor
            captureButton.layer.borderWidth = 2
            captureButton.layer.masksToBounds = true
            
            return captureButton
        }()
        
        captureButton.center = CGPoint(x: bottomView.bounds.width / 2, y: bottomView.bounds.height / 2)
        captureButton.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin
        bottomView.addSubview(captureButton)
        
        // cancel button
        let cancelButton: UIButton = {
            let cancelButton = UIButton()
            cancelButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
            cancelButton.setImage(DKCameraResource.cameraCancelImage(), forState: .Normal)
            cancelButton.sizeToFit()
            
            return cancelButton
        }()
        
        cancelButton.frame.origin = CGPoint(x: contentView.bounds.width - cancelButton.bounds.width - 15, y: 25)
        cancelButton.autoresizingMask = .FlexibleBottomMargin | .FlexibleLeftMargin
        contentView.addSubview(cancelButton)
        
        let flashButton: UIButton = {
            let flashButton = UIButton()
            flashButton.addTarget(self, action: "switchFlashMode", forControlEvents: .TouchUpInside)
            
            return flashButton
        }()
        
        self.flashButton.frame.origin = CGPoint(x: 5, y: 15)
        contentView.addSubview(self.flashButton)
    }
    
    // MARK: - Callbacks
    
    internal func dismiss() {
        if let didCancelled = self.didCancelled {
            didCancelled()
        }
    }
    
    internal func takePicture() {
        if let stillImageOutput = self.captureSession.outputs.first as? AVCaptureStillImageOutput {
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                let connection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
                
                connection.videoOrientation = self.currentOrientation.toAVCaptureVideoOrientation()
                
                stillImageOutput.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { (imageDataSampleBuffer, error: NSError?) -> Void in
                    
                    if error == nil {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                        let metaData: NSDictionary = CMCopyDictionaryOfAttachments(nil,
                            imageDataSampleBuffer,
                            CMAttachmentMode(kCMAttachmentMode_ShouldPropagate)).takeUnretainedValue()
                        
                        if let didFinishCapturingImage = self.didFinishCapturingImage,
                            image = UIImage(data: imageData) {

                                didFinishCapturingImage(image: image)
                        }
                    } else {
                        println("error while capturing still image: \(error!.localizedDescription)")
                    }
                })
            })
        }
        
    }
    
    // MARK: - Handles Focus
    
    override public func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let anyTouch = touches.first as! UITouch
        let touchPoint = anyTouch.locationInView(self.view)
        self.focusAtTouchPoint(touchPoint)
    }
    
    // MARK: - Handles Switch Camera
    
    internal func switchCamera() {
        self.currentDevice = self.currentDevice == self.captureDeviceBack ?
            self.captureDeviceFront : self.captureDeviceBack
        
        self.setupCurrentDevice();
    }
    
    // MARK: - Handles Flash
    
    internal func switchFlashMode() {
        switch self.flashModel! {
        case .Auto:
            self.flashModel = .Off
        case .On:
            self.flashModel = .Auto
        case .Off:
            self.flashModel = .On
        }
    }
    
    private func flashModelFromUserDefaults() -> AVCaptureFlashMode {
        let rawValue = NSUserDefaults.standardUserDefaults().integerForKey("DKCamera.flashModel")
        return AVCaptureFlashMode(rawValue: rawValue)!
    }
    
    private func updateFlashModelToUserDefautls(flashModel: AVCaptureFlashMode) {
        NSUserDefaults.standardUserDefaults().setInteger(flashModel.rawValue, forKey: "DKCamera.flashModel")
    }
    
    private func updateFlashButton() {
        struct FlashImage {
            
            static let images = [
                AVCaptureFlashMode.Auto : DKCameraResource.cameraFlashAutoImage(),
                AVCaptureFlashMode.On : DKCameraResource.cameraFlashOnImage(),
                AVCaptureFlashMode.Off : DKCameraResource.cameraFlashOffImage()
            ]
            
        }
        var flashImage: UIImage = FlashImage.images[self.flashModel]!
        
        self.flashButton.setImage(flashImage, forState: .Normal)
        self.flashButton.sizeToFit()
    }
    
    // MARK: - Capture Session
    
    private func beginSession() {
        self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        self.setupCurrentDevice()
        
        let stillImageOutput = AVCaptureStillImageOutput()
        if self.captureSession.canAddOutput(stillImageOutput) {
            self.captureSession.addOutput(stillImageOutput)
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer?.bounds.size = CGSize(width: min(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height),
            height: max(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
        self.previewLayer?.anchorPoint = CGPointZero
        self.previewLayer?.position = CGPointZero
        
        self.view.layer.insertSublayer(self.previewLayer, atIndex: 0)
    }
    
    private func setupCurrentDevice() {
        if let currentDevice = self.currentDevice {
            
            if currentDevice.flashAvailable {
                self.flashButton.hidden = false
                self.flashModel = self.flashModelFromUserDefaults()
            } else {
                self.flashButton.hidden = true
            }
            
            for oldInput in self.captureSession.inputs as! [AVCaptureInput] {
                self.captureSession.removeInput(oldInput)
            }
            
            let frontInput = AVCaptureDeviceInput(device: self.currentDevice, error: nil)
            if self.captureSession.canAddInput(frontInput) {
                self.captureSession.addInput(frontInput)
            }
            
            if currentDevice.lockForConfiguration(nil) {
                if currentDevice.isFocusModeSupported(.ContinuousAutoFocus) {
                    currentDevice.focusMode = .ContinuousAutoFocus
                }
                
                if currentDevice.isExposureModeSupported(.ContinuousAutoExposure) {
                    currentDevice.exposureMode = .ContinuousAutoExposure
                }
                
                currentDevice.unlockForConfiguration()
            }
        }
    }
    
    private func updateFlashMode() {
        if let currentDevice = self.currentDevice
            where currentDevice.flashAvailable && currentDevice.lockForConfiguration(nil) {
                currentDevice.flashMode = self.flashModel
                currentDevice.unlockForConfiguration()
        }
    }
    
    private func focusAtTouchPoint(touchPoint: CGPoint) {
        
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
        
        let focusPoint = self.previewLayer!.captureDevicePointOfInterestForPoint(touchPoint)
        
        showFocusViewAtPoint(touchPoint)
        
        if let currentDevice = self.currentDevice
            where currentDevice.lockForConfiguration(nil) {
                
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
    
    private func setupMotionManager() {
        self.motionManager.accelerometerUpdateInterval = 0.2
        self.motionManager.gyroUpdateInterval = 0.2
    }
    
    private func outputAccelertionData(acceleration: CMAcceleration) {
        var currentOrientation: UIInterfaceOrientation?
        
        if acceleration.x >= 0.75 {
            currentOrientation = .LandscapeLeft
        } else if acceleration.x <= -0.75 {
            currentOrientation = .LandscapeRight
        } else if acceleration.y <= -0.75 {
            currentOrientation = .Portrait
        } else if acceleration.y >= 0.75 {
            currentOrientation = .PortraitUpsideDown
        } else {
            return
        }
        
        if self.currentOrientation != currentOrientation! {
            self.currentOrientation = currentOrientation!
            
            self.updateUIForCurrentOrientation()
        }
    }
    
    private func updateUIForCurrentOrientation() {
        var degree = 0.0
        
        switch self.currentOrientation {
        case .Portrait:
            degree = 0
        case .PortraitUpsideDown:
            degree = 180
        case .LandscapeLeft:
            degree = 270
        case .LandscapeRight:
            degree = 90
        default:
            degree = 0.0
        }
        
        let rotateAffineTransform = CGAffineTransformRotate(CGAffineTransformIdentity, degreesToRadians(degree))
        
        UIView.animateWithDuration(0.2) { () -> Void in
            self.flashButton.transform = rotateAffineTransform
            self.cameraSwitchButton.transform = rotateAffineTransform
        }
    }
    
    public override func shouldAutorotate() -> Bool {
        return false
    }
    
    public override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
}

// MARK: - Utilities

private extension UIInterfaceOrientation {
    
    func toAVCaptureVideoOrientation() -> AVCaptureVideoOrientation {
        return AVCaptureVideoOrientation(rawValue: self.rawValue)!
    }

}

private func degreesToRadians(degree: Double) -> CGFloat {
    return CGFloat(degree / 180.0 * M_PI)
}

// MARK: - Rersources

private extension NSBundle {
    
    class func cameraBundle() -> NSBundle {
        let assetPath = NSBundle(forClass: DKCameraResource.self).resourcePath!
        return NSBundle(path: assetPath.stringByAppendingPathComponent("DKCameraResource.bundle"))!
    }
    
}

private class DKCameraResource {
    
    private class func imageForResource(name: String) -> UIImage {
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

