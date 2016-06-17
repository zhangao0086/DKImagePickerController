//
//  DKAssetGroupGridLayout.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 16/1/17.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

import UIKit

public class DKAssetGroupGridLayout: UICollectionViewFlowLayout {
	
	public override func prepareLayout() {
		super.prepareLayout()
		
		var minItemWidth: CGFloat = 80
		if UI_USER_INTERFACE_IDIOM() == .Pad {
			minItemWidth = 100
		}
		
		let interval: CGFloat = 1
		self.minimumInteritemSpacing = interval
		self.minimumLineSpacing = interval
		
		let contentWidth = self.collectionView!.bounds.width
		
		let itemCount = Int(floor(contentWidth / minItemWidth))
		var itemWidth = (contentWidth - interval * (CGFloat(itemCount) - 1)) / CGFloat(itemCount)
		let actualInterval = (contentWidth - CGFloat(itemCount) * itemWidth) / (CGFloat(itemCount) - 1)
		itemWidth += actualInterval - interval
		
		let itemSize = CGSize(width: itemWidth, height: itemWidth)
		self.itemSize = itemSize
	}
	
}
