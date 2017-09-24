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
import ImageIO

extension AVMetadataFaceObject {

    open func realBounds(inCamera camera: DKCamera) -> CGRect {
        var bounds = CGRect()
        let previewSize = camera.previewLayer.bounds.size
        let isFront = camera.currentDevice == camera.captureDeviceFront
        
        if isFront {
            bounds.origin = CGPoint(x: previewSize.width - previewSize.width * (1 - self.bounds.origin.y - self.bounds.size.height / 2),
                                    y: previewSize.height * (self.bounds.origin.x + self.bounds.size.width / 2))
        } else {
            bounds.origin = CGPoint(x: previewSize.width * (1 - self.bounds.origin.y - self.bounds.size.height / 2),
                                    y: previewSize.height * (self.bounds.origin.x + self.bounds.size.width / 2))
        }
        bounds.size = CGSize(width: self.bounds.width * previewSize.height,
                             height: self.bounds.height * previewSize.width)
        return bounds
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////

@available(iOS, introduced: 10.0)
class DKCameraPhotoCapturer: NSObject, AVCapturePhotoCaptureDelegate {
    
    var didCaptureWithImageData: ((_ imageData: Data) -> Void)?
    var didFinish: (() -> Void)?
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?) {
        guard let photoSampleBuffer = photoSampleBuffer else {
            print("DKCameraError: \(error!)")
            return
        }
        
        if let didCaptureWithImageData = self.didCaptureWithImageData {
            let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)!
            didCaptureWithImageData(imageData)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            print("DKCameraError: \(error)")
        } else if let didFinish = self.didFinish {
            didFinish()
        }
    }
    
}

//////////////////////////////////////////////////////////////////////////////////////////////////////

@objc
public enum DKCameraDeviceSourceType : Int {
    case front, rear
}

open class DKCamera: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    open class func checkCameraPermission(_ handler: @escaping (_ granted: Bool) -> Void) {
        func hasCameraPermission() -> Bool {
            return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized
        }
        
        func needsToRequestCameraPermission() -> Bool {
            return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .notDetermined
        }
        
