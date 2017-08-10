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
		let scale = UIScreen.main.scale
		return CGSize(width: self.width * scale, height: self.height * scale)
	}
}

/**
 An `DKAsset` object represents a photo or a video managed by the `DKImagePickerController`.
 */
open class DKAsset: NSObject {

	/// Returns a UIImage that is appropriate for displaying full screen.
	private var fullScreenImage: (image: UIImage?, info: [AnyHashable: Any]?)?
	
	/// When the asset was an image, it's false. Otherwise true.
	open private(set) var isVideo: Bool = false
	
    /// Returns location, if its contained in original asser
    open private(set) var location: CLLocation?
    
	/// play time duration(seconds) of a video.
	open private(set) var duration: Double?
	
	open private(set) var originalAsset: PHAsset?
    
    open var localIdentifier: String
		
	public init(originalAsset: PHAsset) {
        self.localIdentifier = originalAsset.localIdentifier
        self.location = originalAsset.location
		super.init()
		
		self.originalAsset = originalAsset
		
		let assetType = originalAsset.mediaType
		if assetType == .video {
			self.isVideo = true
			self.duration = originalAsset.duration
		}
	}
	
	private var image: UIImage?
	internal init(image: UIImage) {
        self.localIdentifier = String(image.hash)
		super.init()
        
		self.image = image
		self.fullScreenImage = (image, nil)
	}
	
	override open func isEqual(_ object: Any?) -> Bool {
        if let another = object as? DKAsset {
            return self.localIdentifier == another.localIdentifier
        }
        return false
	}
	
	public func fetchImageWithSize(_ size: CGSize, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
		self.fetchImageWithSize(size, options: nil, completeBlock: completeBlock)
	}
	
	public func fetchImageWithSize(_ size: CGSize, options: PHImageRequestOptions?, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
		self.fetchImageWithSize(size, options: options, contentMode: .aspectFit, completeBlock: completeBlock)
	}
	
	public func fetchImageWithSize(_ size: CGSize, options: PHImageRequestOptions?, contentMode: PHImageContentMode, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
		if let _ = self.originalAsset {
			getImageManager().fetchImageForAsset(self, size: size, options: options, contentMode: contentMode, completeBlock: completeBlock)
		} else {
			completeBlock(self.image, nil)
		}
	}
	
	public func fetchFullScreenImageWithCompleteBlock(_ completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
		self.fetchFullScreenImage(false, completeBlock: completeBlock)
	}
	
	/**
     Fetch an image with the current screen size.
     
     - parameter sync:          If true, the method blocks the calling thread until image is ready or an error occurs.
     - parameter completeBlock: The block is executed when the image download is complete.
	*/
	public func fetchFullScreenImage(_ sync: Bool, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
		if let (image, info) = self.fullScreenImage {
			completeBlock(image, info)
		} else {
			let screenSize = UIScreen.main.bounds.size
			
			let options = PHImageRequestOptions()
			options.deliveryMode = .highQualityFormat
			options.resizeMode = .exact
			options.isSynchronous = sync

			getImageManager().fetchImageForAsset(self, size: screenSize.toPixel(), options: options, contentMode: .aspectFit) { [weak self] image, info in
				guard let strongSelf = self else { return }
				
				strongSelf.fullScreenImage = (image, info)
				completeBlock(image, info)
			}
		}
	}
	
	public func fetchOriginalImageWithCompleteBlock(_ completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
		self.fetchOriginalImage(false, completeBlock: completeBlock)
	}
	
	/**
     Fetch an image with the original size.
     
     - parameter sync:          If true, the method blocks the calling thread until image is ready or an error occurs.
     - parameter completeBlock: The block is executed when the image download is complete.
	*/
	public func fetchOriginalImage(_ sync: Bool, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
		let options = PHImageRequestOptions()
		options.version = .current
		options.isSynchronous = sync
		
		getImageManager().fetchImageDataForAsset(self, options: options, completeBlock: { (data, info) in
            var image: UIImage?
            if let data = data {
    			image = UIImage(data: data)
            }
			completeBlock(image, info)
		})
	}
    
    /**
     Fetch an image data with the original size.
     
     - parameter sync:          If true, the method blocks the calling thread until image is ready or an error occurs.
     - parameter completeBlock: The block is executed when the image download is complete.
     */
    public func fetchImageDataForAsset(_ sync: Bool, completeBlock: @escaping (_ imageData: Data?, _ info: [AnyHashable: Any]?) -> Void) {
        let options = PHImageRequestOptions()
        options.version = .current
        options.isSynchronous = sync
        
        getImageManager().fetchImageDataForAsset(self, options: options, completeBlock: { (data, info) in
            completeBlock(data, info)
        })
    }
	
