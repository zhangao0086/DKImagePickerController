# Change Log

## [4.3.2](https://github.com/zhangao0086/DKImagePickerController/tree/4.3.2) (2020-06-03)

- Adds compression quality parameter to export configuration.

## [4.3.1](https://github.com/zhangao0086/DKImagePickerController/tree/4.3.1) (2020-05-16)

- Fixed an issue that caused Carthage was broken.
- DKImageExtensionController can control whether to disable an specfic extension. 

## [4.3.0](https://github.com/zhangao0086/DKImagePickerController/tree/4.3.0) (2020-04-27)

- Drop support for iOS 8

## [4.2.1](https://github.com/zhangao0086/DKImagePickerController/tree/4.2.1) (2019-11-08)

- Fixed #632
- Fixed #629
- Fixed #630

## [4.2.0](https://github.com/zhangao0086/DKImagePickerController/tree/4.2.0) (2019-10-14)

- Dark Mode Support
- Add scroll:to:indexPath:
- Fixed #553 #620
- Fixed #597

## [4.1.3](https://github.com/zhangao0086/DKImagePickerController/tree/4.1.3) (2019-02-26)

- Avoiding force unwrapping.

- Add `.smartAlbumUserLibrary` conditions into reload logic to avoid huge amount of `collectionView.reloadData()` calling while users have a large amount of groups in their albums.

- Allow customization of asset group list cells and presentation style.

- Allow customization of detail list title view.

## [4.1.2](https://github.com/zhangao0086/DKImagePickerController/tree/4.1.2) (2018-12-23)

- Fixed an issue that caused the callback did not invoke.

## [4.1.1](https://github.com/zhangao0086/DKImagePickerController/tree/4.1.1) (2018-12-22)

- Allow "Select All".

- Fixed #552.

- Fixed #554.

- Fixed a crash caused by performBatchUpdates.

- Updated the version of used TOCropViewController to ~> 2.4.

- The ability to hide cropping feature.

## [4.1.0](https://github.com/zhangao0086/DKImagePickerController/tree/4.1.0) (2018-11-19)

- Can reload with a new configuration.

- Added support for GPS metadata.

- Replace CLImageEditor with TOCropViewController.

- Fixed memory leaks.

## [4.0.3](https://github.com/zhangao0086/DKImagePickerController/tree/4.0.3) (2017-09-24)

- Carthage.

- Swift 4.2 & Xcode 10.

## [3.8.0](https://github.com/zhangao0086/DKImagePickerController/tree/3.8.0) (2017-09-24)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.6.1...3.8.0)

- Swift 4.

- Fixed #380.

- Fixed #381.

- Fixed #374.

- Handle iOS 11 BarButtonItems bug.

- In iOS 10.0, use AVCapturePhotoOutput instead AVCaptureStillImageOutput.

## [3.6.1](https://github.com/zhangao0086/DKImagePickerController/tree/3.6.1) (2017-08-29)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.6.0...3.6.1)

- Updated way of implementation for fetchLimit.

- Call triggerSelectedChanged if deselectAllAssets was called.

## [3.6.0](https://github.com/zhangao0086/DKImagePickerController/tree/3.6.0) (2017-08-24)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.5.6...3.6.0)

- Support Italian language.

- Support Arabic language

- Ability to specify the exported file format.

- Added support for fetchLimit.

- Added support for inline mode.

- Save image with metadata.

- Updated DKCamera.

## [3.5.6](https://github.com/zhangao0086/DKImagePickerController/tree/3.5.6) (2017-06-24)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.5.5...3.5.6)

- Fixes an issue may cause crashes.

- Add norwegian translation for bokmål dialect

- Fixed an issue cause crash when remove observer.

- Updated the size of album list view to fit them when add or remove of photo albums.

- Improved sync of albums.

## [3.5.5](https://github.com/zhangao0086/DKImagePickerController/tree/3.5.5) (2017-05-24)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.5.3...3.5.5)

- Fixed #309

## [3.5.3](https://github.com/zhangao0086/DKImagePickerController/tree/3.5.3) (2017-05-22)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.5.2...3.5.3)

- Fixed minor bugs.

## [3.5.2](https://github.com/zhangao0086/DKImagePickerController/tree/3.5.2) (2017-05-17)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.5.1...3.5.2)

- Custom filter for assets.

- Added location property for DKAsset.

- Removed deprecated calls: M_PI, M_PI_2.

- Fixed an issue cause deselect images failed.

- Fixed an issue cause camera not working properly.

- Fixed an issue cause didCancel not working.	

