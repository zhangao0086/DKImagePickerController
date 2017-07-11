//
//  DKImagePickerViewController.h
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/6/26.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@class DKAsset;
@class DKImagePickerController;
@class DKAssetGroupDetailBaseCell;
@class DKImagePickerControllerDefaultUIDelegate;

@protocol DKImagePickerControllerCameraProtocol <NSObject>

- (void)setDidCancel:(void(^)())block;
- (void)setDidFinishCapturingImage:(void(^)(UIImage * image))block;
- (void)setDidFinishCapturingVideo:(void(^)(NSURL * videoURL))videoURL;

@end



@protocol DKImagePickerControllerUIDelegate <NSObject>



- (void)prepareLayout:(DKImagePickerController *)imagePickerController
                   vc:(UIViewController *)vc;


@optional

- (UICollectionViewLayout *)layoutForImagePickerController:(DKImagePickerController *)imagePickerController;

- (void)imagePickerController:(DKImagePickerController *)imagePickerController
       showsCancelButtonForVC:(UIViewController *)vc;

- (void)imagePickerController:(DKImagePickerController *)imagePickerController
       hidesCancelButtonForVC:(UIViewController *)vc;

- (void)imagePickerController:(DKImagePickerController *)imagePickerController
              didSelectAssets:(NSArray <DKAsset *> *)didSelectAssets;
- (void)imagePickerController:(DKImagePickerController *)imagePickerController
              didDeselectAssets:(NSArray <DKAsset *> *)didDeselectAssets;
- (void)imagePickerControllerDidReachMaxLimit:(DKImagePickerController *)imagePickerController;
- (UIView *)imagePickerControllerFooterView:(DKImagePickerController *)imagePickerController;

- (UIColor *)imagePickerControllerCollectionViewBackgroundColor;
- (Class)imagePickerControllerCollectionImageCell;
- (Class)imagePickerControllerCollectionCameraCell;
- (Class)imagePickerControllerCollectionVideoCell;


- (UIViewController <DKImagePickerControllerCameraProtocol> *)imagePickerControllerCreateCamera:(DKImagePickerController *)imagePickerController;
- (UIViewController <DKImagePickerControllerCameraProtocol> *)imagePickerControllerCreateCamera:(DKImagePickerController *)imagePickerController
                                              didCancel:(void(^)())didCancel
                                didFinishCapturingImage:(void(^)(UIImage * image))didFinishCapturingImage
                                didFinishCapturingVideo:(void(^)(NSURL * videoURL))didFinishCapturingVideo;

@end

typedef enum : NSUInteger {
    DKImagePickerControllerAssetAllPhotosType,
    DKImagePickerControllerAssetAllVideosType,
    DKImagePickerControllerAssetAllAssetsType,
} DKImagePickerControllerAssetType;


typedef enum : NSUInteger {
    DKImagePickerControllerSourceCameraType,
    DKImagePickerControllerSourcePhotoType,
    DKImagePickerControllerSourceBothType,
} DKImagePickerControllerSourceType;

@interface DKImagePickerController : UINavigationController
@property (nonatomic, strong) DKImagePickerControllerDefaultUIDelegate *UIDelegate;
@property (nonatomic, assign) DKImagePickerControllerSourceType sourceType;
@property (nonatomic, copy) NSArray  <DKAsset *> * defaultSelectedAssets;
@property (nonatomic, strong) NSMutableArray <DKAsset *> *selectedAssets;
@property (nonatomic, copy) void(^didCancel)();
@property (nonatomic, copy) void(^didSelectAssets)(NSArray<DKAsset *> * asset);
@property (nonatomic, assign) BOOL singleSelect;
@property (nonatomic, assign) NSInteger maxSelectableCount;
@property (nonatomic, assign) PHAssetCollectionSubtype defaultAssetGroup;
/**
 The types of PHAssetCollection to display in the picker.
 Default value is @[@(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                    @(PHAssetCollectionSubtypeSmartAlbumFavorites),
                    @(PHAssetCollectionSubtypeAlbumRegular)]
 */
@property (nonatomic, copy)NSArray <NSNumber *> * assetGroupTypes;


/**
 Set the showsEmptyAlbums to specify whether or not the empty albums is shown in the picker
 Default value is YES
 */
@property (nonatomic, assign) BOOL showsEmptyAlbums;


@property (nonatomic, copy) BOOL (^assetFilter) (PHAsset * asset);

/**
 The type of picker interface to be displayed by the controller.
 Default value is DKImagePickerControllerAssetAllAssetsType
 */
@property (nonatomic, assign) DKImagePickerControllerAssetType assetType;

/**
 The predicate applies to images only
 */
@property (nonatomic, strong) NSPredicate * imageFetchPredicate;


/**
 The predicate applies to videos only.
 */
@property (nonatomic, strong) NSPredicate * videoFetchPredicate;

/**
 Whether allows to select photos and videos at the same time.
 Default value is NO
 */
@property (nonatomic, assign) BOOL allowMultipleTypes;

/**
 If YES, and the requested image is not stored on the local device, the Picker downloads the image from iCloud.
 Default value is YES
 */
@property (nonatomic, assign) BOOL autoDownloadWhenAssetIsInCloud;

/**
 Determines whether or not the rotation is enabled.
 Default value is NO;
 */
@property (nonatomic, assign) BOOL allowsLandscape;


@property (nonatomic, assign) BOOL showsCancelButton;
- (void)selectImage:(DKAsset *)asset;
- (void)done;
- (void)presentCamera;

- (void)deselectImage:(DKAsset *)asset;
- (void)dismiss;
@end
