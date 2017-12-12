//
//  DKPhotoGalleryResource.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 15/8/11.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit

public extension Bundle {
    
    class func photoGalleryResourceBundle() -> Bundle {
        let assetPath = Bundle(for: DKPhotoGalleryResource.self).resourcePath!
        return Bundle(path: (assetPath as NSString).appendingPathComponent("DKPhotoGalleryResource.bundle"))!
    }
    
}

public class DKPhotoGalleryResource {

    private class func imageForResource(_ name: String) -> UIImage {
        let bundle = Bundle.photoGalleryResourceBundle()
        let imagePath = bundle.path(forResource: name, ofType: "png", inDirectory: "Images")
        let image = UIImage(contentsOfFile: imagePath!)
        return image!
    }
	
	private class func stretchImgFromMiddle(_ image: UIImage) -> UIImage {
		let centerX = image.size.width / 2
		let centerY = image.size.height / 2
		return image.resizableImage(withCapInsets: UIEdgeInsets(top: centerY, left: centerX, bottom: centerY, right: centerX))
	}
    
    class func downloadFailedImage() -> UIImage {
        return imageForResource("ImageFailed")
    }
    
    class func closeVideoImage() -> UIImage {
        return imageForResource("VideoClose")
    }
    
    class func videoPlayImage() -> UIImage {
        return imageForResource("VideoPlay")
    }
    
    class func videoToolbarPlayImage() -> UIImage {
        return imageForResource("ToolbarPlay")
    }
    
    class func videoToolbarPauseImage() -> UIImage {
        return imageForResource("ToolbarPause")
    }
    
    class func videoPlayControlBackgroundImage() -> UIImage {
        return stretchImgFromMiddle(imageForResource("VideoPlayControlBackground"))
    }
    
    class func videoTimeSliderImage() -> UIImage {
        return imageForResource("VideoTimeSlider")
    }
    
}

public class DKPhotoGalleryLocalizedString {
    
    public class func localizedStringForKey(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "DKPhotoGalleryResource", bundle:Bundle.photoGalleryResourceBundle(), value: "", comment: "")
    }
    
    public class func localizedStringForKey(_ key: String, value: String) -> String {
        return NSLocalizedString(key, tableName: "DKPhotoGalleryResource", bundle:Bundle.photoGalleryResourceBundle(), value: value, comment: "")
    }
    
}

public func DKPhotoGalleryLocalizedStringWithKey(_ key: String) -> String {
    return DKPhotoGalleryLocalizedString.localizedStringForKey(key)
}

public func DKPhotoGalleryLocalizedStringWithKey(_ key: String, value: String) -> String {
    return DKPhotoGalleryLocalizedString.localizedStringForKey(key, value: value)
}

