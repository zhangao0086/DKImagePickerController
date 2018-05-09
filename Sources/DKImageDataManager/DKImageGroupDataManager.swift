//
//  DKImageGroupDataManager.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/12/16.
//  Copyright © 2015年 ZhangAo. All rights reserved.
//

import Photos

@objc
protocol DKImageGroupDataManagerObserver {
	
	@objc optional func groupDidUpdate(groupId: String)
	@objc optional func groupDidRemove(groupId: String)
	@objc optional func group(groupId: String, didRemoveAssets assets: [DKAsset])
	@objc optional func group(groupId: String, didInsertAssets assets: [DKAsset])
    @objc optional func groupDidUpdateComplete(groupId: String)
    @objc optional func groupsDidInsert(groupIds: [String])
}

/*
 Configuration options for a DKImageGroupDataManager. When a manager is created,
 a copy of the configuration object is made - you cannot modify the configuration
 of a manager after it has been created.
 */
@objc
public class DKImageGroupDataManagerConfiguration: NSObject, NSCopying {
    
    /// The types of PHAssetCollection to display in the picker.
    public var assetGroupTypes: [PHAssetCollectionSubtype] = [
        .smartAlbumUserLibrary,
        .smartAlbumFavorites,
        .albumRegular
    ]
  
    @objc public var orientationsAllowed: DKImagePickerControllerAssetOrientation = .all
    
    /// Options that specify a filter predicate and sort order for the fetched assets, or nil to use default options.
    @objc public var assetFetchOptions: PHFetchOptions?
    
    /// Limits the maximum number of objects displayed on the UI, a value of 0 means no limit.  Defaults to 0.
    @objc public var fetchLimit = 0
    
    public required override init() {
        super.init()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init()
        copy.assetGroupTypes = self.assetGroupTypes
        copy.assetFetchOptions = self.assetFetchOptions
        copy.fetchLimit = self.fetchLimit
        
        return copy
    }
    
}

/////////////////////////////////////////////////////////////////////////////////////

/*
 Create and manage a collection of DKAssetGroup.
 */
@objc
open class DKImageGroupDataManager: DKImageBaseManager, PHPhotoLibraryChangeObserver {

    public var groupIds: [String]?
    private var groups: [String : DKAssetGroup]?
    private var assets = [String: DKAsset]()
    
    private let configuration: DKImageGroupDataManagerConfiguration
    
    public init(configuration: DKImageGroupDataManagerConfiguration) {
        self.configuration = configuration.copy() as! DKImageGroupDataManagerConfiguration
        
        super.init()
    }
    
	deinit {
		PHPhotoLibrary.shared().unregisterChangeObserver(self)
	}
	
	open func invalidate() {
		self.groupIds?.removeAll()
        self.groups?.removeAll()
        self.assets.removeAll()
		
		PHPhotoLibrary.shared().unregisterChangeObserver(self)
	}

