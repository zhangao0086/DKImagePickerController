//
//  DKAssetGroupDetailBaseCell.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 03/01/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit

@objc
open class DKAssetGroupDetailBaseCell: UICollectionViewCell, DKAssetGroupCellItemProtocol {
    
    // This method must be overridden
    open class func cellReuseIdentifier() -> String { preconditionFailure("This method must be overridden") }
    
    open weak var asset: DKAsset?
    open var index: Int = 0
    open var thumbnailImage: UIImage?
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gestureRecognizer:)))
//        longPressGesture.minimumPressDuration = 0.3
//        self.addGestureRecognizer(longPressGesture)
//    }
//
//    required public init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override open var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                UIView.animate(withDuration: 0.2, animations: {
                    self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                })
            } else {
                UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2, options: [.allowUserInteraction, .curveEaseInOut],
                               animations: { 
                                self.transform = CGAffineTransform.identity
                }, completion: nil)
            }
        }
    }
    
    // MARK: - Private methods
    
//    func longPress(gestureRecognizer: UIGestureRecognizer) {
//        if gestureRecognizer.state == .began {
//            print("longPress")
//        }
//    }

}
