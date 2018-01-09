//
//  DKImageExtensionPhotoEditor.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 16/12/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import Foundation
import CLImageEditor

class DKImageExtensionPhotoEditor: DKImageBaseExtension, CLImageEditorDelegate {
    
    private weak var imageEditor: UIViewController?
    private var metadata: [AnyHashable : Any]?
    private var didFinishEditing: ((UIImage, [AnyHashable : Any]?) -> Void)?
    
    override class func extensionType() -> DKImageExtensionType {
        return .photoEditor
    }
        
    override func perform(with extraInfo: [AnyHashable: Any]) {
        guard let image = extraInfo["image"] as? UIImage
            , let didFinishEditing = extraInfo["didFinishEditing"] as? ((UIImage, [AnyHashable : Any]?) -> Void) else { return }
        
        self.metadata = extraInfo["metadata"] as? [AnyHashable : Any]
        self.didFinishEditing = didFinishEditing
        
        let imageEditor = CLImageEditor(image: image, delegate: self)!
        if let tool = imageEditor.toolInfo.subToolInfo(withToolName: "CLToneCurveTool", recursive: false) {
            tool.available = false
        }
        
        if let tool = imageEditor.toolInfo.subToolInfo(withToolName: "CLStickerTool", recursive: false) {
            tool.available = false
        }
        
        self.imageEditor = imageEditor
        
        let imagePickerController = self.context.imagePickerController
        (imagePickerController?.presentedViewController ?? imagePickerController)?.present(imageEditor, animated: true, completion: nil)
    }

    override func finish() {
        self.imageEditor?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - CLImageEditorDelegate
    
    public func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        if let didFinishEditing = self.didFinishEditing {
            self.metadata?[kCGImagePropertyOrientation as AnyHashable] = NSNumber(integerLiteral: 0)
            
            didFinishEditing(image, self.metadata)
            
            self.didFinishEditing = nil
            self.metadata = nil
        }
    }
    
}
