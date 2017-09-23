//
//  CustomCamera.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 16/3/17.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

import UIKit

open class CustomCameraUIDelegate: DKImagePickerControllerDefaultUIDelegate {
	
    open override func imagePickerControllerCreateCamera(_ imagePickerController: DKImagePickerController) -> UIViewController {
        let picker = CustomCamera()
        picker.sourceType = .camera
        
        return picker
    }
    
}
