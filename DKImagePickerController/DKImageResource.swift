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

public class DKImageResource {

    private class func imageForResource(_ name: String) -> UIImage {
        let bundle = Bundle.imagePickerControllerBundle()
        let imagePath = bundle.path(forResource: name, ofType: "png", inDirectory: "Images")
        let image = UIImage(contentsOfFile: imagePath!)
        return image!
    }
	
	private class func stretchImgFromMiddle(_ image: UIImage) -> UIImage {
		let centerX = image.size.width / 2
		let centerY = image.size.height / 2
		return image.resizableImage(withCapInsets: UIEdgeInsets(top: centerY, left: centerX, bottom: centerY, right: centerX))
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

public class DKImageLocalizedString {
    
    public class func localizedStringForKey(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "DKImagePickerController", bundle:Bundle.imagePickerControllerBundle(), value: "", comment: "")
    }
    
}

public func DKImageLocalizedStringWithKey(_ key: String) -> String {
    return DKImageLocalizedString.localizedStringForKey(key)
}

