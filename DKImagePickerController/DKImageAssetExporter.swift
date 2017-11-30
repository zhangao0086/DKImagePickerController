//
//  DKImageAssetExporter.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/11/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import Foundation
import Photos

/// Purge disk on system UIApplicationWillTerminate notifications.
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
    case complete, cancelled
}

// The Error that describes the failure can be obtained from the error property of DKAsset.
@objc
public enum DKImageAssetExporterError: Int {
    case cancelled, exportFailed
}

@objc
public enum DKImageExportPresent : Int {
    case
    compatible, // A preset for converting HEIF formatted images to JPEG.
    current     // A preset for passing image data as-is to the client.
}

public let DKImageAssetExporterDomain = "DKImageAssetExporterDomain"

@objc
protocol DKImageAssetExporterObserver {
    
    @objc optional func exporterWillBeginExporting(exporter: DKImageAssetExporter, asset: DKAsset)
    
    /// The progress can be obtained from the DKAsset.
    @objc optional func exporterDidUpdateProgress(exporter: DKImageAssetExporter, asset: DKAsset)
    
    @objc optional func exporterDidEndExporting(exporter: DKImageAssetExporter, asset: DKAsset)
}

/*
 Configuration options for an DKImageAssetExporter.  When a exporter is created,
 a copy of the configuration object is made - you cannot modify the configuration
 of a exporter after it has been created.
 */
@objc
public class DKImageAssetExporterConfiguration: NSObject, NSCopying {
    
    @objc public var imageExportPreset = DKImageExportPresent.compatible
    
    /// videoExportPreset can be used to specify the transcoding quality for videos (via a AVAssetExportPreset* string).
    @objc public var videoExportPreset = AVAssetExportPresetHighestQuality
    
    #if swift(>=4.0)
    @objc public var avOutputFileType = AVFileType.mov
    #else
    @objc public var avOutputFileType = AVFileTypeQuickTimeMovie
    #endif
    
    @objc public var exportDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("DKImageAssetExporter")
    
    public required override init() {
        super.init()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init()
        copy.imageExportPreset = self.imageExportPreset
        copy.videoExportPreset = self.videoExportPreset
        copy.avOutputFileType = self.avOutputFileType
        copy.exportDirectory = self.exportDirectory
        
        return copy
    }
}

/*
 This exporter is able to export DKAsset (PHAsset) from album (or iCloud) to app's tmp directory
 and it will automatically cleanup when appropriate.
 */
@objc
open class DKImageAssetExporter: DKBaseManager {
    
    static public let sharedInstance = DKImageAssetExporter(configuration: DKImageAssetExporterConfiguration())

    private let configuration: DKImageAssetExporterConfiguration
    
    private var exportQueue: OperationQueue = {
        let exportQueue = OperationQueue()
        exportQueue.name = "DKImageAssetExporter_exportQueue"
        exportQueue.maxConcurrentOperationCount = 1
        return exportQueue
    }()
    
    private let semaphore = DispatchSemaphore(value: 1)
    
    private weak var currentAVExportSession: AVAssetExportSession?
    private var requestIDs = [DKImageRequestID : Int]()
    private var isCancelled = false
    
    public init(configuration: DKImageAssetExporterConfiguration) {
        self.configuration = configuration.copy() as! DKImageAssetExporterConfiguration
        
        super.init()
    }
    
