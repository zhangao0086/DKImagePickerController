//
//  DKGroupDataManager.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 15/12/16.
//  Copyright © 2015年 ZhangAo. All rights reserved.
//

import Photos

//			fetchOptions.predicate = NSPredicate(format:"mediaType == %d", PHAssetMediaType.Image.rawValue);
//			let fetchResult = PHAsset.fetchAssetsWithOptions(fetchOptions)
//			fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

protocol DKGroupDataManagerObserver {
	
	func groupDidUpdate(groupId: String)
	func groupDidRemove(groupId: String)
}

public class DKGroupDataManager: DKBaseManager, PHPhotoLibraryChangeObserver {

	private var groups: [String : DKAssetGroup]?
	public var groupIds: [String]?
	
	public var fetchGroupsOptions : PHFetchOptions?
	public var assetGroupTypes: [PHAssetCollectionSubtype]?
	
	override init() {
		super.init()
		
		PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
	}
	
	deinit {
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
			
			let fetchOptions = PHFetchOptions()
			
			for (_, groupType) in assetGroupTypes.enumerate() {
				let fetchResult = PHAssetCollection.fetchAssetCollectionsWithType(self.collectionTypeForSubtype(groupType),
					subtype: groupType,
					options: fetchOptions)
				fetchResult.enumerateObjectsUsingBlock { (object, index, stop) -> Void in
					if let collection = object as? PHAssetCollection {
						let assetGroup = DKAssetGroup()
						assetGroup.groupId = collection.localIdentifier
						assetGroup.originalCollection = collection
						groups[assetGroup.groupId] = assetGroup
						groupIds.append(assetGroup.groupId)
					}
				}
			}
			self.groups = groups
			self.groupIds = groupIds
			completeBlock(groups: groupIds, error: nil)
		}
	}
	
	public func fetchGroupWithGroupId(groupId: String) -> DKAssetGroup {
		return self.groups![groupId]!
	}
	
	// MARK: - Private methods
	
	private func collectionTypeForSubtype(subtype: PHAssetCollectionSubtype) -> PHAssetCollectionType {
		return subtype.rawValue < PHAssetCollectionSubtype.SmartAlbumGeneric.rawValue ? .Album : .SmartAlbum
	}
	
	// MARK: - PHPhotoLibraryChangeObserver methods
	
	public func photoLibraryDidChange(changeInstance: PHChange) {
		for group in self.groups!.values {
			if let changeDetails = changeInstance.changeDetailsForObject(group.originalCollection) {
				if changeDetails.objectWasDeleted {
					self.groups![group.groupId] = nil
					self.notifyObserversWithSelector(Selector("groupDidRemove:"), object: group.groupId)
					continue
				}
				
				if let objectAfterChanges = changeDetails.objectAfterChanges as? PHAssetCollection {
					self.groups![group.groupId]?.originalCollection = objectAfterChanges
					self.notifyObserversWithSelector(Selector("groupDidUpdate:"), object: group.groupId)
				}
			}
		}
	}


}
