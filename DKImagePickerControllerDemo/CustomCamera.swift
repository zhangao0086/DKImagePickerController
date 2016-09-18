//
//  CustomCamera.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 16/3/17.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

import UIKit
import MobileCoreServices

open class CustomUIDelegate: DKImagePickerControllerDefaultUIDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	var didCancel: (() -> Void)?
	var didFinishCapturingImage: ((_ image: UIImage) -> Void)?
	var didFinishCapturingVideo: ((_ videoURL: URL) -> Void)?
	
	open override func imagePickerControllerCreateCamera(_ imagePickerController: DKImagePickerController,
	                                                       didCancel: @escaping (() -> Void),
	                                                       didFinishCapturingImage: @escaping ((_ image: UIImage) -> Void),
	                                                       didFinishCapturingVideo: @escaping ((_ videoURL: URL) -> Void)
	                                                       ) -> UIViewController {
		self.didCancel = didCancel
		self.didFinishCapturingImage = didFinishCapturingImage
		self.didFinishCapturingVideo = didFinishCapturingVideo
		
		let picker = UIImagePickerController()
		picker.delegate = self
		picker.sourceType = .camera
		picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
		
		return picker
	}
	
	// MARK: - UIImagePickerControllerDelegate methods
	
	open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		let mediaType = info[UIImagePickerControllerMediaType] as! String
		
		if mediaType == kUTTypeImage as String {
			let image = info[UIImagePickerControllerOriginalImage] as! UIImage
			self.didFinishCapturingImage?(image)
		} else if mediaType == kUTTypeMovie as String {
			let videoURL = info[UIImagePickerControllerMediaURL] as! URL
			self.didFinishCapturingVideo?(videoURL)
		}
	}
	
	open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		self.didCancel?()
	}
	
}