    /// This method starts an asynchronous export operation of a batch of asset.
    @objc public func exportAssetsAsynchronously(assets: [DKAsset], completion: @escaping ((DKImageAssetExportResult) -> Void)) {
        guard assets.count > 0 else {
            return completion(.complete)
        }
        
        var operationVisitor = [Operation]()
        
        let operation = BlockOperation {
            self.semaphore.wait()
            
            self.isCancelled = false
            let operation = operationVisitor.popLast()!
            
            var success = true
            var exportedCount = 0
            
            let exportCompletionBlock: (DKAsset, Error?) -> Void = { asset, error in
                exportedCount += 1
                
                defer {
                    if exportedCount == assets.count {
                        self.removeAllRequests()
                        self.semaphore.signal()
                        
                        DispatchQueue.main.async {
                            completion(operation.isCancelled ? .cancelled : .complete)
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
                
                if operation.isCancelled {
                    exportCompletionBlock(asset, self.makeCancelledError())
                    continue
                }
                
                asset.localTemporaryPath = self.generateTemporaryPath(with: asset)
                asset.error = nil
                
                if let localTemporaryPath = asset.localTemporaryPath, FileManager.default.fileExists(atPath: localTemporaryPath.path) {
                    exportCompletionBlock(asset, nil)
                    continue
                }
                
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
        self.currentAVExportSession?.cancelExport()
        self.cancelAllRequests()
    }
    
    // MARK: - Private
    
    private func cancelAllRequests() {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        self.isCancelled = true
        for (requestID, _) in requestIDs {
            getImageDataManager().cancelRequest(requestID: requestID)
        }
        self.requestIDs.removeAll()
    }
    
    private func add(requestID: DKImageRequestID) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if self.isCancelled {
            getImageDataManager().cancelRequest(requestID: requestID)
        } else {
            self.requestIDs[requestID] = 1
        }
    }
    
    private func removeAllRequests() {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        self.requestIDs.removeAll()
    }
    
    private func makeCancelledError() -> Error {
        return NSError(domain: DKImageAssetExporterDomain,
                       code: DKImageAssetExporterError.cancelled.rawValue,
                       userInfo: [NSLocalizedDescriptionKey : "The operation was cancelled."])
    }
    
    private func isHEIC(with imageData: Data) -> Bool {
        if imageData.count >= 12, let firstByte = imageData.first, firstByte == 0 {
            let subdata = imageData.subdata(in: Range(4..<12))
            let str = String(data: subdata, encoding: .ascii)
            return str == "ftypheic" || str == "ftypheix" || str == "ftyphevc" || str == "ftyphevx"
        } else {
            return false
        }
    }
    
    private func imageToJPEG(with image: UIImage) -> Data? {
        return UIImageJPEGRepresentation(image, 0.9)
    }
    
    private func generateTemporaryPath(with asset: DKAsset) -> URL {
        var fileName: String!
        if let originalAsset = asset.originalAsset {
            let localIdentifier = originalAsset.localIdentifier
            fileName = localIdentifier.data(using: .utf8)?.base64EncodedString()
            
            if let modificationDate = originalAsset.modificationDate {
                fileName = fileName + String(modificationDate.timeIntervalSinceReferenceDate)
            }
            
            if asset.type == .photo {
                fileName = fileName + String(self.configuration.imageExportPreset.rawValue)
            } else {
                fileName = fileName + self.configuration.videoExportPreset + self.configuration.avOutputFileType.rawValue
            }
        } else {
            fileName = "\(Date().timeIntervalSince1970)"
        }
        
        if !FileManager.default.fileExists(atPath: self.configuration.exportDirectory.path) {
            try? FileManager.default.createDirectory(at: self.configuration.exportDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        DKImageAssetDiskPurger.sharedInstance.addDirectory(self.configuration.exportDirectory)
        
        return self.configuration.exportDirectory.appendingPathComponent(fileName)
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
                
                let requestID = getImageDataManager().fetchImageData(for: asset, options: options, completeBlock: { (data, info) in
                    DKImageAssetExporter.ioQueue.async {
                        if var imageData = data {
                            if let info = info, let fileURL = info["PHImageFileURLKey"] as? NSURL {
                                asset.fileName = fileURL.lastPathComponent
                            }
                            
                            let image = UIImage(data: imageData)
                            if let image = image {
                                asset.width = Float(image.size.width)
                                asset.height = Float(image.size.height)
                            }
                            
                            if FileManager.default.fileExists(atPath: asset.localTemporaryPath!.path) {
                                return completion(nil)
                            }
                            
                            if  let image = image
                                , self.configuration.imageExportPreset == .compatible
                                , self.isHEIC(with: imageData) {
                                imageData = self.imageToJPEG(with: image) ?? imageData
                            }
                            
                            do {
                                try imageData.write(to: asset.localTemporaryPath!, options: [.atomic])
                                completion(nil)
                            } catch {
                                completion(error)
                            }
                        } else {
                            if let info = info, let isCancelled = info[PHImageCancelledKey] as? NSNumber, isCancelled.boolValue {
                                completion(self.makeCancelledError())
                            } else {
                                completion(NSError(domain: DKImageAssetExporterDomain,
                                                   code: DKImageAssetExporterError.exportFailed.rawValue,
                                                   userInfo: [NSLocalizedDescriptionKey : "Failed to fetch image data."]))
                            }
                        }
                    }
                })
                self.add(requestID: requestID)
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
        
        let requestID = getImageDataManager().fetchAVAsset(for: asset, options: options) { (avAsset, info) in
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
                    let group = DispatchGroup()
                    group.enter()
                    
                    if avAsset.isExportable, let exportSession = AVAssetExportSession(asset: avAsset, presetName: self.configuration.videoExportPreset) {
                        let fileManager = FileManager.default
                        let tempFilePath = asset.localTemporaryPath!.path + "~"
                        let tempFile = URL(fileURLWithPath: tempFilePath)
                        if fileManager.fileExists(atPath: tempFilePath) {
                            try? fileManager.removeItem(at: tempFile)
                        }
                        
                        exportSession.outputFileType = self.configuration.avOutputFileType
                        exportSession.outputURL = tempFile
                        exportSession.shouldOptimizeForNetworkUse = true
                        exportSession.exportAsynchronously(completionHandler: {
                            group.leave()
                                                        
                            switch (exportSession.status) {
                            case .completed:
                                try! fileManager.moveItem(at: tempFile, to: asset.localTemporaryPath!)
                                completion(nil)
                            case .cancelled:
                                completion(self.makeCancelledError())
                            case .failed:
                                completion(exportSession.error)
                            default:
                                assert(false)
                            }
                            
                            try? fileManager.removeItem(at: tempFile)
                        })
                        
                        self.currentAVExportSession = exportSession
                        
                        self.waitForExportToFinish(exportSession: exportSession, group: group) { p in
                            progress(p)
                        }
                    } else {
                        if let info = info, let isCancelled = info[PHImageCancelledKey] as? NSNumber, isCancelled.boolValue {
                            completion(self.makeCancelledError())
                        } else {
                            completion(NSError(domain: DKImageAssetExporterDomain,
                                               code: DKImageAssetExporterError.exportFailed.rawValue,
                                               userInfo: [NSLocalizedDescriptionKey : "Can't setup AVAssetExportSession."]))
                        }
                    }
                }
            } else {
                completion(NSError(domain: DKImageAssetExporterDomain,
                                   code: DKImageAssetExporterError.exportFailed.rawValue,
                                   userInfo: [NSLocalizedDescriptionKey : "Failed to fetch AVAsset."]))
            }
        }
        self.add(requestID: requestID)
    }
    
    private func waitForExportToFinish(exportSession: AVAssetExportSession, group: DispatchGroup, progress: (Double) -> Void) {
        while exportSession.status == .waiting || exportSession.status == .exporting {
            let _ = group.wait(timeout: .now() + .milliseconds(500))
            progress(Double(exportSession.progress))
        }
        progress(1.0)
    }
}
