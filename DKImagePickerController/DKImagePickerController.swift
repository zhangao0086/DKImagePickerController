//
//  DKImagePickerController.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 14-10-2.
//  Copyright (c) 2014年 ZhangAo. All rights reserved.
//

import UIKit
import Photos

@objc
public protocol DKImagePickerControllerUIDelegate {
	
	/**
		Returns a custom camera.

		**Note**

		If you are using a UINavigationController as the custom camera,
		you should also set the picker's modalPresentationStyle to .OverCurrentContext, like this:
		
		```
		pickerController.modalPresentationStyle = .OverCurrentContext
		```
	*/
	func imagePickerControllerCreateCamera(imagePickerController: DKImagePickerController,
	                                       didCancel: (() -> Void),
	                                       didFinishCapturingImage: ((image: UIImage) -> Void),
	                                       didFinishCapturingVideo: ((videoURL: NSURL) -> Void)) -> UIViewController
	
	/**
		The camera image to be displayed in the album's first cell.
	*/
	func imagePickerControllerCameraImage() -> UIImage
	
	/**
		The layout is to provide information about the position and visual state of items in the collection view.
	*/
	func layoutForImagePickerController(imagePickerController: DKImagePickerController) -> UICollectionViewLayout.Type
	
	/**
		Called when the user needs to show the cancel button.
	*/
	func imagePickerController(imagePickerController: DKImagePickerController, showsCancelButtonForVC vc: UIViewController)
	
	/**
		Called when the user needs to hide the cancel button.
	*/
	func imagePickerController(imagePickerController: DKImagePickerController, hidesCancelButtonForVC vc: UIViewController)
	
	/**
		Called when the user needs to show the done button.
	*/
	func imagePickerController(imagePickerController: DKImagePickerController, showsDoneButtonForVC vc: UIViewController)
	
	/**
		Called after the user changes the selection.
	*/
	func imagePickerController(imagePickerController: DKImagePickerController, didSelectAsset: DKAsset)
	
	/**
		Called after the user changes the selection.
	*/
	func imagePickerController(imagePickerController: DKImagePickerController, didDeselectAsset: DKAsset)
	
	/**
		Called when the selectedAssets'count did reach `maxSelectableCount`.
	*/
	func imagePickerControllerDidReachMaxLimit(imagePickerController: DKImagePickerController)
	
}

/**
- AllPhotos: Get all photos assets in the assets group.
- AllVideos: Get all video assets in the assets group.
- AllAssets: Get all assets in the group.
*/
@objc
public enum DKImagePickerControllerAssetType : Int {
	case AllPhotos, AllVideos, AllAssets
}

@objc
public enum DKImagePickerControllerSourceType : Int {
	case Camera, Photo, Both
}

// MARK: - Public DKImagePickerController

/**
 * The `DKImagePickerController` class offers the all public APIs which will affect the UI.
 */
public class DKImagePickerController : UINavigationController {
	
	private weak static var imagePickerController : DKImagePickerController?
	internal static func sharedInstance() -> DKImagePickerController {
		return DKImagePickerController.imagePickerController!;
	}

