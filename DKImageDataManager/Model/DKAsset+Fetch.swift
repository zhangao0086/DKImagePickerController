//
//  DKAsset+Fetch.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 30/11/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import Foundation
import UIKit
import Photos

public extension DKAsset {
    
    @objc public func fetchImage(with size: CGSize, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
        self.fetchImage(with: size, options: nil, completeBlock: completeBlock)
    }
    
    @objc public func fetchImage(with size: CGSize, options: PHImageRequestOptions?, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
        self.fetchImage(with: size, options: options, contentMode: .aspectFit, completeBlock: completeBlock)
    }
    
    @objc public func fetchImage(with size: CGSize, options: PHImageRequestOptions?, contentMode: PHImageContentMode, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
        if let _ = self.originalAsset {
            self.requestID = getImageDataManager().fetchImage(for: self, size: size, options: options, contentMode: contentMode, completeBlock: completeBlock)
        } else {
            completeBlock(self.image, nil)
        }
    }
    
    @objc public func fetchFullScreenImage(with completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
        self.fetchFullScreenImage(sync: false, completeBlock: completeBlock)
    }
    
    /**
     Fetch an image with the current screen size.
     
     - parameter sync:          If true, the method blocks the calling thread until image is ready or an error occurs.
     - parameter completeBlock: The block is executed when the image download is complete.
     */
    @objc public func fetchFullScreenImage(sync: Bool, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
        if let (image, info) = self.fullScreenImage {
            completeBlock(image, info)
        } else {
            let screenSize = UIScreen.main.bounds.size
            
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            options.isSynchronous = sync
            
            self.requestID = getImageDataManager().fetchImage(for: self, size: screenSize.toPixel(), options: options, contentMode: .aspectFit) { [weak self] image, info in
                guard let strongSelf = self else { return }
                
                strongSelf.fullScreenImage = (image, info)
                completeBlock(image, info)
            }
        }
    }
    
    @objc public func fetchOriginalImage(with completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
        self.fetchOriginalImage(sync: false, completeBlock: completeBlock)
    }
    
    /**
     Fetch an image with the original size.
     
     - parameter sync:          If true, the method blocks the calling thread until image is ready or an error occurs.
     - parameter completeBlock: The block is executed when the image download is complete.
     */
    @objc public func fetchOriginalImage(sync: Bool, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
        if let _ = self.originalAsset {
            let options = PHImageRequestOptions()
            options.version = .current
            options.isSynchronous = sync
            
            self.requestID = getImageDataManager().fetchImageData(for: self, options: options, completeBlock: { (data, info) in
                var image: UIImage?
                if let data = data {
                    image = UIImage(data: data)
                }
                completeBlock(image, info)
            })
        } else {
            completeBlock(self.image, nil)
        }
    }
    
    /**
     Fetch an image data with the original size.
     
     - parameter sync:          If true, the method blocks the calling thread until image is ready or an error occurs.
     - parameter completeBlock: The block is executed when the image download is complete.
     */
    @objc public func fetchImageData(sync: Bool, completeBlock: @escaping (_ imageData: Data?, _ info: [AnyHashable: Any]?) -> Void) {
        let options = PHImageRequestOptions()
        options.version = .current
        options.isSynchronous = sync
        
        self.requestID = getImageDataManager().fetchImageData(for: self, options: options, completeBlock: { (data, info) in
            completeBlock(data, info)
        })
    }
    
    /**
     Fetch an AVAsset with a completeBlock.
     */
    @objc public func fetchAVAsset(with completeBlock: @escaping (_ AVAsset: AVAsset?, _ info: [AnyHashable: Any]?) -> Void) {
        self.fetchAVAsset(options: nil, completeBlock: completeBlock)
    }
    
    /**
     Fetch an AVAsset with a completeBlock and PHVideoRequestOptions.
     */
    @objc public func fetchAVAsset(options: PHVideoRequestOptions?, completeBlock: @escaping (_ AVAsset: AVAsset?, _ info: [AnyHashable: Any]?) -> Void) {
        self.requestID = getImageDataManager().fetchAVAsset(for: self, options: options, completeBlock: completeBlock)
    }
    
    /**
     Sync fetch an AVAsset with a completeBlock and PHVideoRequestOptions.
     */
    @objc public func fetchAVAsset(sync: Bool, options: PHVideoRequestOptions?, completeBlock: @escaping (_ AVAsset: AVAsset?, _ info: [AnyHashable: Any]?) -> Void) {
        if sync {
            let semaphore = DispatchSemaphore(value: 0)
            self.fetchAVAsset(options: options, completeBlock: { (AVAsset, info) -> Void in
                completeBlock(AVAsset, info)
                semaphore.signal()
            })
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        } else {
            self.fetchAVAsset(options: options, completeBlock: completeBlock)
        }
    }
    
    @objc public func cancelCurrentRequest() {
        if self.requestID != DKImageInvalidRequestID {
            getImageDataManager().cancelRequest(requestID: self.requestID)
            self.requestID = DKImageInvalidRequestID
        }
    }
    
    // MARK: - Private
    
    struct FetchKeys {
        static fileprivate var requestID: UInt8 = 0
    }
    
    private var requestID: DKImageRequestID {
        get { return (getAssociatedObject(key: &FetchKeys.requestID) as? DKImageRequestID) ?? DKImageInvalidRequestID }
        set { setAssociatedObject(key: &FetchKeys.requestID, value: newValue) }
    }

    
}
