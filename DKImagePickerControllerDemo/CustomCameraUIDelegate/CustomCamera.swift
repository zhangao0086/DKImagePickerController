//
//  CustomCamera.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 03/01/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import MobileCoreServices

open class CustomCamera : UIImagePickerController, DKImagePickerControllerCameraProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var didCancel: (() -> Void)?
    var didFinishCapturingImage: ((_ image: UIImage, _ metadata: [AnyHashable : Any]?) -> Void)?
    var didFinishCapturingVideo: ((_ videoURL: URL) -> Void)?
    
    public func setDidCancel(block: @escaping () -> Void) {
        self.didCancel = block
    }
    
    public func setDidFinishCapturingImage(block: @escaping (UIImage, [AnyHashable : Any]?) -> Void) {
        self.didFinishCapturingImage = block
    }
    
    public func setDidFinishCapturingVideo(block: @escaping (URL) -> Void) {
        self.didFinishCapturingVideo = block
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        let metadata = info[UIImagePickerControllerMediaMetadata] as! [AnyHashable : Any]
        
        if mediaType == kUTTypeImage as String {
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
