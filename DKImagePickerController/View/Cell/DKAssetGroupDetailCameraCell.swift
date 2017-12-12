//
//  DKAssetGroupDetailCameraCell.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 07/12/2016.
//  Copyright © 2016 ZhangAo. All rights reserved.
//

import UIKit

class DKAssetGroupDetailCameraCell: DKAssetGroupDetailBaseCell {
    
    class override func cellReuseIdentifier() -> String {
        return "DKImageCameraIdentifier"
    }
    
    private var cameraImageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let cameraImageView = UIImageView(frame: self.bounds)
        cameraImageView.contentMode = .center
        cameraImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.addSubview(cameraImageView)
        self.cameraImageView = cameraImageView
        
        self.contentView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var imagePickerController: DKImagePickerController? {
        willSet {
            if let newValue = newValue, let cameraImageView = self.cameraImageView, cameraImageView.image == nil {
                cameraImageView.image = newValue.imageResource.cameraImage()
            }
        }
    }
    
} /* DKAssetGroupDetailCameraCell */
