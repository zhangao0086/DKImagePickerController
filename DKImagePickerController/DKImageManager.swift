//
//  DKImageManager.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 15/11/29.
//  Copyright © 2015年 ZhangAo. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

private extension DKImagePickerControllerAssetType {
	
	func toALAssetsFilter() -> ALAssetsFilter {
		switch self {
		case .allPhotos:
			return ALAssetsFilter.allPhotos()
		case .allVideos:
			return ALAssetsFilter.allVideos()
		case .allAssets:
			return ALAssetsFilter.allAssets()
		}
	}
}

// Group Model
internal class DKAssetGroup : NSObject {
	var groupName: String!
	var thumbnail: UIImage!
	var totalCount: Int!
	
	private var originalCollection: PHAssetCollection!
	private var fetchResult: PHFetchResult!
}

// Asset Model

private extension DKAsset {
	
}

internal class DKImageManager: NSObject {
	
	static let sharedInstance = DKImageManager()
	
	private var groups: [DKAssetGroup]?
	private var latestFetchGroupsError: NSError?
	
	private let manager = PHCachingImageManager.defaultManager()
	
	func fetchGroups(
		assetGroupTypes: UInt32,
		assetType: DKImagePickerControllerAssetType,
		groupsBlock: (groups: [DKAssetGroup]?, error: NSError?) -> Void) {
			
			if self.groups?.count > 0 {
				groupsBlock(groups: self.groups, error: nil)
				return
			}
			
			let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
			var groups: [DKAssetGroup] = []
			topLevelUserCollections.enumerateObjectsUsingBlock { (result, index, stop) in
				if let collection = result as? PHAssetCollection {
					let assetGroup = DKAssetGroup()
					assetGroup.groupName = collection.localizedTitle
					assetGroup.totalCount = collection.estimatedAssetCount
					
					if let latestAsset = PHAsset.fetchKeyAssetsInAssetCollection(collection, options: nil)?.firstObject as? PHAsset {
						self.manager.requestImageForAsset(latestAsset,
							targetSize: CGSize(width: 70, height: 70),
							contentMode: .AspectFill,
							options: nil,
							resultHandler: { image, info in
								assetGroup.thumbnail = image
						})
					}
					assetGroup.originalCollection = collection
					groups.append(assetGroup)
				}
				self.groups = groups
				groupsBlock(groups: groups, error: nil)
			}
	}
	
	func fetchAssetWithGroup(group: DKAssetGroup, index: Int) -> DKAsset {
		
		if group.fetchResult == nil {
			group.fetchResult = PHAsset.fetchAssetsInAssetCollection(group.originalCollection, options: nil)
		}
		
		let asset: DKAsset(originalAsset:group.fetchResult[index] as! PHAsset)
		
		return asset
	}
	
	func configCell(cell: DKAssetGroupDetailVC.DKAssetCell, asset: DKAsset) {
		self.manager.requestImageForAsset(originalAsset,
			targetSize: CGSize(width: 160 * 3, height: 160 * 3),
			contentMode: .AspectFill,
			options: nil,
			resultHandler: { image, info in
				asset = DKAsset(image: image!)
		})
	}
}
