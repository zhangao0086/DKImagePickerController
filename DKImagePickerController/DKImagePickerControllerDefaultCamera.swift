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
	
	public weak var imagePickerController: DKImagePickerController!
	
	public lazy var doneButton: UIButton = {
		return self.createDoneButton()
	}()
	
	public func createDoneButton() -> UIButton {
		let button = UIButton(type: UIButtonType.custom)
		button.setTitleColor(UINavigationBar.appearance().tintColor ?? self.imagePickerController.navigationBar.tintColor, for: UIControlState())
		button.addTarget(self.imagePickerController, action: #selector(DKImagePickerController.done), for: UIControlEvents.touchUpInside)
		self.updateDoneButtonTitle(button)
		
		return button
	}
	
	// Delegate methods...
	
	public func prepareLayout(_ imagePickerController: DKImagePickerController, vc: UIViewController) {
		self.imagePickerController = imagePickerController
		vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.doneButton)
	}
	
	public func imagePickerControllerCreateCamera(_ imagePickerController: DKImagePickerController,
	                                              didCancel: (() -> Void),
	                                              didFinishCapturingImage: ((_ image: UIImage) -> Void),
	                                              didFinishCapturingVideo: ((_ videoURL: URL) -> Void)) -> UIViewController {
		
		let camera = DKCamera()
		
		camera.didCancel = { () -> Void in
			didCancel()
		}
		
		camera.didFinishCapturingImage = { (image) in
			didFinishCapturingImage(image)
		}
		
		self.checkCameraPermission(camera)
	
		return camera
	}
	
	public func layoutForImagePickerController(_ imagePickerController: DKImagePickerController) -> UICollectionViewLayout.Type {
		return DKAssetGroupGridLayout.self
	}
	
	public func imagePickerControllerCameraImage() -> UIImage {
		return DKImageResource.cameraImage()
	}
	
	public func imagePickerController(_ imagePickerController: DKImagePickerController,
	                                  showsCancelButtonForVC vc: UIViewController) {
		vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
		                                                      target: imagePickerController,
		                                                      action: #selector(DKImagePickerController.dismiss))
	}
	
	public func imagePickerController(_ imagePickerController: DKImagePickerController,
	                                  hidesCancelButtonForVC vc: UIViewController) {
		vc.navigationItem.leftBarButtonItem = nil
	}
	
	public func imagePickerController(_ imagePickerController: DKImagePickerController, didSelectAsset: DKAsset) {
		self.updateDoneButtonTitle(self.doneButton)
	}
	
	public func imagePickerController(_ imagePickerController: DKImagePickerController, didDeselectAsset: DKAsset) {
		self.updateDoneButtonTitle(self.doneButton)
	}
	
	public func imagePickerControllerDidReachMaxLimit(_ imagePickerController: DKImagePickerController) {
		UIAlertView(title: DKImageLocalizedStringWithKey("maxLimitReached"),
		            message: String(format: DKImageLocalizedStringWithKey("maxLimitReachedMessage"), imagePickerController.maxSelectableCount),
		            delegate: nil,
		            cancelButtonTitle: DKImageLocalizedStringWithKey("ok"))
			.show()
	}
	
	public func imagePickerControllerFooterView(_ imagePickerController: DKImagePickerController) -> UIView? {
		return nil
	}
	
	// Internal
	
	public func checkCameraPermission(_ camera: DKCamera) {
		func cameraDenied() {
			DispatchQueue.main.async {
				let permissionView = DKPermissionView.permissionView(.camera)
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
	
	public func updateDoneButtonTitle(_ button: UIButton) {
		if self.imagePickerController.selectedAssets.count > 0 {
			button.setTitle(String(format: DKImageLocalizedStringWithKey("select"), self.imagePickerController.selectedAssets.count), for: UIControlState())
		} else {
			button.setTitle(DKImageLocalizedStringWithKey("done"), for: UIControlState())
		}
		
		button.sizeToFit()
	}
	
}
