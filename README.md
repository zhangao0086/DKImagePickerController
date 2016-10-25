DKImagePickerController
=======================

 [![Build Status](https://secure.travis-ci.org/zhangao0086/DKImagePickerController.svg)](http://travis-ci.org/zhangao0086/DKImagePickerController) [![Version Status](http://img.shields.io/cocoapods/v/DKImagePickerController.png)][docsLink] [![license MIT](http://img.shields.io/badge/license-MIT-orange.png)][mitLink] [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot1.png" /><img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot2.png" />
---
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot3.png" /><img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot4.png" />
---
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot5.png" /><img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot6.png" />
---

## Description
It's a Facebook style Image Picker Controller by Swift. It uses [DKCamera][DKCamera] instead of `UIImagePickerController` since the latter cannot be Integrated into another container, and it will raise a warning `Snapshotting ... or snapshot after screen updates.` in **iOS 8**.

### Features
* Supports both single and multiple selection.
* Supports filtering albums and sorting by type.
* Supports landscape and iPad and orientation switching.
* Supports iCloud.
* Supports UIAppearance.
* Supports custom camera.
* Supports custom UICollectionViewLayout.
* Supports footer view.

## Requirements
* iOS 8.0+
* ARC
* Swift 3 and Xcode 8

## Installation
#### iOS 8 and newer
DKImagePickerController is available on CocoaPods. Simply add the following line to your podfile:

```ruby
# For latest release in cocoapods
pod 'DKImagePickerController'


```

#### iOS 7.x

> The 3.x aren't supported before iOS 8. If you want to support iOS 7, you can look at the [2.4.3](https://github.com/zhangao0086/DKImagePickerController/tree/2.4.3) branch that uses `ALAssetsLibrary` instead of using `Photos`.

> To use Swift libraries on apps that support iOS 7, you must manually copy the files into your application project.
[CocoaPods only supports Swift on OS X 10.9 and newer, and iOS 8 and newer.](https://github.com/CocoaPods/blog.cocoapods.org/commit/6933ae5ccfc1e0b39dd23f4ec67d7a083975836d)

#### Swift 2.2
> For Swift 2.2, use version <= 3.3.4

#### Swift 2.3
> For Swift 2.3, use version = 3.3.5

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
/// Forces selection of tapped image immediatly.
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

/// If YES, and the requested image is not stored on the local device, the Picker downloads the image from iCloud.
public var autoDownloadWhenAssetIsInCloud = true

/// Determines whether or not the rotation is enabled.
public var allowsLandscape = false

/// The callback block is executed when user pressed the cancel button.
public var didCancel: (() -> Void)?
public var showsCancelButton = false

/// The callback block is executed when user pressed the select button.
public var didSelectAssets: ((assets: [DKAsset]) -> Void)?

/// It will have selected the specific assets.
public var defaultSelectedAssets: [DKAsset]?

```

##### Exporting to file
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

##### Customize Navigation Bar
You can easily customize the appearance of navigation bar using the appearance proxy.
```swift
UINavigationBar.appearance().titleTextAttributes = [
    NSFontAttributeName : UIFont(name: "Optima-BoldItalic", size: 21)!,
    NSForegroundColorAttributeName : UIColor.redColor()
]
```
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot9.png" />

#### Hides camera

```swift
pickerController.sourceType = .Photo
```
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot10.png" />

#### Quickly take a picture

```swift
pickerController.sourceType = .Camera
```
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Exhibit1.gif" />

##### Customize footer view and UI color
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot11.png" />

#### Create a custom camera

You can give a class that implements the `DKImagePickerControllerUIDelegate` protocol to customize camera.  
The following code uses a `UIImagePickerController`:
```swift
public class CustomUIDelegate: DKImagePickerControllerDefaultUIDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var didCancel: (() -> Void)?
    var didFinishCapturingImage: ((image: UIImage) -> Void)?
    var didFinishCapturingVideo: ((videoURL: NSURL) -> Void)?
    
    public override func imagePickerControllerCreateCamera(imagePickerController: DKImagePickerController,
                                                           didCancel: (() -> Void),
                                                           didFinishCapturingImage: ((image: UIImage) -> Void),
                                                           didFinishCapturingVideo: ((videoURL: NSURL) -> Void)
                                                           ) -> UIViewController {
        self.didCancel = didCancel
        self.didFinishCapturingImage = didFinishCapturingImage
        self.didFinishCapturingVideo = didFinishCapturingVideo
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .Camera
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        return picker
    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        if mediaType == kUTTypeImage as String {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.didFinishCapturingImage?(image: image)
        } else if mediaType == kUTTypeMovie as String {
            let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
            self.didFinishCapturingVideo?(videoURL: videoURL)
        }
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.didCancel?()
    }
    
}
```

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

## Localization
It has been supported languages so far:

* en.lproj
* zh-Hans.lproj
* hu.lproj
* ru.lproj
* es.lproj
* tr.lproj
* de.lproj
* ur.lproj

If you want to add new language, pull request or issue!

---
You can merge your branch into the `develop` branch. Any Pull Requests to be welcome!!!

## Change Log

## [3.4.1](https://github.com/zhangao0086/DKImagePickerController/tree/3.4.1) (2016-10-25)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.4.0...3.4.1)

- Added french language.

- Updated the condition of isInCloud.

- Add CryptoSwift lib in order to the DKAsset has a unique identifier.

- Improve scroll performance.

- Fix crash issue.

- Added support for asset editing.

- Fix an issue that may cause arrow does not appear.

## [3.4.0](https://github.com/zhangao0086/DKImagePickerController/tree/3.4.0) (2016-09-18)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.3.4...3.4.0)

- Migrating to swift3

> [More logs...](https://github.com/zhangao0086/DKImagePickerController/blob/develop/CHANGELOG.md)

## Special Thanks
Big thanks to all the [contributors][contributors] so far!

## License
DKImagePickerController is released under the MIT license. See LICENSE for details.

[docsLink]:http://cocoadocs.org/docsets/DKImagePickerController
[mitLink]:http://opensource.org/licenses/MIT
[DKCamera]:https://github.com/zhangao0086/DKCamera
[contributors]:https://github.com/zhangao0086/DKImagePickerController/graphs/contributors
