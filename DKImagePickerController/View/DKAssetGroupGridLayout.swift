//
//  DKAssetGroupGridLayout.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 16/1/17.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

import UIKit

public class DKAssetGroupGridLayout: UICollectionViewFlowLayout {
	
	init(contentSize: CGSize) {
		super.init()

		let interval: CGFloat = 1
		self.minimumInteritemSpacing = interval
		self.minimumLineSpacing = interval
		
		let contentWidth = contentSize.width

		let itemCount = 3
		var itemWidth = (contentWidth - interval * (CGFloat(itemCount) - 1)) / CGFloat(itemCount)
		let actualInterval = (contentWidth - CGFloat(itemCount) * itemWidth) / (CGFloat(itemCount) - 1)
		itemWidth += actualInterval - interval
		
		let itemSize = CGSize(width: itemWidth, height: itemWidth)
		self.itemSize = itemSize
	}
	
	convenience override init() {
		self.init(contentSize: CGSize(width: 80, height: 80))
	}

	required public init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
}
