//
//  DKImagePickerController.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 14-10-2.
//  Copyright (c) 2014年 ZhangAo. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary

/**
 - AllPhotos: Get all photos assets in the assets group.
 - AllVideos: Get all video assets in the assets group.
 - AllAssets: Get all assets in the group.
 */
@objc
public enum DKImagePickerControllerAssetType : Int {
    case allPhotos, allVideos, allAssets
}

@objc
public enum DKImagePickerControllerSourceType : Int {
    case camera, photo, both
}

@objc
public enum DKImagePickerControllerExportStatus: Int {
    case none, exporting
}

@objc
public enum DKImagePickerControllerAssetOrientation: Int {
    case landscape, portrait, all
}

////////////////////////////////////////////////////////////////////////

@objc
internal protocol DKImagePickerControllerObserver {
    
    @objc optional func imagePickerControllerDidSelect(assets: [DKAsset])
    
    @objc optional func imagePickerControllerDidDeselect(assets: [DKAsset])
    
}

////////////////////////////////////////////////////////////////////////

@objc
open class DKImagePickerController: UINavigationController, DKImageBaseManagerObserver {
    
    /// Use UIDelegate to Customize the picker UI.
    @objc public var UIDelegate: DKImagePickerControllerBaseUIDelegate! {
        willSet {
            newValue?.imagePickerController = self
        }
    }
    
    /// Forces deselect of previous selected image. allowSwipeToSelect will be ignored.
    @objc public var singleSelect = false
    
    /// Auto close picker on single select
    @objc public var autoCloseOnSingleSelect = true
    
    /// The maximum count of assets which the user will be able to select, a value of 0 means no limit.
    @objc public var maxSelectableCount = 0
    
    /// Set the defaultAssetGroup to specify which album is the default asset group.
    public var defaultAssetGroup: PHAssetCollectionSubtype?
    
    /// Allow swipe to select images.
    @objc public var allowSwipeToSelect: Bool = false
    
    /// A Bool value indicating whether the inline mode is enabled.
    @objc public var inline: Bool = false
    
    /// The type of picker interface to be displayed by the controller.
    @objc public var assetType: DKImagePickerControllerAssetType = .allAssets
    
    /// If sourceType is Camera will cause the assetType & maxSelectableCount & allowMultipleTypes & defaultSelectedAssets to be ignored.
    @objc public var sourceType: DKImagePickerControllerSourceType = .both
    
    /// A Bool value indicating whether to allow the picker to select photos and videos at the same time.
    @objc public var allowMultipleTypes = true
    
    /// A Bool value indicating whether to allow the picker auto-rotate the screen.
    @objc public var allowsLandscape = false
  
    ///An Int indicating the orientation filter to apply when fetching the assets
    @objc public var orientationsAllowed: DKImagePickerControllerAssetOrientation = .all
    
    /// Set the showsEmptyAlbums to specify whether or not the empty albums is shown in the picker.
    @objc public var showsEmptyAlbums = true
    
    /// A Bool value indicating whether to allow the picker shows the cancel button.
    @objc public var showsCancelButton = false
    
    /// Limits the maximum number of objects displayed on the UI, a value of 0 means no limit.  Defaults to 0.
    @objc public var fetchLimit = 0
    
    /// The block is executed when the user presses the cancel button.
    @objc public var didCancel: (() -> Void)?
    
    /// The block is executed when the user presses the select button.
    @objc public var didSelectAssets: ((_ assets: [DKAsset]) -> Void)?
    
    /// The block is executed when the number of the selected assets is changed.
    @objc public var selectedChanged: (() -> Void)?

    /// Colors applied to the permission view when access needs to be granted by the user
    @objc public var permissionViewColors = DKPermissionViewColors()
    
    /// A Bool value indicating whether to allow the picker to auto-export the selected assets to the specified directory when done is called.
    /// picker will creating a default exporter if exportsWhenCompleted is true and the exporter is nil.
    @objc public var exportsWhenCompleted = false
    
