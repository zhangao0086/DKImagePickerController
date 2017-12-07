//
//  DKImageResource.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/8/11.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit

public extension Bundle {
    
    class func imagePickerControllerBundle() -> Bundle {
        let assetPath = Bundle(for: DKImageResource.self).resourcePath!
        return Bundle(path: (assetPath as NSString).appendingPathComponent("DKImagePickerController.bundle"))!
    }
    
}

@objc
open class DKImageResource: NSObject {
    
    private let cache = NSCache<NSString, UIImage>()
	
    @objc open func checkedImage() -> UIImage {
        return imageForResource("checked_background", stretchable: true, cacheable: true)
    }
    
    @objc open func blueTickImage() -> UIImage {
        return imageForResource("tick_blue", stretchable: false, cacheable: false)
    }
    
    @objc open func cameraImage() -> UIImage {
        return imageForResource("camera", stretchable: false, cacheable: false)
    }
    
    @objc open func videoCameraIcon() -> UIImage {
        return imageForResource("video_camera", stretchable: false, cacheable: true)
    }
	
	@objc open func emptyAlbumIcon() -> UIImage {
        return imageForResource("empty_album", stretchable: true, cacheable: false)
	}
    
    @objc open func photoGalleryCheckedImage() -> UIImage {
        return imageForResource("photoGalleryCheckedImage", stretchable: true, cacheable: true)
    }
    
    @objc open func imageForResource(_ name: String, stretchable: Bool = false, cacheable: Bool = false) -> UIImage {
        if cacheable {
            if let cache = self.cache.object(forKey: name as NSString) {
                return cache
            }
        }
        
        let bundle = Bundle.imagePickerControllerBundle()
        let imagePath = bundle.path(forResource: name, ofType: "png", inDirectory: "Images")
        var image = UIImage(contentsOfFile: imagePath!)!
        
        if stretchable {
            image = self.stretchImgFromMiddle(image)
        }
        
        if cacheable {
            self.cache.setObject(image, forKey: name as NSString)
        }
        
        return image
    }
    
    @objc open func stretchImgFromMiddle(_ image: UIImage) -> UIImage {
        let centerX = image.size.width / 2
        let centerY = image.size.height / 2
        return image.resizableImage(withCapInsets: UIEdgeInsets(top: centerY, left: centerX, bottom: centerY, right: centerX))
    }
    
}

public class DKImageLocalizedString {
    
    public class func localizedStringForKey(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "DKImagePickerController", bundle:Bundle.imagePickerControllerBundle(), value: "", comment: "")
    }
    
    public class func localizedStringForKey(_ key: String, value: String) -> String {
        return NSLocalizedString(key, tableName: "DKImagePickerController", bundle:Bundle.imagePickerControllerBundle(), value: value, comment: "")
    }
    
}

public func DKImageLocalizedStringWithKey(_ key: String) -> String {
    return DKImageLocalizedString.localizedStringForKey(key)
}

public func DKImageLocalizedStringWithKey(_ key: String, value: String) -> String {
    return DKImageLocalizedString.localizedStringForKey(key, value: value)
}

