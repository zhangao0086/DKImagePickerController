//
//  DKGroupDataManager.m
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/23.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKGroupDataManager.h"
#import "DKAsset.h"
#import "DKAssetGroup.h"


@interface DKGroupDataManager()

@end

@implementation DKGroupDataManager
- (id)init{
    if (self= [super init]) {
        _showsEmptyAlbums = YES;
        _assets = @{}.mutableCopy;
    }
    return self;
}

- (void)dealloc{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)invalidate{
    [self.groupIds removeAllObjects];
    [self.groups removeAllObjects];
    [self.assets removeAllObjects];
    self.groups = nil;
    self.groupIds = nil;
    self.assets = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (DKAssetGroup *)fetchGroupWithGroupId:(NSString *)groupId{
    return _groups[groupId];
}


- (void)fetchGroupsWithCompleteBlock:(void(^)(NSArray <NSString *> * groupIds, NSError * error))completeBlock{
    if (self.assetGroupTypes) {
        
        __weak typeof(self) weakSelf = self;
       dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
       dispatch_async(queue, ^{
           __strong typeof(self) strongSelf = weakSelf;
           if (strongSelf.groups != nil) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   completeBlock(strongSelf.groupIds, nil);
               });
           }
           
           NSMutableDictionary <NSString *, DKAssetGroup *>* groups = @{}.mutableCopy;
           NSMutableArray <NSString *> * groupIds = @[].mutableCopy;
           [self.assetGroupTypes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               PHFetchResult<PHAssetCollection *> * fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:[self collectionTypeForSubtype:[obj integerValue]] subtype:[obj integerValue] options:nil];
               [fetchResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                   DKAssetGroup * assetGroup = [DKAssetGroup new];
                   assetGroup.groupId = obj.localIdentifier;
                   [strongSelf updateGroup:assetGroup collection:obj];
                   [strongSelf updateGroup:assetGroup fetchResult:[PHAsset fetchAssetsInAssetCollection:obj options:self.assetFetchOptions]];
                   if (strongSelf.showsEmptyAlbums || assetGroup.totalCount > 0) {
                       groups[assetGroup.groupId] = assetGroup;
                       [groupIds addObject:assetGroup.groupId];
                   }
                   
               }];
               
           }];
           
           [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:strongSelf];
           [strongSelf updatePartial:groups groupIds:groupIds completeBlock:completeBlock];
       });
        
    }
}

- (void)updatePartial:(NSMutableDictionary<NSString *, DKAssetGroup *>*)groups
             groupIds:(NSMutableArray <NSString *>*)groupIds
        completeBlock:(void(^)(NSArray <NSString *>* groupIds, NSError * error))completeBlock
{
    self.groups = groups;
    self.groupIds = groupIds;
    dispatch_async(dispatch_get_main_queue(), ^{
        completeBlock(groupIds, nil);
    });
}

- (void)updateGroup:(DKAssetGroup *)group
         collection:(PHAssetCollection *)collection{
    group.groupName = collection.localizedTitle;
    group.originalCollection = collection;
}

- (void)updateGroup:(DKAssetGroup *)group
        fetchResult:(PHFetchResult <PHAsset *>*)fetchResult{
    group.fetchResult = [self filterResults:fetchResult];
    group.totalCount = group.fetchResult.count;
}
- (PHFetchResult <PHAsset *>*)filterResults:(PHFetchResult <PHAsset *>*)fetchResult{
    if (!self.assetFilter) {
        return fetchResult;
    }
    
    NSMutableArray <PHAsset *>* filtered = @[].mutableCopy;
    for (int i = 0; i < fetchResult.count; i++) {
        if (self.assetFilter(fetchResult[i])) {
            [filtered addObject:fetchResult[i]];
        }
    }
    
   PHAssetCollection * collection = [PHAssetCollection transientAssetCollectionWithAssets:filtered title:nil];
    return [PHAsset fetchAssetsInAssetCollection:collection options:nil];
}


- (PHAssetCollectionType)collectionTypeForSubtype:(PHAssetCollectionSubtype)subtype{
    return  subtype < PHAssetCollectionSubtypeSmartAlbumGeneric ? PHAssetCollectionTypeAlbum : PHAssetCollectionTypeSmartAlbum;
}


- (void)fetchGroupThumbnailForGroup:(NSString *)groupId
                               size:(CGSize)size
                            options:(PHImageRequestOptions *)options
                      completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock{
    DKAssetGroup * group = [self fetchGroupWithGroupId:groupId];
    if (group.totalCount == 0) {
        completeBlock(nil, nil);
        return;
    }
    
    DKAsset * asset =  [[DKAsset alloc] initWithOriginalAsset:group.fetchResult.lastObject];
    [asset fetchImageWithSize:size options:options completeBlock:completeBlock];
}

- (DKAsset *)fetchAsset:(DKAssetGroup *)group
             index:(NSInteger)index{
    PHAsset * originalAsset = [self fetchOriginalAsset:group index:index];
    DKAsset * asset = self.assets[originalAsset.localIdentifier];
    if (asset == nil) {
        asset = [[DKAsset alloc] initWithOriginalAsset:originalAsset];
        self.assets[originalAsset.localIdentifier] = asset;
    }
    return asset;
}
- (PHAsset *)fetchOriginalAsset:(DKAssetGroup *)group
                          index:(NSInteger)index{
    
    return group.fetchResult[group.totalCount - index - 1];
}
#pragma mark -- PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    for (DKAssetGroup * group in self.groups.allValues) {
       
        if ([changeInstance changeDetailsForObject:group.originalCollection]) {
            PHObjectChangeDetails * changeDetails = [changeInstance changeDetailsForObject:group.originalCollection];
            if (changeDetails.objectWasDeleted) {
                [self.groups removeObjectForKey:group.groupId];
                [self notifyObserversWithSelector:@selector(groupDidRemove:) object:group.groupId];
                continue;
            }
            
            if ([changeDetails.objectAfterChanges isKindOfClass:[PHAssetCollection class]]) {
                PHAssetCollection * objectAfterChanges = changeDetails.objectAfterChanges;
                [self updateGroup:self.groups[group.groupId] collection:objectAfterChanges];
                [self notifyObserversWithSelector:@selector(groupDidUpdate:) object:group.groupId];
            }
        }
        
        if ([changeInstance changeDetailsForFetchResult:group.fetchResult]) {
            PHFetchResultChangeDetails * changeDetails = [changeInstance changeDetailsForFetchResult:group.fetchResult];
            NSMutableArray * removedAssets = @[].mutableCopy;
            [changeDetails.removedObjects enumerateObjectsUsingBlock:^(PHAsset *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [removedAssets addObject: [[DKAsset alloc] initWithOriginalAsset:obj]];
            }];
            
            if (removedAssets.count > 0) {
                [self notifyObserversWithSelector:@selector(group:didRemoveAssets:) object:group.groupId objectTwo:removedAssets];
            }
            
            [self updateGroup:group fetchResult:changeDetails.fetchResultAfterChanges];
            
 
            NSMutableArray * insertedAssets = @[].mutableCopy;
            
            [changeDetails.insertedObjects enumerateObjectsUsingBlock:^(PHAsset *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [insertedAssets addObject: [[DKAsset alloc] initWithOriginalAsset:obj]];
            }];
        
            if (insertedAssets.count > 0) {
                [self notifyObserversWithSelector:@selector(group:didInsertAssets:) object:group.groupId objectTwo:insertedAssets];
            }
            
            [self notifyObserversWithSelector:@selector(groupDidUpdateComplete:) object:group.groupId];
        }
    }
}
@end
