//
//  DKImageResource.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/8/11.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit

private extension NSBundle {
    
    class func imagePickerControllerBundle() -> NSBundle {
        let assetPath = NSBundle(forClass: DKImageResource.self).resourcePath!
        return NSBundle(path: (assetPath as NSString).stringByAppendingPathComponent("DKImagePickerController.bundle"))!
    }
    
}

internal class DKImageResource {

    private class func imageForResource(name: String) -> UIImage {
        let bundle = NSBundle.imagePickerControllerBundle()
        let imagePath = bundle.pathForResource(name, ofType: "png", inDirectory: "Images")
        let image = UIImage(contentsOfFile: imagePath!)
        return image!
    }
    
    class func checkedImage() -> UIImage {
        var image = imageForResource("checked_background")
        let center = image.size.width / 2
        image = image.resizableImageWithCapInsets(UIEdgeInsets(top: center, left: center, bottom: center, right: center))
        
        return image
    }
    
    class func blueTickImage() -> UIImage {
        return imageForResource("tick_blue")
    }
    
    class func cameraImage() -> UIImage {
        return imageForResource("camera")
    }
    
    class func videoCameraIcon() -> UIImage {
        return imageForResource("video_camera")
    }
    
}

internal class DKImageLocalizedString {
    
    class func localizedStringForKey(key: String) -> String {
        return NSLocalizedString(key, tableName: "DKImagePickerController", bundle:NSBundle.imagePickerControllerBundle(), value: "", comment: "")
    }
    
}

internal func DKImageLocalizedStringWithKey(key: String) -> String {
    return DKImageLocalizedString.localizedStringForKey(key)
}