    open func fetchGroups(_ completeBlock: @escaping (_ groups: [String]?, _ error: NSError?) -> Void) {
        let assetGroupTypes = self.configuration.assetGroupTypes
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let strongSelf = self else { return }
            
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
                groups[assetGroup.groupId] = assetGroup
                groupIds.append(assetGroup.groupId)
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
	
	open func fetchGroupWithGroupId(_ groupId: String) -> DKAssetGroup {
		return self.groups![groupId]!
	}
	
	open func fetchGroupThumbnailForGroup(_ groupId: String, size: CGSize, options: PHImageRequestOptions, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
		let group = self.fetchGroupWithGroupId(groupId)
		if group.totalCount == 0 {
			completeBlock(nil, nil)
			return
		}
		
		let latestAsset = DKAsset(originalAsset:group.fetchResult.lastObject!)
        latestAsset.fetchImage(with: size, options: options, completeBlock: completeBlock)
	}
	
	open func fetchAsset(_ group: DKAssetGroup, index: Int) -> DKAsset {
        let phAsset = self.fetchPHAsset(group, index: index)
        var asset = self.assets[phAsset.localIdentifier]
        if asset == nil {
            asset = DKAsset(originalAsset:phAsset)
            self.assets[phAsset.localIdentifier] = asset
        }
		return asset!
	}
    
    open func fetchPHAsset(_ group: DKAssetGroup, index: Int) -> PHAsset {
        return group.fetchResult[group.fetchResult.count - 1 - index]
    }
    
    open func makeDKAssetGroup(with collection: PHAssetCollection) -> DKAssetGroup {
        let assetGroup = DKAssetGroup()
        assetGroup.groupId = collection.localIdentifier
        self.updateGroup(assetGroup, collection: collection)
        
        let fetchResult = PHAsset.fetchAssets(in: collection, options: self.configuration.assetFetchOptions)
        self.updateGroup(assetGroup, fetchResult: fetchResult)
        
        return assetGroup
    }
    
    open func collectionTypeForSubtype(_ subtype: PHAssetCollectionSubtype) -> PHAssetCollectionType {
        return subtype.rawValue < PHAssetCollectionSubtype.smartAlbumGeneric.rawValue ? .album : .smartAlbum
    }
    
    open func fetchGroups(assetGroupTypes: [PHAssetCollectionSubtype], block: @escaping (PHAssetCollection) -> Void) {
        for (_, groupType) in assetGroupTypes.enumerated() {
            let fetchResult = PHAssetCollection.fetchAssetCollections(with: self.collectionTypeForSubtype(groupType),
                                                                      subtype: groupType,
                                                                      options: nil)
            fetchResult.enumerateObjects({ (collection, index, stop) in
                block(collection)
            })
        }
    }
    
    open func updatePartial(groups: [String : DKAssetGroup], groupIds: [String], completeBlock: @escaping (_ groups: [String]?, _ error: NSError?) -> Void) {
        self.groups = groups
        self.groupIds = groupIds
        
        DispatchQueue.main.async {
            completeBlock(groupIds, nil)
        }
    }
	
	open func updateGroup(_ group: DKAssetGroup, collection: PHAssetCollection) {
		group.groupName = collection.localizedTitle
		group.originalCollection = collection
	}
	
	open func updateGroup(_ group: DKAssetGroup, fetchResult: PHFetchResult<PHAsset>) {
        var indexes: [Int] = []
        fetchResult.enumerateObjects ({ (asset, index, _) in
            if self.configuration.orientationsAllowed == .landscape {
                if asset.pixelWidth > asset.pixelHeight {
                    indexes.append(index)
                }
            } else if self.configuration.orientationsAllowed == .portrait {
                if asset.pixelHeight > asset.pixelWidth {
                    indexes.append(index)
                }
            }
        })
        group.assets = fetchResult.objects(at: IndexSet(indexes))
        group.fetchResult = fetchResult
        group.displayCount = self.configuration.fetchLimit
	}
    
	// MARK: - PHPhotoLibraryChangeObserver methods
	
	open func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let groups = self.groups?.values else { return  }
        
        for group in groups {
			if let changeDetails = changeInstance.changeDetails(for: group.originalCollection) {
				if changeDetails.objectWasDeleted {
					self.groups![group.groupId] = nil
                    self.notify(with: #selector(DKImageGroupDataManagerObserver.groupDidRemove(groupId:)), object: group.groupId as AnyObject?)
					continue
				}
				
				if let objectAfterChanges = changeDetails.objectAfterChanges {
					self.updateGroup(self.groups![group.groupId]!, collection: objectAfterChanges)
                    self.notify(with: #selector(DKImageGroupDataManagerObserver.groupDidUpdate(groupId:)), object: group.groupId as AnyObject?)
				}
			}
			
			if let changeDetails = changeInstance.changeDetails(for: group.fetchResult) {
                let removedAssets = changeDetails.removedObjects.map{ DKAsset(originalAsset: $0) }
				if removedAssets.count > 0 {
                    self.notify(with: #selector(DKImageGroupDataManagerObserver.group(groupId:didRemoveAssets:)), object: group.groupId as AnyObject?, objectTwo: removedAssets as AnyObject?)
				}
				self.updateGroup(group, fetchResult: changeDetails.fetchResultAfterChanges)
				
                let insertedAssets = changeDetails.insertedObjects.map{ DKAsset(originalAsset: $0) }
				if insertedAssets.count > 0  {
                    self.notify(with: #selector(DKImageGroupDataManagerObserver.group(groupId:didInsertAssets:)), object: group.groupId as AnyObject?, objectTwo: insertedAssets as AnyObject?)
				}
                
                self.notify(with: #selector(DKImageGroupDataManagerObserver.groupDidUpdateComplete(groupId:)), object: group.groupId as AnyObject?)
            }
        }
        
        let assetGroupTypes = self.configuration.assetGroupTypes
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
            self.notify(with: #selector(DKImageGroupDataManagerObserver.groupsDidInsert(groupIds:)), object: insertedGroupIds as AnyObject)
        }
    }
}
