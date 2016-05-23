//
//  DKPermissionView.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 15/12/17.
//  Copyright © 2015年 ZhangAo. All rights reserved.
//

import UIKit

internal class DKPermissionView: UIView {
	
	private let titleLabel = UILabel()
	private let permitButton = UIButton()
	
	internal class func permissionView(style: DKImagePickerControllerSourceType) -> DKPermissionView {
		
		let permissionView = DKPermissionView()
		permissionView.addSubview(permissionView.titleLabel)
		permissionView.addSubview(permissionView.permitButton)
		
		if style == .Photo {
			permissionView.titleLabel.text = DKImageLocalizedStringWithKey("permissionPhoto")
			permissionView.titleLabel.textColor = UIColor.grayColor()
		} else {
			permissionView.titleLabel.textColor = UIColor.whiteColor()
			permissionView.titleLabel.text = DKImageLocalizedStringWithKey("permissionCamera")
		}
		permissionView.titleLabel.sizeToFit()
		
		permissionView.permitButton.setTitle(DKImageLocalizedStringWithKey("permit"), forState: .Normal)
		permissionView.permitButton.setTitleColor(UIColor(red: 0, green: 122.0 / 255, blue: 1, alpha: 1), forState: .Normal)
		permissionView.permitButton.addTarget(permissionView, action: #selector(DKPermissionView.gotoSettings), forControlEvents: .TouchUpInside)
		permissionView.permitButton.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
		permissionView.permitButton.sizeToFit()
		permissionView.permitButton.center = CGPoint(x: permissionView.titleLabel.center.x,
			y: permissionView.titleLabel.bounds.height + 40)
		
		permissionView.frame.size = CGSize(width: max(permissionView.titleLabel.bounds.width, permissionView.permitButton.bounds.width),
			height: permissionView.permitButton.frame.maxY)
		
		return permissionView
	}
	
	override func didMoveToWindow() {
		super.didMoveToWindow()
		
		self.center = self.superview!.center
	}
	
	internal func gotoSettings() {
		if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
			UIApplication.sharedApplication().openURL(appSettings)
		}
	}
	
}
