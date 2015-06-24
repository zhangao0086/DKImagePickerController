FBImagePickerController
=======================

## Description
This is a very simple Image Picker Controller by Swift.
It has been styled with similarity to image picker used by
Facebook application. That's why name FBImagePickerController.
It does not link to FB in any other way.
**AssetsLibrary.framework is required.**

## Use
#### Initialization and presentation
```swift

let pickerController = FBImagePickerController()
pickerController.pickerDelegate = self
self.presentViewController(pickerController, animated: true) {}
````
#### Delegate methods
```swift
func imagePickerControllerCancelled() {
    self.dismissViewControllerAnimated(true, completion: nil)
}

func imagePickerControllerDidSelectedAssets(assets: [FBAsset]!) {
    for (index, asset) in enumerate(assets) {
        
    }
    
    self.dismissViewControllerAnimated(true, completion: nil)
}

````
#### Configurable properties
```swift
/// Displayed when denied access
var noAccessView: UIView
````

## Screenshots
<img width="50%" height="50%" src="https://raw.githubusercontent.com/oskarirauta/FBImagePickerController/master/screenshot1.png" />
---
<img width="50%" height="50%" src="https://raw.githubusercontent.com/oskarirauta/FBImagePickerController/master/screenshot2.png" />  
---
<img width="50%" height="50%" src="https://raw.githubusercontent.com/oskarirauta/FBImagePickerController/master/screenshot3.png" />
