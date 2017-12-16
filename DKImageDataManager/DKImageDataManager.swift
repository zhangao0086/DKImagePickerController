//
//  DKImageDataManager.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/11/29.
//  Copyright © 2015年 ZhangAo. All rights reserved.
//

import Photos

public typealias DKImageRequestID = Int32
public let DKImageInvalidRequestID: DKImageRequestID = 0

public func getImageDataManager() -> DKImageDataManager {
	return DKImageDataManager.sharedInstance
}

public class DKImageDataManager {
	
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
	
	static let sharedInstance = DKImageDataManager()
	
    private let manager = PHCachingImageManager()
	
	private lazy var imageRequestOptions: PHImageRequestOptions = {
		let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
		
		return options
	}()
	
	private lazy var videoRequestOptions: PHVideoRequestOptions = {
		let options = PHVideoRequestOptions()
		options.deliveryMode = .mediumQualityFormat
        options.isNetworkAccessAllowed = true
		
		return options
	}()
    
    @discardableResult
    public func fetchImage(for asset: DKAsset,
                           size: CGSize,
                           options: PHImageRequestOptions? = nil,
                           contentMode: PHImageContentMode = .aspectFill,
                           completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) -> DKImageRequestID {
        return self.fetchImage(for: asset, size: size, options: options, contentMode: contentMode, oldRequestID: nil, completeBlock: completeBlock)
    }
    
    @discardableResult
    private func fetchImage(for asset: DKAsset, size: CGSize, options: PHImageRequestOptions?, contentMode: PHImageContentMode,
                            oldRequestID: DKImageRequestID?,
                            completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) -> DKImageRequestID {
        let requestID = oldRequestID ?? self.getSeed()
        
        let requestOptions = options ?? self.imageRequestOptions
        let imageRequestID = self.manager.requestImage(for: asset.originalAsset!,
                                                       targetSize: size,
                                                       contentMode: contentMode,
                                                       options: requestOptions,
                                                       resultHandler: { image, info in
                                                        if let info = info, let isCancelled = info[PHImageCancelledKey] as? NSNumber, isCancelled.boolValue {
                                                            completeBlock(image, info)
                                                            return
                                                        }
                                                        
                                                        if let isInCloud = info?[PHImageResultIsInCloudKey] as AnyObject?
                                                            , image == nil && isInCloud.boolValue && !requestOptions.isNetworkAccessAllowed {
                                                            if self.requestIDs[requestID] == nil {
                                                                completeBlock(nil, [PHImageCancelledKey : NSNumber(value: 1)])
                                                                return
                                                            }
                                                            
                                                            let requestCloudOptions = requestOptions.copy() as! PHImageRequestOptions
                                                            requestCloudOptions.isNetworkAccessAllowed = true
                                                            
                                                            self.fetchImage(for: asset, size: size, options: options, contentMode: contentMode, oldRequestID: requestID, completeBlock: completeBlock)
                                                        } else {
                                                            self.update(requestID: requestID, with: nil)
                                                            completeBlock(image, info)
                                                        }
        })
        
        self.update(requestID: requestID, with: imageRequestID, old: oldRequestID)
        return requestID
    }
    
    @discardableResult
    public func fetchImageData(for asset: DKAsset, options: PHImageRequestOptions? = nil, completeBlock: @escaping (_ data: Data?, _ info: [AnyHashable: Any]?) -> Void) -> DKImageRequestID {
        return self.fetchImageData(for: asset, options: options, oldRequestID: nil, completeBlock: completeBlock)
    }
    
