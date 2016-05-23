//
//  DKImagePickerControllerDefaultCamera.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 16/3/7.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

import UIKit

@objc
public class DKImagePickerControllerDefaultUIDelegate: NSObject, DKImagePickerControllerUIDelegate {
	
	private var doneButton: UIButton?
	
	public func doneButtonForPickerController(imagePickerController: DKImagePickerController) -> UIButton {
		if self.doneButton == nil {
			let button = UIButton(type: UIButtonType.Custom)
			button.setTitleColor(UINavigationBar.appearance().tintColor ?? imagePickerController.navigationBar.tintColor, forState: UIControlState.Normal)
			button.addTarget(imagePickerController, action: #selector(DKImagePickerController.done), forControlEvents: UIControlEvents.TouchUpInside)
			
			self.doneButton = button
			
			self.updateDoneButtonTitleForImagePickerController(imagePickerController)
		}
		
		return self.doneButton!
	}
	
	// Delegate methods...
	
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
	
	public func imagePickerControllerCameraImage() -> UIImage {
		return DKImageResource.cameraImage()
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
	
	public func imagePickerController(imagePickerController: DKImagePickerController, showsDoneButtonForVC vc: UIViewController) {
		vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.doneButtonForPickerController(imagePickerController))
	}
	
	public func imagePickerController(imagePickerController: DKImagePickerController, didSelectAsset: DKAsset) {
		self.updateDoneButtonTitleForImagePickerController(imagePickerController)
	}
	
	public func imagePickerController(imagePickerController: DKImagePickerController, didDeselectAsset: DKAsset) {
		self.updateDoneButtonTitleForImagePickerController(imagePickerController)
	}
	
	public func imagePickerControllerDidReachMaxLimit(imagePickerController: DKImagePickerController) {
		UIAlertView(title: DKImageLocalizedStringWithKey("maxLimitReached"),
		            message: String(format: DKImageLocalizedStringWithKey("maxLimitReachedMessage"), DKImagePickerController.sharedInstance().maxSelectableCount),
		            delegate: nil,
		            cancelButtonTitle: DKImageLocalizedStringWithKey("ok"))
			.show()
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
	
	public func updateDoneButtonTitleForImagePickerController(imagePickerController: DKImagePickerController) {
		if imagePickerController.selectedAssets.count > 0 {
			self.doneButtonForPickerController(imagePickerController).setTitle(String(format: DKImageLocalizedStringWithKey("select"), imagePickerController.selectedAssets.count), forState: UIControlState.Normal)
		} else {
			self.doneButtonForPickerController(imagePickerController).setTitle(DKImageLocalizedStringWithKey("done"), forState: UIControlState.Normal)
		}
		
		self.doneButton?.sizeToFit()
	}
	
}
