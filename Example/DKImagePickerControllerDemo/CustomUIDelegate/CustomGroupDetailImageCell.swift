//
//  CustomGroupDetailImageCell.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 03/01/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import DKImagePickerController

class CustomGroupDetailImageCell: DKAssetGroupDetailBaseCell {
    
    class override func cellReuseIdentifier() -> String {
        return "CustomGroupDetailImageCell"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.thumbnailImageView.frame = self.bounds
        self.thumbnailImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.addSubview(self.thumbnailImageView)
        
        self.checkView.frame = self.bounds
        self.checkView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.addSubview(self.checkView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var thumbnailImage: UIImage? {
        didSet {
            self.thumbnailImageView.image = self.thumbnailImage
        }
    }

    internal lazy var _thumbnailImageView: UIImageView = {
        let thumbnailImageView = UIImageView()
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        
        return thumbnailImageView
    }()
    
    override var thumbnailImageView: UIImageView {
        get {
            return _thumbnailImageView
        }
    }
    
    fileprivate lazy var checkView: UIImageView = {
        let checkView = UIImageView(image: DKImagePickerControllerResource.blueTickImage())
        checkView.contentMode = .center
        
        return checkView
    }()

    override var isSelected: Bool {
        didSet {
            if super.isSelected {
                self.thumbnailImageView.alpha = 0.5
                self.checkView.isHidden = false
            } else {
                self.thumbnailImageView.alpha = 1
                self.checkView.isHidden = true
            }
        }
    }

}