    @discardableResult
    private func fetchImageData(for asset: DKAsset, options: PHImageRequestOptions?, oldRequestID: DKImageRequestID?, completeBlock: @escaping (_ data: Data?, _ info: [AnyHashable: Any]?) -> Void) -> DKImageRequestID {
        let requestID = oldRequestID ?? self.getSeed()
        
        let requestOptions = options ?? self.imageRequestOptions
        let imageRequestID = self.manager.requestImageData(for: asset.originalAsset!,
                                                           options: requestOptions) { (data, dataUTI, orientation, info) in
                                                            if let info = info, let isCancelled = info[PHImageCancelledKey] as? NSNumber, isCancelled.boolValue {
                                                                completeBlock(data, info)
                                                                return
                                                            }
                                                            
                                                            if let isInCloud = info?[PHImageResultIsInCloudKey] as AnyObject?
                                                                , data == nil && isInCloud.boolValue && !requestOptions.isNetworkAccessAllowed {
                                                                if self.requestIDs[requestID] == nil {
                                                                    completeBlock(nil, [PHImageCancelledKey : NSNumber(value: 1)])
                                                                    return
                                                                }
                                                                
                                                                let requestCloudOptions = requestOptions.copy() as! PHImageRequestOptions
                                                                requestCloudOptions.isNetworkAccessAllowed = true
                                                                
                                                                self.fetchImageData(for: asset, options: requestCloudOptions, oldRequestID: requestID, completeBlock: completeBlock)
                                                            } else {
                                                                self.update(requestID: requestID, with: nil)
                                                                completeBlock(data, info)
                                                            }
        }
        
        self.update(requestID: requestID, with: imageRequestID, old: oldRequestID)
        return requestID
    }
	
    @discardableResult
    public func fetchAVAsset(for asset: DKAsset, options: PHVideoRequestOptions? = nil, completeBlock: @escaping (_ avAsset: AVAsset?, _ info: [AnyHashable: Any]?) -> Void) -> DKImageRequestID {
        return self.fetchAVAsset(for: asset, options: options, oldRequestID: nil, completeBlock: completeBlock)
    }
    
    @discardableResult
    private func fetchAVAsset(for asset: DKAsset, options: PHVideoRequestOptions?, oldRequestID: DKImageRequestID?, completeBlock: @escaping (_ avAsset: AVAsset?, _ info: [AnyHashable: Any]?) -> Void) -> DKImageRequestID {
        let requestID = oldRequestID ?? self.getSeed()
        
        let requestOptions = options ?? self.videoRequestOptions
        let imageRequestID = self.manager.requestAVAsset(forVideo: asset.originalAsset!,
                                                         options: requestOptions) { avAsset, audioMix, info in
                                                            if let info = info, let isCancelled = info[PHImageCancelledKey] as? NSNumber, isCancelled.boolValue {
                                                                completeBlock(avAsset, info)
                                                                return
                                                            }

                                                            if let isInCloud = info?[PHImageResultIsInCloudKey] as AnyObject?
                                                                , avAsset == nil && isInCloud.boolValue && !requestOptions.isNetworkAccessAllowed {
                                                                if self.requestIDs[requestID] == nil {
                                                                    completeBlock(nil, [PHImageCancelledKey : NSNumber(value: 1)])
                                                                    return
                                                                }

                                                                let requestCloudOptions = requestOptions.copy() as! PHVideoRequestOptions
                                                                requestCloudOptions.isNetworkAccessAllowed = true
                                                                
                                                                self.fetchAVAsset(for: asset, options: requestCloudOptions, oldRequestID: requestID, completeBlock: completeBlock)
                                                            } else {
                                                                self.update(requestID: requestID, with: nil)
                                                                completeBlock(avAsset, info)
                                                            }
        }
        
        self.update(requestID: requestID, with: imageRequestID, old: oldRequestID)
        return requestID
    }
    
    public func cancelRequest(requestID: DKImageRequestID) {
        self.executeOnMainThread {
            if let imageRequestID = self.requestIDs[requestID] {
                self.manager.cancelImageRequest(imageRequestID)
            }
            
            self.update(requestID: requestID, with: nil)
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
    
    // MARK: - RequestID
    
    private var requestIDs = [DKImageRequestID : PHImageRequestID]()
    private var seed: DKImageRequestID = 0
    
    private func getSeed() -> DKImageRequestID {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        seed += 1
        return seed
    }
    
    private func update(requestID: DKImageRequestID,
                        with imageRequestID: PHImageRequestID?,
                        old oldImageRequestID: DKImageRequestID? = nil) {
        self.executeOnMainThread {
            if let imageRequestID = imageRequestID {
                if self.requestIDs[requestID] != nil || oldImageRequestID == nil {
                    self.requestIDs[requestID] = imageRequestID
                } else {
                    self.manager.cancelImageRequest(imageRequestID)
                }
            } else {
                self.requestIDs[requestID] = nil
            }
        }
    }
    
    private func executeOnMainThread(block: @escaping (() -> Void)) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
}
