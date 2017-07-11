//
//  DKImageManager.m
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/23.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKImageManager.h"
#import "DKGroupDataManager.h"
#import "DKAsset.h"

@interface DKImageManager()

@property (nonatomic, strong) PHCachingImageManager * manager;
@property (nonatomic, strong) PHImageRequestOptions * defaultImageRequestOptions;
@property (nonatomic, strong) PHVideoRequestOptions * defaultVideoRequestOptions;
@end


@implementation DKImageManager

- (id)init{
    self = [super init];
    if (self) {
        _manager = [[PHCachingImageManager alloc] init];
        _autoDownloadWhenAssetIsInCloud = YES;
    }
    return self;
}
- (DKGroupDataManager *)groupDataManager{
    if (!_groupDataManager) {
        _groupDataManager = [DKGroupDataManager new];
    }
    return  _groupDataManager;
}
- (PHImageRequestOptions *)defaultImageRequestOptions{
    if (_defaultImageRequestOptions == nil) {
        _defaultImageRequestOptions = [[PHImageRequestOptions alloc] init];
    }
    return _defaultImageRequestOptions;
}

- (PHVideoRequestOptions *)defaultVideoRequestOptions{
    if (_defaultVideoRequestOptions == nil) {
        _defaultVideoRequestOptions = [[PHVideoRequestOptions alloc] init];
        _defaultVideoRequestOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeMediumQualityFormat;
    }
    return _defaultVideoRequestOptions;
}


+ (instancetype)shareInstance{
    static DKImageManager * shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[DKImageManager alloc] init];
    });
    return  shareInstance;
}

+ (void)checkPhotoPermissionWithHandle:(void(^)(BOOL granted))handle{
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        handle(YES);
    }else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handle(status == PHAuthorizationStatusAuthorized);
            });
        }];
    }else{
        handle(NO);
    }
}


#pragma mark -- Fetch Image
- (void)fetchImageForAssetWith:(DKAsset *)asset
                          size:(CGSize)size
                 completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock

{
    
    [self fetchImageForAssetWith:asset size:size options:nil completeBlock:completeBlock];
}

- (void)fetchImageForAssetWith:(DKAsset *)asset
                          size:(CGSize)size
                   contentMode:(PHImageContentMode)contentMode
                 completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock{
    [self fetchImageForAssetWith:asset size:size options:nil contentMode:contentMode completeBlock:completeBlock];
}


- (void)fetchImageForAssetWith:(DKAsset *)asset
                          size:(CGSize)size
                       options:(PHImageRequestOptions *)options
                 completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock{
    [self fetchImageForAssetWith:asset size:size options:options contentMode:PHImageContentModeAspectFill completeBlock:completeBlock];
    
}



- (void)fetchImageForAssetWith:(DKAsset *)asset
                          size:(CGSize)size
                       options:(PHImageRequestOptions *)options
                   contentMode:(PHImageContentMode)contentMode
                 completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock

{
    if (!options) {
        options = self.defaultImageRequestOptions.copy;
    }
    [self.manager requestImageForAsset:asset.originalAsset targetSize:size contentMode:contentMode options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL isInCloud = [info[PHImageResultIsInCloudKey] boolValue];
        if (isInCloud && !result && self.autoDownloadWhenAssetIsInCloud) {
            options.networkAccessAllowed = YES;
            [self fetchImageForAssetWith:asset size:size options:options contentMode:contentMode completeBlock:completeBlock];
        }else{
            completeBlock(result, info);
        }
    }];
    
}

- (void)fetchImageDataForAsset:(DKAsset *)asset
                       options:(PHImageRequestOptions *)options
                 completeBlock:(void(^)(NSData * imageData, NSDictionary * info))completeBlock{
    if (!options) {
        options = self.defaultImageRequestOptions.copy;
    }

    [self.manager requestImageDataForAsset:asset.originalAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL isInCloud = [info[PHImageResultIsInCloudKey] boolValue];
        if (isInCloud && !imageData && self.autoDownloadWhenAssetIsInCloud) {
            options.networkAccessAllowed = YES;
            [self fetchImageDataForAsset:asset options:options completeBlock:completeBlock];
        }else{
            completeBlock(imageData, info);
        }
        
    }];
}


- (void)fetchAVAsset:(DKAsset *)asset
       completeBlock:(void(^)(AVAsset * avAsset, NSDictionary * info))completeBlock{
}


- (void)fetchAVAsset:(DKAsset *)asset
             options:(PHVideoRequestOptions *)options
completeBlock:(void(^)(AVAsset * avAsset, NSDictionary * info))completeBlock
{
    if (!options) {
        options = self.defaultVideoRequestOptions.copy;
    }
    [self.manager requestAVAssetForVideo:asset.originalAsset options:options resultHandler:^(AVAsset * _Nullable avAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        BOOL isInCloud = [info[PHImageResultIsInCloudKey] boolValue];
        if (isInCloud && !asset && self.autoDownloadWhenAssetIsInCloud) {
            options.networkAccessAllowed = YES;
            [self fetchAVAsset:asset options:options completeBlock:completeBlock];
        }else{
            completeBlock(avAsset, info);
        }
    }];
}
- (void)stopCachingForAllAssets{
    [self.manager stopCachingImagesForAllAssets];
}
+ (CGSize)toPixel:(CGSize)size{
    CGFloat scale = [[UIScreen mainScreen] scale];
    return CGSizeMake(size.width * scale, size.height * scale);
}
- (void)invalidate{
    [self.groupDataManager invalidate];
    self.groupDataManager = nil;
}
@end
