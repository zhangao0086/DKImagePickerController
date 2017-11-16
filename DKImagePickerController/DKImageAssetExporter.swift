//
//  DKImageAssetExporter.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/11/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import Foundation
import Photos

fileprivate class DKImageAssetDiskPurger {
    
    static let sharedInstance = DKImageAssetDiskPurger()
    
    private var directories = Set<URL>()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(removeFiles), name: .UIApplicationWillTerminate, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func addDirectory(_ directory: URL) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        self.directories.insert(directory)
    }
    
    // MARK: - Private
    
    @objc private func removeFiles() {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        let manager = FileManager.default
        for directory in self.directories {
            if let contents = try? manager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
                for URL in contents {
                    try? manager.removeItem(at: URL)
                }
            }
        }
        
        self.directories.removeAll()
    }
}

/////////////////////////////////////////////////////////////////////////////

public class DKImageAssetExporter {
    
    public var presetName = AVAssetExportPresetPassthrough
    public var outputFileType = AVFileType.mov
    public var exportDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("DKImageAssetExporter")
    
    public func exportAssetsAsynchronously(assets: [DKAsset], completion: @escaping ((Error?) -> Void)) {
        DispatchQueue.global().async {
            var exportError: NSError?
            var exportedCount = 0
            
            let exportCompletionBlock: (DKAsset, Error?) -> Void = { asset, error in
                exportedCount += 1
                
                defer {
                    if exportedCount == assets.count {
                        DispatchQueue.main.async {
                            completion(exportError)
                        }
                    }
                }
                
                if let error = error as NSError? {
                    exportError = error
                    
                    asset.localTemporaryPath = nil
                } else {
                    do {
                        let attributes = try FileManager.default.attributesOfItem(atPath: asset.localTemporaryPath!.path)
                        asset.fileSize = (attributes[FileAttributeKey.size] as! NSNumber).uintValue
                    } catch let error as NSError {
                        exportError = error
                        
                        asset.localTemporaryPath = nil
                    }
                }
            }
            
            for i in 0..<assets.count {
                let asset = assets[i]
                
                if asset.localTemporaryPath != nil {
                    exportCompletionBlock(asset, nil)
                    continue
                }
                
                asset.localTemporaryPath = self.generateTemporaryPath(with: asset)
                
                self.exportAsset(with: asset, completion: { error in
                    exportCompletionBlock(asset, error)
                })
            }
        }
    }
    
    // MARK: - Private
    
    private func generateTemporaryPath(with asset: DKAsset) -> URL {
        var fileName: String!
        if let originalAsset = asset.originalAsset {
            let localIdentifier = originalAsset.localIdentifier
            fileName = localIdentifier.data(using: .utf8)?.base64EncodedString()
        } else {
            fileName = "\(Date().timeIntervalSince1970)"
        }
        
        if !FileManager.default.fileExists(atPath: self.exportDirectory.path) {
            try? FileManager.default.createDirectory(at: self.exportDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        DKImageAssetDiskPurger.sharedInstance.addDirectory(self.exportDirectory)
        
        return self.exportDirectory.appendingPathComponent(fileName)
    }
    
    static let ioQueue = DispatchQueue(label: "DKPhotoImagePreviewVC.ioQueue")
    
    private func exportAsset(with asset: DKAsset, completion: @escaping (Error?) -> Void) {
        switch asset.type {
        case .photo:
            self.exportImage(with: asset, completion: completion)
        case .video:
            self.exportAsset(with: asset, completion: completion)
        }
    }
    
    private func exportImage(with asset: DKAsset, completion: @escaping (Error?) -> Void) {
        if let _ = asset.originalAsset {
            autoreleasepool {
                let options = PHImageRequestOptions()
                options.version = .current
                
                getImageDataManager().fetchImageData(for: asset, options: options, completeBlock: { (data, info) in
                    if let imageData = data {
                        if let info = info, let fileURL = info["PHImageFileURLKey"] as? NSURL {
                            asset.fileName = fileURL.lastPathComponent
                        }
                        
                        if let image = UIImage(data: imageData) {
                            asset.width = image.size.width
                            asset.height = image.size.height
                        }
                        
                        if FileManager.default.fileExists(atPath: asset.localTemporaryPath!.path) {
                            return completion(nil)
                        }
                        
                        DKImageAssetExporter.ioQueue.async {
                            do {
                                try imageData.write(to: asset.localTemporaryPath!, options: [.atomic])
                                completion(nil)
                            } catch {
                                completion(error)
                            }
                        }
                    } else {
                        completion(nil)
                    }
                })
            }
        } else {
            DKImageAssetExporter.ioQueue.async {
                do {
                    try UIImageJPEGRepresentation(asset.image!, 0.9)!.write(to: asset.localTemporaryPath!)
                    completion(nil)
                } catch {
                    completion(error)
                }
            }
        }
    }
    
    private func exportAVAsset(with asset: DKAsset, completion: @escaping (Error?) -> Void) {
        getImageDataManager().fetchAVAsset(for: asset, completeBlock: { (avAsset, _) in
            if let avAsset = avAsset {
                if let avURLAsset = avAsset as? AVURLAsset {
                    asset.fileName = avURLAsset.url.lastPathComponent
                } else {
                    asset.fileName = asset.localIdentifier
                }
                
                if let track = avAsset.tracks(withMediaType: .video).first {
                    let size = __CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform)
                    asset.width = size.width
                    asset.height = size.height
                }
                
                DKImageAssetExporter.ioQueue.async {
                    if avAsset.isExportable, let exportSession = AVAssetExportSession(asset: avAsset, presetName: self.presetName) {
                        exportSession.outputFileType = self.outputFileType
                        exportSession.outputURL = asset.localTemporaryPath!
                        exportSession.shouldOptimizeForNetworkUse = true
                        exportSession.exportAsynchronously(completionHandler: {
                            completion(exportSession.error)
                        })
                    } else {
                        completion(NSError(domain: AVFoundationErrorDomain,
                                           code: AVError.exportFailed.rawValue,
                                           userInfo: nil))
                    }
                }
            } else {
                completion(NSError(domain: AVFoundationErrorDomain,
                                   code: AVError.exportFailed.rawValue,
                                   userInfo: nil))
            }
        })
    }
}
