//
//  DKPhotoImagePreviewVC.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 08/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import SDWebImage
import Photos
import MobileCoreServices

protocol DKPhotoImageDownloader {
    
    static func downloader() -> DKPhotoImageDownloader
    
    func downloadImage(with identifier: Any, progressBlock: ((_ progress: Float) -> Void)?,
                       completeBlock: @escaping ((_ image: UIImage?, _ data: Data?,  _ error: Error?) -> Void))
    
}

class DKPhotoImageWebDownloader: DKPhotoImageDownloader {
    
    private static let shared = DKPhotoImageWebDownloader()
    
    static func downloader() -> DKPhotoImageDownloader {
        return shared
    }
    
    var _downloader: SDWebImageDownloader = {
        let downloader = SDWebImageDownloader()
        downloader.executionOrder = .lifoExecutionOrder
        
        return downloader
    }()
    
    func downloadImage(with identifier: Any, progressBlock: ((Float) -> Void)?,
                       completeBlock: @escaping ((UIImage?, Data?, Error?) -> Void)) {
        if let URL = identifier as? URL {
            self._downloader.downloadImage(with: URL,
                                           options: .highPriority,
                                           progress: { (receivedSize, expectedSize, targetURL) in
                                            if let progressBlock = progressBlock {
                                                progressBlock(Float(receivedSize) / Float(expectedSize))
                                            }
            }, completed: { (image, data, error, finished) in
                if (image != nil || data != nil) && finished {
                    completeBlock(image, data, error)
                } else {
                    let error = NSError(domain: Bundle.main.bundleIdentifier!, code: -1, userInfo: [
                        NSLocalizedDescriptionKey : "获取图片失败"
                        ])
                    completeBlock(nil, nil, error)
                }
            })
        } else {
            assertionFailure()
        }
    }
    
}

class DKPhotoImageAssetDownloader: DKPhotoImageDownloader {
    
    private static let shared = DKPhotoImageAssetDownloader()
    
    static func downloader() -> DKPhotoImageDownloader {
        return shared
    }
    
    func downloadImage(with identifier: Any, progressBlock: ((Float) -> Void)?,
                       completeBlock: @escaping ((UIImage?, Data?, Error?) -> Void)) {
        if let asset = identifier as? PHAsset {
            let options = PHImageRequestOptions()
            options.resizeMode = .exact
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            if let progressBlock = progressBlock {
                options.progressHandler = { (progress, error, stop, info) in
                    if progress > 0 {
                        progressBlock(Float(progress))
                    }
                }
            }
            
            let isGif = (asset.value(forKey: "uniformTypeIdentifier") as? String) == (kUTTypeGIF as String)
            if isGif {
                PHImageManager.default().requestImageData(for: asset,
                                                          options: options,
                                                          resultHandler: { (data, _, _, info) in
                                                            if let data = data {
                                                                completeBlock(nil, data, nil)
                                                            } else {
                                                                let error = NSError(domain: Bundle.main.bundleIdentifier!, code: -1, userInfo: [
                                                                    NSLocalizedDescriptionKey : "获取图片失败"
                                                                    ])
                                                                completeBlock(nil, nil, error)
                                                            }
                })
            } else {
                PHImageManager.default().requestImage(for: asset,
                                                      targetSize: CGSize(width: UIScreen.main.bounds.width * UIScreen.main.scale, height:UIScreen.main.bounds.height * UIScreen.main.scale),
                                                      contentMode: .default,
                                                      options: options,
                                                      resultHandler: { (image, info) in
                                                        if let image = image {
                                                            completeBlock(image, nil, nil)
                                                        } else {
                                                            let error = NSError(domain: Bundle.main.bundleIdentifier!, code: -1, userInfo: [
                                                                NSLocalizedDescriptionKey : "获取图片失败"
                                                                ])
                                                            completeBlock(nil, nil, error)
                                                        }
                })
            }
        } else {
            assertionFailure()
        }
    }
    
}

////////////////////////////////////////////////////////////////////////

class DKPhotoImagePreviewVC: DKPhotoBaseImagePreviewVC {

    private var image: UIImage?
    private var downloadURL: URL?
    private var asset: PHAsset?
    
    private var reuseIdentifier: Int? // hash
    
    private let downloadOriginalImageButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.downloadOriginalImageButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.downloadOriginalImageButton.layer.borderWidth = 1
        self.downloadOriginalImageButton.layer.borderColor = UIColor(red: 0.47, green: 0.45, blue: 0.45, alpha: 1).cgColor
        self.downloadOriginalImageButton.layer.cornerRadius = 2
        self.downloadOriginalImageButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        self.downloadOriginalImageButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        self.downloadOriginalImageButton.addTarget(self, action: #selector(downloadOriginalImage), for: .touchUpInside)
        self.view.addSubview(self.downloadOriginalImageButton)
    }
    