    @objc public var exporter: DKImageAssetExporter?
    
    /// Indicates the status of the exporter.
    @objc public private(set) var exportStatus = DKImagePickerControllerExportStatus.none {
        willSet {
            if self.exportStatus != newValue {
                self.willChangeValue(forKey: #keyPath(DKImagePickerController.exportStatus))
            }
        }
        
        didSet {
            if self.exportStatus != oldValue {
                self.didChangeValue(forKey: #keyPath(DKImagePickerController.exportStatus))
                
                self.exportStatusChanged?(self.exportStatus)
            }
        }
    }
    
    /// The block is executed when the exportStatus is changed.
    @objc public var exportStatusChanged: ((DKImagePickerControllerExportStatus) -> Void)?
    
    /// The object that acts as the data source of the picker.
    @objc public private(set) lazy var groupDataManager: DKImageGroupDataManager = {
        let configuration = DKImageGroupDataManagerConfiguration()
        configuration.assetFetchOptions = self.createDefaultAssetFetchOptions()
        configuration.fetchLimit = self.fetchLimit
        
        return DKImageGroupDataManager(configuration: configuration)
    }()
    
    public private(set) var selectedAssetIdentifiers = [String]() // DKAsset.localIdentifier
    private var assets = [String : DKAsset]() // DKAsset.localIdentifier : DKAsset
    
    private lazy var extensionController: DKImageExtensionController! = {
        return DKImageExtensionController(imagePickerController: self)
    }()
    
    internal var proxyObserver = DKImageBaseManager()
    
    public convenience init() {
        let rootVC = UIViewController()
        
        self.init(rootViewController: rootVC)
    }
    
    public convenience init(groupDataManager: DKImageGroupDataManager) {
        let rootVC = UIViewController()
        self.init(rootViewController: rootVC)
        
        self.groupDataManager = groupDataManager
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        self.preferredContentSize = CGSize(width: 680, height: 600)
        
        rootViewController.navigationItem.hidesBackButton = true
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        self.groupDataManager.invalidate()
    }
    
    private lazy var doSetupOnce: () -> Void = {
        if self.UIDelegate == nil {
            self.UIDelegate = DKImagePickerControllerBaseUIDelegate()
        }
        
        if self.exportsWhenCompleted && self.exporter == nil {
            self.exporter = DKImageAssetExporter.sharedInstance
        }
        
        if self.inline || self.sourceType == .camera {
            self.isNavigationBarHidden = true
        } else {
            self.isNavigationBarHidden = false
        }
        
        if self.sourceType != .camera {
            let rootVC = self.makeRootVC()
            rootVC.imagePickerController = self
            
            self.UIDelegate.prepareLayout(self, vc: rootVC)
            self.updateCancelButtonForVC(rootVC)
            self.setViewControllers([rootVC], animated: false)
        }
        
        if self.selectedAssetIdentifiers.count > 0 {
            self.UIDelegate.imagePickerController(self, didSelectAssets: self.selectedAssets)
        }
        
        return {}
    }()
    
    private var needShowInlineCamera = true
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.doSetupOnce()
        
        if self.needShowInlineCamera && self.sourceType == .camera {
            self.needShowInlineCamera = false
            self.showCamera(isInline: true)
        }
    }
    
    @objc open func makeRootVC() -> DKAssetGroupDetailVC {
      return DKAssetGroupDetailVC()
    }
    
    @objc open func presentCamera() {
        self.showCamera(isInline: false)
    }
    
    @objc open override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool = true, completion: (() -> Swift.Void)? = nil) {
        var targetVC: UIViewController = self
        if self.inline {
            targetVC = UIApplication.shared.keyWindow!.rootViewController!
        }
        
        while let presentedViewController = targetVC.presentedViewController {
            targetVC = presentedViewController
        }
        
        if targetVC == self {
            super.present(viewControllerToPresent, animated: flag, completion: completion)
        } else {
            targetVC.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
    
    @objc open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if self.inline {
            UIApplication.shared.keyWindow!.rootViewController!.dismiss(animated: true, completion: completion)
        } else {
            super.dismiss(animated: true, completion: completion)
        }
    }
    
    @objc open func dismissCamera(isInline: Bool = false) {
        self.extensionController.finish(extensionType: isInline ? .inlineCamera : .camera)
    }
    
    @objc open func dismiss() {
        self.cancelCurrentExportRequestIfNeeded()
        
        self.presentingViewController?.dismiss(animated: true, completion: {
            self.didCancel?()
            
            if self.sourceType == .camera {
                self.needShowInlineCamera = true
            }
        })
    }
    
    private var exportRequestID = DKImageAssetExportInvalidRequestID
    @objc open func done() {
        self.cancelCurrentExportRequestIfNeeded()
        
        let completeBlock: ([DKAsset]) -> Void = { assets in
            self.exportStatus = .none
            
            self.didSelectAssets?(assets)
            
            if self.sourceType == .camera {
                self.needShowInlineCamera = true
            }
        }
        
        let exportBlock = {
            let assets = self.selectedAssets
            if let exporter = self.exporter {
                self.exportRequestID = exporter.exportAssetsAsynchronously(assets: assets) { [weak self] info in
                    if let strongSelf = self {
                        let requestID = info[DKImageAssetExportResultRequestIDKey] as! DKImageAssetExportRequestID
                        if strongSelf.exportRequestID == requestID {
                            strongSelf.exportRequestID = DKImageAssetExportInvalidRequestID
                            completeBlock(assets)
                        }
                    }
                }
                
                self.exportStatus = .exporting
            } else {
                completeBlock(assets)
            }
        }
        
        if self.inline {
            exportBlock()
        } else {
            self.presentingViewController?.dismiss(animated: true, completion: {
                exportBlock()
            })
        }
    }
    
    private func cancelCurrentExportRequestIfNeeded() {
        if self.exportRequestID != DKImageAssetExportInvalidRequestID {
            self.exporter?.cancel(requestID: self.exportRequestID)
            self.exportStatus = .none
        }
    }
    
    private func updateCancelButtonForVC(_ vc: UIViewController) {
        if self.showsCancelButton {
            self.UIDelegate.imagePickerController(self, showsCancelButtonForVC: vc)
        } else {
            self.UIDelegate.imagePickerController(self, hidesCancelButtonForVC: vc)
        }
    }
  
    private func createDefaultAssetFetchOptions() -> PHFetchOptions {
        
        let createImagePredicate = { () -> NSPredicate in
            let imagePredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            
            return imagePredicate
        }
        
        let createVideoPredicate = { () -> NSPredicate in
            let videoPredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
            
            return videoPredicate
        }
        
        var predicate: NSPredicate?
        switch self.assetType {
        case .allAssets:
            predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [createImagePredicate(), createVideoPredicate()])
        case .allPhotos:
            predicate = createImagePredicate()
        case .allVideos:
            predicate = createVideoPredicate()
        }
        
        let assetFetchOptions = PHFetchOptions()
        assetFetchOptions.predicate = predicate
        
        return assetFetchOptions
    }
    
