//
//  DKImageManager.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 15/11/29.
//  Copyright © 2015年 ZhangAo. All rights reserved.
//

import UIKit
import AssetsLibrary

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
	
	private var originalGroup: ALAssetsGroup!
}

internal class DKImageManager: NSObject {
	
	static let sharedInstance = DKImageManager()
	
	private let fetchGroupsQueue: NSOperationQueue = {
		let queue = NSOperationQueue()
		queue.maxConcurrentOperationCount = 1
		
		return queue
	}()
	
	private var groups: [DKAssetGroup]?
	private var latestFetchGroupsError: NSError?
	
	private let library = ALAssetsLibrary()
	
	func fetchGroups(
		assetGroupTypes: UInt32,
		assetType: DKImagePickerControllerAssetType,
		groupsBlock: (groups: [DKAssetGroup]?, error: NSError?) -> Void) {
			if self.groups?.count > 0 {
				groupsBlock(groups: self.groups, error: nil)
				return
			}
			
			if self.fetchGroupsQueue.operationCount == 0 && self.groups == nil {
				self.fetchGroupsQueue.addOperationWithBlock {
					var groups: [DKAssetGroup] = []
					self.library.enumerateGroupsWithTypes(assetGroupTypes
						, usingBlock: { (group, stop) -> Void in
							
							if group != nil {
								group.setAssetsFilter(assetType.toALAssetsFilter())
								
								if group.numberOfAssets() != 0 {
									let groupName = group.valueForProperty(ALAssetsGroupPropertyName) as! String
									
									let assetGroup = DKAssetGroup()
									assetGroup.groupName = groupName
									
									group.enumerateAssetsAtIndexes(NSIndexSet(index: group.numberOfAssets() - 1),
										options: .Reverse,
										usingBlock: { (asset, index, stop) -> Void in
											if asset != nil {
												assetGroup.thumbnail = UIImage(CGImage:asset.thumbnail().takeUnretainedValue())
											}
									})
									
									assetGroup.originalGroup = group
									assetGroup.totalCount = group.numberOfAssets()
									groups.insert(assetGroup, atIndex: 0)
								}
							} else {
								self.groups = groups
								dispatch_async(dispatch_get_main_queue(), { () -> Void in
									groupsBlock(groups: groups, error: nil)
								})
							}
						}, failureBlock: { error in
							self.latestFetchGroupsError = error
							dispatch_async(dispatch_get_main_queue(), { () -> Void in
								groupsBlock(groups: nil, error: error)
							})
					})
				}
			} else {
				self.fetchGroupsQueue.addOperationWithBlock {
					groupsBlock(groups: self.groups, error: self.latestFetchGroupsError)
				}
			}
	}
	
	func fetchAssetWithGroup(group: DKAssetGroup, index: Int) -> DKAsset {
		var asset: DKAsset!
		group.originalGroup.enumerateAssetsAtIndexes(NSIndexSet(index: index), options: .Reverse,
			usingBlock: { (result, index, stop) -> Void in
				if result != nil {
					asset = DKAsset(originalAsset: result)
				}
		})
		
		return asset
	}
}