    @objc private func downloadOriginalImage() {
        if let extraInfo = self.item.extraInfo, let originalURL = extraInfo[DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalURL] as? URL {
            self.downloadOriginalImageButton.isEnabled = false

            let reuseIdentifier = self.reuseIdentifier
            
            self.downloadImage(with: originalURL, progressBlock: { [weak self] (progress) in
                guard reuseIdentifier == self?.reuseIdentifier else { return }
                
                DispatchQueue.main.async {
                    self?.updateDownloadOriginalButton(with: progress)
                }
            }, completeBlock: { [weak self] (data, error) in
                guard reuseIdentifier == self?.reuseIdentifier else { return }
                
                if error == nil {
                    self?.setNeedsUpdateContent()
                    self?.downloadOriginalImageButton.isHidden = true
                } else {
                    self?.downloadOriginalImageButton.isEnabled = true
                    self?.updateDownloadOriginalButtonTitle()
                }
            })
        }
    }
    
    private func updateDownloadOriginalButtonTitle() {
        if let extraInfo = self.item.extraInfo, let fileSize = extraInfo[DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalSize] as? UInt {
            self.downloadOriginalImageButton.setTitle("下载原图(\(self.formattedFileSize(fileSize)))", for: .normal)
        } else {
            self.downloadOriginalImageButton.setTitle("下载原图", for: .normal)
        }
        self.updateDownloadOriginalButtonFrame()
    }
    
    private func updateDownloadOriginalButton(with progress: Float) {
        if progress > 0 {
            self.downloadOriginalImageButton.setTitle(String(format: "%.0f%%", progress * 100), for: .normal)
            self.updateDownloadOriginalButtonFrame()
        }
    }
    
    private func updateDownloadOriginalButtonFrame() {
        self.downloadOriginalImageButton.sizeToFit()
        
        let buttonWidth = max(100, self.downloadOriginalImageButton.bounds.width)
        let buttonHeight = CGFloat(25)
        
        self.downloadOriginalImageButton.frame = CGRect(x: (self.view.bounds.width - buttonWidth) / 2,
                                                        y: self.view.bounds.height - buttonHeight - 20,
                                                        width: buttonWidth,
                                                        height: buttonHeight)
    }
    
    private func formattedFileSize(_ fileSize: UInt) -> String {
        let tokens = ["B", "KB", "MB", "GB", "TB"]
        
        var convertedSize = Double(fileSize)
        var factor = 0
        
        while convertedSize > 1024 {
            convertedSize = convertedSize / 1024
            factor = factor + 1
        }
        
        if factor == 0 {
            return String(format: "%4.0f%@", convertedSize, tokens[factor])
        } else {
            return String(format: "%4.2f%@", convertedSize, tokens[factor])
        }
    }
    
    // MARK: - Fetch Image
    
    private func asyncFetchImage(with identifier: Any,
                                 progressBlock: @escaping ((_ progress: Float) -> Void),
                                 completeBlock: @escaping ((_ data: Any?, _ error: Error?) -> Void)) {
        if let downloadURL = identifier as? URL, downloadURL.isFileURL {
            self.asyncFetchLocalImage(with: downloadURL as URL, completeBlock: completeBlock)
        } else {
            self.downloadImage(with: identifier, progressBlock: progressBlock, completeBlock: completeBlock)
        }
    }
    
    static let ioQueue = DispatchQueue(label: "DKPhotoImagePreviewVC.ioQueue")
    private func asyncFetchLocalImage(with URL: URL, completeBlock: @escaping ((_ data: Any?, _ error: Error?) -> Void)) {
        DKPhotoImagePreviewVC.ioQueue.async {
            let key = URL.absoluteString
            
            var error: Error?
            var image = SDImageCache.shared().imageFromMemoryCache(forKey: key)
            
            if image == nil {
                if let compressedImage = UIImage(contentsOfFile: URL.path) {
                    image = self.decompressImage(with: compressedImage)
                    SDImageCache.shared().store(image, forKey: key, toDisk: false, completion: nil)
                } else {
                    error = NSError(domain: Bundle.main.bundleIdentifier!, code: -1, userInfo: [
                        NSLocalizedDescriptionKey : "获取图片失败"
                        ])
                }
            }
            
            completeBlock(image, error)
        }
    }
    
