//
//  CustomGroupDetailCameraCell.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 03/01/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import DKImagePickerController

class CustomGroupDetailCameraCell: DKAssetGroupDetailBaseCell {
    
    class override func cellReuseIdentifier() -> String {
        return "CustomGroupDetailCameraCell"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let cameraLabel = UILabel(frame: frame)
        cameraLabel.text = "Camera"
        cameraLabel.textAlignment = .center
        cameraLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.addSubview(cameraLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