- Fixed a memory leak issue.

## [3.5.1](https://github.com/zhangao0086/DKImagePickerController/tree/3.5.1) (2017-02-22)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.5.0...3.5.1)

- Fix https://github.com/zhangao0086/DKImagePickerController/pull/277.

- Update DKCamera.

- Sorting photos like native Photos app.

## [3.5.0](https://github.com/zhangao0086/DKImagePickerController/tree/3.5.0) (2017-01-03)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.4.1...3.5.0)

- Added danish translation.

- Added Korean Language.

- Added Traditional Chinese language.

- Added Vietnamese language.

- Updated DKCamera.

- Updated demo project.

- Updated API for custom camera.

- Supports UICollectionViewCell customizable.

- DKPermissionView access modifier is open.

- Fixed some bugs.

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

## [3.3.4](https://github.com/zhangao0086/DKImagePickerController/tree/3.3.4) (2016-08-16)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.3.3...3.3.4)

- Fixed an issue may cause singleSelect doesn't work as it should.

## [3.3.3](https://github.com/zhangao0086/DKImagePickerController/tree/3.3.3) (2016-08-08)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.3.2...3.3.3)

- Added Carthage support

- Added Urdu lozalization

- Added German localization

- Added `deselectAssetAtIndex` and `deselectAsset`.

- Added `deselectAllAssets`.

- Fixed an issue may cause `takePicture` is incorrect.

- If a camera is not available, don't pops-up "Max photos limit reached".

- The `didCancel` and `didSelectAssets` are executed after completion.

- Updated DKImagePickerControllerDefaultUIDelegate interface.

- Rename `unselectedImage` to `deselectImage`.

- Rename `selectedImage` to `selectImage`. 

- Replace tags with spaces.

## [3.3.2](https://github.com/zhangao0086/DKImagePickerController/tree/3.3.2) (2016-06-20)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.3.1...3.3.2)

**Merged pull requests:**

- Fixed an issue that can cause memory leaks to DKAssetGroupDetailVC.

- Fixed an issue that may cause the backgroundColor of the DKAssetGroupDetail's view is incorrect.

## [3.3.1](https://github.com/zhangao0086/DKImagePickerController/tree/3.3.1) (2016-06-19)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.3.0...3.3.1)

**Merged pull requests:**

- Fixed an issue that may cause crash when an asset group doesn't know its totalCount.

## [3.3.0](https://github.com/zhangao0086/DKImagePickerController/tree/3.3.0) (2016-06-17)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.2.1...3.3.0)

**Merged pull requests:**

- Fix the thumbnails have low quality.

- Added Turkish localization support.

- Added footer view.

- Removed picker singleton.

- Updated DKImagePickerControllerDefaultUIDelegate.

## [3.2.1](https://github.com/zhangao0086/DKImagePickerController/tree/3.2.1) (2016-05-23)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.2.0...3.2.1)

**Merged pull requests:**

- Add Russian translation.

- Fixed an issue may cause popoverView show in incorrect position.

- Optimized memory usage with large files.

- Added support for Slow Motion.

## [3.2.0](https://github.com/zhangao0086/DKImagePickerController/tree/3.2.0) (2016-05-02)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.1.3...3.2.0)

**Merged pull requests:**

- Supports accessing sourceType in Objective-C.

- Added auto download for AVAsset if locally unavailable.

- Making checkCameraPermission public in DKImagePickerControllerDefault.

- Added support for custom cancel button and done button.

- Fixed dismiss of camera.

- Added alertview on maxlimit reach.

- Added supports for custom UICollectionViewLayout.

## [3.1.3](https://github.com/zhangao0086/DKImagePickerController/tree/3.1.3) (2016-04-01)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.1.2...3.1.3)

**Merged pull requests:**

- Added support for custom camera based UINavigationController.

- Added video support for custom camera.

## [3.1.2](https://github.com/zhangao0086/DKImagePickerController/tree/3.1.2) (2016-04-01)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.1.1...3.1.2)

**Merged pull requests:**

- Fixed an issue that will cause the didSelectAssets block is called twice.

- Added support for custom predicate to assets.

- Optimized for fetching original image.

- The fetchImageWithSize fetching image with .AspectFit.

- Fixed an issue that may cause the popover not display as rounded.

## [3.1.1](https://github.com/zhangao0086/DKImagePickerController/tree/3.1.1) (2016-03-18)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.0.10...3.1.1)

**Merged pull requests:**

- Fixed an issue that may cause crash when user not authorized camera access.

