//
//  DKImageExtensionPhotoCropper.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 28/9/2018.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import Foundation

#if canImport(TOCropViewController)
import TOCropViewController
#endif

open class DKImageExtensionPhotoCropper: DKImageBaseExtension, TOCropViewControllerDelegate {
    
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
        
        let imageCropper = TOCropViewController(image: image)
        imageCropper.delegate = self
        
        self.imageEditor = imageCropper
        
        let imagePickerController = self.context.imagePickerController
        (imagePickerController?.presentedViewController ?? imagePickerController)?.present(imageCropper, animated: true, completion: nil)
    }

    override open func finish() {
        self.imageEditor?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TOCropViewControllerDelegate
    
    open func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        if let didFinishEditing = self.didFinishEditing {
            self.metadata?[kCGImagePropertyOrientation as AnyHashable] = NSNumber(integerLiteral: 0)
            
            didFinishEditing(image, self.metadata)
            
            self.didFinishEditing = nil
            self.metadata = nil
        }
    }
    
}
