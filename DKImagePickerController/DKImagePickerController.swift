//
//  DKImagePickerController.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 14-10-2.
//  Copyright (c) 2014年 ZhangAo. All rights reserved.
//

import UIKit
import Photos

/**
* allPhotos: Get all photos assets in the assets group.
* allVideos: Get all video assets in the assets group.
* allAssets: Get all assets in the group.
*/
@objc
public enum DKImagePickerControllerAssetType : Int {
	
	case AllPhotos, AllVideos, AllAssets
}

public struct DKImagePickerControllerSourceType : OptionSetType {
    
    private var value: UInt = 0
    init(_ value: UInt) { self.value = value }
    // MARK: _RawOptionSetType
    public init(rawValue value: UInt) { self.value = value }
    // MARK: NilLiteralConvertible
    public init(nilLiteral: ()) { self.value = 0 }
    // MARK: RawRepresentable
    public var rawValue: UInt { return self.value }
    // MARK: BitwiseOperationsType
    public static var allZeros: DKImagePickerControllerSourceType { return self.init(0) }
    
    public static var Camera: DKImagePickerControllerSourceType { return self.init(1 << 0) }
    public static var Photo: DKImagePickerControllerSourceType { return self.init(1 << 1) }
}

// MARK: - Public DKImagePickerController

/**
 * The `DKImagePickerController` class offers the all public APIs which will affect the UI.
 */
public class DKImagePickerController: UINavigationController {
    
    /// Forces selection of tapped image immediatly.
	public var singleSelect = false
		
    /// The maximum count of assets which the user will be able to select.
    public var maxSelectableCount = 999
	
	/// Set the defaultAssetGroup to specify which album is the default asset group.
	public var defaultAssetGroup: PHAssetCollectionSubtype?
	
	/// The types of PHAssetCollection to display in the picker.
	public var assetGroupTypes: [PHAssetCollectionSubtype] = [
		.SmartAlbumUserLibrary,
		.SmartAlbumFavorites,
		.AlbumRegular
		] {
		didSet {
			getImageManager().groupDataManager.assetGroupTypes = self.assetGroupTypes
		}
	}
	
	/// Set the showsEmptyAlbums to specify whether or not the empty albums is shown in the picker.
	public var showsEmptyAlbums = true {
		didSet {
			getImageManager().groupDataManager.showsEmptyAlbums = self.showsEmptyAlbums
		}
	}
	
	/// The type of picker interface to be displayed by the controller.
	public var assetType: DKImagePickerControllerAssetType = .AllAssets {
		didSet {
			getImageManager().groupDataManager.assetFetchOptions = self.createAssetFetchOptions()
		}
	}
	