        hasCameraPermission() ? handler(true) : (needsToRequestCameraPermission() ?
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { granted in
                DispatchQueue.main.async(execute: { () -> Void in
                    hasCameraPermission() ? handler(true) : handler(false)
                })
            }) : handler(false))
    }
    
    open var didCancel: (() -> Void)?
    open var didFinishCapturingImage: ((_ image: UIImage, _ metadata: [AnyHashable : Any]?) -> Void)?
    
    /// Notify the listener of the detected faces in the preview frame.
    open var onFaceDetection: ((_ faces: [AVMetadataFaceObject]) -> Void)?
    
    /// Be careful this may cause the view to load prematurely.
    open var cameraOverlayView: UIView? {
        didSet {
            if let cameraOverlayView = cameraOverlayView {
                self.view.addSubview(cameraOverlayView)
            }
        }
    }
    
    /// The flashModel will to be remembered to next use.
    open var flashMode:AVCaptureDevice.FlashMode! {
        didSet {
            self.updateFlashButton()
            self.updateFlashMode()
            self.updateFlashModeToUserDefautls(self.flashMode)
        }
    }
    
    open class func isAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    /// Determines whether or not the rotation is enabled.
    
    open var allowsRotate = false
    
    /// set to NO to hide all standard camera UI. default is YES.
    open var showsCameraControls = true {
        didSet {
            self.contentView.isHidden = !self.showsCameraControls
        }
    }
    
    open let captureSession = AVCaptureSession()
    open var previewLayer: AVCaptureVideoPreviewLayer!
    fileprivate let sessionQueue = DispatchQueue(label: "DKCamera_CaptureSession_Queue")
    fileprivate var beginZoomScale: CGFloat = 1.0
    fileprivate var zoomScale: CGFloat = 1.0
    
    open var defaultCaptureDevice = DKCameraDeviceSourceType.rear
    open var currentDevice: AVCaptureDevice?
    open var captureDeviceFront: AVCaptureDevice?
    open var captureDeviceRear: AVCaptureDevice?
    
    fileprivate weak var captureOutput: AVCaptureOutput?
    
    fileprivate var __defaultPhotoSettings: Any?
    @available(iOS 10.0, *)
    fileprivate var defaultPhotoSettings: AVCapturePhotoSettings {
        get {
            if __defaultPhotoSettings == nil {
                let photoSettings = AVCapturePhotoSettings()
                photoSettings.isHighResolutionPhotoEnabled = true
                
                __defaultPhotoSettings = photoSettings
            }
            
            return __defaultPhotoSettings as! AVCapturePhotoSettings
        }
    }
    fileprivate var currentCapturer: Any? // DKCameraPhotoCapturer
    
    open var contentView = UIView()
    
    open var originalOrientation: UIDeviceOrientation!
    open var currentOrientation: UIDeviceOrientation!
    open let motionManager = CMMotionManager()
    
    open lazy var flashButton: UIButton = {
        let flashButton = UIButton()
        flashButton.addTarget(self, action: #selector(DKCamera.switchFlashMode), for: .touchUpInside)
        
        return flashButton
    }()
    open var cameraSwitchButton: UIButton!
    open var captureButton: UIButton!
    
    let cameraResource: DKCameraResource
    
    init(cameraResource: DKCameraResource = DKDefaultCameraResource()) {
        self.cameraResource = cameraResource
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.cameraResource = DKDefaultCameraResource()
        super.init(coder: aDecoder)
    }
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupDevices()
        self.setupUI()
        self.setupSession()
        
        self.setupMotionManager()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.captureSession.isRunning {
            self.captureSession.startRunning()
        }
        
        if !self.motionManager.isAccelerometerActive {
            self.motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { accelerometerData, error in
                if error == nil {
                    let currentOrientation = accelerometerData!.acceleration.toDeviceOrientation() ?? self.currentOrientation
                    if self.originalOrientation == nil {
                        self.initialOriginalOrientationForOrientation()
                        self.currentOrientation = self.originalOrientation
                    }
                    if let currentOrientation = currentOrientation , self.currentOrientation != currentOrientation {
                        self.currentOrientation = currentOrientation
                        self.updateContentLayoutForCurrentOrientation()
                    }
                } else {
                    print("error while update accelerometer: \(error!.localizedDescription)", terminator: "")
                }
            })
        }
        
        self.updateSession(isEnable: true)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.originalOrientation == nil {
            self.contentView.frame = self.view.bounds
            self.previewLayer.frame = self.view.bounds
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.updateSession(isEnable: false)
        self.motionManager.stopAccelerometerUpdates()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - Setup
    
    let bottomView = UIView()
    open func setupUI() {
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(self.contentView)
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.frame = self.view.bounds
        
        let bottomViewHeight: CGFloat = 70
        bottomView.bounds.size = CGSize(width: contentView.bounds.width, height: bottomViewHeight)
        bottomView.frame.origin = CGPoint(x: 0, y: contentView.bounds.height - bottomViewHeight)
        bottomView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        bottomView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        contentView.addSubview(bottomView)
        
        // switch button
        let cameraSwitchButton: UIButton = {
            let cameraSwitchButton = UIButton()
            cameraSwitchButton.addTarget(self, action: #selector(DKCamera.switchCamera), for: .touchUpInside)
            cameraSwitchButton.setImage(cameraResource.cameraSwitchImage(), for: .normal)
            cameraSwitchButton.sizeToFit()
            
            return cameraSwitchButton
        }()
        
        cameraSwitchButton.frame.origin = CGPoint(x: bottomView.bounds.width - cameraSwitchButton.bounds.width - 15,
                                                  y: (bottomView.bounds.height - cameraSwitchButton.bounds.height) / 2)
        cameraSwitchButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
        bottomView.addSubview(cameraSwitchButton)
        self.cameraSwitchButton = cameraSwitchButton
        
        // capture button
        let captureButton: UIButton = {
            
            class DKCaptureButton: UIButton {
                fileprivate override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
                    self.backgroundColor = UIColor.white
                    return true
                }
                
                fileprivate override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
                    self.backgroundColor = UIColor.white
                    return true
                }
                
                fileprivate override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
                    self.backgroundColor = nil
                }
                
                fileprivate override func cancelTracking(with event: UIEvent?) {
                    self.backgroundColor = nil
                }
            }
            
            let captureButton = DKCaptureButton()
            captureButton.addTarget(self, action: #selector(DKCamera.takePicture), for: .touchUpInside)
            captureButton.bounds.size = CGSize(width: bottomViewHeight,
                                               height: bottomViewHeight).applying(CGAffineTransform(scaleX: 0.9, y: 0.9))
            captureButton.layer.cornerRadius = captureButton.bounds.height / 2
            captureButton.layer.borderColor = UIColor.white.cgColor
            captureButton.layer.borderWidth = 2
            captureButton.layer.masksToBounds = true
            
            return captureButton
        }()
        
        captureButton.center = CGPoint(x: bottomView.bounds.width / 2, y: bottomView.bounds.height / 2)
        captureButton.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        bottomView.addSubview(captureButton)
        self.captureButton = captureButton
        
        // cancel button
        let cancelButton: UIButton = {
            let cancelButton = UIButton()
            cancelButton.addTarget(self, action: #selector(dismiss as () -> Void), for: .touchUpInside)
            cancelButton.setImage(cameraResource.cameraCancelImage(), for: .normal)
            cancelButton.sizeToFit()
            
            return cancelButton
        }()
        
        cancelButton.frame.origin = CGPoint(x: contentView.bounds.width - cancelButton.bounds.width - 15, y: 25)
        cancelButton.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
        contentView.addSubview(cancelButton)
        
        self.flashButton.frame.origin = CGPoint(x: 5, y: 15)
        contentView.addSubview(self.flashButton)
        
        contentView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(DKCamera.handleZoom(_:))))
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DKCamera.handleFocus(_:))))
    }
    
    open func setupSession() {
        self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        self.setupCurrentDevice()
        
        var captureOutput: AVCaptureOutput!
        if #available(iOS 10.0, *) {
            let photoOutput = AVCapturePhotoOutput()
            photoOutput.isHighResolutionCaptureEnabled = true
            captureOutput = photoOutput
        } else {
            captureOutput = AVCaptureStillImageOutput()
        }
        
        if self.captureSession.canAddOutput(captureOutput) {
            self.captureSession.addOutput(captureOutput)
            self.captureOutput = captureOutput
        }
        
        if self.onFaceDetection != nil {
            let metadataOutput = AVCaptureMetadataOutput()
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue(label: "MetadataOutputQueue"))
            
            if self.captureSession.canAddOutput(metadataOutput) {
                self.captureSession.addOutput(metadataOutput)
                metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.face]
            }
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer.frame = self.view.bounds
        
        let rootLayer = self.view.layer
        rootLayer.masksToBounds = true
        rootLayer.insertSublayer(self.previewLayer, at: 0)
    }
    
    open func setupCurrentDevice() {
        if let currentDevice = self.currentDevice {
            
            if currentDevice.isFlashAvailable {
                self.flashButton.isHidden = false
                self.flashMode = self.flashModeFromUserDefaults()
            } else {
                self.flashButton.isHidden = true
            }
            
            for oldInput in self.captureSession.inputs {
                self.captureSession.removeInput(oldInput)
            }
            
            let frontInput = try? AVCaptureDeviceInput(device: self.currentDevice!)
            if self.captureSession.canAddInput(frontInput!) {
                self.captureSession.addInput(frontInput!)
            }
            
            try! currentDevice.lockForConfiguration()
            if currentDevice.isFocusModeSupported(.continuousAutoFocus) {
                currentDevice.focusMode = .continuousAutoFocus
            }
            
            if currentDevice.isExposureModeSupported(.continuousAutoExposure) {
                currentDevice.exposureMode = .continuousAutoExposure
            }
            
            currentDevice.unlockForConfiguration()
        }
    }
    
    open func setupDevices() {
        if #available(iOS 10.0, *) {
            self.captureDeviceFront = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            self.captureDeviceRear = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        } else {
            let devices = AVCaptureDevice.devices(for: .video)
            
            for device in devices {
                if device.position == .back {
                    self.captureDeviceRear = device
                }
                
                if device.position == .front {
                    self.captureDeviceFront = device
                }
            }
        }
        
        switch self.defaultCaptureDevice {
        case .front:
            self.currentDevice = self.captureDeviceFront ?? self.captureDeviceRear
        case .rear:
            self.currentDevice = self.captureDeviceRear ?? self.captureDeviceFront
        }
    }
    
    // MARK: - Session
    
    fileprivate var isStopped = false
    
    open func startSession() {
        self.isStopped = false
        
        if !self.captureSession.isRunning {
            self.captureSession.startRunning()
        }
    }
    
    open func stopSession() {
        self.pauseSession()
        
        self.captureSession.stopRunning()
    }
    
    open func pauseSession() {
        self.isStopped = true
        
        self.updateSession(isEnable: false)
    }
    
    open func updateSession(isEnable: Bool) {
        if ((!self.isStopped) || (self.isStopped && !isEnable)),
            let connection = self.previewLayer.connection {
            connection.isEnabled = isEnable
        }
    }
    
    // MARK: - Callbacks
    
    @objc internal func dismiss() {
        self.didCancel?()
    }
    
    @objc open func takePicture() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus == .denied {
            return
        }
        
        func process(_ imageData: Data) {
            let takenImage = UIImage(data: imageData)!
            let outputRect = self.previewLayer.metadataOutputRectConverted(fromLayerRect: self.previewLayer.bounds)
            let takenCGImage = takenImage.cgImage!
            let width = CGFloat(takenCGImage.width)
            let height = CGFloat(takenCGImage.height)
            let cropRect = CGRect(x: outputRect.origin.x * width, y: outputRect.origin.y * height, width: outputRect.size.width * width, height: outputRect.size.height * height)
            
            let cropCGImage = takenCGImage.cropping(to: cropRect)
            let cropTakenImage = UIImage(cgImage: cropCGImage!, scale: 1, orientation: takenImage.imageOrientation)
            
            var metadata: Dictionary<AnyHashable, Any>?
            if let source = CGImageSourceCreateWithData(imageData as CFData, nil) {
                metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? Dictionary<AnyHashable, Any>
            }
            
            self.didFinishCapturingImage?(cropTakenImage, metadata)
        }
        
        if #available(iOS 10.0, *) {
            if let photoOutput = self.captureOutput as? AVCapturePhotoOutput, self.currentCapturer == nil {
                self.captureButton.isEnabled = false
                
                self.sessionQueue.async {
                    if let connection = photoOutput.connection(with: .video) {
                        connection.videoOrientation = self.currentOrientation.toAVCaptureVideoOrientation()
                        connection.videoScaleAndCropFactor = self.zoomScale
                        
                        let settings = AVCapturePhotoSettings(from: self.defaultPhotoSettings)
                        
                        let capturer = DKCameraPhotoCapturer()
                        capturer.didCaptureWithImageData = { (imageData) in
                            process(imageData)
                        }
                        capturer.didFinish = { [unowned self] in
                            self.currentCapturer = nil
                            self.captureButton.isEnabled = true
                        }
                        
                        photoOutput.capturePhoto(with: settings, delegate: capturer)
                        
                        self.currentCapturer = capturer
                    }
                }
            }
        } else {
            if let stillImageOutput = self.captureOutput as? AVCaptureStillImageOutput, !stillImageOutput.isCapturingStillImage {
                self.captureButton.isEnabled = false
                
                self.sessionQueue.async(execute: {
                    if let connection = stillImageOutput.connection(with: .video) {
                        connection.videoOrientation = self.currentOrientation.toAVCaptureVideoOrientation()
                        connection.videoScaleAndCropFactor = self.zoomScale
                        
                        stillImageOutput.captureStillImageAsynchronously(from: connection, completionHandler: { (imageDataSampleBuffer, error) in
                            if error == nil {
                                if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!) {
                                    process(imageData)
                                    self.captureButton.isEnabled = true
                                }
                            } else {
                                print("error while capturing still image: \(error!.localizedDescription)", terminator: "")
                            }
                        })
                    }
                })
            }
        }
    }
    
    // MARK: - Handles Zoom
    
    @objc open func handleZoom(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .began {
            self.beginZoomScale = self.zoomScale
        } else if gesture.state == .changed {
            self.zoomScale = min(4.0, max(1.0, self.beginZoomScale * gesture.scale))
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.025)
            self.previewLayer.setAffineTransform(CGAffineTransform(scaleX: self.zoomScale, y: self.zoomScale))
            CATransaction.commit()
        }
    }
    
    // MARK: - Handles Focus
    
    @objc open func handleFocus(_ gesture: UITapGestureRecognizer) {
        if let currentDevice = self.currentDevice , currentDevice.isFocusPointOfInterestSupported {
            let touchPoint = gesture.location(in: self.view)
            self.focusAtTouchPoint(touchPoint)
        }
    }
    
    open func focusAtTouchPoint(_ touchPoint: CGPoint) {
        
        func showFocusViewAtPoint(_ touchPoint: CGPoint) {
            
            struct FocusView {
                static let focusView: UIView = {
                    let focusView = UIView()
                    let diameter: CGFloat = 100
                    focusView.bounds.size = CGSize(width: diameter, height: diameter)
                    focusView.layer.borderWidth = 2
                    focusView.layer.cornerRadius = diameter / 2
                    focusView.layer.borderColor = UIColor.white.cgColor
                    
                    return focusView
                }()
            }
            FocusView.focusView.transform = CGAffineTransform.identity
            FocusView.focusView.center = touchPoint
            self.view.addSubview(FocusView.focusView)
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.1,
                           options: UIViewAnimationOptions(), animations: { () -> Void in
                            FocusView.focusView.transform = CGAffineTransform.identity.scaledBy(x: 0.6, y: 0.6)
            }) { (Bool) -> Void in
                FocusView.focusView.removeFromSuperview()
            }
        }
        
        if self.currentDevice == nil || self.currentDevice?.isFlashAvailable == false {
            return
        }
        
        let focusPoint = self.previewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)
        
        showFocusViewAtPoint(touchPoint)
        
        if let currentDevice = self.currentDevice {
            try! currentDevice.lockForConfiguration()
            currentDevice.focusPointOfInterest = focusPoint
            currentDevice.exposurePointOfInterest = focusPoint
            
            currentDevice.focusMode = .continuousAutoFocus
            
            if currentDevice.isExposureModeSupported(.continuousAutoExposure) {
                currentDevice.exposureMode = .continuousAutoExposure
            }
            
            currentDevice.unlockForConfiguration()
        }
        
    }
    
    // MARK: - Handles Switch Camera
    
    @objc internal func switchCamera() {
        self.currentDevice = self.currentDevice == self.captureDeviceRear ?
            self.captureDeviceFront : self.captureDeviceRear
        
        self.setupCurrentDevice()
    }
    
    // MARK: - Handles Flash
    
    @objc internal func switchFlashMode() {
        switch self.flashMode! {
        case .auto:
            self.flashMode = .off
        case .on:
            self.flashMode = .auto
        case .off:
            self.flashMode = .on
        }
    }
    
    open func flashModeFromUserDefaults() -> AVCaptureDevice.FlashMode {
        let rawValue = UserDefaults.standard.integer(forKey: "DKCamera.flashMode")
        return AVCaptureDevice.FlashMode(rawValue: rawValue)!
    }
    
    open func updateFlashModeToUserDefautls(_ flashMode: AVCaptureDevice.FlashMode) {
        UserDefaults.standard.set(flashMode.rawValue, forKey: "DKCamera.flashMode")
    }
    
    open func updateFlashButton() {
        struct FlashImage {
            let images: [AVCaptureDevice.FlashMode: UIImage]
            
            init(cameraResource: DKCameraResource) {
                self.images = [
                    AVCaptureDevice.FlashMode.auto : cameraResource.cameraFlashAutoImage(),
                    AVCaptureDevice.FlashMode.on : cameraResource.cameraFlashOnImage(),
                    AVCaptureDevice.FlashMode.off : cameraResource.cameraFlashOffImage()
                ]
            }

            
        }
        let flashImage: UIImage = FlashImage(cameraResource:cameraResource).images[self.flashMode]!
        
        self.flashButton.setImage(flashImage, for: .normal)
        self.flashButton.sizeToFit()
    }
    
    open func updateFlashMode() {
        if let currentDevice = self.currentDevice, let captureOutput = self.captureOutput, currentDevice.isFlashAvailable  {
            if #available(iOS 10.0, *) {
                let isFlashModeSupported = (captureOutput as! AVCapturePhotoOutput).__supportedFlashModes.contains(NSNumber(value: self.flashMode.rawValue))
                if isFlashModeSupported {
                    self.defaultPhotoSettings.flashMode = self.flashMode
                }
            } else {
                if currentDevice.isFlashModeSupported(self.flashMode) {
                    try! currentDevice.lockForConfiguration()
                    currentDevice.flashMode = self.flashMode
                    currentDevice.unlockForConfiguration()
                }
            }
        }
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    
    public func metadataOutput(captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        self.onFaceDetection?(metadataObjects as! [AVMetadataFaceObject])
    }
    
    // MARK: - Handles Orientation
    
    open override var shouldAutorotate : Bool {
        return false
    }
    
    open func setupMotionManager() {
        self.motionManager.accelerometerUpdateInterval = 0.5
        self.motionManager.gyroUpdateInterval = 0.5
    }
    
    open func initialOriginalOrientationForOrientation() {
        self.originalOrientation = UIApplication.shared.statusBarOrientation.toDeviceOrientation()
        if let connection = self.previewLayer.connection {
            connection.videoOrientation = self.originalOrientation.toAVCaptureVideoOrientation()
        }
    }
    
    open func updateContentLayoutForCurrentOrientation() {
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
            
            UIView.animate(withDuration: 0.2, animations: {
                self.contentView.bounds.size = contentViewNewSize
                self.contentView.transform = CGAffineTransform(rotationAngle: newAngle)
            })
        } else {
            let rotateAffineTransform = CGAffineTransform.identity.rotated(by: newAngle)
            
            UIView.animate(withDuration: 0.2, animations: {
                self.flashButton.transform = rotateAffineTransform
                self.cameraSwitchButton.transform = rotateAffineTransform
            })
        }
    }
    
}

