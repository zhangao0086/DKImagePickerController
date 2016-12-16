//
//  DKPermissionView.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 15/12/17.
//  Copyright © 2015年 ZhangAo. All rights reserved.
//

import UIKit

@objc
open class DKPermissionView: UIView {
	
	private let titleLabel = UILabel()
	private let permitButton = UIButton()
	
	open class func permissionView(_ style: DKImagePickerControllerSourceType) -> DKPermissionView {
		
		let permissionView = DKPermissionView()
		permissionView.addSubview(permissionView.titleLabel)
		permissionView.addSubview(permissionView.permitButton)
		
		if style == .photo {
			permissionView.titleLabel.text = DKImageLocalizedStringWithKey("permissionPhoto")
			permissionView.titleLabel.textColor = UIColor.gray
		} else {
			permissionView.titleLabel.textColor = UIColor.white
			permissionView.titleLabel.text = DKImageLocalizedStringWithKey("permissionCamera")
		}
		permissionView.titleLabel.sizeToFit()
		
		permissionView.permitButton.setTitle(DKImageLocalizedStringWithKey("permit"), for: .normal)
		permissionView.permitButton.setTitleColor(UIColor(red: 0, green: 122.0 / 255, blue: 1, alpha: 1), for: .normal)
		permissionView.permitButton.addTarget(permissionView, action: #selector(DKPermissionView.gotoSettings), for: .touchUpInside)
		permissionView.permitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
		permissionView.permitButton.sizeToFit()
		permissionView.permitButton.center = CGPoint(x: permissionView.titleLabel.center.x,
			y: permissionView.titleLabel.bounds.height + 40)
		
		permissionView.frame.size = CGSize(width: max(permissionView.titleLabel.bounds.width, permissionView.permitButton.bounds.width),
			height: permissionView.permitButton.frame.maxY)
		
		return permissionView
	}
	
	open override func didMoveToWindow() {
		super.didMoveToWindow()
		
		self.center = self.superview!.center
	}
	
	open func gotoSettings() {
		if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
			UIApplication.shared.openURL(appSettings)
		}
	}
	
}