## [3.1.0](https://github.com/zhangao0086/DKImagePickerController/tree/3.1.0) (2016-03-17)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.0.11...3.1.0)

**Merged pull requests:**

- Added support for custom camera.

- Added support for UIDelegate.

- Added a function to sync fetch an AVAsset.

- Fixed an issue that may cause crashing when downloading image from iCloud.

## [3.0.11](https://github.com/zhangao0086/DKImagePickerController/tree/3.0.11) (2016-02-27)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.0.10...3.0.11)

**Merged pull requests:**

- Added a PHVideoRequestOptions API to fetch AVAsset.

**Closed issues:**

- Synchronous options for multiple video fetch [\#76](https://github.com/zhangao0086/DKImagePickerController/pull/76)

## [3.0.10](https://github.com/zhangao0086/DKImagePickerController/tree/3.0.10) (2016-02-04)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.0.9...3.0.10)

**Merged pull requests:**

- Added possibility to deselect all selected assets when showing a single instance picker.

**Closed issues:**

- Possibility to deselect assets when displaying picker for second time. [\#69](https://github.com/zhangao0086/DKImagePickerController/pull/69)

## [3.0.9](https://github.com/zhangao0086/DKImagePickerController/tree/3.0.9) (2016-01-29)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.0.8...3.0.9)

**Merged pull requests:**

- Fixed an issue that cause showsCancelButton flag is ignored.

**Closed issues:**

- showsCancelButton has no effect if set before presenting the view controller [\#66](https://github.com/zhangao0086/DKImagePickerController/issues/66)

## [3.0.8](https://github.com/zhangao0086/DKImagePickerController/tree/3.0.8) (2016-01-21)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.0.7...3.0.8)

**Merged pull requests:**

- Fixed an issue that cause crash when a user taps on front facing camera to focus.

## [3.0.7](https://github.com/zhangao0086/DKImagePickerController/tree/3.0.7) (2016-01-21)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.0.6...3.0.7)

**Merged pull requests:**

- Updated DKCamera.

## [3.0.6](https://github.com/zhangao0086/DKImagePickerController/tree/3.0.6) (2016-01-20)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.0.5...3.0.6)

**Merged pull requests:**

- Added a function to sync fetch the full-screen image and the original image.

## [3.0.5](https://github.com/zhangao0086/DKImagePickerController/tree/3.0.5) (2016-01-17)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.0.4...3.0.5)

**Merged pull requests:**

- Added support for iPad.

- Added support for landscape.

- Updated fetching targetSize for full-screen image.

- Make DKAssetGroup public.

## [3.0.4](https://github.com/zhangao0086/DKImagePickerController/tree/3.0.4) (2015-12-28)

[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.0.3...3.0.4)

**Closed issues:**

- Cannot use DKAsset.fetchImageWithSize with iCloud photos \(Perhaps?\) [\#58](https://github.com/zhangao0086/DKImagePickerController/issues/58)

**Merged pull requests:**

- Improved performance when getting list of images.

- Added support for iCloud.

- Improved support for iCloud and updated `fetchImage...` interface that added handling for `info`.

## [3.0.3](https://github.com/zhangao0086/DKImagePickerController/tree/3.0.3) (2015-12-25)
[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.0.2...3.0.3)

**Merged pull requests:**

- Fixed an issue that may cause full screen image is incorrect.

## [3.0.2](https://github.com/zhangao0086/DKImagePickerController/tree/3.0.2) (2015-12-24)
[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.0.1...3.0.2)

**Merged pull requests:**

- Updated the defaultImageRequestOptions.

## [3.0.1](https://github.com/zhangao0086/DKImagePickerController/tree/3.0.1) (2015-12-22)
[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/3.0.0...3.0.1)

**Merged pull requests:**

- Added default request option.

**Implemented enhancements:**

- CompleteBlock executes twice [\#54](https://github.com/zhangao0086/DKImagePickerController/issues/54)

## [3.0.0](https://github.com/zhangao0086/DKImagePickerController/tree/3.0.0) (2015-12-18)
[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/2.4.3...3.0.0)

**Closed issues:**

- Update AssetsLibrary to Photos framework, deprecated [\#47](https://github.com/zhangao0086/DKImagePickerController/issues/47)
- Crash when trying to force unwrap fullResolution image when there is only nil [\#37](https://github.com/zhangao0086/DKImagePickerController/issues/37)
- Please Allow Camera Access shows in camera view even if accepted allowing access. [\#31](https://github.com/zhangao0086/DKImagePickerController/issues/31)
- Hide album "My photo stream" [\#25](https://github.com/zhangao0086/DKImagePickerController/issues/25)

**Merged pull requests:**

- Added `defaultAssetGroup`.
- Added `assetGroupTypes`.
- Added `showsEmptyAlbums`.
- Update to **Photos framework**.
- Removed AssetsLibrary framework.
- Added `DKImageManager` to separate data access from business logic.
- Added `DKGroupDataManager` and `DKBaseManager`.
- Added empty album image.

## [2.4.3](https://github.com/zhangao0086/DKImagePickerController/tree/2.4.3) (2015-12-11)
[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/2.4.2...2.4.3)

**Closed issues:**

- DKImagePickerControllerAssetType not visible in Objective-C [\#49](https://github.com/zhangao0086/DKImagePickerController/issues/49)

## [2.4.2](https://github.com/zhangao0086/DKImagePickerController/tree/2.4.2) (2015-12-10)
[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/2.4.1...2.4.2)

**Closed issues:**

- Change Default Folder [\#50](https://github.com/zhangao0086/DKImagePickerController/issues/50)
- Getting the right orientation of asset [\#48](https://github.com/zhangao0086/DKImagePickerController/issues/48)
- Suggestion, Add "Cancel" button on picker [\#44](https://github.com/zhangao0086/DKImagePickerController/issues/44)
- Problem when show more than one time the picker [\#40](https://github.com/zhangao0086/DKImagePickerController/issues/40)

**Merged pull requests:**

- Update README [\#46](https://github.com/zhangao0086/DKImagePickerController/pull/46) ([zhangao0086](https://github.com/zhangao0086))
- 	A user can show the "cancel" button via an optional property. [\#45](https://github.com/zhangao0086/DKImagePickerController/pull/45) ([zhangao0086](https://github.com/zhangao0086))

## [2.4.1](https://github.com/zhangao0086/DKImagePickerController/tree/2.4.1) (2015-11-19)
[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/2.4.0...2.4.1)

**Merged pull requests:**

- Bumping version to 2.4.0 [\#43](https://github.com/zhangao0086/DKImagePickerController/pull/43) ([zhangao0086](https://github.com/zhangao0086))

## [2.4.0](https://github.com/zhangao0086/DKImagePickerController/tree/2.4.0) (2015-11-16)
[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/2.3.7...2.4.0)

**Closed issues:**

- Allow selection of no photos, like Facebook application does [\#38](https://github.com/zhangao0086/DKImagePickerController/issues/38)
- Get images ordered by date [\#18](https://github.com/zhangao0086/DKImagePickerController/issues/18)

**Merged pull requests:**

- Develop [\#42](https://github.com/zhangao0086/DKImagePickerController/pull/42) ([zhangao0086](https://github.com/zhangao0086))
- Improving UI if authorization status changed.
- Fixes an issue that cause the thumbnail of the asset is blurred.
- Allow Selection of No Photos [\#41](https://github.com/zhangao0086/DKImagePickerController/pull/41) ([AnthonyMDev](https://github.com/AnthonyMDev))
- Adding a convenient way to get the create date of selected asset. [\#39](https://github.com/zhangao0086/DKImagePickerController/pull/39) ([zhangao0086](https://github.com/zhangao0086))

## [2.3.7](https://github.com/zhangao0086/DKImagePickerController/tree/2.3.7) (2015-11-08)
[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/2.3.6...2.3.7)

**Closed issues:**

- didRotateFromInterfaceOrientation was deprecated in iOS 8.0 [\#27](https://github.com/zhangao0086/DKImagePickerController/issues/27)

**Merged pull requests:**

- temporarily suppressed the deprecated warning [\#36](https://github.com/zhangao0086/DKImagePickerController/pull/36) ([zhangao0086](https://github.com/zhangao0086))

## [2.3.6](https://github.com/zhangao0086/DKImagePickerController/tree/2.3.6) (2015-10-28)
[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/2.3.5...2.3.6)

**Closed issues:**

- Return nil a video with asset.url [\#34](https://github.com/zhangao0086/DKImagePickerController/issues/34)

**Merged pull requests:**

- add a method to get the raw data of the selected asset. [\#35](https://github.com/zhangao0086/DKImagePickerController/pull/35) ([zhangao0086](https://github.com/zhangao0086))

## [2.3.5](https://github.com/zhangao0086/DKImagePickerController/tree/2.3.5) (2015-10-27)
[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/2.3.1...2.3.5)

**Closed issues:**

- Deselecting photos does not update the numbering. [\#32](https://github.com/zhangao0086/DKImagePickerController/issues/32)

**Merged pull requests:**

- Fixed an issue that not update the numbering when deselecting photos. [\#33](https://github.com/zhangao0086/DKImagePickerController/pull/33) ([zhangao0086](https://github.com/zhangao0086))

## [2.3.1](https://github.com/zhangao0086/DKImagePickerController/tree/2.3.1) (2015-10-25)
[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/2.3.0...2.3.1)

**Merged pull requests:**

- Develop [\#30](https://github.com/zhangao0086/DKImagePickerController/pull/30) ([zhangao0086](https://github.com/zhangao0086))
- Customize the navigation bar
- Fixed a bug that may cause
- Performance improvement

## [2.3.0](https://github.com/zhangao0086/DKImagePickerController/tree/2.3.0) (2015-10-18)
[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/2.2.0...2.3.0)

**Fixed bugs:**

- It crashed [\#28](https://github.com/zhangao0086/DKImagePickerController/issues/28)
- Crash when get the `fullScreenImage` in Xcode 6.4 [\#14](https://github.com/zhangao0086/DKImagePickerController/issues/14)

**Closed issues:**

- Original Picture [\#26](https://github.com/zhangao0086/DKImagePickerController/issues/26)
- Unable to save the selected assets array [\#16](https://github.com/zhangao0086/DKImagePickerController/issues/16)

**Merged pull requests:**

- Added ability to customize asset group types for enumeration [\#23](https://github.com/zhangao0086/DKImagePickerController/pull/23) ([scottdelly](https://github.com/scottdelly))
- Added ability to auto close the image picker after selecting a single image [\#22](https://github.com/zhangao0086/DKImagePickerController/pull/22) ([scottdelly](https://github.com/scottdelly))
- Some minor english language corrections and swift optional block optimizations [\#21](https://github.com/zhangao0086/DKImagePickerController/pull/21) ([scottdelly](https://github.com/scottdelly))
- Swift2.0 [\#17](https://github.com/zhangao0086/DKImagePickerController/pull/17) ([zhangao0086](https://github.com/zhangao0086))

## [2.2.0](https://github.com/zhangao0086/DKImagePickerController/tree/2.2.0) (2015-09-17)
[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/2.1.0...2.2.0)

**Closed issues:**

- Swift 2.0 compatibility [\#15](https://github.com/zhangao0086/DKImagePickerController/issues/15)

**Merged pull requests:**

- Updated demo [\#13](https://github.com/zhangao0086/DKImagePickerController/pull/13) ([zhangao0086](https://github.com/zhangao0086))

## [2.1.0](https://github.com/zhangao0086/DKImagePickerController/tree/2.1.0) (2015-09-04)
[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/2.0.0...2.1.0)

**Closed issues:**

- Can I use this from Objective-C? [\#11](https://github.com/zhangao0086/DKImagePickerController/issues/11)
- Changing Album After Selecting Images [\#10](https://github.com/zhangao0086/DKImagePickerController/issues/10)

**Merged pull requests:**

- Develop [\#12](https://github.com/zhangao0086/DKImagePickerController/pull/12) ([zhangao0086](https://github.com/zhangao0086))
- Added supports for 7.1
- Added hidesCamera
- Quickly take a picture

## [2.0.0](https://github.com/zhangao0086/DKImagePickerController/tree/2.0.0) (2015-08-27)
[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/1.1.0...2.0.0)

**Closed issues:**

- Select multi image! [\#7](https://github.com/zhangao0086/DKImagePickerController/issues/7)
- Video Thumbnails [\#6](https://github.com/zhangao0086/DKImagePickerController/issues/6)
- crash in iphone 6 [\#5](https://github.com/zhangao0086/DKImagePickerController/issues/5)

**Merged pull requests:**

- Develop [\#8](https://github.com/zhangao0086/DKImagePickerController/pull/8) ([zhangao0086](https://github.com/zhangao0086))
- Added selected and unselected style
- Added resource file
- Updated localized strings
- Added permission warning for Photo
- Optimize the selectAssetGroup function
- Added detected for video
- Added style for video
- Improve animation
- Updated access permission
- Added control for picking type
- Added function whether allows to select photos and videos at the same time.
- Updated podspec
- Added .travis.yml
- Optimize codes

## [1.1.0](https://github.com/zhangao0086/DKImagePickerController/tree/1.1.0) (2015-07-28)
[Full Changelog](https://github.com/zhangao0086/DKImagePickerController/compare/1.0.4...1.1.0)

**Closed issues:**

- how to set only 20 limit selected Image  [\#4](https://github.com/zhangao0086/DKImagePickerController/issues/4)

