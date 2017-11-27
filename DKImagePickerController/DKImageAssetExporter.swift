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

@objc
public enum DKImageAssetExportResult: Int {
    case complete, canceled
}

public let DKImageAssetExporterDomain = "DKImageAssetExporterDomain"

@objc
public enum DKImageAssetExporterError: Int {
    
    case canceled, exportFailed
}

@objc
protocol DKImageAssetExporterObserver {
    
    @objc optional func exporterWillBeginExporting(exporter: DKImageAssetExporter, asset: DKAsset)
    
    @objc optional func exporterDidUpdateProgress(exporter: DKImageAssetExporter, asset: DKAsset)
    
    @objc optional func exporterDidEndExporting(exporter: DKImageAssetExporter, asset: DKAsset)
}

@objc
public class DKImageAssetExporter: DKBaseManager {
    
    static public let sharedInstance = DKImageAssetExporter()
    
    public var presetName = AVAssetExportPresetPassthrough
    
    #if swift(>=4.0)
    public var outputFileType = AVFileType.mov
    #else
    public var outputFileType = AVFileTypeQuickTimeMovie
    #endif
    
    public var exportDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("DKImageAssetExporter")
    
    private var exportQueue: OperationQueue = {
        let exportQueue = OperationQueue()
        exportQueue.name = "DKImageAssetExporter_exportQueue"
        exportQueue.maxConcurrentOperationCount = 1
        return exportQueue
    }()
    
    public func exportAssetsAsynchronously(assets: [DKAsset], completion: @escaping ((DKImageAssetExportResult) -> Void)) {
        var operationVisitor = [Operation]()
        
        let operation = BlockOperation {
            objc_sync_enter(self)
            let operation = operationVisitor.first!
            
            var success = true
            var exportedCount = 0
            
            let exportCompletionBlock: (DKAsset, Error?) -> Void = { asset, error in
                exportedCount += 1
                
                defer {
                    if exportedCount == assets.count {
                        objc_sync_exit(self)
                        
                        DispatchQueue.main.async {
                            completion(operation.isCancelled ? .canceled : .complete)
                        }
                    }
                }
                
                if let error = error as NSError? {
                    success = false
                    asset.error = error
                    
                    asset.localTemporaryPath = nil
                } else {
                    defer {
                        self.notify(with: #selector(DKImageAssetExporterObserver.exporterDidEndExporting(exporter:asset:)), object: self, objectTwo: asset)
                    }
                    
                    do {
                        let attributes = try FileManager.default.attributesOfItem(atPath: asset.localTemporaryPath!.path)
                        asset.fileSize = (attributes[FileAttributeKey.size] as! NSNumber).uintValue
                    } catch let error as NSError {
                        success = false
                        asset.error = error
                        
                        asset.localTemporaryPath = nil
                    }
                }
            }
            
            for i in 0..<assets.count {
                let asset = assets[i]
                
                if asset.localTemporaryPath != nil {
                    exportCompletionBlock(asset, NSError(domain: DKImageAssetExporterDomain,
                                                         code: DKImageAssetExporterError.canceled.rawValue,
                                                         userInfo: [NSLocalizedDescriptionKey : "The operation was canceled."]))
                    continue
                }
                
                if operation.isCancelled {
                    exportCompletionBlock(asset, nil)
                    continue
                }
                
                asset.localTemporaryPath = self.generateTemporaryPath(with: asset)
                asset.error = nil
                
                asset.progress = 0.0
                self.notify(with: #selector(DKImageAssetExporterObserver.exporterWillBeginExporting(exporter:asset:)), object: self, objectTwo: asset)
                
                self.exportAsset(with: asset, progress: { progress in
                    asset.progress = progress
                    
                    self.notify(with: #selector(DKImageAssetExporterObserver.exporterDidUpdateProgress(exporter:asset:)), object: self, objectTwo: asset)
                }, completion: { error in
                    exportCompletionBlock(asset, error)
                })
                
            }
        }
        
        operationVisitor.append(operation)
        self.exportQueue.addOperation(operation)
    }
    
    public func cancelAll() {
        self.exportQueue.cancelAllOperations()
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
    
    private func exportAsset(with asset: DKAsset, progress: @escaping (Double) -> Void, completion: @escaping (Error?) -> Void) {
        switch asset.type {
        case .photo:
            self.exportImage(with: asset, progress: progress, completion: completion)
        case .video:
            self.exportAVAsset(with: asset, progress: progress, completion: completion)
        }
    }
    
    private func exportImage(with asset: DKAsset, progress: @escaping (Double) -> Void, completion: @escaping (Error?) -> Void) {
        if let _ = asset.originalAsset {
            autoreleasepool {
                let options = PHImageRequestOptions()
                options.version = .current
                options.progressHandler = { (p, _, _, _) in
                    progress(p)
                }
                
                getImageDataManager().fetchImageData(for: asset, options: options, completeBlock: { (data, info) in
                    if let imageData = data {
                        if let info = info, let fileURL = info["PHImageFileURLKey"] as? NSURL {
                            asset.fileName = fileURL.lastPathComponent
                        }
                        
                        if let image = UIImage(data: imageData) {
                            asset.width = Float(image.size.width)
                            asset.height = Float(image.size.height)
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
    
    private func exportAVAsset(with asset: DKAsset, progress: @escaping (Double) -> Void, completion: @escaping (Error?) -> Void) {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .mediumQualityFormat
        options.progressHandler = { (p, _, _, _) in
            progress(p)
        }
        
        getImageDataManager().fetchAVAsset(for: asset, options: options) { (avAsset, _) in
            if let avAsset = avAsset {
                if let avURLAsset = avAsset as? AVURLAsset {
                    asset.fileName = avURLAsset.url.lastPathComponent
                } else {
                    asset.fileName = asset.localIdentifier
                }
                
                #if swift(>=4.0)
                if let track = avAsset.tracks(withMediaType: .video).first {
                    let size = __CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform)
                    asset.width = Float(size.width)
                    asset.height = Float(size.height)
                }
                #else
                if let track = avAsset.tracks(withMediaType: AVMediaTypeVideo).first {
                    let size = __CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform)
                    asset.width = Float(size.width)
                    asset.height = Float(size.height)
                }
                #endif
                
                DKImageAssetExporter.ioQueue.async {
                    if avAsset.isExportable, let exportSession = AVAssetExportSession(asset: avAsset, presetName: self.presetName) {
                        exportSession.outputFileType = self.outputFileType
                        exportSession.outputURL = asset.localTemporaryPath!
                        exportSession.shouldOptimizeForNetworkUse = true
                        exportSession.exportAsynchronously(completionHandler: {
                            completion(exportSession.error)
                        })
                    } else {
                        completion(NSError(domain: DKImageAssetExporterDomain,
                                           code: DKImageAssetExporterError.exportFailed.rawValue,
                                           userInfo: [NSLocalizedDescriptionKey : "Can't setup AVAssetExportSession."]))
                    }
                }
            } else {
                completion(NSError(domain: DKImageAssetExporterDomain,
                                   code: DKImageAssetExporterError.exportFailed.rawValue,
                                   userInfo: [NSLocalizedDescriptionKey : "Failed to fetch AVAsset."]))
            }
        }
    }
}
