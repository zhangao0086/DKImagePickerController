//
//  DKImageManager.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 15/11/29.
//  Copyright © 2015年 ZhangAo. All rights reserved.
//

import AssetsLibrary
import Photos

public class DKImageManager: NSObject {
	
	static let sharedInstance = DKImageManager()
	
	private var groups: [DKAssetGroup]?
	private var latestFetchGroupsError: NSError?
	
	private let manager = PHCachingImageManager.defaultManager()
	
	public func fetchGroups(
		assetGroupTypes: [PHAssetCollectionSubtype],
		assetType: DKImagePickerControllerAssetType,
		completeBlock: (groups: [DKAssetGroup]?, error: NSError?) -> Void) {
			
			if self.groups?.count > 0 {
				completeBlock(groups: self.groups, error: nil)
				return
			}
			
			var groups: [DKAssetGroup] = []
			
			let fetchOptions = PHFetchOptions();
//			fetchOptions.predicate = NSPredicate(format:"mediaType == %d", PHAssetMediaType.Image.rawValue);
//			let fetchResult = PHAsset.fetchAssetsWithOptions(fetchOptions)
//			fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

			for (_, groupType) in assetGroupTypes.enumerate() {
				let fetchResult = PHAssetCollection.fetchAssetCollectionsWithType(self.collectionTypeForSubtype(groupType),
					subtype: groupType,
					options: fetchOptions)
				fetchResult.enumerateObjectsUsingBlock { (object, index, stop) -> Void in
					if let collection = object as? PHAssetCollection {
						let assetGroup = DKAssetGroup()
						assetGroup.groupName = collection.localizedTitle
						assetGroup.totalCount = PHAsset.fetchAssetsInAssetCollection(collection, options: nil).count
						assetGroup.originalCollection = collection
						groups.append(assetGroup)
					}
				}
			}
			self.groups = groups
			completeBlock(groups: groups, error: nil)
	}
	
	private func collectionTypeForSubtype(subtype: PHAssetCollectionSubtype) -> PHAssetCollectionType {
		return subtype.rawValue < PHAssetCollectionSubtype.SmartAlbumGeneric.rawValue ? .Album : .SmartAlbum
	}
	
	public func fetchAssetWithGroup(group: DKAssetGroup, index: Int) -> DKAsset {
		let asset = DKAsset(originalAsset:group.fetchResult[index] as! PHAsset)
		return asset
	}
	
	public func fetchGroupThumbnailForGroup(group: DKAssetGroup, size: CGSize, completeBlock: (image: UIImage?) -> Void) {
		if group.fetchResult.count == 0 {
			completeBlock(image: nil)
			return
		}
		let latestAsset = self.fetchAssetWithGroup(group, index: group.fetchResult.count - 1)
		self.fetchImageForAsset(latestAsset, size: size, completeBlock: completeBlock)
	}
	
	public func fetchImageForAsset(asset: DKAsset, size: CGSize, completeBlock: (image: UIImage?) -> Void) {
		self.manager.requestImageForAsset(asset.originalAsset!,
			targetSize: size,
			contentMode: .AspectFill,
			options: nil,
			resultHandler: { image, info in
				completeBlock(image: image)
		})
	}
	
	public func fetchAVAsset(asset: DKAsset, completeBlock: (avAsset: AVURLAsset?) -> Void) {
		self.manager.requestAVAssetForVideo(asset.originalAsset!,
			options: nil) { (avAsset, audioMix, info) -> Void in
				completeBlock(avAsset: avAsset as? AVURLAsset)
		}
	}
	
}