    private func downloadImage(with identifier: Any,
                               progressBlock: @escaping ((_ progress: Float) -> Void),
                               completeBlock: @escaping ((_ data: Any?, _ error: Error?) -> Void)) {
        var key = ""
        var downloader: DKPhotoImageDownloader! = nil
        if let URL = identifier as? URL {
            key = URL.absoluteString
            downloader = DKPhotoImageWebDownloader.downloader()
        } else if let asset = identifier as? PHAsset {
            key = asset.localIdentifier
            downloader = DKPhotoImageAssetDownloader.downloader()
        } else {
            assertionFailure()
        }
        
        SDImageCache.shared().queryCacheOperation(forKey: key) { (image, data, cacheType) in
            if image != nil || data != nil {
                completeBlock(image ?? data, nil)
            } else {
                downloader.downloadImage(with: identifier, progressBlock: { (progress) in
                    progressBlock(progress)
                }, completeBlock: { (image, data, error) in
                    if error == nil {
                        SDImageCache.shared().store(image, imageData: data, forKey: key, toDisk: true, completion: nil)
                        
                        completeBlock(image ?? data, nil)
                    } else {
                        completeBlock(nil, error)
                    }
                })
            }
        }
    }
    
    private func decompressImage(with image: UIImage) -> UIImage {
        guard let imageRef = image.cgImage else { return image }

        let width = imageRef.width
        let height = imageRef.height
        
        if width == 0 || height == 0 { return image }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return image }
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: CGFloat(-height))
        context.draw(imageRef, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let decompressedImageRef = context.makeImage() else { return image }
        
        return UIImage(cgImage: decompressedImageRef, scale: image.scale, orientation: image.imageOrientation)
    }
    
    // MARK: - DKPhotoBasePreviewDataSource
    
    override func photoPreviewWillAppear() {
        super.photoPreviewWillAppear()
        
        if let image = self.item.image {
            self.image = image
        } else if let _ = self.item.imageURL {
            self.downloadURL = self.item.imageURL
            self.reuseIdentifier = self.downloadURL?.hashValue
        } else if let asset = self.item.asset {
            self.asset = asset
            self.reuseIdentifier = asset.localIdentifier.hashValue
        } else {
            assertionFailure()
        }
    }
    
    override func fetchContent(withProgressBlock progressBlock: @escaping ((_ progress: Float) -> Void), completeBlock: @escaping ((_ data: Any?, _ error: Error?) -> Void)) {
        if let image = self.image {
            completeBlock(image, nil)
            return
        }
        
        let reuseIdentifier = self.reuseIdentifier
        
        let checkProgressBlock = { [weak self] (progress: Float) in
            guard reuseIdentifier == self?.reuseIdentifier else { return }
         
            DispatchQueue.main.async {
                progressBlock(progress)
            }
        }
        
        let checkCompleteBlock = { [weak self] (data: Any?, error: Error?) in
            guard reuseIdentifier == self?.reuseIdentifier else { return }
            
            DispatchQueue.main.async {
                completeBlock(data, error)
            }
        }
        
        if let _ = self.downloadURL {
            if let extraInfo = self.item.extraInfo, let originalURL = extraInfo[DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalURL] as? URL {
                SDImageCache.shared().queryCacheOperation(forKey: originalURL.absoluteString, done: { (image, data, _) in
                    if image != nil || data != nil {
                        self.downloadURL = originalURL
                    }
                    
                    self.asyncFetchImage(with: self.downloadURL!, progressBlock: checkProgressBlock, completeBlock: checkCompleteBlock)
                })
            } else {
                self.asyncFetchImage(with: self.downloadURL!, progressBlock: checkProgressBlock, completeBlock: checkCompleteBlock)
            }
        } else if let asset = self.asset {
            self.asyncFetchImage(with: asset, progressBlock: checkProgressBlock, completeBlock: checkCompleteBlock)
        } else {
            assertionFailure()
        }
    }
    
    override func updateContentView(with content: Any) {
        super.updateContentView(with: content)
        
        if let extraInfo = self.item.extraInfo, let originalURL = extraInfo[DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalURL] as? URL {
            if self.downloadURL == originalURL  {
                self.downloadOriginalImageButton.isHidden = true
            } else {
                let reuseIdentifier = self.reuseIdentifier
                SDImageCache.shared().queryCacheOperation(forKey: originalURL.absoluteString, done: { [weak self] (image, data, _) in
                    guard reuseIdentifier == self?.reuseIdentifier else { return }
                    
                    if image != nil || data != nil {
                        self?.downloadOriginalImageButton.isHidden = true
                    } else {
                        self?.updateDownloadOriginalButtonTitle()
                        self?.downloadOriginalImageButton.isEnabled = true
                        self?.downloadOriginalImageButton.isHidden = false
                    }
                })
            }
        } else {
            self.downloadOriginalImageButton.isHidden = true
        }
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        self.reuseIdentifier = nil
        self.downloadURL = nil
        self.image = nil
        self.asset = nil
        self.downloadOriginalImageButton.isHidden = true
    }
    
}
