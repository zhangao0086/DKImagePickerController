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
    
    /**
     Fetch an image with the specific size.
     */
    @objc public func fetchImage(with size: CGSize,
                                 options: PHImageRequestOptions? = nil,
                                 contentMode: PHImageContentMode = .aspectFit,
                                 completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
        if let _ = self.originalAsset {
            self.requestID = getImageDataManager().fetchImage(for: self, size: size, options: options, contentMode: contentMode, completeBlock: completeBlock)
        } else {
            completeBlock(self.image, nil)
        }
    }
    
    /**
     Fetch an image with the current screen size.
     */
    @objc public func fetchFullScreenImage(completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
        if let (image, info) = self.fullScreenImage {
            completeBlock(image, info)
        } else if self.originalAsset == nil {
            completeBlock(self.image, nil)
        } else {
            let screenSize = UIScreen.main.bounds.size
            
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            
            self.requestID = getImageDataManager().fetchImage(for: self, size: screenSize.toPixel(), options: options, contentMode: .aspectFit) { [weak self] image, info in
                guard let strongSelf = self else { return }
                
                strongSelf.fullScreenImage = (image, info)
                completeBlock(image, info)
            }
        }
    }
    
    /**
     Fetch an image with the original size.
     */
    @objc public func fetchOriginalImage(options: PHImageRequestOptions? = nil, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
        if let _ = self.originalAsset {
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
     */
    @objc public func fetchImageData(options: PHImageRequestOptions? = nil, completeBlock: @escaping (_ imageData: Data?, _ info: [AnyHashable: Any]?) -> Void) {
        self.requestID = getImageDataManager().fetchImageData(for: self, options: options, completeBlock: completeBlock)
    }
    
    /**
     Fetch an AVAsset with a completeBlock and PHVideoRequestOptions.
     */
    @objc public func fetchAVAsset(options: PHVideoRequestOptions? = nil, completeBlock: @escaping (_ AVAsset: AVAsset?, _ info: [AnyHashable: Any]?) -> Void) {
        self.requestID = getImageDataManager().fetchAVAsset(for: self, options: options, completeBlock: completeBlock)
    }

    @objc public func cancelCurrentRequest() {
        if self.requestID != DKImageInvalidRequestID {
            getImageDataManager().cancelRequest(requestID: self.requestID)
            self.requestID = DKImageInvalidRequestID
        }
    }
    
    // MARK: - Private
    
    private struct FetchKeys {
        static fileprivate var requestID: UInt8 = 0
        static fileprivate var fullScreenImage: UInt8 = 0
    }
    
    private var requestID: DKImageRequestID {
        get { return (getAssociatedObject(key: &FetchKeys.requestID) as? DKImageRequestID) ?? DKImageInvalidRequestID }
        set { setAssociatedObject(key: &FetchKeys.requestID, value: newValue) }
    }

    public private(set) var fullScreenImage: (image: UIImage?, info: [AnyHashable: Any]?)? {
        
        get { return getAssociatedObject(key: &FetchKeys.fullScreenImage) as? (image: UIImage?, info: [AnyHashable: Any]?) }
        set { setAssociatedObject(key: &FetchKeys.fullScreenImage, value: newValue) }
    }
    
}
