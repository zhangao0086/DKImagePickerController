//
//  DKAssetGroupDetailImageCell.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 07/12/2016.
//  Copyright © 2016 ZhangAo. All rights reserved.
//

import UIKit

class DKAssetGroupDetailImageCell: DKAssetGroupDetailBaseCell {
    
    class override func cellReuseIdentifier() -> String {
        return "DKImageAssetIdentifier"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.thumbnailImageView.frame = self.bounds
        self.thumbnailImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.addSubview(self.thumbnailImageView)
        
        self.checkView.frame = self.bounds
        self.checkView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.checkView.checkImageView.tintColor = nil
        self.checkView.checkLabel.font = UIFont.boldSystemFont(ofSize: 14)
        self.checkView.checkLabel.textColor = UIColor.white
        self.contentView.addSubview(self.checkView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class DKImageCheckView: UIView {
        
        internal lazy var checkImageView: UIImageView = {
            let imageView = UIImageView(image: DKImageResource.checkedImage().withRenderingMode(.alwaysTemplate))
            return imageView
        }()
        
        internal lazy var checkLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .right
            
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.addSubview(checkImageView)
            self.addSubview(checkLabel)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            self.checkImageView.frame = self.bounds
            self.checkLabel.frame = CGRect(x: 0, y: 5, width: self.bounds.width - 5, height: 20)
        }
        
    } /* DKImageCheckView */
    
    override var thumbnailImage: UIImage? {
        didSet {
            self.thumbnailImageView.image = self.thumbnailImage
        }
    }
    override var index: Int {
        didSet {
            self.checkView.checkLabel.text =  "\(self.index + 1)"
        }
    }
    
    fileprivate lazy var thumbnailImageView: UIImageView = {
        let thumbnailImageView = UIImageView()
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        
        return thumbnailImageView
    }()
    
    fileprivate let checkView = DKImageCheckView()
    
    override var isSelected: Bool {
        didSet {
            checkView.isHidden = !super.isSelected
        }
    }
    
} /* DKAssetGroupDetailCell */
