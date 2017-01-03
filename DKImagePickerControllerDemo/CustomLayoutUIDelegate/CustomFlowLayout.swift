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
//        var minItemWidth: CGFloat = 80
//        if UI_USER_INTERFACE_IDIOM() == .pad {
//            minItemWidth = 100
//        }
//        
//        let interval: CGFloat = 1
//        self.minimumInteritemSpacing = interval
//        self.minimumLineSpacing = interval
//        
//        let contentWidth = self.collectionView!.bounds.width
//        
//        let itemCount = Int(floor(contentWidth / minItemWidth))
//        var itemWidth = (contentWidth - interval * (CGFloat(itemCount) - 1)) / CGFloat(itemCount)
//        let actualInterval = (contentWidth - CGFloat(itemCount) * itemWidth) / (CGFloat(itemCount) - 1)
//        itemWidth += actualInterval - interval
//        
//        let itemSize = CGSize(width: itemWidth, height: itemWidth)
//        self.itemSize = itemSize
    }
    
}
