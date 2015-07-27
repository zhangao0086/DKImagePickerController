DKImagePickerController
=======================

Update for Xcode 6.3 with Swift 1.2
---
## Description
This is a very simple Image Picker Controller by Swift.  

## Installation
DKImagePickerController is available on Cocoapods. Simply add the following line to your podfile:
```
pod 'DKImagePickerController', '~> 1.0.0'
```

## Use
#### Initialization and presentation
```swift

let pickerController = DKImagePickerController()
pickerController.pickerDelegate = self
self.presentViewController(pickerController, animated: true) {}
````
#### Delegate methods
```swift
func imagePickerControllerCancelled() {
    self.dismissViewControllerAnimated(true, completion: nil)
}

func imagePickerControllerDidSelectedAssets(assets: [DKAsset]!) {
    for (index, asset) in enumerate(assets) {
        
    }
    
    self.dismissViewControllerAnimated(true, completion: nil)
}

````
#### Configurable properties
```swift
/// The height of the bottom of the preview
var previewHeight: CGFloat = 80

var rightButtonTitle: String = "确定"

/// Displayed when denied access
var noAccessView: UIView
````

## Screenshots
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/master/intro1.PNG" />
---
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/master/intro2.PNG" />  
---
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/master/intro3.PNG" />
---
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/master/intro4.PNG" />  
