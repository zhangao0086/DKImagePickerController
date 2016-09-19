//
//  DKImagePickerControllerDefaultUIDelegate.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 16/3/7.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

import UIKit

@objc
open class DKImagePickerControllerDefaultUIDelegate: NSObject, DKImagePickerControllerUIDelegate {
	
	open weak var imagePickerController: DKImagePickerController!
	
	open lazy var doneButton: UIButton = {
		return self.createDoneButton()
	}()
	
	open func createDoneButton() -> UIButton {
		let button = UIButton(type: UIButtonType.custom)
		button.setTitleColor(UINavigationBar.appearance().tintColor ?? self.imagePickerController.navigationBar.tintColor, for: .normal)
		button.addTarget(self.imagePickerController, action: #selector(DKImagePickerController.done), for: UIControlEvents.touchUpInside)
		self.updateDoneButtonTitle(button)
		
		return button
	}
    
    open func updateDoneButtonTitle(_ button: UIButton) {
        if self.imagePickerController.selectedAssets.count > 0 {
            button.setTitle(String(format: DKImageLocalizedStringWithKey("select"), self.imagePickerController.selectedAssets.count), for: .normal)
        } else {
            button.setTitle(DKImageLocalizedStringWithKey("done"), for: .normal)
        }
        
        button.sizeToFit()
    }
	
	// Delegate methods...
	
	open func prepareLayout(_ imagePickerController: DKImagePickerController, vc: UIViewController) {
		self.imagePickerController = imagePickerController
		vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.doneButton)
	}
    
	open func imagePickerControllerCreateCamera(_ imagePickerController: DKImagePickerController,
	                                              didCancel: @escaping (() -> Void),
	                                              didFinishCapturingImage: @escaping ((_ image: UIImage) -> Void),
	                                              didFinishCapturingVideo: @escaping ((_ videoURL: URL) -> Void)) -> UIViewController {
		
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
	
	open func layoutForImagePickerController(_ imagePickerController: DKImagePickerController) -> UICollectionViewLayout.Type {
		return DKAssetGroupGridLayout.self
	}
	
	open func imagePickerController(_ imagePickerController: DKImagePickerController,
	                                  showsCancelButtonForVC vc: UIViewController) {
		vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
		                                                      target: imagePickerController,
		                                                      action: #selector(imagePickerController.dismiss as (Void) -> Void))
	}
	
	open func imagePickerController(_ imagePickerController: DKImagePickerController,
	                                  hidesCancelButtonForVC vc: UIViewController) {
		vc.navigationItem.leftBarButtonItem = nil
	}
	
	open func imagePickerController(_ imagePickerController: DKImagePickerController, didSelectAsset: DKAsset) {
		self.updateDoneButtonTitle(self.doneButton)
	}
    
    open func imagePickerController(_ imagePickerController: DKImagePickerController, didSelectAssets: [DKAsset]) {
        self.updateDoneButtonTitle(self.doneButton)
    }
	
	open func imagePickerController(_ imagePickerController: DKImagePickerController, didDeselectAsset: DKAsset) {
		self.updateDoneButtonTitle(self.doneButton)
	}
    
    open func imagePickerController(_ imagePickerController: DKImagePickerController, didDeselectAssets: [DKAsset]) {
        self.updateDoneButtonTitle(self.doneButton)
    }
	
	open func imagePickerControllerDidReachMaxLimit(_ imagePickerController: DKImagePickerController) {
        let alert = UIAlertController(title: DKImageLocalizedStringWithKey("maxLimitReached")
            , message:String(format: DKImageLocalizedStringWithKey("maxLimitReachedMessage"), imagePickerController.maxSelectableCount)
            , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: DKImageLocalizedStringWithKey("ok"), style: .cancel) { _ in })
        imagePickerController.present(alert, animated: true){}
	}
	
	open func imagePickerControllerFooterView(_ imagePickerController: DKImagePickerController) -> UIView? {
		return nil
	}
    
    open func imagePickerControllerCameraImage() -> UIImage {
        return DKImageResource.cameraImage()
    }
    
    open func imagePickerControllerCheckedNumberColor() -> UIColor {
        return UIColor.white
    }
    
    open func imagePickerControllerCheckedNumberFont() -> UIFont {
        return UIFont.boldSystemFont(ofSize: 14)
    }
    
    open func imagePickerControllerCheckedImageTintColor() -> UIColor? {
        return nil
    }
    
    open func imagePickerControllerCollectionViewBackgroundColor() -> UIColor {
        return UIColor.white
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
		
}
