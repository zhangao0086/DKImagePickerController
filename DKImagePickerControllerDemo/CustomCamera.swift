//
//  CustomCamera.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 16/3/17.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

import UIKit

public class CustomUIDelegate: DKImagePickerControllerDefaultUIDelegate {
	
	public override func imagePickerControllerCreateCamera(imagePickerController: DKImagePickerController, didCancel: (() -> Void), didFinishCapturingImage: ((image: UIImage) -> Void)) -> UIViewController {
		let vc = UIViewController()
		vc.view.backgroundColor = UIColor.redColor()
		
		let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
		dispatch_after(delayTime, dispatch_get_main_queue()) {
			didCancel()
		}
		
		return vc
	}
	
}
