//
//  CustomFlowLayout.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 03/01/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit

open class CustomFlowLayout: UICollectionViewFlowLayout {
    
    open override func prepare() {
        super.prepare()
        
        self.scrollDirection = .horizontal
        
        let contentWidth = self.collectionView!.bounds.width * 0.7
        self.itemSize = CGSize(width: contentWidth, height: contentWidth)
        
        self.minimumInteritemSpacing = 999
    }
    
}
