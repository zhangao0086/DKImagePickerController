//
//  DKImagePickerControllerDefaultUIDelegate.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 16/3/7.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

import UIKit

@objc
public class DKImagePickerControllerSTPhotoImporter: NSObject, DKImagePickerControllerUIDelegate {
	
	public weak var imagePickerController: DKImagePickerController!
	
	public lazy var doneButton: UIButton = {
		return self.createDoneButton()
	}()
	
	public func createDoneButton() -> UIButton {
		let button = UIButton(type: UIButtonType.Custom)
		button.setTitleColor(UINavigationBar.appearance().tintColor ?? self.imagePickerController.navigationBar.tintColor, forState: UIControlState.Normal)
		button.addTarget(self.imagePickerController, action: #selector(DKImagePickerController.done), forControlEvents: UIControlEvents.TouchUpInside)
		self.updateDoneButtonTitle(button)
		
		return button
	}
	
	// Delegate methods...
	
	public func prepareLayout(imagePickerController: DKImagePickerController, vc: UIViewController) {
		self.imagePickerController = imagePickerController
		vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.doneButton)
	}
	
	public func imagePickerControllerCreateCamera(imagePickerController: DKImagePickerController,
	                                              didCancel: (() -> Void),
	                                              didFinishCapturingImage: ((image: UIImage) -> Void),
	                                              didFinishCapturingVideo: ((videoURL: NSURL) -> Void)) -> UIViewController {
		
		let camera = DKCamera()
		
		camera.didCancel = { () -> Void in
			didCancel()
		}
		
		camera.didFinishCapturingImage = { (image) in
			didFinishCapturingImage(image: image)
		}
		
		self.checkCameraPermission(camera)
	
		return camera
	}
	
	public func layoutForImagePickerController(imagePickerController: DKImagePickerController) -> UICollectionViewLayout.Type {
		return DKAssetGroupGridLayout.self
	}
	
	public func imagePickerController(imagePickerController: DKImagePickerController,
	                                  showsCancelButtonForVC vc: UIViewController) {
		vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel,
		                                                      target: imagePickerController,
		                                                      action: #selector(DKImagePickerController.dismiss))
	}
	
	public func imagePickerController(imagePickerController: DKImagePickerController,
	                                  hidesCancelButtonForVC vc: UIViewController) {
		vc.navigationItem.leftBarButtonItem = nil
	}
	
	public func imagePickerController(imagePickerController: DKImagePickerController, didSelectAsset: DKAsset) {
		self.updateDoneButtonTitle(self.doneButton)
	}
    
    public func imagePickerController(imagePickerController: DKImagePickerController, didSelectAssets: [DKAsset]) {
        self.updateDoneButtonTitle(self.doneButton)
    }
	
	public func imagePickerController(imagePickerController: DKImagePickerController, didDeselectAsset: DKAsset) {
		self.updateDoneButtonTitle(self.doneButton)
	}
    
    public func imagePickerController(imagePickerController: DKImagePickerController, didDeselectAssets: [DKAsset]) {
        self.updateDoneButtonTitle(self.doneButton)
    }
	
	public func imagePickerControllerDidReachMaxLimit(imagePickerController: DKImagePickerController) {
		UIAlertView(title: DKImageLocalizedStringWithKey("maxLimitReached"),
		            message: String(format: DKImageLocalizedStringWithKey("maxLimitReachedMessage"), imagePickerController.maxSelectableCount),
		            delegate: nil,
		            cancelButtonTitle: DKImageLocalizedStringWithKey("ok"))
			.show()
	}
	
	public func imagePickerControllerFooterView(imagePickerController: DKImagePickerController) -> UIView? {
		return nil
	}
    
    public func imagePickerControllerCameraImage() -> UIImage {
        return DKImageResource.cameraImage()
    }

//	public var checkedNumberColor:UIColor?
	public lazy var checkedNumberColor: UIColor = { return UIColor.whiteColor() }()
	public func imagePickerControllerCheckedNumberColor() -> UIColor {
		return UIColor.redColor()
    }

	public var checkedNumberFont:UIFont?
    public func imagePickerControllerCheckedNumberFont() -> UIFont {
		return self.checkedNumberFont ?? UIFont.systemFontOfSize(24)
    }
    
    public func imagePickerControllerCheckedImageTintColor() -> UIColor? {
        return nil
    }

//	public var teeeee:Int

	public var collectionViewBackgroundColor: UIColor?// = { return UIColor.whiteColor() }()
    public func imagePickerControllerCollectionViewBackgroundColor() -> UIColor {
		return UIColor.redColor()
//		print(teeeee)
		print(self.collectionViewBackgroundColor)
        return self.collectionViewBackgroundColor!
    }
	
	// Internal
	
	public func checkCameraPermission(camera: DKCamera) {
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
	
	public func updateDoneButtonTitle(button: UIButton) {
		if self.imagePickerController.selectedAssets.count > 0 {
			button.hidden = false
			button.setTitle(String(format: DKImageLocalizedStringWithKey("select"), self.imagePickerController.selectedAssets.count), forState: UIControlState.Normal)
		} else {
			button.hidden = true
			button.setTitle(DKImageLocalizedStringWithKey("done"), forState: UIControlState.Normal)
		}
		
		button.sizeToFit()
	}
	
}