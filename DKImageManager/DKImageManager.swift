//
//  DKImageManager.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 15/11/29.
//  Copyright © 2015年 ZhangAo. All rights reserved.
//

import Photos

open class DKBaseManager: NSObject {

	private let observers = NSHashTable<AnyObject>.weakObjects()
	
	open func addObserver(_ object: AnyObject) {
		self.observers.add(object)
	}
	
	open func removeObserver(_ object: AnyObject) {
		self.observers.remove(object)
	}
	
	open func notifyObserversWithSelector(_ selector: Selector, object: AnyObject?) {
		self.notifyObserversWithSelector(selector, object: object, objectTwo: nil)
	}
	
	open func notifyObserversWithSelector(_ selector: Selector, object: AnyObject?, objectTwo: AnyObject?) {
		if self.observers.count > 0 {
			DispatchQueue.main.async(execute: { () -> Void in
				for observer in self.observers.allObjects {
					if observer.responds(to: selector) {
						_ = observer.perform(selector, with: object, with: objectTwo)
					}
				}
			})
		}
	}

}

public func getImageManager() -> DKImageManager {
	return DKImageManager.sharedInstance
}

public class DKImageManager: DKBaseManager {
	
	public class func checkPhotoPermission(_ handler: @escaping (_ granted: Bool) -> Void) {
		func hasPhotoPermission() -> Bool {
			return PHPhotoLibrary.authorizationStatus() == .authorized
		}
		
		func needsToRequestPhotoPermission() -> Bool {
			return PHPhotoLibrary.authorizationStatus() == .notDetermined
		}
		
		hasPhotoPermission() ? handler(true) : (needsToRequestPhotoPermission() ?
			PHPhotoLibrary.requestAuthorization({ status in
				DispatchQueue.main.async(execute: { () in
					hasPhotoPermission() ? handler(true) : handler(false)
				})
			}) : handler(false))
	}
	
	static let sharedInstance = DKImageManager()
	
    private let manager = PHCachingImageManager()
	
	private lazy var defaultImageRequestOptions: PHImageRequestOptions = {
		let options = PHImageRequestOptions()
		
		return options
	}()
	
	private lazy var defaultVideoRequestOptions: PHVideoRequestOptions = {
		let options = PHVideoRequestOptions()
		options.deliveryMode = .mediumQualityFormat
		
		return options
	}()
	
	public var autoDownloadWhenAssetIsInCloud = true
	
    public lazy var groupDataManager: DKGroupDataManager! = {
        return DKGroupDataManager()
    }()
	
	public func invalidate() {
		self.groupDataManager.invalidate()
        self.groupDataManager = nil
	}
	
	public func fetchImageForAsset(_ asset: DKAsset, size: CGSize, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
		self.fetchImageForAsset(asset, size: size, options: nil, completeBlock: completeBlock)
	}
	
	public func fetchImageForAsset(_ asset: DKAsset, size: CGSize, contentMode: PHImageContentMode, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
			self.fetchImageForAsset(asset, size: size, options: nil, contentMode: contentMode, completeBlock: completeBlock)
	}

	public func fetchImageForAsset(_ asset: DKAsset, size: CGSize, options: PHImageRequestOptions?, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
		self.fetchImageForAsset(asset, size: size, options: options, contentMode: .aspectFill, completeBlock: completeBlock)
	}
	
	public func fetchImageForAsset(_ asset: DKAsset, size: CGSize, options: PHImageRequestOptions?, contentMode: PHImageContentMode,
	                               completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
            let options = (options ?? self.defaultImageRequestOptions).copy() as! PHImageRequestOptions

            self.manager.requestImage(for: asset.originalAsset!,
                                      targetSize: size,
                                      contentMode: contentMode,
                                      options: options,
                                      resultHandler: { image, info in
                                        if let isInCloud = info?[PHImageResultIsInCloudKey] as AnyObject?
                                            , image == nil && isInCloud.boolValue && self.autoDownloadWhenAssetIsInCloud {
                                            options.isNetworkAccessAllowed = true
                                            self.fetchImageForAsset(asset, size: size, options: options, contentMode: contentMode, completeBlock: completeBlock)
                                        } else {
                                            completeBlock(image, info)
                                        }
            })
	}
	
	public func fetchImageDataForAsset(_ asset: DKAsset, options: PHImageRequestOptions?, completeBlock: @escaping (_ data: Data?, _ info: [AnyHashable: Any]?) -> Void) {
		self.manager.requestImageData(for: asset.originalAsset!,
		                                      options: options ?? self.defaultImageRequestOptions) { (data, dataUTI, orientation, info) in
												if let isInCloud = info?[PHImageResultIsInCloudKey] as AnyObject?
													, data == nil && isInCloud.boolValue && self.autoDownloadWhenAssetIsInCloud {
													let requestCloudOptions = (options ?? self.defaultImageRequestOptions).copy() as! PHImageRequestOptions
													requestCloudOptions.isNetworkAccessAllowed = true
													self.fetchImageDataForAsset(asset, options: requestCloudOptions, completeBlock: completeBlock)
												} else {
													completeBlock(data, info)
												}
		}
	}
	
	public func fetchAVAsset(_ asset: DKAsset, completeBlock: @escaping (_ avAsset: AVAsset?, _ info: [AnyHashable: Any]?) -> Void) {
		self.fetchAVAsset(asset, options: nil, completeBlock: completeBlock)
	}
	
	public func fetchAVAsset(_ asset: DKAsset, options: PHVideoRequestOptions?, completeBlock: @escaping (_ avAsset: AVAsset?, _ info: [AnyHashable: Any]?) -> Void) {
		self.manager.requestAVAsset(forVideo: asset.originalAsset!,
			options: options ?? self.defaultVideoRequestOptions) { avAsset, audioMix, info in
				if let isInCloud = info?[PHImageResultIsInCloudKey] as AnyObject?
					, avAsset == nil && isInCloud.boolValue && self.autoDownloadWhenAssetIsInCloud {
					let requestCloudOptions = (options ?? self.defaultVideoRequestOptions).copy() as! PHVideoRequestOptions
					requestCloudOptions.isNetworkAccessAllowed = true
					self.fetchAVAsset(asset, options: requestCloudOptions, completeBlock: completeBlock)
				} else {
					completeBlock(avAsset, info)
				}
		}
	}
    
    public func startCachingAssets(for assets: [PHAsset], targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) {
        self.manager.startCachingImages(for: assets, targetSize: targetSize, contentMode: contentMode, options: options)
    }
    
    public func stopCachingAssets(for assets: [PHAsset], targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) {
        self.manager.stopCachingImages(for: assets, targetSize: targetSize, contentMode: contentMode, options: options)
    }
    
    public func stopCachingForAllAssets() {
        self.manager.stopCachingImagesForAllAssets()
    }
}
