DKCamera
=======================

 [![Build Status](https://secure.travis-ci.org/zhangao0086/DKCamera.svg)](http://travis-ci.org/zhangao0086/DKCamera) [![Version Status](http://img.shields.io/cocoapods/v/DKCamera.png)][docsLink] [![license MIT](https://img.shields.io/cocoapods/l/DKCamera.svg?style=flat)][mitLink]

<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKCamera/develop/Screenshot1.png" />

---
## Description
A light weight & simple & easy camera for iOS by Swift. It uses `CoreMotion` framework to detect device orientation, so the screen-orientation lock will be ignored(*Perfect orientation handling*). And it has two other purposes:

* Can be presenting or pushing or Integrating.
* Suppressing the warning **"Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates."**(It seems a bug in iOS 8).
* Compatible with iOS 11 and iPhone X

## Requirements
* Xcode 9
* Swift 4

## Installation
#### iOS 8 and newer
DKCamera is available on CocoaPods. Simply add the following line to your podfile:

```ruby
# For latest release in cocoapods
pod 'DKCamera'
```

#### Swift 3.x
> use version < 1.5.0

#### iOS 7.x
> Please use the `1.2.11` tag.
> To use Swift libraries on apps that support iOS 7, you must manually copy the files into your application project.
> [CocoaPods only supports Swift on OS X 10.9 and newer, and iOS 8 and newer.](https://github.com/CocoaPods/blog.cocoapods.org/commit/6933ae5ccfc1e0b39dd23f4ec67d7a083975836d)

## Easy to use

```swift
let camera = DKCamera()

camera.didCancel = {
	print("didCancel")

	self.dismiss(animated: true, completion: nil)
}

camera.didFinishCapturingImage = { (image: UIImage?, metadata: [AnyHashable : Any]?) in
    print("didFinishCapturingImage")
    
    self.dismiss(animated: true, completion: nil)
    
    self.imageView?.image = image
}

self.present(camera, animated: true, completion: nil)

````

### You also can use these APIs:

```swift
open var cameraOverlayView: UIView?

/// The flashModel will to be remembered to next use.
open var flashMode:AVCaptureFlashMode!

open class func isAvailable() -> Bool

/// Determines whether or not the rotation is enabled.
open var allowsRotate = false

/// set to NO to hide all standard camera UI. default is YES.
open var showsCameraControls = true

open var defaultCaptureDevice = DKCameraDeviceSourceType.rear

/// Notify the listener of the detected faces in the preview frame.
open var onFaceDetection: ((_ faces: [AVMetadataFaceObject]) -> Void)?
```

> If you are going to add a full-screen view as `cameraOverlayView`, maybe you should use the `DKCameraPassthroughView` or its subclass that have overriden the `hitTest` method in order to the event passes through to the expected view.
```swift
//  DKCamera.swift
public class DKCameraPassthroughView: UIView {
	public override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
		let hitTestingView = super.hitTest(point, withEvent: event)
		return hitTestingView == self ? nil : hitTestingView
	}
}
```

## License
DKCamera is released under the MIT license. See LICENSE for details.

[docsLink]:http://cocoadocs.org/docsets/DKCamera
[mitLink]:http://opensource.org/licenses/MIT
