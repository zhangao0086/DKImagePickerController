//
//  DKPhotoImageView.swift
//  DKPhotoGalleryDemo
//
//  Created by ZhangAo on 07/11/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//
//  Inspired by: https://github.com/patrickbdev/PBImageView/blob/master/PBImageView/Classes/PBImageView.swift
//

import UIKit
import FLAnimatedImage

open class DKPhotoImageView: FLAnimatedImageView {
    
    public override init(image: UIImage? = nil, highlightedImage: UIImage? = nil) {
        super.init(image: image, highlightedImage: highlightedImage)
        
        self.contentMode = .scaleAspectFit
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

open class DKPhotoContentAnimationView: UIView {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.imageView)
    }
    
    init(image: UIImage?) {
        super.init(frame: CGRect.zero)
        
        self.imageView.image = image
        self.addSubview(self.imageView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addSubview(self.imageView)
    }
    
    open override var contentMode: UIViewContentMode {
        didSet {
            self.layoutImageView()
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        self.layoutImageView()
    }
    
    open var image: UIImage? {
        get { return self.imageView.image }
        set { self.imageView.image = newValue }
    }
    
    open override var backgroundColor: UIColor? {
        get { return self.imageView.backgroundColor }
        set { self.imageView.backgroundColor = newValue }
    }
    
    private func layoutImageView() {
        
        guard let image = self.imageView.image else { return }
        
        // MARK: - Layout Helpers
        func imageToBoundsWidthRatio(image: UIImage) -> CGFloat  { return image.size.width / bounds.size.width }
        func imageToBoundsHeightRatio(image: UIImage) -> CGFloat { return image.size.height / bounds.size.height }
        func centerImageViewToPoint(point: CGPoint)              { self.imageView.center = point }
        func imageViewBoundsToImageSize()                        { imageViewBoundsToSize(size: image.size) }
        func imageViewBoundsToSize(size: CGSize)                 { self.imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height) }
        func centerImageView()                                   { self.imageView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2) }
        
        // MARK: - Layouts
        func layoutAspectFit() {
            let widthRatio = imageToBoundsWidthRatio(image: image)
            let heightRatio = imageToBoundsHeightRatio(image: image)
            imageViewBoundsToSize(size: CGSize(width: image.size.width / max(widthRatio, heightRatio), height: image.size.height / max(widthRatio, heightRatio)))
            centerImageView()
        }
        
        func layoutAspectFill() {
            let widthRatio = imageToBoundsWidthRatio(image: image)
            let heightRatio = imageToBoundsHeightRatio(image: image)
            imageViewBoundsToSize(size: CGSize(width: image.size.width /  min(widthRatio, heightRatio), height: image.size.height / min(widthRatio, heightRatio)))
            centerImageView()
        }
        
        func layoutFill() {
            imageViewBoundsToSize(size: CGSize(width: bounds.size.width, height: bounds.size.height))
        }
        
        func layoutCenter() {
            imageViewBoundsToImageSize()
            centerImageView()
        }
        
        func layoutTop() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(point: CGPoint(x: bounds.size.width / 2, y: image.size.height / 2))
        }
        
        func layoutBottom() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(point: CGPoint(x: bounds.size.width / 2, y: bounds.size.height - image.size.height / 2))
        }
        
        func layoutLeft() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(point: CGPoint(x: image.size.width / 2, y: bounds.size.height / 2))
        }
        
        func layoutRight() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(point: CGPoint(x: bounds.size.width - image.size.width / 2, y: bounds.size.height / 2))
        }
        
        func layoutTopLeft() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(point: CGPoint(x: image.size.width / 2, y: image.size.height / 2))
        }
        
        func layoutTopRight() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(point: CGPoint(x: bounds.size.width - image.size.width / 2, y: image.size.height / 2))
        }
        
        func layoutBottomLeft() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(point: CGPoint(x: image.size.width / 2, y: bounds.size.height - image.size.height / 2))
        }
        
        func layoutBottomRight() {
            imageViewBoundsToImageSize()
            centerImageViewToPoint(point: CGPoint(x: bounds.size.width - image.size.width / 2, y: bounds.size.height - image.size.height / 2))
        }
        
        switch contentMode {
        case .scaleAspectFit:  layoutAspectFit()
        case .scaleAspectFill: layoutAspectFill()
        case .scaleToFill:     layoutFill()
        case .redraw:          break;
        case .center:          layoutCenter()
        case .top:             layoutTop()
        case .bottom:          layoutBottom()
        case .left:            layoutLeft()
        case .right:           layoutRight()
        case .topLeft:         layoutTopLeft()
        case .topRight:        layoutTopRight()
        case .bottomLeft:      layoutBottomLeft()
        case .bottomRight:     layoutBottomRight()
        }
    }
}