    /// If sourceType is Camera will cause the assetType & maxSelectableCount & allowMultipleTypes & defaultSelectedAssets to be ignored.
    public var sourceType: DKImagePickerControllerSourceType = [.Camera, .Photo]
    
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
			if let rootVC =  self.viewControllers.first {
				self.updateCancelButtonForVC(rootVC)
			}
		}
	}
	
    /// The callback block is executed when user pressed the select button.
    public var didSelectAssets: ((assets: [DKAsset]) -> Void)?
	
    /// It will have selected the specific assets.
    public var defaultSelectedAssets: [DKAsset]? {
        didSet {
			self.selectedAssets = self.defaultSelectedAssets ?? []
			
			if let rootVC = self.viewControllers.first as? DKAssetGroupDetailVC {
				rootVC.collectionView?.reloadData()
			}
			self.updateDoneButtonTitle()
        }
    }
    
    internal var selectedAssets = [DKAsset]()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: UIButtonType.Custom)
		button.setTitleColor(UINavigationBar.appearance().tintColor ?? self.navigationBar.tintColor, forState: UIControlState.Normal)
        button.addTarget(self, action: "done", forControlEvents: UIControlEvents.TouchUpInside)
      
        return button
    }()
    
    public convenience init() {
		let rootVC = UIViewController()
        self.init(rootViewController: rootVC)
		
		self.preferredContentSize = CGSize(width: 680, height: 600)
		
        rootVC.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.doneButton)
        rootVC.navigationItem.hidesBackButton = true
		
		getImageManager().groupDataManager.assetGroupTypes = self.assetGroupTypes
		getImageManager().groupDataManager.assetFetchOptions = self.createAssetFetchOptions()
		getImageManager().groupDataManager.showsEmptyAlbums = self.showsEmptyAlbums
		getImageManager().autoDownloadWhenAssetIsInCloud = self.autoDownloadWhenAssetIsInCloud
		
        self.updateDoneButtonTitle()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
		getImageManager().invalidate()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
	
	private var hasInitialized = false
	override public func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if !hasInitialized {
			hasInitialized = true
			
			if !self.sourceType.contains(.Photo) {
				self.navigationBarHidden = true
				self.setViewControllers([self.createCamera()], animated: false)
			} else {
				let rootVC = DKAssetGroupDetailVC()
				self.updateCancelButtonForVC(rootVC)
				self.setViewControllers([rootVC], animated: false)
				rootVC.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.doneButton)
			}
		}
	}
	
	private lazy var assetFetchOptions: PHFetchOptions = {
		let assetFetchOptions = PHFetchOptions()
		assetFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
		return assetFetchOptions
	}()
	
	private func createAssetFetchOptions() -> PHFetchOptions? {
		if self.assetType != .AllAssets {
			self.assetFetchOptions.predicate = NSPredicate(format: "mediaType == %d",
				self.assetType == .AllPhotos ? PHAssetMediaType.Image.rawValue : PHAssetMediaType.Video.rawValue)
		}
		return self.assetFetchOptions
	}
	
	private func updateCancelButtonForVC(vc: UIViewController) {
		if self.showsCancelButton {
			vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel,
				target: self,
				action: "dismiss")
		} else {
			vc.navigationItem.leftBarButtonItem = nil
		}
	}
	
    private func updateDoneButtonTitle() {
        if self.selectedAssets.count > 0 {
            self.doneButton.setTitle(DKImageLocalizedStringWithKey("select") + "(\(selectedAssets.count))", forState: UIControlState.Normal)
        } else {
            self.doneButton.setTitle(DKImageLocalizedStringWithKey("done"), forState: UIControlState.Normal)
        }
        self.doneButton.sizeToFit()
    }
	
	private func createCamera() -> DKCamera {
		let camera = DKCamera()
		
		camera.didCancel = {[unowned camera] () -> Void in
			camera.dismissViewControllerAnimated(true, completion: nil)
		}
		
		camera.didFinishCapturingImage = { [unowned self] (image) in
			var newImageIdentifier: String!
			PHPhotoLibrary.sharedPhotoLibrary().performChanges(
				{ () in
					let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
					newImageIdentifier = assetRequest.placeholderForCreatedAsset!.localIdentifier
				}, completionHandler: { (success, error) -> Void in
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						if success {
							if let newAsset = PHAsset.fetchAssetsWithLocalIdentifiers([newImageIdentifier], options: nil).firstObject as? PHAsset {
								self.dismissViewControllerAnimated(true, completion: nil)
								self.selectedImage(DKAsset(originalAsset: newAsset), needsToDismiss: true)
							}
						} else {
							self.dismissViewControllerAnimated(true, completion: nil)
							self.selectedImage(DKAsset(image: image), needsToDismiss: true)
						}
					})
			})
		}
		self.checkCameraPermission(camera)
		
		return camera
	}
	
	internal func checkCameraPermission(camera: DKCamera) {
		func cameraDenied() {
			dispatch_async(dispatch_get_main_queue()) {
				let permissionView = DKPermissionView.permissionView(.Camera)
				camera.cameraOverlayView = permissionView
			}
		}
		
		func setup() {
			camera.cameraOverlayView = nil
		}
		
		DKCamera.checkCameraPermission { granted in
			granted ? setup() : cameraDenied()
		}
	}
	
	internal func presentCamera() {
		self.presentViewController(self.createCamera(), animated: true, completion: nil)
	}
	
	internal func dismiss() {
		self.dismissViewControllerAnimated(true, completion: nil)
		self.didCancel?()
	}
	
    internal func done() {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.didSelectAssets?(assets: self.selectedAssets)
    }
    
    // MARK: - Selection Image
	
	internal func selectedImage(asset: DKAsset) {
		self.selectedImage(asset, needsToDismiss: false)
	}
	
	internal func selectedImage(asset: DKAsset, needsToDismiss: Bool) {
		selectedAssets.append(asset)
		if needsToDismiss {
			self.done()
		} else if self.singleSelect {
			self.done()
		} else {
			updateDoneButtonTitle()
		}
	}
	
	internal func unselectedImage(asset: DKAsset) {
		selectedAssets.removeAtIndex(selectedAssets.indexOf(asset)!)
		updateDoneButtonTitle()
	}
	
    // MARK: - Handles Orientation

    public override func shouldAutorotate() -> Bool {
		return self.allowsLandscape ? true : false
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		if self.allowsLandscape {
			return super.supportedInterfaceOrientations()
		} else {
			return UIInterfaceOrientationMask.Portrait
		}
    }
}

// MARK: - Utilities

internal extension UIViewController {
    
    var imagePickerController: DKImagePickerController? {
        get {
            let nav = self.navigationController
            if nav is DKImagePickerController {
                return nav as? DKImagePickerController
            } else {
                return nil
            }
        }
    }
    
}
