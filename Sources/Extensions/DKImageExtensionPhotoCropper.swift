//
//  DKImageExtensionPhotoCropper.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 28/9/2018.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import Foundation

#if canImport(CropViewController)
import CropViewController
#endif

open class DKImageExtensionPhotoCropper: DKImageBaseExtension {
    
    open  weak var imageEditor: UIViewController?
    open  var metadata: [AnyHashable : Any]?
    open  var didFinishEditing: ((UIImage, [AnyHashable : Any]?) -> Void)?
    
    override class func extensionType() -> DKImageExtensionType {
        return .photoEditor
    }
        
    override open func perform(with extraInfo: [AnyHashable: Any]) {
        guard let image = extraInfo["image"] as? UIImage
            , let didFinishEditing = extraInfo["didFinishEditing"] as? ((UIImage, [AnyHashable : Any]?) -> Void) else { return }
        
        self.metadata = extraInfo["metadata"] as? [AnyHashable : Any]
        self.didFinishEditing = didFinishEditing
        
        let imageCropper = CropViewController(image: image)
        imageCropper.onDidCropToRect = { [weak self] image, _, _ in
            guard let strongSelf = self else { return }
            
            if let didFinishEditing = strongSelf.didFinishEditing {
                strongSelf.metadata?[kCGImagePropertyOrientation as AnyHashable] = NSNumber(integerLiteral: 0)
                
                didFinishEditing(image, strongSelf.metadata)
                
                strongSelf.didFinishEditing = nil
                strongSelf.metadata = nil
            }
        }
        
        self.imageEditor = imageCropper
        
        let imagePickerController = self.context.imagePickerController
        (imagePickerController?.presentedViewController ?? imagePickerController)?.present(imageCropper, animated: true, completion: nil)
    }

    override open func finish() {
        self.imageEditor?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
