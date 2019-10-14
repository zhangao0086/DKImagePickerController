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
    
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[.mediaType] as! String
        
        if mediaType == kUTTypeImage as String {
            let metadata = info[.mediaMetadata] as! [AnyHashable : Any]
            
            let image = info[.originalImage] as! UIImage
            self.didFinishCapturingImage?(image, metadata)
        } else if mediaType == kUTTypeMovie as String {
            let videoURL = info[.mediaURL] as! URL
            self.didFinishCapturingVideo?(videoURL)
        }
    }
    
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.didCancel?()
    }
}
