//
//  DKImageExtensionController.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 16/12/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import Foundation

public class DKImageExtensionContext {
    
    public var imagePickerController: DKImagePickerController!
    public var groupDetailVC: DKAssetGroupDetailVC?
    
}

////////////////////////////////////////////////////////////////////////

public enum DKImageExtensionType : Int {
    case gallery, camera, inlineCamera
}

public protocol DKImageExtensionProtocol {
    
    func perform(with extraInfo: [AnyHashable: Any])
    
    func finish()
}

@objc
open class DKImageBaseExtension : NSObject, DKImageExtensionProtocol {
    
    public let context: DKImageExtensionContext
    
    required public init(context: DKImageExtensionContext) {
        self.context = context
    }
    
    open func perform(with extraInfo: [AnyHashable : Any]) {
        fatalError("This method must be overridden.")
    }
    
    open func finish() {
        fatalError("This method must be overridden.")
    }
    
    internal class func extensionType() -> DKImageExtensionType {
        fatalError("This method must be overridden.")
    }
    
    @objc internal class func registerAsDefaultExtension() {
        registerDefaultExtension(extensionClass: self, for: self.extensionType())
    }
    
}

public func registerExtension(extensionClass: DKImageBaseExtension.Type, for type: DKImageExtensionType) {
    DKImageExtensionController.extensions[type] = extensionClass
}

public func unregisterExtension(for type: DKImageExtensionType) {
    DKImageExtensionController.extensions[type] = nil
}

internal func registerDefaultExtension(extensionClass: DKImageBaseExtension.Type, for type: DKImageExtensionType) {
    DKImageExtensionController.defaultExtensions[type] = extensionClass
}


class DKImageExtensionController {
    
    fileprivate static var defaultExtensions = [DKImageExtensionType : DKImageBaseExtension.Type]()
    fileprivate static var extensions = [DKImageExtensionType: DKImageBaseExtension.Type]()
    
    private var cache = [DKImageExtensionType : DKImageBaseExtension]()
    
    private static let checkDefaultExtensions: Void = {
        let defaultClasses = [
            "DKImagePickerController.DKImageExtensionGallery",
            "DKImagePickerController.DKImageExtensionCamera",
            "DKImagePickerController.DKImageExtensionInlineCamera",
        ]
        
        for defaultClass in defaultClasses {
            if let defaultClass = NSClassFromString(defaultClass) {
                if let defaultClass = (defaultClass as AnyObject) as? NSObjectProtocol {
                    if defaultClass.responds(to: #selector(DKImageBaseExtension.registerAsDefaultExtension)) {
                        defaultClass.perform(#selector(DKImageBaseExtension.registerAsDefaultExtension))
                    }
                }
            }
        }
    }()
    
    private let imagePickerController: DKImagePickerController
    
    init(imagePickerController: DKImagePickerController) {
        self.imagePickerController = imagePickerController
    }
    
    func perform(extensionType: DKImageExtensionType, with extraInfo: [AnyHashable : Any]) {
        DKImageExtensionController.checkDefaultExtensions
        
        if let extensionClass = (DKImageExtensionController.extensions[extensionType] ?? DKImageExtensionController.defaultExtensions[extensionType]) {
            var e = self.cache[extensionType]
            if e == nil {
                e = extensionClass.init(context: self.createContext())
                self.cache[extensionType] = e
            }
            
            e?.perform(with: extraInfo)
        } else {
            debugPrint("No DKImageExtension founed.")
        }
    }
    
    func finish(extensionType: DKImageExtensionType) {
        if let e = self.cache[extensionType] {
            e.finish()
        }
    }
    
    private func createContext() -> DKImageExtensionContext {
        let context = DKImageExtensionContext()
        context.groupDetailVC = self.imagePickerController.topViewController as? DKAssetGroupDetailVC
        context.imagePickerController = self.imagePickerController
        
        return context
    }
    
}
