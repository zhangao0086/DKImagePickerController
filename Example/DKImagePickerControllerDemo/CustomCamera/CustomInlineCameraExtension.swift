//
//  CustomInlineCamera.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 03/01/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import MobileCoreServices
import DKImagePickerController

open class CustomInlineCameraExtension: DKImageBaseExtension, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var didCancel: (() -> Void)?
    var didFinishCapturingImage: ((_ image: UIImage, _ metadata: [AnyHashable : Any]?) -> Void)?
    var didFinishCapturingVideo: ((_ videoURL: URL) -> Void)?
    
    open override func perform(with extraInfo: [AnyHashable : Any]) {
        guard let didFinishCapturingImage = extraInfo["didFinishCapturingImage"] as? ((UIImage, [AnyHashable : Any]?) -> Void)
            , let didFinishCapturingVideo = extraInfo["didFinishCapturingVideo"] as? ((URL) -> Void)
            , let didCancel = extraInfo["didCancel"] as? (() -> Void) else { return }

        self.didFinishCapturingImage = didFinishCapturingImage
        self.didFinishCapturingVideo = didFinishCapturingVideo
        self.didCancel = didCancel
        
        let camera = UIImagePickerController()
        camera.delegate = self
        camera.sourceType = .camera
        camera.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        if (camera as UIViewController) is UINavigationController {
            self.context.imagePickerController.present(camera, animated: true)
            self.context.imagePickerController.setViewControllers([], animated: false)
        } else {
            self.context.imagePickerController.setViewControllers([camera], animated: false)
        }
    }
    
    open override func finish() {
        self.context.imagePickerController.dismiss(animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        if mediaType == kUTTypeImage as String {
            let metadata = info[UIImagePickerControllerMediaMetadata] as! [AnyHashable : Any]
            
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.didFinishCapturingImage?(image, metadata)
        } else if mediaType == kUTTypeMovie as String {
            let videoURL = info[UIImagePickerControllerMediaURL] as! URL
            self.didFinishCapturingVideo?(videoURL)
        }
    }
    
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.didCancel?()
    }
}
