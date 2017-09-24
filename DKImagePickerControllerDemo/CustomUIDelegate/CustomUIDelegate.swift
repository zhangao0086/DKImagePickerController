//
//  CustomUIDelegate.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 03/01/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit

open class CustomUIDelegate: DKImagePickerControllerDefaultUIDelegate {
    
    lazy var footer: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        toolbar.isTranslucent = false
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: self.createDoneButtonIfNeeded()),
        ]
        self.updateDoneButtonTitle(self.createDoneButtonIfNeeded())
        
        return toolbar
    }()
    
    override open func createDoneButtonIfNeeded() -> UIButton {
        if self.doneButton == nil {
            let button = UIButton(type: .custom)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.setTitleColor(UIColor(red: 85 / 255.0, green: 184 / 255.0, blue: 44 / 255.0, alpha: 1.0), for: .normal)
            button.setTitleColor(UIColor(red: 85 / 255.0, green: 184 / 255.0, blue: 44 / 255.0, alpha: 0.4), for: .disabled)
            button.addTarget(self.imagePickerController, action: #selector(DKImagePickerController.done), for: .touchUpInside)
            self.doneButton = button
        }
        
        return self.doneButton!
    }
    
    override open func prepareLayout(_ imagePickerController: DKImagePickerController, vc: UIViewController) {
        self.imagePickerController = imagePickerController
    }
    
    override open func imagePickerController(_ imagePickerController: DKImagePickerController,
                                               showsCancelButtonForVC vc: UIViewController) {
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                               target: imagePickerController,
                                                               action: #selector(imagePickerController.dismiss as () -> Void))
    }
    
    override open func imagePickerController(_ imagePickerController: DKImagePickerController,
                                               hidesCancelButtonForVC vc: UIViewController) {
        vc.navigationItem.rightBarButtonItem = nil
    }
    
    override open func imagePickerControllerFooterView(_ imagePickerController: DKImagePickerController) -> UIView? {
        return self.footer
    }
    
    override open func updateDoneButtonTitle(_ button: UIButton) {
        if self.imagePickerController.selectedAssets.count > 0 {
            button.setTitle(String(format: "Send(%d)", self.imagePickerController.selectedAssets.count), for: .normal)
            button.isEnabled = true
        } else {
            button.setTitle("Send", for: .normal)
            button.isEnabled = false
        }
        
        button.sizeToFit()
    }
    
    open override func imagePickerControllerCollectionImageCell() -> DKAssetGroupDetailBaseCell.Type {
        return CustomGroupDetailImageCell.self
    }
    
    open override func imagePickerControllerCollectionCameraCell() -> DKAssetGroupDetailBaseCell.Type {
        return CustomGroupDetailCameraCell.self
    }

}
