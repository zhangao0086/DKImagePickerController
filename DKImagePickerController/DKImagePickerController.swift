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
     The picker calls -prepareLayout once at its first layout as the first message to the UIDelegate instance.
	*/
	func prepareLayout(imagePickerController: DKImagePickerController, vc: UIViewController)
	
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
     Called after the user changes the selection.
	*/
	@available(*, deprecated=1.0, message="Use imagePickerController(_:didSelectAssets:) instead.") func imagePickerController(imagePickerController: DKImagePickerController, didSelectAsset: DKAsset)
    func imagePickerController(imagePickerController: DKImagePickerController, didSelectAssets: [DKAsset])
	
	/**
     Called after the user changes the selection.
	*/
	@available(*, deprecated=1.0, message="Use imagePickerController(_:didDeselectAssets:) instead.") func imagePickerController(imagePickerController: DKImagePickerController, didDeselectAsset: DKAsset)
    func imagePickerController(imagePickerController: DKImagePickerController, didDeselectAssets: [DKAsset])
	
	/**
     Called when the count of the selectedAssets did reach `maxSelectableCount`.
	*/
	func imagePickerControllerDidReachMaxLimit(imagePickerController: DKImagePickerController)
	
	/**
     Accessory view below content. default is nil.
	*/
	func imagePickerControllerFooterView(imagePickerController: DKImagePickerController) -> UIView?
    
    /**
     The camera image to be displayed in the album's first cell.
     */
    func imagePickerControllerCameraImage() -> UIImage
    
    /**
     Set the color of the number when object is selected.
     */
    func imagePickerControllerCheckedNumberColor() -> UIColor
    
    /**
     Set the font of the number when object is selected.
     */
    func imagePickerControllerCheckedNumberFont() -> UIFont
    
    /**
     Set the color of the object outline when object is selected.
     */
    func imagePickerControllerCheckedImageTintColor() -> UIColor?
    
    /**
     Set the color of the background of the collection view.
     */
    func imagePickerControllerCollectionViewBackgroundColor() -> UIColor

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

	public var UIDelegate: DKImagePickerControllerUIDelegate = {
		return DKImagePickerControllerDefaultUIDelegate()
	}()

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
    public var sourceType: DKImagePickerControllerSourceType = .Both {
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
					rootVC.collectionView.reloadData()
				}
			}
        }
    }
        
    public var selectedAssets = [DKAsset]()
	
    public convenience init() {
		let rootVC = UIViewController()
        self.init(rootViewController: rootVC)
		
		self.preferredContentSize = CGSize(width: 680, height: 600)
		
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
                self.navigationBarHidden = false
				let rootVC = DKAssetGroupDetailVC()
				rootVC.imagePickerController = self
                
				self.UIDelegate.prepareLayout(self, vc: rootVC)
				self.updateCancelButtonForVC(rootVC)
				self.setViewControllers([rootVC], animated: false)
				if self.defaultSelectedAssets?.count > 0 {
					self.UIDelegate.imagePickerController(self, didSelectAssets: [self.defaultSelectedAssets!.last!])
				}
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
							self.selectImage(DKAsset(originalAsset: newAsset))
						}
					} else {
						if self.sourceType != .Camera {
							self.dismissViewControllerAnimated(true, completion: nil)
						}
						self.selectImage(DKAsset(image: image))
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
							self.selectImage(DKAsset(originalAsset: newAsset))
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
		self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
			self.didCancel?()
		})
	}
	
    public func done() {
		self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
			self.didSelectAssets?(assets: self.selectedAssets)
		})
    }
    
    // MARK: - Selection
    
    public func deselectAssetAtIndex(index: Int) {
        let asset = self.selectedAssets[index]
        self.deselectAsset(asset)
    }
    
    public func deselectAsset(asset: DKAsset) {
        self.deselectImage(asset)
        if let rootVC = self.viewControllers.first as? DKAssetGroupDetailVC {
            rootVC.collectionView?.reloadData()
        }
    }
    
    public func deselectAllAssets() {
        if self.selectedAssets.count > 0 {
            let assets = self.selectedAssets
            self.selectedAssets.removeAll()
            self.UIDelegate.imagePickerController(self, didDeselectAssets: assets)
            if let rootVC = self.viewControllers.first as? DKAssetGroupDetailVC {
                rootVC.collectionView?.reloadData()
            }
        }
    }
	
	internal func selectImage(asset: DKAsset) {
        if self.singleSelect {
            self.deselectAllAssets()
            self.selectedAssets.append(asset)
            self.done()
        } else {
            self.selectedAssets.append(asset)
            if self.sourceType == .Camera {
                self.done()
            } else {
                self.UIDelegate.imagePickerController(self, didSelectAssets: [asset])
            }
        }
	}
	
	internal func deselectImage(asset: DKAsset) {
		self.selectedAssets.removeAtIndex(selectedAssets.indexOf(asset)!)
		self.UIDelegate.imagePickerController(self, didDeselectAssets: [asset])
	}
    
    // MARK: - Handles Orientation

    public override func shouldAutorotate() -> Bool {
		return self.allowsLandscape && self.sourceType != .Camera ? true : false
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		if self.allowsLandscape {
			return super.supportedInterfaceOrientations()
		} else {
			return UIInterfaceOrientationMask.Portrait
		}
    }
}
