//
//  DKGroupDataManager.h
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/6/23.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "DKBaseManager.h"
@class DKAssetGroup;
@class DKAsset;



@protocol DKGroupDataManagerObserver <NSObject>

@optional
- (void)groupDidUpdate:(NSString *)groupId;
- (void)groupDidRemove:(NSString *)groupId;
- (void)group:(NSString *)groupId didRemoveAssets:(NSArray <DKAsset *> *)assets;
- (void)group:(NSString *)groupId didInsertAssets:(NSArray <DKAsset *> *)assets;

- (void)groupDidUpdateComplete:(NSString *)groupId;

@end



@interface DKGroupDataManager : DKBaseManager<PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) NSMutableArray <NSString *>* groupIds;
@property (nonatomic, strong) NSMutableDictionary <NSString * , DKAssetGroup *>* groups;
@property (nonatomic, strong) NSMutableDictionary <NSString * , DKAsset *>* assets;

@property (nonatomic, copy) NSArray <NSNumber *> * assetGroupTypes;

@property (nonatomic, strong) PHFetchOptions * assetFetchOptions;
@property (nonatomic, assign) BOOL showsEmptyAlbums;

@property (nonatomic, copy) BOOL(^assetFilter)(PHAsset * asset);
- (DKAssetGroup *)fetchGroupWithGroupId:(NSString *)groupId;
- (void)fetchGroupsWithCompleteBlock:(void(^)(NSArray <NSString *> * groupIds, NSError * error))completeBlock;
- (void)fetchGroupThumbnailForGroup:(NSString *)groupId
                               size:(CGSize)size
                            options:(PHImageRequestOptions *)options
                      completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock;
- (DKAsset *)fetchAsset:(DKAssetGroup *)group
                  index:(NSInteger)index;
- (PHFetchResult <PHAsset *>*)filterResults:(PHFetchResult <PHAsset *>*)fetchResult;
- (void)invalidate;
@end
