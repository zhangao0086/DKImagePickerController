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
public var previewHeight: CGFloat = 80

public var rightButtonTitle: String = "Select"

public var maxSelectableCount = 999

/// Displayed when denied access
public var noAccessView: UIView = {
    let label = UILabel()
    label.text = "User has denied access"
    label.textAlignment = NSTextAlignment.Center
    label.textColor = UIColor.lightGrayColor()
    return label
}()

public weak var pickerDelegate: DKImagePickerControllerDelegate?

public var defaultSelectedAssets: [DKAsset]?
````

## Screenshots
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot1.png" /><img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot2.png" />
---
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot3.png" />
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot4.png" />
---
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot5.png" />
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot6.png" />
---
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot7.png" />
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot8.png" />
---
