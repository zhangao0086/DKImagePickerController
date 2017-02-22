//
//  DKAssetGroupDetailBaseCell.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 03/01/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit

@objc
open class DKAssetGroupDetailBaseCell: UICollectionViewCell, DKAssetGroupCellItemProtocol {
    
    // This method must be overridden
    open class func cellReuseIdentifier() -> String { preconditionFailure("This method must be overridden") }
    
    open weak var asset: DKAsset?
    open var index: Int = 0
    open var thumbnailImage: UIImage!
}
