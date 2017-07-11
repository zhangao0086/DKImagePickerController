//
//  DKImageManager.h
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/23.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DKBaseManager.h"
#import <Photos/Photos.h>
@class DKAsset;
@class DKGroupDataManager;
@interface DKImageManager : DKBaseManager 

@property (nonatomic, strong) DKGroupDataManager * groupDataManager;

+ (instancetype)shareInstance;


- (void)fetchImageForAssetWith:(DKAsset *)asset
                          size:(CGSize)size
                 completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock;

- (void)fetchImageForAssetWith:(DKAsset *)asset
                          size:(CGSize)size
                   contentMode:(PHImageContentMode)contentMode
                 completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock;


- (void)fetchImageForAssetWith:(DKAsset *)asset
                          size:(CGSize)size
                       options:(PHImageRequestOptions *)options
                 completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock;


- (void)fetchImageForAssetWith:(DKAsset *)asset
                          size:(CGSize)size
                       options:(PHImageRequestOptions *)options
                   contentMode:(PHImageContentMode)contentMode
                 completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock;

- (void)fetchImageDataForAsset:(DKAsset *)asset
                       options:(PHImageRequestOptions *)options
                 completeBlock:(void(^)(NSData * imageData, NSDictionary * info))completeBlock;

- (void)fetchAVAsset:(DKAsset *)asset
       completeBlock:(void(^)(AVAsset * avAsset, NSDictionary * info))completeBlock;

- (void)fetchAVAsset:(DKAsset *)asset
             options:(PHVideoRequestOptions *)options
       completeBlock:(void(^)(AVAsset * avAsset, NSDictionary * info))completeBlock;
- (void)stopCachingForAllAssets;
+ (void)checkPhotoPermissionWithHandle:(void(^)(BOOL granted))handle;

@property (nonatomic, assign) BOOL autoDownloadWhenAssetIsInCloud;
+ (CGSize)toPixel:(CGSize)size;
- (void)invalidate;
@end
