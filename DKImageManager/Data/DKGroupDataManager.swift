//
//  DKGroupDataManager.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 15/12/16.
//  Copyright © 2015年 ZhangAo. All rights reserved.
//

import Photos

@objc
protocol DKGroupDataManagerObserver {
	
	optional func groupDidUpdate(groupId: String)
	optional func groupDidRemove(groupId: String)
	optional func group(groupId: String, didRemoveAssets assets: [DKAsset])
	optional func group(groupId: String, didInsertAssets assets: [DKAsset])
}

public class DKGroupDataManager: DKBaseManager, PHPhotoLibraryChangeObserver {

	private var groups: [String : DKAssetGroup]?
	public var groupIds: [String]?
	
	public var assetGroupTypes: [PHAssetCollectionSubtype]?
	public var assetFetchOptions: PHFetchOptions?
	public var showsEmptyAlbums: Bool = true
	
	deinit {
		PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
	}
	
	public func invalidate() {
		self.groupIds?.removeAll()
		self.groupIds = nil
		self.groups?.removeAll()
		self.groups = nil
		
		PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
	}
	
	public func fetchGroups(completeBlock: (groups: [String]?, error: NSError?) -> Void) {
		if let assetGroupTypes = self.assetGroupTypes {
			if self.groups != nil {
				completeBlock(groups: self.groupIds, error: nil)
				return
			}
			
			var groups: [String : DKAssetGroup] = [:]
			var groupIds: [String] = []
			
			for (_, groupType) in assetGroupTypes.enumerate() {
				let fetchResult = PHAssetCollection.fetchAssetCollectionsWithType(self.collectionTypeForSubtype(groupType),
				                                                                  subtype: groupType,
				                                                                  options: nil)
				fetchResult.enumerateObjectsUsingBlock { object, index, stop in
					if let collection = object as? PHAssetCollection {
						let assetGroup = DKAssetGroup()
						assetGroup.groupId = collection.localIdentifier
						self.updateGroup(assetGroup, collection: collection)
						if self.showsEmptyAlbums || assetGroup.totalCount > 0 {
							groups[assetGroup.groupId] = assetGroup
							groupIds.append(assetGroup.groupId)
						}
					}
				}
			}
			self.groups = groups
			self.groupIds = groupIds
			
			PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
			completeBlock(groups: groupIds, error: nil)
		}
	}
	
	public func fetchGroupWithGroupId(groupId: String) -> DKAssetGroup {
		return self.groups![groupId]!
	}
	
	public func fetchGroupThumbnailForGroup(groupId: String, size: CGSize, options: PHImageRequestOptions, completeBlock: (image: UIImage?, info: [NSObject : AnyObject]?) -> Void) {
		let group = self.fetchGroupWithGroupId(groupId)
		if group.fetchResult.count == 0 {
			completeBlock(image: nil, info: nil)
			return
		}
		
		let latestAsset = DKAsset(originalAsset:group.fetchResult.firstObject as! PHAsset)
		latestAsset.fetchImageWithSize(size, options: options, completeBlock: completeBlock)
	}
	
	public func fetchAssetWithGroup(group: DKAssetGroup, index: Int) -> DKAsset {
		let asset = DKAsset(originalAsset:group.fetchResult[index] as! PHAsset)
		return asset
	}
	
	// MARK: - Private methods
	
	private func collectionTypeForSubtype(subtype: PHAssetCollectionSubtype) -> PHAssetCollectionType {
		return subtype.rawValue < PHAssetCollectionSubtype.SmartAlbumGeneric.rawValue ? .Album : .SmartAlbum
	}
	
	private func updateGroup(group: DKAssetGroup, collection: PHAssetCollection) {
		group.groupName = collection.localizedTitle
		self.updateGroup(group, fetchResult: PHAsset.fetchAssetsInAssetCollection(collection, options: self.assetFetchOptions))
		group.originalCollection = collection
	}
	
	private func updateGroup(group: DKAssetGroup, fetchResult: PHFetchResult) {
		group.fetchResult = fetchResult
		group.totalCount = group.fetchResult.count
	}
	
	// MARK: - PHPhotoLibraryChangeObserver methods
	
	public func photoLibraryDidChange(changeInstance: PHChange) {
		for group in self.groups!.values {
			if let changeDetails = changeInstance.changeDetailsForObject(group.originalCollection) {
				if changeDetails.objectWasDeleted {
					self.groups![group.groupId] = nil
					self.notifyObserversWithSelector(#selector(DKGroupDataManagerObserver.groupDidRemove(_:)), object: group.groupId)
					continue
				}
				
				if let objectAfterChanges = changeDetails.objectAfterChanges as? PHAssetCollection {
					self.updateGroup(self.groups![group.groupId]!, collection: objectAfterChanges)
					self.notifyObserversWithSelector(#selector(DKGroupDataManagerObserver.groupDidUpdate(_:)), object: group.groupId)
				}
			}
			
			if let changeDetails = changeInstance.changeDetailsForFetchResult(group.fetchResult) {
				if let removedIndexes = changeDetails.removedIndexes {
					var removedAssets = [DKAsset]()
					removedIndexes.enumerateIndexesUsingBlock({ index, stop in
						removedAssets.append(self.fetchAssetWithGroup(group, index: index))
					})
					self.notifyObserversWithSelector(#selector(DKGroupDataManagerObserver.group(_:didRemoveAssets:)), object: group.groupId, objectTwo: removedAssets)
				}
				self.updateGroup(group, fetchResult: changeDetails.fetchResultAfterChanges)
				
				if changeDetails.insertedObjects.count > 0  {
					var insertedAssets = [DKAsset]()
					for insertedAsset in changeDetails.insertedObjects {
						insertedAssets.append(DKAsset(originalAsset: insertedAsset as! PHAsset))
					}
					self.notifyObserversWithSelector(#selector(DKGroupDataManagerObserver.group(_:didInsertAssets:)), object: group.groupId, objectTwo: insertedAssets)
				}
			}
		}
	}

}
