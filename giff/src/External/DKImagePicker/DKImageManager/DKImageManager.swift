//
//  DKImageManager.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 15/11/29.
//  Copyright © 2015年 ZhangAo. All rights reserved.
//

import Photos

public class DKBaseManager: NSObject {

	private let observers = NSHashTable.weakObjectsHashTable()
	
	public func addObserver(object: AnyObject) {
		self.observers.addObject(object)
	}
	
	public func removeObserver(object: AnyObject) {
		self.observers.removeObject(object)
	}
	
	public func notifyObserversWithSelector(selector: Selector, object: AnyObject?) {
		self.notifyObserversWithSelector(selector, object: object, objectTwo: nil)
	}
	
	public func notifyObserversWithSelector(selector: Selector, object: AnyObject?, objectTwo: AnyObject?) {
		if self.observers.count > 0 {
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				for observer in self.observers.objectEnumerator() {
					if observer.respondsToSelector(selector) {
						observer.performSelector(selector, withObject: object, withObject: objectTwo)
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
	
	public class func checkPhotoPermission(handler: (granted: Bool) -> Void) {
		func hasPhotoPermission() -> Bool {
			return PHPhotoLibrary.authorizationStatus() == .Authorized
		}
		
		func needsToRequestPhotoPermission() -> Bool {
			return PHPhotoLibrary.authorizationStatus() == .NotDetermined
		}
		
		hasPhotoPermission() ? handler(granted: true) : (needsToRequestPhotoPermission() ?
			PHPhotoLibrary.requestAuthorization({ status in
				dispatch_async(dispatch_get_main_queue(), { () in
					hasPhotoPermission() ? handler(granted: true) : handler(granted: false)
				})
			}) : handler(granted: false))
	}
	
	static let sharedInstance = DKImageManager()
	
	private let manager = PHCachingImageManager.defaultManager()
	
	private lazy var defaultImageRequestOptions: PHImageRequestOptions = {
		let options = PHImageRequestOptions()
		options.deliveryMode = .HighQualityFormat
		options.resizeMode = .Exact
		
		return options
	}()
	
	private lazy var defaultVideoRequestOptions: PHVideoRequestOptions = {
		let options = PHVideoRequestOptions()
		options.deliveryMode = .MediumQualityFormat
		
		return options
	}()
	
	public var autoDownloadWhenAssetIsInCloud = true
	
	public let groupDataManager = DKGroupDataManager()
	
	public func invalidate() {
		self.groupDataManager.invalidate()
	}
	
	public func fetchImageForAsset(asset: DKAsset, size: CGSize, completeBlock: (image: UIImage?, info: [NSObject : AnyObject]?) -> Void) {
		self.fetchImageForAsset(asset, size: size, options: nil, completeBlock: completeBlock)
	}
	
	public func fetchImageForAsset(asset: DKAsset, size: CGSize, contentMode: PHImageContentMode, completeBlock: (image: UIImage?, info: [NSObject : AnyObject]?) -> Void) {
			self.fetchImageForAsset(asset, size: size, options: nil, contentMode: contentMode, completeBlock: completeBlock)
	}

	public func fetchImageForAsset(asset: DKAsset, size: CGSize, options: PHImageRequestOptions?, completeBlock: (image: UIImage?, info: [NSObject : AnyObject]?) -> Void) {
		self.fetchImageForAsset(asset, size: size, options: options, contentMode: .AspectFill, completeBlock: completeBlock)
	}
	
	public func fetchImageForAsset(asset: DKAsset, size: CGSize, options: PHImageRequestOptions?, contentMode: PHImageContentMode,
	                               completeBlock: (image: UIImage?, info: [NSObject : AnyObject]?) -> Void) {
		let options = (options ?? self.defaultImageRequestOptions).copy() as! PHImageRequestOptions
		self.manager.requestImageForAsset(asset.originalAsset!,
		                                  targetSize: size,
		                                  contentMode: contentMode,
		                                  options: options,
		                                  resultHandler: { image, info in
											if let isInCloud = info?[PHImageResultIsInCloudKey]?.boolValue
												where image == nil && isInCloud && self.autoDownloadWhenAssetIsInCloud {
//												var requestCloudOptions = (options ?? self.defaultImageRequestOptions).copy() as! PHImageRequestOptions
//												requestCloudOptions.networkAccessAllowed = true
												options.networkAccessAllowed = true
												self.fetchImageForAsset(asset, size: size, options: options, contentMode: contentMode, completeBlock: completeBlock)
											} else {
												completeBlock(image: image, info: info)
											}
		})
	}
	
	public func fetchImageDataForAsset(asset: DKAsset, options: PHImageRequestOptions?, completeBlock: (data: NSData?, info: [NSObject : AnyObject]?) -> Void) {
		self.manager.requestImageDataForAsset(asset.originalAsset!,
		                                      options: options ?? self.defaultImageRequestOptions) { (data, dataUTI, orientation, info) in
												if let isInCloud = info?[PHImageResultIsInCloudKey]?.boolValue
													where data == nil && isInCloud && self.autoDownloadWhenAssetIsInCloud {
													let requestCloudOptions = (options ?? self.defaultImageRequestOptions).copy() as! PHImageRequestOptions
													requestCloudOptions.networkAccessAllowed = true
													self.fetchImageDataForAsset(asset, options: requestCloudOptions, completeBlock: completeBlock)
												} else {
													completeBlock(data: data, info: info)
												}
		}
	}
	
	public func fetchAVAsset(asset: DKAsset, completeBlock: (avAsset: AVAsset?, info: [NSObject : AnyObject]?) -> Void) {
		self.fetchAVAsset(asset, options: nil, completeBlock: completeBlock)
	}
	
	public func fetchAVAsset(asset: DKAsset, options: PHVideoRequestOptions?, completeBlock: (avAsset: AVAsset?, info: [NSObject : AnyObject]?) -> Void) {
		self.manager.requestAVAssetForVideo(asset.originalAsset!,
			options: options ?? self.defaultVideoRequestOptions) { avAsset, audioMix, info in
				if let isInCloud = info?[PHImageResultIsInCloudKey]?.boolValue
					where avAsset == nil && isInCloud && self.autoDownloadWhenAssetIsInCloud {
					let requestCloudOptions = (options ?? self.defaultVideoRequestOptions).copy() as! PHVideoRequestOptions
					requestCloudOptions.networkAccessAllowed = true
					self.fetchAVAsset(asset, options: requestCloudOptions, completeBlock: completeBlock)
				} else {
					completeBlock(avAsset: avAsset, info: info)
				}
		}
	}
	
}
