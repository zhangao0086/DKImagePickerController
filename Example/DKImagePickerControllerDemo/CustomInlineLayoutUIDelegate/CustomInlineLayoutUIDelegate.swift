//
//  CustomInlineLayoutUIDelegate.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 03/01/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import DKImagePickerController

open class CustomInlineLayoutUIDelegate: DKImagePickerControllerBaseUIDelegate {
    
    override open func layoutForImagePickerController(_ imagePickerController: DKImagePickerController) -> UICollectionViewLayout.Type {
        return CustomInlineFlowLayout.self
    }
    
}
