//
//  DKAsset.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 15/12/13.
//  Copyright © 2015年 ZhangAo. All rights reserved.
//

import Photos

public extension CGSize {
	
	public func toPixel() -> CGSize {
		let scale = UIScreen.mainScreen().scale
		return CGSize(width: self.width * scale, height: self.height * scale)
	}
}

/**
* An `DKAsset` object represents a photo or a video managed by the `DKImagePickerController`.
*/
public class DKAsset: NSObject {
	
	private var fullScreenImage: UIImage?
	private var originalImage: UIImage?
	
	/// The url uniquely identifies an asset that is an image or a video.
	//    public private(set) var url: NSURL?
	
	/// The asset's creation date.
	public private(set) lazy var createDate: NSDate? = {
		//		if let originalAsset = self.originalAsset {
		//			return originalAsset.valueForProperty(ALAssetPropertyDate) as? NSDate
		//		}
		return nil
	}()
	
	/// When the asset was an image, it's false. Otherwise true.
	public private(set) var isVideo: Bool = false
	
	/// play time duration(seconds) of a video.
	public private(set) var duration: Double?
	
	internal var isFromCamera: Bool = false
	public private(set) var originalAsset: PHAsset?
	
	/// The source data of the asset.
	public private(set) lazy var rawData: NSData? = {
		//		if let rep = self.originalAsset?.defaultRepresentation() {
		//			let sizeOfRawDataInBytes = Int(rep.size())
		//			let rawData = NSMutableData(length: sizeOfRawDataInBytes)!
		//			let bufferPtr = rawData.mutableBytes
		//			let bufferPtr8 = UnsafeMutablePointer<UInt8>(bufferPtr)
		//
		//			rep.getBytes(bufferPtr8, fromOffset: 0, length: sizeOfRawDataInBytes, error: nil)
		//			return rawData
		//		}
		return nil
	}()
	
	init(originalAsset: PHAsset) {
		super.init()
		
		self.originalAsset = originalAsset
		
		let assetType = originalAsset.mediaType
		if assetType == .Video {
			let duration = originalAsset.duration
			
			self.isVideo = true
			self.duration = duration
		}
	}
	
	internal init(image: UIImage) {
		super.init()
		
		self.isFromCamera = true
		self.fullScreenImage = image
		self.originalImage = image
	}
	
	override public func isEqual(object: AnyObject?) -> Bool {
		let another = object as! DKAsset!
		
		if let localIdentifier = self.originalAsset?.localIdentifier,
			anotherLocalIdentifier = another.originalAsset?.localIdentifier {
				return localIdentifier.isEqual(anotherLocalIdentifier)
		} else {
			return false
		}
	}
	
	public func fetchImageWithSize(size: CGSize, completeBlock: (image: UIImage?) -> Void) {
		if self.isFromCamera {
			completeBlock(image:self.fullScreenImage)
		} else {
			DKImageManager.sharedInstance.fetchImageForAsset(self, size: size, completeBlock: completeBlock)
		}
	}
	
	public func fetchFullScreenImageWithCompleteBlock(completeBlock: (image: UIImage?) -> Void) {
		if let fullScreenImage = self.fullScreenImage {
			completeBlock(image: fullScreenImage)
		} else {
			DKImageManager.sharedInstance.fetchImageForAsset(self, size: UIScreen.mainScreen().bounds.size) { [weak self] image in
				guard let strongSelf = self else { return }
				
				strongSelf.fullScreenImage = image
				completeBlock(image: image)
			}
		}
	}
	
	public func fetchOriginalImageWithCompleteBlock(completeBlock: (image: UIImage?) -> Void) {
		if let originalImage = self.originalImage {
			completeBlock(image: originalImage)
		} else {
			DKImageManager.sharedInstance.fetchImageForAsset(self, size: PHImageManagerMaximumSize) { [weak self] image in
				guard let strongSelf = self else { return }
				
				strongSelf.originalImage = image
				completeBlock(image: image)
			}
		}
	}
	
	public func fetchAVAssetWithCompleteBlock(completeBlock: (avAsset: AVURLAsset?) -> Void) {
		DKImageManager.sharedInstance.fetchAVAsset(self, completeBlock: completeBlock)
	}
	
}
