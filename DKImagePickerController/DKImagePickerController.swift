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

@objc
public protocol DKImagePickerControllerCameraProtocol {
    
    func setDidCancel(block: @escaping () -> Void) -> Void
    
    func setDidFinishCapturingImage(block: @escaping (_ image: UIImage, _ metadata: [AnyHashable : Any]?) -> Void) -> Void
    
    func setDidFinishCapturingVideo(block: @escaping (_ videoURL: URL) -> Void) -> Void
}

@objc
public protocol DKImagePickerControllerUIDelegate {
    
    /**
     The picker calls -prepareLayout once at its first layout as the first message to the UIDelegate instance.
     */
    func prepareLayout(_ imagePickerController: DKImagePickerController, vc: UIViewController)
    
    /**
     Returns a custom camera.
     
     **Note**
     
     If you are using a UINavigationController as the custom camera,
     you should also set the picker's modalPresentationStyle to .overCurrentContext, like this:
     
     ```
     pickerController.modalPresentationStyle = .overCurrentContext
     ```
     
     - Parameter imagePickerController: DKImagePickerController
     - Returns: The returned `UIViewControlelr` must conform to the `DKImagePickerControllerCameraProtocol`.
     */
    func imagePickerControllerCreateCamera(_ imagePickerController: DKImagePickerController) -> UIViewController
        
    /**
     The layout is to provide information about the position and visual state of items in the collection view.
     */
    func layoutForImagePickerController(_ imagePickerController: DKImagePickerController) -> UICollectionViewLayout.Type
    
    /**
     Called when the user needs to show the cancel button.
     */
    func imagePickerController(_ imagePickerController: DKImagePickerController, showsCancelButtonForVC vc: UIViewController)
    
    /**
     Called when the user needs to hide the cancel button.
     */
    func imagePickerController(_ imagePickerController: DKImagePickerController, hidesCancelButtonForVC vc: UIViewController)
    
    /**
     Called after the user changes the selection.
     */
    func imagePickerController(_ imagePickerController: DKImagePickerController, didSelectAssets: [DKAsset])
    
    /**
     Called after the user changes the selection.
     */
    func imagePickerController(_ imagePickerController: DKImagePickerController, didDeselectAssets: [DKAsset])
    
    /**
     Called when the count of the selectedAssets did reach `maxSelectableCount`.
     */
    func imagePickerControllerDidReachMaxLimit(_ imagePickerController: DKImagePickerController)
    
    /**
     Accessory view below content. default is nil.
     */
    func imagePickerControllerFooterView(_ imagePickerController: DKImagePickerController) -> UIView?
    
    /**
     Set the color of the background of the collection view.
     */
    func imagePickerControllerCollectionViewBackgroundColor() -> UIColor
 
    func imagePickerControllerCollectionImageCell() -> DKAssetGroupDetailBaseCell.Type
    
    func imagePickerControllerCollectionCameraCell() -> DKAssetGroupDetailBaseCell.Type
    
    func imagePickerControllerCollectionVideoCell() -> DKAssetGroupDetailBaseCell.Type
}

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

// MARK: - Public DKImagePickerController

/**
 * The `DKImagePickerController` class offers the all public APIs which will affect the UI.
 */
open class DKImagePickerController : UINavigationController {
    
    lazy public var UIDelegate: DKImagePickerControllerUIDelegate = {
        return DKImagePickerControllerDefaultUIDelegate()
    }()
    
    /// Forces deselect of previous selected image
    public var singleSelect = false
    
    /// Auto close picker on single select
    public var autoCloseOnSingleSelect = true
    
    /// The maximum count of assets which the user will be able to select.
    public var maxSelectableCount = 999
    
    /// Set the defaultAssetGroup to specify which album is the default asset group.
    public var defaultAssetGroup: PHAssetCollectionSubtype?
    
    /// allow swipe to select images.
    public var allowSwipeToSelect: Bool = false
    
    public var inline: Bool = false
    
