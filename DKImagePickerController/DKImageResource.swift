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
	
	private class func stretchImgFromMiddle(image: UIImage) -> UIImage {
		let centerX = image.size.width / 2
		let centerY = image.size.height / 2
		return image.resizableImageWithCapInsets(UIEdgeInsets(top: centerY, left: centerX, bottom: centerY, right: centerX))
	}
	
    class func checkedImage() -> UIImage {
		return stretchImgFromMiddle(imageForResource("checked_background"))
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
	
	class func emptyAlbumIcon() -> UIImage {
		return stretchImgFromMiddle(imageForResource("empty_album"))
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

