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
	
	@objc optional func groupDidUpdate(_ groupId: String)
	@objc optional func groupDidRemove(_ groupId: String)
	@objc optional func group(_ groupId: String, didRemoveAssets assets: [DKAsset])
	@objc optional func group(_ groupId: String, didInsertAssets assets: [DKAsset])
    @objc optional func groupDidUpdateComplete(_ groupId: String)
    @objc optional func groupsDidInsert(_ groupIds: [String])
}

public class DKGroupDataManager: DKBaseManager, PHPhotoLibraryChangeObserver {

    public var groupIds: [String]?
	private var groups: [String : DKAssetGroup]?
    private var assets = [String: DKAsset]()
	
	public var assetGroupTypes: [PHAssetCollectionSubtype]?
	public var assetFetchOptions: PHFetchOptions?
	public var showsEmptyAlbums: Bool = true

    public var assetFilter: ((_ asset: PHAsset) -> Bool)?
	
	deinit {
		PHPhotoLibrary.shared().unregisterChangeObserver(self)
	}
	
	public func invalidate() {
		self.groupIds?.removeAll()
        self.groups?.removeAll()
        self.assets.removeAll()
		
		PHPhotoLibrary.shared().unregisterChangeObserver(self)
	}

	public func fetchGroups(_ completeBlock: @escaping (_ groups: [String]?, _ error: NSError?) -> Void) {
		if let assetGroupTypes = self.assetGroupTypes {
			DispatchQueue.global(qos: .userInteractive).async {
				[weak self] in
				guard let strongSelf = self else {
					return
				}

				guard strongSelf.groups == nil else {
					DispatchQueue.main.async {
						completeBlock(strongSelf.groupIds, nil)
					}
					return
				}

				var groups: [String : DKAssetGroup] = [:]
				var groupIds: [String] = []

                strongSelf.fetchGroups(assetGroupTypes: assetGroupTypes, block: { (collection) in
                    let assetGroup = strongSelf.makeDKAssetGroup(with: collection)
                    if strongSelf.showsEmptyAlbums || assetGroup.totalCount > 0 {
                        groups[assetGroup.groupId] = assetGroup
                        groupIds.append(assetGroup.groupId)
                    }
                    if !groupIds.isEmpty {
                        strongSelf.updatePartial(groups: groups, groupIds: groupIds, completeBlock: completeBlock)
                    }
                })
				PHPhotoLibrary.shared().register(strongSelf)
                if !groupIds.isEmpty {
                    strongSelf.updatePartial(groups: groups, groupIds: groupIds, completeBlock: completeBlock)
                }
			}
		}
	}
	
	public func fetchGroupWithGroupId(_ groupId: String) -> DKAssetGroup {
		return self.groups![groupId]!
	}
	
	public func fetchGroupThumbnailForGroup(_ groupId: String, size: CGSize, options: PHImageRequestOptions, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
		let group = self.fetchGroupWithGroupId(groupId)
		if group.totalCount == 0 {
			completeBlock(nil, nil)
			return
		}
		
		let latestAsset = DKAsset(originalAsset:group.fetchResult.lastObject!)
		latestAsset.fetchImageWithSize(size, options: options, completeBlock: completeBlock)
	}
	
	public func fetchAsset(_ group: DKAssetGroup, index: Int) -> DKAsset {
        let originalAsset = self.fetchOriginalAsset(group, index: index)
        var asset = self.assets[originalAsset.localIdentifier]
        if asset == nil {
            asset = DKAsset(originalAsset:originalAsset)
            self.assets[originalAsset.localIdentifier] = asset
        }
		return asset!
	}
    
    public func fetchOriginalAsset(_ group: DKAssetGroup, index: Int) -> PHAsset {
        return group.fetchResult[group.totalCount - index - 1]
    }
	
	// MARK: - Private methods
    
    private func makeDKAssetGroup(with collection: PHAssetCollection) -> DKAssetGroup {
        let assetGroup = DKAssetGroup()
        assetGroup.groupId = collection.localIdentifier
        self.updateGroup(assetGroup, collection: collection)
        self.updateGroup(assetGroup, fetchResult: PHAsset.fetchAssets(in: collection, options: self.assetFetchOptions))
        
        return assetGroup
    }
    
    private func collectionTypeForSubtype(_ subtype: PHAssetCollectionSubtype) -> PHAssetCollectionType {
        return subtype.rawValue < PHAssetCollectionSubtype.smartAlbumGeneric.rawValue ? .album : .smartAlbum
    }
    