    /// Limits the maximum number of objects returned in the fetch result, a value of 0 means no limit.
    public var fetchLimit = 0
    
    /// The types of PHAssetCollection to display in the picker.
    public var assetGroupTypes: [PHAssetCollectionSubtype] = [
        .smartAlbumUserLibrary,
        .smartAlbumFavorites,
        .albumRegular
        ] {
        willSet(newTypes) {
            getImageManager().groupDataManager.assetGroupTypes = newTypes
        }
    }
    
    /// Set the showsEmptyAlbums to specify whether or not the empty albums is shown in the picker.
    public var showsEmptyAlbums = true {
        didSet {
            getImageManager().groupDataManager.showsEmptyAlbums = self.showsEmptyAlbums
        }
    }
    
    public var assetFilter: ((_ asset: PHAsset) -> Bool)? {
        didSet {
            getImageManager().groupDataManager.assetFilter = self.assetFilter
        }
    }
    
    /// The type of picker interface to be displayed by the controller.
    public var assetType: DKImagePickerControllerAssetType = .allAssets {
        didSet {
            getImageManager().groupDataManager.assetFetchOptions = self.createAssetFetchOptions()
        }
    }
    
    /// The predicate applies to images only.
    public var imageFetchPredicate: NSPredicate? {
        didSet {
            getImageManager().groupDataManager.assetFetchOptions = self.createAssetFetchOptions()
        }
    }
    
    /// The predicate applies to videos only.
    public var videoFetchPredicate: NSPredicate? {
        didSet {
            getImageManager().groupDataManager.assetFetchOptions = self.createAssetFetchOptions()
        }
    }
    
    /// If sourceType is Camera will cause the assetType & maxSelectableCount & allowMultipleTypes & defaultSelectedAssets to be ignored.
    public var sourceType: DKImagePickerControllerSourceType = .both {
        didSet { /// If source type changed in the scenario of sharing instance, view controller should be reinitialized.
            if(oldValue != sourceType) {
                self.hasInitialized = false
            }
        }
    }
    
    /// Whether allows to select photos and videos at the same time.
    public var allowMultipleTypes = true
    
    /// If YES, and the requested image is not stored on the local device, the Picker downloads the image from iCloud.
    public var autoDownloadWhenAssetIsInCloud = true {
        didSet {
            getImageManager().autoDownloadWhenAssetIsInCloud = self.autoDownloadWhenAssetIsInCloud
        }
    }
    
    /// Determines whether or not the rotation is enabled.
    public var allowsLandscape = false
    
    /// The callback block is executed when user pressed the cancel button.
    public var didCancel: (() -> Void)?
    public var showsCancelButton = false {
        didSet {
            if let rootVC = self.viewControllers.first {
                self.updateCancelButtonForVC(rootVC)
            }
        }
    }
    
    /// The callback block is executed when user pressed the select button.
    public var didSelectAssets: ((_ assets: [DKAsset]) -> Void)?
    
    public var selectedChanged: (() -> Void)?
    
