//
//  DKImagePickerControllerConstants.h
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 16/5/2.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

#ifndef DKImagePickerControllerConstants_h
#define DKImagePickerControllerConstants_h

@import Foundation;

typedef NS_OPTIONS(NSUInteger, DKImagePickerControllerSourceType) {
	DKImagePickerControllerSourceTypeCamera = 1 << 0,
	DKImagePickerControllerSourceTypePhoto = 1 << 1
};

#endif /* DKImagePickerControllerConstants_h */
