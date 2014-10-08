DKImagePickerController
=======================

## Description
This is a very simple Image Picker Controller by Swift.  
**AssetsLibrary.framework is required.**

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
    imageScrollView.subviews.map(){$0.removeFromSuperview}
    
    for (index, asset) in enumerate(assets) {
        
    }
    
    self.dismissViewControllerAnimated(true, completion: nil)
}

````

## Screenshots
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/master/intro1.PNG" />
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/master/intro2.PNG" />  
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/master/intro3.PNG" />
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/master/intro4.PNG" />  