    /**
     Fetch an AVAsset with a completeBlock.
	*/
	public func fetchAVAssetWithCompleteBlock(_ completeBlock: @escaping (_ AVAsset: AVAsset?, _ info: [AnyHashable: Any]?) -> Void) {
		self.fetchAVAsset(nil, completeBlock: completeBlock)
	}
	
    /**
     Fetch an AVAsset with a completeBlock and PHVideoRequestOptions.
     */
	public func fetchAVAsset(_ options: PHVideoRequestOptions?, completeBlock: @escaping (_ AVAsset: AVAsset?, _ info: [AnyHashable: Any]?) -> Void) {
		getImageManager().fetchAVAsset(self, options: options, completeBlock: completeBlock)
	}
	
    /**
     Sync fetch an AVAsset with a completeBlock and PHVideoRequestOptions.
     */
	public func fetchAVAsset(_ sync: Bool, options: PHVideoRequestOptions?, completeBlock: @escaping (_ AVAsset: AVAsset?, _ info: [AnyHashable: Any]?) -> Void) {
		if sync {
			let semaphore = DispatchSemaphore(value: 0)
			self.fetchAVAsset(options, completeBlock: { (AVAsset, info) -> Void in
				completeBlock(AVAsset, info)
				semaphore.signal()
			})
			_ = semaphore.wait(timeout: DispatchTime.distantFuture)
		} else {
			self.fetchAVAsset(options, completeBlock: completeBlock)
		}
	}
	
}

public extension DKAsset {
	
	struct DKAssetWriter {
		static let writeQueue: OperationQueue = {
			let queue = OperationQueue()
			queue.name = "DKAsset_Write_Queue"
			queue.maxConcurrentOperationCount = 5
			return queue
		}()
	}
	
	
    /**
     Writes the image in the receiver to the file specified by a given path.
     */
	public func writeImageToFile(_ path: String, completeBlock: @escaping (_ success: Bool) -> Void) {
		let options = PHImageRequestOptions()
		options.version = .current
		
		getImageManager().fetchImageDataForAsset(self, options: options, completeBlock: { (data, _) in
			DKAssetWriter.writeQueue.addOperation({
				if let imageData = data {
					try? imageData.write(to: URL(fileURLWithPath: path), options: [.atomic])
					completeBlock(true)
				} else {
					completeBlock(false)
				}
			})
		})
	}
	
    /**
     Writes the AV in the receiver to the file specified by a given path.
     
     - parameter presetName:        An NSString specifying the name of the preset template for the export. See AVAssetExportPresetXXX.
     - parameter outputFileType:    Type of file to export. Should be a valid media type, otherwise export will fail. See AVFileType.
     */
    public func writeAVToFile(_ path: String, presetName: String, outputFileType: String = AVFileTypeQuickTimeMovie, completeBlock: @escaping (_ success: Bool) -> Void) {
		self.fetchAVAsset(nil) { (avAsset, _) in
            DKAssetWriter.writeQueue.addOperation({
                if let avAsset = avAsset,
                    let exportSession = AVAssetExportSession(asset: avAsset, presetName: presetName) {
                    exportSession.outputFileType = outputFileType
                    exportSession.outputURL = URL(fileURLWithPath: path)
                    exportSession.shouldOptimizeForNetworkUse = true
                    exportSession.exportAsynchronously(completionHandler: {
                        completeBlock(exportSession.status == .completed ? true : false)
                    })
                } else {
                    completeBlock(false)
                }
            })
        }
    }
}

public extension AVAsset {
	
	public func calculateFileSize() -> Float {
		if let URLAsset = self as? AVURLAsset {
			var size: AnyObject?
			try! (URLAsset.url as NSURL).getResourceValue(&size, forKey: URLResourceKey.fileSizeKey)
			if let size = size as? NSNumber {
				return size.floatValue
			} else {
				return 0
			}
		} else if let _ = self as? AVComposition {
			var estimatedSize: Float = 0.0
			var duration: Float = 0.0
			for track in self.tracks {
				let rate = track.estimatedDataRate / 8.0
				let seconds = Float(CMTimeGetSeconds(track.timeRange.duration))
				duration += seconds
				estimatedSize += seconds * rate
			}
			return estimatedSize
		} else {
			return 0
		}
	}
    
}
