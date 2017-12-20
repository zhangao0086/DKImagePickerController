DKImagePickerController
=======================

 [![Build Status](https://secure.travis-ci.org/zhangao0086/DKImagePickerController.svg)](http://travis-ci.org/zhangao0086/DKImagePickerController) [![Version Status](http://img.shields.io/cocoapods/v/DKImagePickerController.png)][docsLink] [![license MIT](https://img.shields.io/cocoapods/l/DKImagePickerController.svg?style=flat)][mitLink]

<img width="30%" height="30%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot3.png" /><img width="30%" height="30%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot4.png" />
---
<img width="30%" height="30%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot11.png" /><img width="30%" height="30%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot6.png" />
---

## Description
`DKImagePickerController` is a highly customizable, pure-Swift library.

### Features
* Supports both single and multiple selection.
* Supports filtering albums and sorting by type.
* Supports landscape and iPad and orientation switching.
* Supports iCloud.
* Supports batch exports `PHAsset` to files.
* Inline mode.
* Customizable `UICollectionViewLayout`.
* Customizable camera/photo gallery/photo editor.

## Requirements
* iOS 8.0+
* ARC
* Swift 3.2 & 4

## Installation
#### iOS 8 and newer
DKImagePickerController is available on CocoaPods. Simply add the following line to your podfile:

```ruby
# For latest release in cocoapods
pod 'DKImagePickerController'
```

## Getting Started
#### Initialization and presentation
```swift

let pickerController = DKImagePickerController()

pickerController.didSelectAssets = { (assets: [DKAsset]) in
    print("didSelectAssets")
    print(assets)
}

self.presentViewController(pickerController, animated: true) {}

````

#### Customizing

```swift
/// Forces selection of tapped image immediately.
public var singleSelect = false
    
/// The maximum count of assets which the user will be able to select.
public var maxSelectableCount = 999

/// Set the defaultAssetGroup to specify which album is the default asset group.
public var defaultAssetGroup: PHAssetCollectionSubtype?

/// The types of PHAssetCollection to display in the picker.
public var assetGroupTypes: [PHAssetCollectionSubtype] = [
    .SmartAlbumUserLibrary,
    .SmartAlbumFavorites,
    .AlbumRegular
    ]

/// Set the showsEmptyAlbums to specify whether or not the empty albums is shown in the picker.
public var showsEmptyAlbums = true

/// The type of picker interface to be displayed by the controller.
public var assetType: DKImagePickerControllerAssetType = .AllAssets

/// The predicate applies to images only.
public var imageFetchPredicate: NSPredicate?

/// The predicate applies to videos only.
public var videoFetchPredicate: NSPredicate?

/// If sourceType is Camera will cause the assetType & maxSelectableCount & allowMultipleTypes & defaultSelectedAssets to be ignored.
public var sourceType: DKImagePickerControllerSourceType = .Both

/// Whether allows to select photos and videos at the same time.
public var allowMultipleTypes = true

/// Determines whether or not the rotation is enabled.
public var allowsLandscape = false

/// The callback block is executed when user pressed the cancel button.
public var didCancel: (() -> Void)?
public var showsCancelButton = false

/// The callback block is executed when user pressed the select button.
public var didSelectAssets: ((assets: [DKAsset]) -> Void)?

/// It will have selected the specific assets.
public var defaultSelectedAssets: [DKAsset]?

/// allow swipe to select images.
public var allowSwipeToSelect: Bool = false

public var inline: Bool = false

/// Limits the maximum number of objects returned in the fetch result, a value of 0 means no limit.
public var fetchLimit = 0

public var selectedChanged: (() -> Void)?

```

## Inline

<img width="30%" height="30%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot11.png" />

```swift
let groupDataManagerConfiguration = DKImageGroupDataManagerConfiguration()
groupDataManagerConfiguration.fetchLimit = 10
groupDataManagerConfiguration.assetGroupTypes = [.smartAlbumUserLibrary]

let groupDataManager = DKImageGroupDataManager(configuration: groupDataManagerConfiguration)

let pickerController = DKImagePickerController(groupDataManager: groupDataManager)
pickerController.inline = true
pickerController.UIDelegate = CustomInlineLayoutUIDelegate(imagePickerController: pickerController)
pickerController.assetType = .allPhotos
pickerController.sourceType = .photo

let pickerView = self.pickerController.view!
pickerView.frame = CGRect(x: 0, y: 170, width: self.view.bounds.width, height: 200)
self.view.addSubview(pickerView)
```

## UI customization

<img width="30%" height="30%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot6.png" />

For example, see [CustomUIDelegate](https://github.com/zhangao0086/DKImagePickerController/tree/develop/DKImagePickerControllerDemo/CustomUIDelegate).

## Layout customization

<img width="30%" height="30%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot10.png" />

For example, see [CustomLayoutUIDelegate](https://github.com/zhangao0086/DKImagePickerController/tree/develop/DKImagePickerControllerDemo/CustomLayoutUIDelegate).

### Conforms UIAppearance protocol

<img width="30%" height="30%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot9.png" />

You can easily customize the appearance of navigation bar using the appearance proxy.
```swift
UINavigationBar.appearance().titleTextAttributes = [
    NSFontAttributeName : UIFont(name: "Optima-BoldItalic", size: 21)!,
    NSForegroundColorAttributeName : UIColor.redColor()
]
```

### Exporting to file
```swift
/**
    Writes the image in the receiver to the file specified by a given path.
*/
public func writeImageToFile(path: String, completeBlock: (success: Bool) -> Void)

/**
    Writes the AV in the receiver to the file specified by a given path.

    - parameter presetName:    An NSString specifying the name of the preset template for the export. See AVAssetExportPresetXXX.
*/
public func writeAVToFile(path: String, presetName: String, completeBlock: (success: Bool) -> Void)

```

## Extensions

#### Camera

You can give a class that implements the `DKImagePickerControllerUIDelegate` protocol to customize camera.  
For example, see [CustomCameraUIDelegate](https://github.com/zhangao0086/DKImagePickerController/tree/develop/DKImagePickerControllerDemo/CustomCameraUIDelegate).

#### Photo Gallery

#### Photo Editor

## How to use in Objective-C

#### If you use [CocoaPods](http://cocoapods.org/)

* Adding the following two lines into your `Podfile`:

    ```ruby
    pod 'DKImagePickerController'
    use_frameworks!
    ```
* Importing it into your Objective-C file: 

    ```objective-c
    #import <DKImagePickerController/DKImagePickerController-Swift.h>
    ```

#### If you use it directly in your project

> See also:[Swift and Objective-C in the Same Project](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html)

* Drag and drop the [DKCamera][DKCamera] and `DKImageManager` and `DKImagePickerController` to your project
* Importing it into your Objective-C file: 

    ```objective-c
    #import "YourProductModuleName-Swift.h"
    ```

---
then you can:

```objective-c
DKImagePickerController *pickerController = [DKImagePickerController new];

 [pickerController setDidSelectAssets:^(NSArray * __nonnull assets) {
     NSLog(@"didSelectAssets");
 }];
 
 [self presentViewController:pickerController animated:YES completion:nil];
```

## Localization
The default supported languages:

> en, es, da, de, fr, hu, ja, ko, nb-NO, pt_BR, ru, tr, ur, vi, ar, it, zh-Hans, zh-Hant

You can also add a hook to return your own localized string:

```swift
DKImagePickerControllerResource.customLocalizationBlock = { title in
    if title == "picker.select.title" {
        return "Test(%@)"
    } else {
        return nil
    }
}
```

or images:

```swift
DKImagePickerControllerResource.customImageBlock = { imageName in
    if imageName == "camera" {
        return DKImagePickerControllerResource.photoGalleryCheckedImage()
    } else {
        return nil
    }
}
```

## Contributing to this project
If you have feature requests or bug reports, feel free to help out by sending pull requests or by creating new issues.

## License
DKImagePickerController is released under the MIT license. See LICENSE for details.

[mitLink]:http://opensource.org/licenses/MIT
[docsLink]:http://cocoadocs.org/docsets/DKImagePickerController
[DKCamera]:https://github.com/zhangao0086/DKCamera