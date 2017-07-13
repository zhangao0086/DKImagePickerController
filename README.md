DKImagePickerController
=======================

<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot1.png" /><img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot2.png" />
---
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot3.png" /><img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot4.png" />
---
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot5.png" /><img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot6.png" />
---

## Description
参考swift写的OC的.  

### Features
* Supports both single and multiple selection.
* Supports filtering albums and sorting by type.
* Supports landscape and iPad and orientation switching.
* Supports iCloud.
* Supports UIAppearance.
* Customizable camera.
* Customizable UI.
* Customizable UICollectionViewLayout.
* Supports footer view.

## Requirements
* iOS 8.0+
* ARC
* Xcode 8



#### Camera customization

You can give a class that implements the `DKImagePickerControllerUIDelegate` protocol to customize camera.  
For example, see [CustomCameraUIDelegate](https://github.com/zhangao0086/DKImagePickerController/tree/develop/DKImagePickerControllerDemo/CustomCameraUIDelegate).

#### UI customization

<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot6.png" />

For example, see [CustomUIDelegate](https://github.com/zhangao0086/DKImagePickerController/tree/develop/DKImagePickerControllerDemo/CustomUIDelegate).

#### Layout customization

<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot10.png" />

For example, see [CustomLayoutUIDelegate](https://github.com/zhangao0086/DKImagePickerController/tree/develop/DKImagePickerControllerDemo/CustomLayoutUIDelegate).

##### Conforms UIAppearance protocol
You can easily customize the appearance of navigation bar using the appearance proxy.
```
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot9.png" />


```objective-c
DKImagePickerController *pickerController = [DKImagePickerController new];
pickerController.assetType = DKImagePickerControllerAssetTypeAllAssets;
pickerController.showsCancelButton = NO;
pickerController.showsEmptyAlbums = YES;
pickerController.allowMultipleTypes = YES;
pickerController.defaultSelectedAssets = @[];
pickerController.sourceType = DKImagePickerControllerSourceTypeBoth;
//  pickerController.assetGroupTypes    // unavailable
//  pickerController.defaultAssetGroup  // unavailable

 [pickerController setDidSelectAssets:^(NSArray * __nonnull assets) {
     NSLog(@"didSelectAssets");
 }];
 
 [self presentViewController:pickerController animated:YES completion:nil];
```