    private func fetchGroups(assetGroupTypes: [PHAssetCollectionSubtype], block: @escaping (PHAssetCollection) -> Void) {
        for (_, groupType) in assetGroupTypes.enumerated() {
            let fetchResult = PHAssetCollection.fetchAssetCollections(with: self.collectionTypeForSubtype(groupType),
                                                                      subtype: groupType,
                                                                      options: nil)
            fetchResult.enumerateObjects({ (collection, index, stop) in
                block(collection)
            })
        }
    }
    
    private func updatePartial(groups: [String : DKAssetGroup], groupIds: [String], completeBlock: @escaping (_ groups: [String]?, _ error: NSError?) -> Void) {
        self.groups = groups
        self.groupIds = groupIds
        DispatchQueue.main.async {
            completeBlock(groupIds, nil)
        }
    }
	
	private func updateGroup(_ group: DKAssetGroup, collection: PHAssetCollection) {
		group.groupName = collection.localizedTitle
		group.originalCollection = collection
	}
	
	private func updateGroup(_ group: DKAssetGroup, fetchResult: PHFetchResult<PHAsset>) {
        group.fetchResult = filterResults(fetchResult)
		group.totalCount = group.fetchResult.count
	}
	
    private func filterResults(_ fetchResult: PHFetchResult<PHAsset>) -> PHFetchResult<PHAsset> {
        guard let filter = assetFilter else { return fetchResult }
        
        var filtered = [PHAsset]()
        for i in 0..<fetchResult.count {
            if filter(fetchResult[i]) {
                filtered.append(fetchResult[i])
            }
        }

        let collection = PHAssetCollection.transientAssetCollection(with: filtered, title: nil)
        return PHAsset.fetchAssets(in: collection, options: nil)
    }
    
	// MARK: - PHPhotoLibraryChangeObserver methods
	
	public func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let groups = self.groups else { return }

        for group in groups.values {
			if let changeDetails = changeInstance.changeDetails(for: group.originalCollection) {
				if changeDetails.objectWasDeleted {
					self.groups![group.groupId] = nil
					self.notifyObserversWithSelector(#selector(DKGroupDataManagerObserver.groupDidRemove(_:)), object: group.groupId as AnyObject?)
					continue
				}
				
				if let objectAfterChanges = changeDetails.objectAfterChanges as? PHAssetCollection {
					self.updateGroup(self.groups![group.groupId]!, collection: objectAfterChanges)
					self.notifyObserversWithSelector(#selector(DKGroupDataManagerObserver.groupDidUpdate(_:)), object: group.groupId as AnyObject?)
				}
			}
			
			if let changeDetails = changeInstance.changeDetails(for: group.fetchResult) {
                let removedAssets = changeDetails.removedObjects.map{ DKAsset(originalAsset: $0) }
				if removedAssets.count > 0 {
					self.notifyObserversWithSelector(#selector(DKGroupDataManagerObserver.group(_:didRemoveAssets:)), object: group.groupId as AnyObject?, objectTwo: removedAssets as AnyObject?)
				}
				self.updateGroup(group, fetchResult: changeDetails.fetchResultAfterChanges)
				
                let insertedAssets = changeDetails.insertedObjects.map{ DKAsset(originalAsset: $0) }
				if insertedAssets.count > 0  {
					self.notifyObserversWithSelector(#selector(DKGroupDataManagerObserver.group(_:didInsertAssets:)), object: group.groupId as AnyObject?, objectTwo: insertedAssets as AnyObject?)
				}
                
                self.notifyObserversWithSelector(#selector(DKGroupDataManagerObserver.groupDidUpdateComplete(_:)), object: group.groupId as AnyObject?)
			}
		}
        
        if let assetGroupTypes = self.assetGroupTypes {
            var insertedGroupIds: [String] = []
            
            self.fetchGroups(assetGroupTypes: assetGroupTypes, block: { (collection) in
                if (self.groups![collection.localIdentifier] == nil) {
                    let assetGroup = self.makeDKAssetGroup(with: collection)
                    self.groups![assetGroup.groupId] = assetGroup
                    self.groupIds!.append(assetGroup.groupId)
                    
                    insertedGroupIds.append(assetGroup.groupId)
                }
            })
            
            if (insertedGroupIds.count > 0) {
                self.notifyObserversWithSelector(#selector(DKGroupDataManagerObserver.groupsDidInsert(_:)), object: insertedGroupIds as AnyObject)
            }
        }
	}

}