	public var UIDelegate: DKImagePickerControllerUIDelegate = DKImagePickerControllerDefaultUIDelegate()
	
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
    public var sourceType: DKImagePickerControllerSourceType = .Both
    
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
			if self.defaultSelectedAssets?.count > 0 {
				self.selectedAssets = self.defaultSelectedAssets ?? []
				
				if let rootVC = self.viewControllers.first as? DKAssetGroupDetailVC {
					rootVC.collectionView?.reloadData()
				}
				
				self.UIDelegate.imagePickerController(self, didSelectAsset: self.defaultSelectedAssets!.last!)
			}
        }
    }
    
    public var selectedAssets = [DKAsset]()
	
    public convenience init() {
		let rootVC = UIViewController()
        self.init(rootViewController: rootVC)
		
		DKImagePickerController.imagePickerController = self
		
		self.preferredContentSize = CGSize(width: 680, height: 600)
		
		self.UIDelegate.imagePickerController(self, showsDoneButtonForVC: rootVC)
        rootVC.navigationItem.hidesBackButton = true
		
		getImageManager().groupDataManager.assetGroupTypes = self.assetGroupTypes
		getImageManager().groupDataManager.assetFetchOptions = self.createAssetFetchOptions()
		getImageManager().groupDataManager.showsEmptyAlbums = self.showsEmptyAlbums
		getImageManager().autoDownloadWhenAssetIsInCloud = self.autoDownloadWhenAssetIsInCloud
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
			
			if self.sourceType == .Camera {
				self.navigationBarHidden = true
				
				let camera = self.createCamera()
				if camera is UINavigationController {
					self.presentViewController(self.createCamera(), animated: true, completion: nil)
					self.setViewControllers([], animated: false)
				} else {
					self.setViewControllers([camera], animated: false)
				}
			} else {
				let rootVC = DKAssetGroupDetailVC()
				self.updateCancelButtonForVC(rootVC)
				self.setViewControllers([rootVC], animated: false)
				self.UIDelegate.imagePickerController(self, showsDoneButtonForVC: rootVC)
			}
		}
	}
	
	private lazy var assetFetchOptions: PHFetchOptions = {
		let assetFetchOptions = PHFetchOptions()
		assetFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
		return assetFetchOptions
	}()
	
	private func createAssetFetchOptions() -> PHFetchOptions? {
		
		let createImagePredicate = { () -> NSPredicate in
			var imagePredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.Image.rawValue)
			if let imageFetchPredicate = self.imageFetchPredicate {
				imagePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [imagePredicate, imageFetchPredicate])
			}
	
			return imagePredicate
		}
		
		let createVideoPredicate = { () -> NSPredicate in
			var videoPredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.Video.rawValue)
			if let videoFetchPredicate = self.videoFetchPredicate {
				videoPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [videoPredicate, videoFetchPredicate])
			}
			
			return videoPredicate
		}
		
		var predicate: NSPredicate?
		switch self.assetType {
		case .AllAssets:
			predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [createImagePredicate(), createVideoPredicate()])
		case .AllPhotos:
			predicate = createImagePredicate()
		case .AllVideos:
			predicate = createVideoPredicate()
		}
		
		self.assetFetchOptions.predicate = predicate
		
		return self.assetFetchOptions
	}
	
	private func updateCancelButtonForVC(vc: UIViewController) {
		if self.showsCancelButton {
			self.UIDelegate.imagePickerController(self, showsCancelButtonForVC: vc)
		} else {
			self.UIDelegate.imagePickerController(self, hidesCancelButtonForVC: vc)
		}
	}
	
	private func createCamera() -> UIViewController {
		
		let didCancel = { () in
			if self.presentedViewController != nil {
				self.dismissViewControllerAnimated(true, completion: nil)
			} else {
				self.dismiss()
			}
		}
	
		let didFinishCapturingImage = { (image: UIImage) in
			var newImageIdentifier: String!
			PHPhotoLibrary.sharedPhotoLibrary().performChanges( { () in
				let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
				newImageIdentifier = assetRequest.placeholderForCreatedAsset!.localIdentifier
			}, completionHandler: { (success, error) in
				dispatch_async(dispatch_get_main_queue(), {
					if success {
						if let newAsset = PHAsset.fetchAssetsWithLocalIdentifiers([newImageIdentifier], options: nil).firstObject as? PHAsset {
							if self.sourceType != .Camera || self.viewControllers.count == 0 {
								self.dismissViewControllerAnimated(true, completion: nil)
							}
							self.selectedImage(DKAsset(originalAsset: newAsset))
						}
					} else {
						if self.sourceType != .Camera {
							self.dismissViewControllerAnimated(true, completion: nil)
						}
						self.selectedImage(DKAsset(image: image))
					}
				})
			})
		}
		
		let didFinishCapturingVideo = { (videoURL: NSURL) in
			var newVideoIdentifier: String!
			PHPhotoLibrary.sharedPhotoLibrary().performChanges({ 
				let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(videoURL)
				newVideoIdentifier = assetRequest?.placeholderForCreatedAsset?.localIdentifier
			}, completionHandler: { (success, error) in
				dispatch_async(dispatch_get_main_queue(), { 
					if success {
						if let newAsset = PHAsset.fetchAssetsWithLocalIdentifiers([newVideoIdentifier], options: nil).firstObject as? PHAsset {
							if self.sourceType != .Camera || self.viewControllers.count == 0 {
								self.dismissViewControllerAnimated(true, completion: nil)
							}
							self.selectedImage(DKAsset(originalAsset: newAsset))
						}

					} else {
						self.dismissViewControllerAnimated(true, completion: nil)
					}
				})
			})
		}
		
		let camera = self.UIDelegate.imagePickerControllerCreateCamera(self,
		                                                               didCancel: didCancel,
		                                                               didFinishCapturingImage: didFinishCapturingImage,
		                                                               didFinishCapturingVideo: didFinishCapturingVideo)
		
		return camera
	}
	
	internal func presentCamera() {
		self.presentViewController(self.createCamera(), animated: true, completion: nil)
	}
	
	public func dismiss() {
		self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
		self.didCancel?()
	}
	
    public func done() {
		self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        self.didSelectAssets?(assets: self.selectedAssets)
    }
    
    // MARK: - Selection Image
	
	internal func selectedImage(asset: DKAsset) {
		selectedAssets.append(asset)
		
		if self.sourceType == .Camera {
			self.done()
		} else if self.singleSelect {
			self.done()
		} else {
			self.UIDelegate.imagePickerController(self, didSelectAsset: asset)
		}
	}
	
	internal func unselectedImage(asset: DKAsset) {
		selectedAssets.removeAtIndex(selectedAssets.indexOf(asset)!)
		self.UIDelegate.imagePickerController(self, didDeselectAsset: asset)
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