    /// It will have selected the specific assets.
    public var defaultSelectedAssets: [DKAsset]? {
        didSet {
            if let defaultSelectedAssets = self.defaultSelectedAssets {
                if Set(self.selectedAssets) != Set(defaultSelectedAssets) {
                    self.selectedAssets = self.defaultSelectedAssets ?? []
                    
                    if let rootVC = self.viewControllers.first as? DKAssetGroupDetailVC {
                        rootVC.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    open private(set) var selectedAssets = [DKAsset]()
    
    static private var imagePickerControllerReferenceCount = 0
    public convenience init() {
        let rootVC = UIViewController()
        self.init(rootViewController: rootVC)
        
        self.preferredContentSize = CGSize(width: 680, height: 600)
        
        rootVC.navigationItem.hidesBackButton = true
        
        getImageManager().groupDataManager.assetGroupTypes = self.assetGroupTypes
        getImageManager().groupDataManager.assetFetchOptions = self.createAssetFetchOptions()
        getImageManager().groupDataManager.showsEmptyAlbums = self.showsEmptyAlbums
        getImageManager().autoDownloadWhenAssetIsInCloud = self.autoDownloadWhenAssetIsInCloud
        
        DKImagePickerController.imagePickerControllerReferenceCount += 1
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        DKImagePickerController.imagePickerControllerReferenceCount -= 1
        if DKImagePickerController.imagePickerControllerReferenceCount == 0 {
            getImageManager().invalidate()
        }
    }
    
    private var hasInitialized = false
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !hasInitialized {
            hasInitialized = true
            
            if self.inline || self.sourceType == .camera {
                self.isNavigationBarHidden = true
            } else {
                self.isNavigationBarHidden = false
            }
            
            if self.sourceType == .camera {
                let camera = self.createCamera()
                if camera is UINavigationController {
                    self.present(camera: camera)
                    self.setViewControllers([], animated: false)
                } else {
                    self.setViewControllers([camera], animated: false)
                }
            } else {
                let rootVC = self.makeRootVC()
                rootVC.imagePickerController = self
                
                self.UIDelegate.prepareLayout(self, vc: rootVC)
                self.updateCancelButtonForVC(rootVC)
                self.setViewControllers([rootVC], animated: false)
                if let count = self.defaultSelectedAssets?.count, count > 0 {
                    self.UIDelegate.imagePickerController(self, didSelectAssets: [self.defaultSelectedAssets!.last!])
                }
            }
        }
    }
    
    private lazy var assetFetchOptions: PHFetchOptions = {
        let assetFetchOptions = PHFetchOptions()
        return assetFetchOptions
    }()
  
    open func makeRootVC() -> DKAssetGroupDetailVC {
      return DKAssetGroupDetailVC()
    }
    
    private func createAssetFetchOptions() -> PHFetchOptions? {
        let createImagePredicate = { () -> NSPredicate in
            var imagePredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            if let imageFetchPredicate = self.imageFetchPredicate {
                imagePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [imagePredicate, imageFetchPredicate])
            }
            
            return imagePredicate
        }
        
        let createVideoPredicate = { () -> NSPredicate in
            var videoPredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
            if let videoFetchPredicate = self.videoFetchPredicate {
                videoPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [videoPredicate, videoFetchPredicate])
            }
            
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
        
        self.assetFetchOptions.predicate = predicate
        
        return self.assetFetchOptions
    }
    
    private func updateCancelButtonForVC(_ vc: UIViewController) {
        if self.showsCancelButton {
            self.UIDelegate.imagePickerController(self, showsCancelButtonForVC: vc)
        } else {
            self.UIDelegate.imagePickerController(self, hidesCancelButtonForVC: vc)
        }
    }
    
    private func createCamera() -> UIViewController {
        let didCancel = { [unowned self] () in
            if self.sourceType == .camera {
                self.dismissCamera()
                self.dismiss()
            } else {
                self.dismissCamera()
            }
        }
        
        let didFinishCapturingImage = { [unowned self] (image: UIImage, metadata: [AnyHashable : Any]?) in
            self.capturingImage(image, metadata, { [unowned self] (asset) in
                if self.sourceType != .camera {
                    self.dismissCamera()
                }
                self.selectImage(asset)
            })
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
                            self.selectImage(DKAsset(originalAsset: newAsset))
                        }
                    } else {
                        self.dismissCamera()
                    }
                })
            }
        }
        
        let camera = self.UIDelegate.imagePickerControllerCreateCamera(self)
        let cameraProtocol = camera as! DKImagePickerControllerCameraProtocol
        
        cameraProtocol.setDidCancel(block: didCancel)
        cameraProtocol.setDidFinishCapturingImage(block: didFinishCapturingImage)
        cameraProtocol.setDidFinishCapturingVideo(block: didFinishCapturingVideo)
        
        return camera
    }
    
    @objc open func presentCamera() {
        self.present(camera: self.createCamera())
    }
    
    internal weak var camera: UIViewController?
    @objc open func present(camera: UIViewController) {
        self.camera = camera
        
        if self.inline {
            UIApplication.shared.keyWindow!.rootViewController!.present(camera, animated: true, completion: nil)
        } else {
            self.present(camera, animated: true, completion: nil)
        }
    }
    
    open func dismissCamera() {
        if let _ = self.camera {
            if self.inline {
                UIApplication.shared.keyWindow!.rootViewController!.dismiss(animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            self.camera = nil
        }
    }
    @objc
    open func dismiss() {
        self.presentingViewController?.dismiss(animated: true, completion: {
            self.didCancel?()
        })
    }
    
    @objc open func done() {
        self.presentingViewController?.dismiss(animated: true, completion: {
            self.didSelectAssets?(self.selectedAssets)
        })
    }
    
    // MARK:- Capturing Image
    
    internal func capturingImage(_ image: UIImage, _ metadata: [AnyHashable : Any]?, _ completeBlock: @escaping ((_ asset: DKAsset) -> Void)) {
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
    
    internal func saveImageToAlbum(_ image: UIImage, _ completeBlock: @escaping ((_ asset: DKAsset) -> Void)) {
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
    
    internal func saveImageDataToAlbumForiOS8(_ imageData: Data, _ metadata: Dictionary<AnyHashable, Any>?, _ completeBlock: @escaping ((_ asset: DKAsset) -> Void)) {
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
    
    internal func saveImageDataToAlbumForiOS9(_ imageDataWithMetadata: Data, _ completeBlock: @escaping ((_ asset: DKAsset) -> Void)) {
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
    
    internal func writeMetadata(_ metadata: Dictionary<AnyHashable, Any>, into imageData: Data) -> Data? {
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
    
    public func selectImage(atIndexPath index: IndexPath) {
        if let rootVC = self.viewControllers.first as? DKAssetGroupDetailVC {
            rootVC.selectAsset(atIndex: index)
            rootVC.collectionView?.reloadData()
        }
    }
    
    public func deselectAssetAtIndex(_ index: Int) {
        let asset = self.selectedAssets[index]
        self.deselectAsset(asset)
    }
    
    public func deselectAsset(_ asset: DKAsset) {
        self.deselectImage(asset)
        if let rootVC = self.viewControllers.first as? DKAssetGroupDetailVC {
            rootVC.collectionView?.reloadData()
        }
    }
    
    public func deselectAllAssets() {
        if self.selectedAssets.count > 0 {
            let assets = self.selectedAssets
            self.selectedAssets.removeAll()
            self.triggerSelectedChanged()
            self.UIDelegate.imagePickerController(self, didDeselectAssets: assets)
            if let rootVC = self.viewControllers.first as? DKAssetGroupDetailVC {
                rootVC.collectionView?.reloadData()
            }
        }
    }
    
    internal func selectImage(_ asset: DKAsset) {
        if self.singleSelect {
            self.deselectAllAssets()
            self.selectedAssets.append(asset)
            if self.sourceType == .camera || autoCloseOnSingleSelect {
                self.done()
            } else {
                self.UIDelegate.imagePickerController(self, didSelectAssets: [asset])
            }
        } else {
            self.selectedAssets.append(asset)
            if self.sourceType == .camera {
                self.done()
            } else {
                self.UIDelegate.imagePickerController(self, didSelectAssets: [asset])
                self.triggerSelectedChanged()
            }
        }
    }
    
    internal func deselectImage(_ asset: DKAsset) {
        self.selectedAssets.remove(at: selectedAssets.index(of: asset)!)
        self.UIDelegate.imagePickerController(self, didDeselectAssets: [asset])
        self.triggerSelectedChanged()
    }
    
    internal func triggerSelectedChanged() {
        if let selectedChanged = self.selectedChanged {
            selectedChanged()
        }
    }
    
    // MARK: - Handles Orientation
    
    open override var shouldAutorotate : Bool {
        return self.allowsLandscape && self.sourceType != .camera ? true : false
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if self.allowsLandscape {
            return super.supportedInterfaceOrientations
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }
}
