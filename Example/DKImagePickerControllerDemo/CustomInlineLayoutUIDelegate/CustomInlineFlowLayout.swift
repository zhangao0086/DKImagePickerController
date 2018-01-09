//
//  CustomInlineFlowLayout.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 03/01/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit

open class CustomInlineFlowLayout: UICollectionViewFlowLayout {
    
    open override func prepare() {
        super.prepare()
        
        self.scrollDirection = .horizontal
        
        let contentWidth = self.collectionView!.bounds.width / 3.5
        let contentHeight = self.collectionView!.bounds.height
        self.itemSize = CGSize(width: contentWidth, height: contentHeight)
        
        self.minimumInteritemSpacing = 999
    }
    
}
