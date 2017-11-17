//
//  DKAsset+Export.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 17/11/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import Foundation

/**
 The following properties only available after exporting to local.
 */
extension DKAsset {
    
    struct Keys {
        static fileprivate var localTemporaryPath: UInt8 = 0
        static fileprivate var fileName: UInt8 = 0
        static fileprivate var fileSize: UInt8 = 0
        static fileprivate var width: UInt8 = 0
        static fileprivate var height: UInt8 = 0
        static fileprivate var progress: UInt8 = 0
        static fileprivate var error: UInt8 = 0
    }
    
    /// The exported file will be placed in this location.
    /// All exported files can be automatically cleaned by the DKImageAssetDiskPurger when appropriate.
    @objc public var localTemporaryPath: URL? {
        
        get { return getAssociatedObject(key: &Keys.localTemporaryPath) as? URL }
        set { setAssociatedObject(key: &Keys.localTemporaryPath, value: newValue) }
    }
    
    @objc public var fileName: String? {
        
        get { return getAssociatedObject(key: &Keys.fileName) as? String }
        set { setAssociatedObject(key: &Keys.fileName, value: newValue) }
    }
    
    /// Indicates the file's size in bytes.
    @objc public var fileSize: UInt {
        
        get { return (getAssociatedObject(key: &Keys.fileSize) as? UInt) ?? 0 }
        set { setAssociatedObject(key: &Keys.fileSize, value: newValue) }
    }
    
    /// If the type of asset is an image, returns the size of image, measured in points.
    /// If the type of asset is an AVAsset, returns the resolution size calculated by naturalSize and preferredTransform.
    @objc public var width: Float {
        
        get { return (getAssociatedObject(key: &Keys.width) as? Float) ?? 0.0 }
        set { setAssociatedObject(key: &Keys.width, value: newValue) }
    }
    
    /// If the type of asset is an image, returns the size of image, measured in points.
    /// If the type of asset is an AVAsset, returns the resolution size calculated by naturalSize and preferredTransform.
    @objc public var height: Float {
        
        get { return (getAssociatedObject(key: &Keys.height) as? Float) ?? 0.0 }
        set { setAssociatedObject(key: &Keys.height, value: newValue) }
    }
    
    /// If you export an asset whose data is not on the local device, and you have enabled downloading with the isNetworkAccessAllowed property, the progress indicating the progress of the download. A value of 0.0 indicates that the download has just started, and a value of 1.0 indicates the download is complete.
    @objc public var progress: Double {
        
        get { return (getAssociatedObject(key: &Keys.progress) as? Double) ?? 0.0 }
        set { setAssociatedObject(key: &Keys.progress, value: newValue) }
    }
    
    /// Describes the error that occurred if the export is failed or cancelled.
    @objc public var error: Error? {
        
        get { return getAssociatedObject(key: &Keys.error) as? Error }
        set { setAssociatedObject(key: &Keys.error, value: newValue) }
    }
    
    // MARK: - Private
    
    private func setAssociatedObject(key: UnsafePointer<UInt8>, value: Any?, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN) {
        objc_setAssociatedObject(self, key, value, policy)
    }
    
    private func getAssociatedObject(key: UnsafePointer<UInt8>) -> Any? {
        return objc_getAssociatedObject(self, key)
    }
    
}
