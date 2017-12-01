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
import CLImageEditor

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

@objc
public enum DKImagePickerControllerStatus: Int {
    case unknown, selecting, exporting, completed, cancelled
}

@objc
open class DKImagePickerController : UINavigationController, CLImageEditorDelegate {
    
    @objc lazy public var UIDelegate: DKImagePickerControllerUIDelegate = {
        return DKImagePickerControllerDefaultUIDelegate()
    }()
    
    /// Forces deselect of previous selected image
    @objc public var singleSelect = false
    
    /// Auto close picker on single select
    @objc public var autoCloseOnSingleSelect = true
    
    /// The maximum count of assets which the user will be able to select, a value of 0 means no limit.
    @objc public var maxSelectableCount = 0
    
    /// Set the defaultAssetGroup to specify which album is the default asset group.
    public var defaultAssetGroup: PHAssetCollectionSubtype?
    
    /// allow swipe to select images.
    @objc public var allowSwipeToSelect: Bool = false
    
    @objc public var inline: Bool = false
    
    /// Limits the maximum number of objects returned in the fetch result, a value of 0 means no limit.
    @objc public var fetchLimit = 0
    
    /// The type of picker interface to be displayed by the controller.
    @objc public var assetType: DKImagePickerControllerAssetType = .allAssets
    
    /// If sourceType is Camera will cause the assetType & maxSelectableCount & allowMultipleTypes & defaultSelectedAssets to be ignored.
    @objc public var sourceType: DKImagePickerControllerSourceType = .both {
        didSet { /// If source type changed in the scenario of sharing instance, view controller should be reinitialized.
            if (oldValue != sourceType) {
                self.hasInitialized = false
            }
        }
    }
    
    /// Whether allows to select photos and videos at the same time.
    @objc public var allowMultipleTypes = true
    
    /// Determines whether or not the rotation is enabled.
    @objc public var allowsLandscape = false
    
    /// Set the showsEmptyAlbums to specify whether or not the empty albums is shown in the picker.
    @objc public var showsEmptyAlbums = true
    
    @objc public var showsCancelButton = false {
        didSet {
            if let rootVC = self.viewControllers.first {
                self.updateCancelButtonForVC(rootVC)
            }
        }
    }
    
    /// The callback block is executed when user pressed the select button.
    @objc public var didSelectAssets: ((_ assets: [DKAsset]) -> Void)?
    
    @objc public private(set) var status = DKImagePickerControllerStatus.unknown {
        didSet {
            self.statusChanged?(self.status)
        }
    }
    
    @objc public var statusChanged: ((DKImagePickerControllerStatus) -> Void)?
    
    @objc public var selectedChanged: (() -> Void)?
    
    @objc public var exporter: DKImageAssetExporter? = DKImageAssetExporter.sharedInstance
    
