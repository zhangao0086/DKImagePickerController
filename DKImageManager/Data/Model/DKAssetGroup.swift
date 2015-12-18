//
//  DKAssetGroup.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 15/12/13.
//  Copyright © 2015年 ZhangAo. All rights reserved.
//

import Photos

// Group Model
public class DKAssetGroup : NSObject {
	var groupId: String!
	var groupName: String!
	var totalCount: Int!
	
	internal var originalCollection: PHAssetCollection!
	internal var fetchResult: PHFetchResult!
}