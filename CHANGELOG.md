# Change Log

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