    /// It will have selected the specific assets.
    @objc public var defaultSelectedAssets: [DKAsset]? {
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
    
    @objc open private(set) var selectedAssets = [DKAsset]()
    
    internal lazy var groupDataManager: DKImageGroupDataManager = {
        let configuration = DKImageGroupDataManagerConfiguration()
        configuration.assetFetchOptions = self.createAssetFetchOptions()
        
        return DKImageGroupDataManager(configuration: configuration)
    }()
    
    public convenience init() {
        let rootVC = UIViewController()
        
        self.init(rootViewController: rootVC)
    }
    
    public convenience init(groupDataManager: DKImageGroupDataManager) {
        let rootVC = UIViewController()
        self.init(rootViewController: rootVC)
        
        self.groupDataManager = groupDataManager
    }
    
    private override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        self.preferredContentSize = CGSize(width: 680, height: 600)
        
        rootViewController.navigationItem.hidesBackButton = true
    }
    
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        self.groupDataManager.invalidate()
    }
    
    private var hasInitialized = false
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.hasInitialized {
            self.hasInitialized = true
            
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
    
    @objc open func makeRootVC() -> DKAssetGroupDetailVC {
      return DKAssetGroupDetailVC()
    }
    
    private func updateCancelButtonForVC(_ vc: UIViewController) {
        if self.showsCancelButton {
            self.UIDelegate.imagePickerController(self, showsCancelButtonForVC: vc)
        } else {
            self.UIDelegate.imagePickerController(self, hidesCancelButtonForVC: vc)
        }
    }
    
    private func createAssetFetchOptions() -> PHFetchOptions {
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
    private func createCamera() -> UIViewController {
        let didCancel = { [unowned self] () in
            if self.sourceType == .camera {
                self.dismissCamera()
                self.dismiss()
            } else {
                self.dismissCamera()
            }
        }
        
        let didFinishCapturingImage = { [weak self] (image: UIImage, metadata: [AnyHashable : Any]?) in
            if let strongSelf = self {
                strongSelf.metadataFromCamera = metadata
                
                let imageEditor = CLImageEditor(image: image, delegate: self)!
                if let tool = imageEditor.toolInfo.subToolInfo(withToolName: "CLToneCurveTool", recursive: false) {
                    tool.available = false
                }
                
                if let tool = imageEditor.toolInfo.subToolInfo(withToolName: "CLStickerTool", recursive: false) {
                    tool.available = false
                }
                
                strongSelf.camera?.present(imageEditor, animated: true, completion: nil)
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
        
        self.camera = camera
        
        return camera
    }
    
    @objc open func presentCamera() {
        self.present(camera: self.createCamera())
    }
    
    internal weak var camera: UIViewController?
    @objc open func present(camera: UIViewController) {
        if self.inline {
            UIApplication.shared.keyWindow!.rootViewController!.present(camera, animated: true, completion: nil)
        } else {
            self.present(camera, animated: true, completion: nil)
        }
    }
    
    @objc open func dismissCamera() {
        if let _ = self.camera {
            if self.inline {
                UIApplication.shared.keyWindow!.rootViewController!.dismiss(animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            self.camera = nil
        }
    }
    
    @objc open func dismiss() {
        self.presentingViewController?.dismiss(animated: true, completion: {
            self.status = .cancelled
        })
    }
    
    @objc open func done() {
        self.presentingViewController?.dismiss(animated: true, completion: {
            if let exporter = self.exporter {
                self.status = .exporting
                
                exporter.exportAssetsAsynchronously(assets: self.selectedAssets, completion: { [weak self] result in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.status = .completed
                    strongSelf.didSelectAssets?(strongSelf.selectedAssets)
                })
            } else {
                self.status = .completed
                self.didSelectAssets?(self.selectedAssets)
            }
        })
    }
    
    @objc open func triggerSelectedChanged() {
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
            self.selectImage(asset)
        }
    }
    
    // MARK: - CLImageEditorDelegate
    
    public func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        self.metadataFromCamera?[kCGImagePropertyOrientation as AnyHashable] = NSNumber(integerLiteral: 0)

        self.processImageFromCamera(image, self.metadataFromCamera)
        self.metadataFromCamera = nil
    }
}

// MARK: - Selection

extension DKImagePickerController {
    
    @objc open func selectImage(atIndexPath index: IndexPath) {
        if let rootVC = self.viewControllers.first as? DKAssetGroupDetailVC {
            rootVC.selectAsset(atIndex: index)
            rootVC.collectionView?.reloadData()
        }
    }
    
    @objc open func deselectAssetAtIndex(_ index: Int) {
        let asset = self.selectedAssets[index]
        self.deselectAsset(asset)
    }
    
    @objc open func deselectAsset(_ asset: DKAsset) {
        self.deselectImage(asset)
        if let rootVC = self.viewControllers.first as? DKAssetGroupDetailVC {
            rootVC.collectionView?.reloadData()
        }
    }
    
    @objc open func deselectAllAssets() {
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
    
    @objc open func selectImage(_ asset: DKAsset) {
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
    
    @objc open func deselectImage(_ asset: DKAsset) {
        self.selectedAssets.remove(at: selectedAssets.index(of: asset)!)
        self.UIDelegate.imagePickerController(self, didDeselectAssets: [asset])
        self.triggerSelectedChanged()
    }

}

// MARK: - Save Image
extension DKImagePickerController {
    
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
    
}

// MARK: - Orientation
extension DKImagePickerController {
    
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
    
}
