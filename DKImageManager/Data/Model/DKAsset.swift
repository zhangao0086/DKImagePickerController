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

	/// Returns a UIImage that is appropriate for displaying full screen.
	private var fullScreenImage: (image: UIImage?, info: [NSObject : AnyObject]?)?
	
	/// Returns the original image.
	private var originalImage: (image: UIImage?, info: [NSObject : AnyObject]?)?
	
	/// When the asset was an image, it's false. Otherwise true.
	public private(set) var isVideo: Bool = false
	
	/// play time duration(seconds) of a video.
	public private(set) var duration: Double?
	
	public private(set) var originalAsset: PHAsset?
		
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
	
	private var image: UIImage?
	internal init(image: UIImage) {
		super.init()
		self.image = image
		self.fullScreenImage = (image, nil)
		self.originalImage = (image, nil)
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
	
	public func fetchImageWithSize(size: CGSize, completeBlock: (image: UIImage?, info: [NSObject : AnyObject]?) -> Void) {
		self.fetchImageWithSize(size, options: nil, completeBlock: completeBlock)
	}
	
	public func fetchImageWithSize(size: CGSize, options: PHImageRequestOptions?, completeBlock: (image: UIImage?, info: [NSObject : AnyObject]?) -> Void) {
		if let _ = self.originalAsset {
			getImageManager().fetchImageForAsset(self, size: size, options: options, completeBlock: completeBlock)
		} else {
			completeBlock(image: self.image!, info: nil)
		}
	}
	
	public func fetchFullScreenImageWithCompleteBlock(completeBlock: (image: UIImage?, info: [NSObject : AnyObject]?) -> Void) {
		if let (image, info) = self.fullScreenImage {
			completeBlock(image: image, info: info)
		} else {
			var screenSize = UIScreen.mainScreen().bounds.size
			if screenSize.width > screenSize.height {
				screenSize = CGSize(width: screenSize.height, height: screenSize.width)
			}
			getImageManager().fetchImageForAsset(self, size: screenSize, contentMode: .AspectFit) { [weak self] image, info in
				guard let strongSelf = self else { return }
				
				strongSelf.fullScreenImage = (image, info)
				completeBlock(image: image, info: info)
			}
		}
	}
	
	public func fetchOriginalImageWithCompleteBlock(completeBlock: (image: UIImage?, info: [NSObject : AnyObject]?) -> Void) {
		if let (image, info) = self.originalImage {
			completeBlock(image: image, info: info)
		} else {
			getImageManager().fetchImageForAsset(self, size: PHImageManagerMaximumSize) { [weak self] image, info in
				guard let strongSelf = self else { return }
				
				strongSelf.originalImage = (image, info)
				completeBlock(image: image, info: info)
			}
		}
	}
	
	public func fetchAVAssetWithCompleteBlock(completeBlock: (avAsset: AVURLAsset?) -> Void) {
		getImageManager().fetchAVAsset(self, completeBlock: completeBlock)
	}
	
}