    private var metadataFromCamera: [AnyHashable : Any]?
    private func showCamera(isInline: Bool) {
        let didCancel = { [unowned self] () in
            if self.sourceType == .camera {
                self.dismissCamera(isInline: true)
                self.dismiss()
            } else {
                self.dismissCamera()
            }
        }
        
        let didFinishCapturingImage = { [weak self] (image: UIImage, metadata: [AnyHashable : Any]?) in
            if let strongSelf = self {
                strongSelf.metadataFromCamera = metadata
                
                let didFinishEditing: ((UIImage, [AnyHashable : Any]?) -> Void) = { (image, metadata) in
                    self?.processImageFromCamera(image, metadata)
                }
                
                if strongSelf.extensionController.isExtensionTypeAvailable(.photoEditor) {
                    var extraInfo: [AnyHashable : Any] = [
                        "image" : image,
                        "didFinishEditing" : didFinishEditing,
                        ]
                    
                    if let metadata = metadata {
                        extraInfo["metadata"] = metadata
                    }
                    
                    strongSelf.extensionController.perform(extensionType: .photoEditor, with: extraInfo)
                } else {
                    didFinishEditing(image, metadata)
                }
            }
        }
        
        let didFinishCapturingVideo = { [unowned self] (videoURL: URL) in
            var newVideoIdentifier: String!
            PHPhotoLibrary.shared().performChanges({
                let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                newVideoIdentifier = assetRequest?.placeholderForCreatedAsset?.localIdentifier
            }) { (success, error) in
                DispatchQueue.main.async(execute: {
                    if success {
                        if let newAsset = PHAsset.fetchAssets(withLocalIdentifiers: [newVideoIdentifier], options: nil).firstObject {
                            if self.sourceType != .camera || self.viewControllers.count == 0 {
                                self.dismissCamera()
                            }
                            self.select(asset: DKAsset(originalAsset: newAsset))
                        }
                    } else {
                        self.dismissCamera()
                    }
                })
            }
        }
        
        self.extensionController.perform(extensionType: isInline ? .inlineCamera : .camera, with: [
            "didFinishCapturingImage" : didFinishCapturingImage,
            "didFinishCapturingVideo" : didFinishCapturingVideo,
            "didCancel" : didCancel
            ])
    }
    
