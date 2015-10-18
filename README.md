DKImagePickerController
=======================

 [![Build Status](https://secure.travis-ci.org/zhangao0086/DKImagePickerController.svg)](http://travis-ci.org/zhangao0086/DKImagePickerController) [![Version Status](http://img.shields.io/cocoapods/v/DKImagePickerController.png)][docsLink] [![license MIT](http://img.shields.io/badge/license-MIT-orange.png)][mitLink]
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot1.png" /><img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot2.png" />
---
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot3.png" /><img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot4.png" />
---
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot5.png" /><img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot6.png" />
---
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot7.png" /><img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Screenshot8.png" />
---


Update for Xcode 7 with Swift 2.0
---
## Description
New version! It's a Facebook style Image Picker Controller by Swift. It uses [DKCamera][DKCamera] instead of `UIImagePickerController` since the latter cannot be Integrated into another container, and it will raise a warning `Snapshotting ... or snapshot after screen updates.` in **iOS 8**.

## Requirements
* iOS 7.1+
* ARC

## Installation
#### iOS 8 and newer
DKImagePickerController is available on Cocoapods. Simply add the following line to your podfile:

```ruby
# For latest release in cocoapods
pod 'DKImagePickerController'
```

#### iOS 7.x
To use Swift libraries on apps that support iOS 7, you must manually copy the files into your application project.
[CocoaPods only supports Swift on OS X 10.9 and newer, and iOS 8 and newer.](https://github.com/CocoaPods/blog.cocoapods.org/commit/6933ae5ccfc1e0b39dd23f4ec67d7a083975836d)

## Getting Started
#### Initialization and presentation
```swift

let pickerController = DKImagePickerController()

pickerController.didCancel = { () in
    println("didCancel")
}

pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
    println("didSelectAssets")
    println(assets)
}

self.presentViewController(pickerController, animated: true) {}

````

#### Customizing

```swift
/// Forces selction of tapped image immediatly
public var singleSelect = false

/// The maximum count of assets which the user will be able to select.
public var maxSelectableCount = 999

// The types of ALAssetsGroups to display in the picker
public var assetGroupTypes: UInt32 = ALAssetsGroupAll

/// The type of picker interface to be displayed by the controller.
public var assetType = DKImagePickerControllerAssetType.allAssets

/// If sourceType is Camera will cause the assetType & maxSelectableCount & allowMultipleTypes & defaultSelectedAssets to be ignored.
public var sourceType: DKImagePickerControllerSourceType = .Camera | .Photo

/// Whether allows to select photos and videos at the same time.
public var allowMultipleTypes = true

/// The callback block is executed when user pressed the select button.
public var didSelectAssets: ((assets: [DKAsset]) -> Void)?

/// The callback block is executed when user pressed the cancel button.
public var didCancel: (() -> Void)?

/// It will have selected the specific assets.
public var defaultSelectedAssets: [DKAsset]?
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

#### Quickly take a picture

```swift
pickerController.sourceType = .Camera
```
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Exhibit2.gif" />

#### Hides camera

```swift
pickerController.sourceType = .Photo
```
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKImagePickerController/develop/Exhibit1.png" />

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

* Drag and drop the [DKCamera][DKCamera] and `DKImagePickerController` to your project
* Importing it into your Objective-C file: 

    ```objective-c
    #import "YourProductModuleName-Swift.h"
    ```

---
then you can:

```objective-c
DKImagePickerController *imagePickerController = [DKImagePickerController new];
[imagePickerController setDidSelectAssets:^(NSArray * __nonnull assets) {
    NSLog(@"didSelectAssets");
}];

[self presentViewController:imagePickerController animated:YES completion:nil];
```

## Localization
It has been supported languages so far:

* en.lproj
* zh-Hans.lproj

If you want to add new language, pull request or issue!

---
You can merge your branch into the `develop` branch. Any Pull Requests to be welcome!!!

## Special Thanks
Thanks for [scottdelly][scottdelly]'s [contribution][scottdellyCon] and [performance improvement][scottdellyCon1]!  
Thanks for [LucidityDesign][LucidityDesign]'s [contribution][LucidityDesignCon]!

## License
DKImagePickerController is released under the MIT license. See LICENSE for details.

[docsLink]:http://cocoadocs.org/docsets/DKImagePickerController
[mitLink]:http://opensource.org/licenses/MIT
[DKCamera]:https://github.com/zhangao0086/DKCamera
[scottdelly]:https://github.com/scottdelly
[scottdellyCon]:https://github.com/zhangao0086/DKImagePickerController/graphs/contributors
[scottdellyCon1]:https://github.com/zhangao0086/DKImagePickerController/pull/24/commits
[LucidityDesign]:https://github.com/LucidityDesign
[LucidityDesignCon]:https://github.com/zhangao0086/DKImagePickerController/pull/19/commits