// MARK: - Utilities

public extension UIInterfaceOrientation {
    
    func toDeviceOrientation() -> UIDeviceOrientation {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeRight:
            return .landscapeLeft
        case .landscapeLeft:
            return .landscapeRight
        default:
            return .portrait
        }
    }
}

public extension UIDeviceOrientation {
    
    func toAVCaptureVideoOrientation() -> AVCaptureVideoOrientation {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeRight:
            return .landscapeLeft
        case .landscapeLeft:
            return .landscapeRight
        default:
            return .portrait
        }
    }
    
    func toInterfaceOrientationMask() -> UIInterfaceOrientationMask {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeRight:
            return .landscapeLeft
        case .landscapeLeft:
            return .landscapeRight
        default:
            return .portrait
        }
    }
    
    func toAngleRelativeToPortrait() -> CGFloat {
        switch self {
        case .portrait:
            return 0
        case .portraitUpsideDown:
            return CGFloat.pi
        case .landscapeRight:
            return -CGFloat.pi / 2.0
        case .landscapeLeft:
            return CGFloat.pi / 2.0
        default:
            return 0.0
        }
    }
    
}

public extension CMAcceleration {
    func toDeviceOrientation() -> UIDeviceOrientation? {
        if self.x >= 0.75 {
            return .landscapeRight
        } else if self.x <= -0.75 {
            return .landscapeLeft
        } else if self.y <= -0.75 {
            return .portrait
        } else if self.y >= 0.75 {
            return .portraitUpsideDown
        } else {
            return nil
        }
    }
}

// MARK: - Rersources

public extension Bundle {
    
    class func cameraBundle() -> Bundle {
        let assetPath = Bundle(for: DKDefaultCameraResource.self).resourcePath!
        return Bundle(path: (assetPath as NSString).appendingPathComponent("DKCameraResource.bundle"))!
    }
    
}

open class DKDefaultCameraResource: DKCameraResource {
    
    open func imageForResource(_ name: String) -> UIImage {
        let bundle = Bundle.cameraBundle()
        let imagePath = bundle.path(forResource: name, ofType: "png", inDirectory: "Images")
        let image = UIImage(contentsOfFile: imagePath!)
        return image!
    }
    
     public func cameraCancelImage() -> UIImage {
        return imageForResource("camera_cancel")
    }
    
     public func cameraFlashOnImage() -> UIImage {
        return imageForResource("camera_flash_on")
    }
    
     public func cameraFlashAutoImage() -> UIImage {
        return imageForResource("camera_flash_auto")
    }
    
     public func cameraFlashOffImage() -> UIImage {
        return imageForResource("camera_flash_off")
    }
    
     public func cameraSwitchImage() -> UIImage {
        return imageForResource("camera_switch")
    }
    
}