    private func triggerSelectedChangedIfNeeded() {
        if let selectedChanged = self.selectedChanged {
            selectedChanged()
        }
    }
    
    // MARK: - Capturing Image
    
    internal func processImageFromCamera(_ image: UIImage, _ metadata: [AnyHashable : Any]?) {
        self.saveImage(image, metadata) { asset in
            if self.sourceType != .camera {
                self.dismissCamera()
            }
            self.select(asset: asset)
        }
    }
    
    // MARK: - Save Image
    
    @objc open func saveImage(_ image: UIImage, _ metadata: [AnyHashable : Any]?, _ completeBlock: @escaping ((_ asset: DKAsset) -> Void)) {
        if let metadata = metadata {
            let imageData = UIImageJPEGRepresentation(image, 1)!
            
            if #available(iOS 9.0, *) {
                if let imageDataWithMetadata = self.writeMetadata(metadata, into: imageData) {
                    self.saveImageDataToAlbumForiOS9(imageDataWithMetadata, completeBlock)
                } else {
                    self.saveImageDataToAlbumForiOS9(imageData, completeBlock)
                }
            } else {
                self.saveImageDataToAlbumForiOS8(imageData, metadata, completeBlock)
            }
        } else {
            self.saveImageToAlbum(image, completeBlock)
        }
    }
    
    @objc open func saveImageToAlbum(_ image: UIImage, _ completeBlock: @escaping ((_ asset: DKAsset) -> Void)) {
        var newImageIdentifier: String!
        
        PHPhotoLibrary.shared().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            newImageIdentifier = assetRequest.placeholderForCreatedAsset!.localIdentifier
        }) { (success, error) in
            DispatchQueue.main.async(execute: {
                if success, let newAsset = PHAsset.fetchAssets(withLocalIdentifiers: [newImageIdentifier], options: nil).firstObject {
                    completeBlock(DKAsset(originalAsset: newAsset))
                } else {
                    completeBlock(DKAsset(image: image))
                }
            })
        }
    }
    
    @objc open func saveImageDataToAlbumForiOS8(_ imageData: Data, _ metadata: Dictionary<AnyHashable, Any>?, _ completeBlock: @escaping ((_ asset: DKAsset) -> Void)) {
        let library = ALAssetsLibrary()
        library.writeImageData(toSavedPhotosAlbum: imageData, metadata: metadata, completionBlock: { (newURL, error) in
            if let _ = error {
                completeBlock(DKAsset(image: UIImage(data: imageData)!))
            } else {
                if let newAsset = PHAsset.fetchAssets(withALAssetURLs: [newURL!], options: nil).firstObject {
                    completeBlock(DKAsset(originalAsset: newAsset))
                }
            }
        })
    }
    
    @objc open func saveImageDataToAlbumForiOS9(_ imageDataWithMetadata: Data, _ completeBlock: @escaping ((_ asset: DKAsset) -> Void)) {
        var newImageIdentifier: String!
        
        PHPhotoLibrary.shared().performChanges({
            if #available(iOS 9.0, *) {
                let assetRequest = PHAssetCreationRequest.forAsset()
                assetRequest.addResource(with: .photo, data: imageDataWithMetadata, options: nil)
                newImageIdentifier = assetRequest.placeholderForCreatedAsset!.localIdentifier
            } else {
                // Fallback on earlier versions
            }
        }) { (success, error) in
            DispatchQueue.main.async(execute: {
                if success, let newAsset = PHAsset.fetchAssets(withLocalIdentifiers: [newImageIdentifier], options: nil).firstObject {
                    completeBlock(DKAsset(originalAsset: newAsset))
                } else {
                    completeBlock(DKAsset(image: UIImage(data: imageDataWithMetadata)!))
                }
            })
            
        }
    }
    
    @objc open func writeMetadata(_ metadata: Dictionary<AnyHashable, Any>, into imageData: Data) -> Data? {
        let source = CGImageSourceCreateWithData(imageData as CFData, nil)!
        let UTI = CGImageSourceGetType(source)!
        
        let newImageData = NSMutableData()
        if let destination = CGImageDestinationCreateWithData(newImageData, UTI, 1, nil) {
            CGImageDestinationAddImageFromSource(destination, source, 0, metadata as CFDictionary)
            if CGImageDestinationFinalize(destination) {
                return newImageData as Data
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    // MARK: - Selection
        
    @objc open func select(asset: DKAsset) {
        self.select(assets: [asset])
    }
    
    @objc open func select(assets: [DKAsset]) {
        if self.singleSelect {
            self.deselectAll()
        }
        
        var insertedAssets = [DKAsset]()
        
        for asset in assets {
            if self.assets[asset.localIdentifier] != nil { continue }
            if !self.canSelect(asset: asset) { break }
            
            self.selectedAssetIdentifiers.append(asset.localIdentifier)
            self.assets[asset.localIdentifier] = asset
            
            insertedAssets.append(asset)
        }
        
        if insertedAssets.count > 0 {
            self.clearSelectedAssetsCache()
            
            if self.sourceType == .camera || (self.singleSelect && self.autoCloseOnSingleSelect) {
                self.done()
            } else {
                self.triggerSelectedChangedIfNeeded()
                self.UIDelegate?.imagePickerController(self, didSelectAssets: insertedAssets)
            }
            
            self.notify(with: #selector(DKImagePickerControllerObserver.imagePickerControllerDidSelect(assets:)), object: insertedAssets as AnyObject)
        }
    }
    
    @objc open func deselect(asset: DKAsset) {
        if self.assets[asset.localIdentifier] == nil { return }
        
        self.selectedAssetIdentifiers.remove(at: self.selectedAssetIdentifiers.index(of: asset.localIdentifier)!)
        self.assets[asset.localIdentifier] = nil
        self.clearSelectedAssetsCache()
        
        self.triggerSelectedChangedIfNeeded()
        
        let deselectAssets = [asset]
        self.UIDelegate?.imagePickerController(self, didDeselectAssets: deselectAssets)
        
        self.notify(with: #selector(DKImagePickerControllerObserver.imagePickerControllerDidDeselect(assets:)), object: deselectAssets as AnyObject)
    }
    
    @objc open func deselectAll() {
        if self.selectedAssetIdentifiers.count > 0 {
            let assets = self.selectedAssets
            self.selectedAssetIdentifiers.removeAll()
            self.assets.removeAll()
            self.clearSelectedAssetsCache()
            
            self.triggerSelectedChangedIfNeeded()
            self.UIDelegate?.imagePickerController(self, didDeselectAssets: assets)
            
            self.notify(with: #selector(DKImagePickerControllerObserver.imagePickerControllerDidDeselect(assets:)), object: assets as AnyObject)
        }
    }
    
    @objc open func setSelectedAssets(assets: [DKAsset]) {
        if assets.count > 0 {
            self.deselectAll()
            self.select(assets: assets)
        } else {
            self.deselectAll()
        }
    }
    
    open func index(of asset: DKAsset) -> Int? {
        if self.contains(asset: asset) {
            return self.selectedAssetIdentifiers.index(of: asset.localIdentifier)
        } else {
            return nil
        }
    }
    
    @objc func contains(asset: DKAsset) -> Bool {
        return self.assets[asset.localIdentifier] != nil
    }
    
    private var internalSelectedAssetsCache: [DKAsset]?
    @objc public var selectedAssets: [DKAsset] {
        get {
            if self.internalSelectedAssetsCache != nil {
                return self.internalSelectedAssetsCache!
            }
            
            var assets = [DKAsset]()
            for assetIdentifier in self.selectedAssetIdentifiers {
                assets.append(self.assets[assetIdentifier]!)
            }
            
            self.internalSelectedAssetsCache = assets

            return assets
        }
    }
    
    @objc open func canSelect(asset: DKAsset, showAlert: Bool = true) -> Bool {
        if let firstSelectedAsset = self.selectedAssets.first,
            self.allowMultipleTypes == false && firstSelectedAsset.type != asset.type {
            
            if showAlert {
                let alert = UIAlertController(title: DKImagePickerControllerResource.localizedStringWithKey("picker.select.photosOrVideos.error.title"),
                                              message: DKImagePickerControllerResource.localizedStringWithKey("picker.select.photosOrVideos.error.message"),
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: DKImagePickerControllerResource.localizedStringWithKey("picker.alert.ok"),
                                              style: .cancel))
                
                self.present(alert, animated: true){}
            }
            
            return false
        }
        
        if self.maxSelectableCount > 0 {
            let shouldSelect = self.selectedAssetIdentifiers.count < self.maxSelectableCount
            if !shouldSelect && showAlert && !self.UIDelegate.isMaxLimitAlertDisplayed {
                self.UIDelegate.imagePickerControllerDidReachMaxLimit(self)
            }
            
            return shouldSelect
        } else {
            return true
        }
    }
    
    private func clearSelectedAssetsCache() {
        self.internalSelectedAssetsCache = nil
    }
    
    // MARK: - DKImageBaseManagerObserver
    
    internal func add(observer object: AnyObject) {
        self.proxyObserver.add(observer: object)
    }
    
    internal func remove(observer object: AnyObject) {
        self.proxyObserver.remove(observer: object)
    }
    
    internal func notify(with selector: Selector, object: AnyObject?) {
        self.proxyObserver.notify(with: selector, object: object)
    }
    
    internal func notify(with selector: Selector, object: AnyObject?, objectTwo: AnyObject?) {
        self.proxyObserver.notify(with: selector, object: object, objectTwo: objectTwo)
    }
    
    // MARK: - Orientation
    
    @objc open override var shouldAutorotate : Bool {
        return self.allowsLandscape && self.sourceType != .camera ? true : false
    }
    
    @objc open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if self.allowsLandscape {
            return super.supportedInterfaceOrientations
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    // MARK: - Gallery
    
    open func showGallery(with presentationIndex: Int?,
                            presentingFromImageView: UIImageView?,
                            groupId: String) {
        var extraInfo: [AnyHashable : Any] = [
            "groupId" : groupId
        ]
        
        if let presentationIndex = presentationIndex {
            extraInfo["presentationIndex"] = presentationIndex
        }
        
        if let presentingFromImageView = presentingFromImageView {
            extraInfo["presentingFromImageView"] = presentingFromImageView
        }
        
        self.extensionController.perform(extensionType: .gallery, with: extraInfo)
    }
    
}
