//
//  DKPopoverViewController.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/6/27.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit

public class DKPopoverViewController: UIViewController {
    
    public class func popoverViewController(viewController: UIViewController, fromView: UIView) {
        let window = UIApplication.sharedApplication().keyWindow!
        
        let popoverViewController = DKPopoverViewController()
        
        popoverViewController.contentViewController = viewController
        popoverViewController.fromView = fromView
        
        popoverViewController.showInView(window)
        window.rootViewController!.addChildViewController(popoverViewController)
    }
    
    public class func dismissPopoverViewController() {
        let window = UIApplication.sharedApplication().keyWindow!

        for vc in window.rootViewController!.childViewControllers {
            if vc is DKPopoverViewController {
                (vc as! DKPopoverViewController).dismiss()
            }
        }
    }
    
    private class DKPopoverView: UIView {
        
        var contentView: UIView! {
            didSet {
                contentView.layer.cornerRadius = 5
				contentView.clipsToBounds = true
                contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                self.addSubview(contentView)
            }
        }
        
        let arrowWidth: CGFloat = 20
        let arrowHeight: CGFloat = 10
        private let arrowImageView: UIImageView = UIImageView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.commonInit()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            
            self.commonInit()
        }
        
        func commonInit() {
            arrowImageView.image = self.arrowImage()
            self.addSubview(arrowImageView)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            self.arrowImageView.frame = CGRect(x: (self.bounds.width - self.arrowWidth) / 2, y: 0, width: arrowWidth, height: arrowHeight)
            self.contentView.frame = CGRect(x: 0, y: self.arrowHeight, width: self.bounds.width, height: self.bounds.height - arrowHeight)
        }
        
        func arrowImage() -> UIImage {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: arrowWidth, height: arrowHeight), false, UIScreen.mainScreen().scale)
            
            let context = UIGraphicsGetCurrentContext()
            UIColor.clearColor().setFill()
            CGContextFillRect(context, CGRect(x: 0, y: 0, width: arrowWidth, height: arrowHeight))
            
            let arrowPath = CGPathCreateMutable()
            
            CGPathMoveToPoint(arrowPath, nil,  arrowWidth / 2, 0)
            CGPathAddLineToPoint(arrowPath, nil, arrowWidth, arrowHeight)
            CGPathAddLineToPoint(arrowPath, nil, 0, arrowHeight)
            CGPathCloseSubpath(arrowPath)

            CGContextAddPath(context, arrowPath)
            
            CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
            CGContextDrawPath(context, CGPathDrawingMode.Fill)

            let arrowImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return arrowImage
        }
    }
    
    var contentViewController: UIViewController!
    var fromView: UIView!
    private let popoverView = DKPopoverView()
    
    override public func loadView() {
        super.loadView()
        
        let backgroundView = UIControl(frame: self.view.frame)
        backgroundView.backgroundColor = UIColor.clearColor()
        backgroundView.addTarget(self, action: #selector(DKPopoverViewController.dismiss), forControlEvents: .TouchUpInside)
        backgroundView.autoresizingMask = self.view.autoresizingMask
        self.view = backgroundView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(popoverView)
    }

	@available(iOS, deprecated=8.0)
    override public func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
		super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
		
        UIView.animateWithDuration(0.2, animations: {
            self.popoverView.frame = self.calculatePopoverViewFrame()
        })
    }
    
    func showInView(view: UIView) {
		view.addSubview(self.view)
		
		self.popoverView.contentView = self.contentViewController.view
        self.popoverView.frame = self.calculatePopoverViewFrame()
		
        self.popoverView.transform = CGAffineTransformScale(CGAffineTransformTranslate(self.popoverView.transform, 0, -(self.popoverView.bounds.height / 2)), 0.1, 0.1)
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.3, options: [.CurveEaseInOut, .AllowUserInteraction], animations: {
            self.popoverView.transform = CGAffineTransformIdentity
            self.view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        }, completion: nil)
    }
    
    func dismiss() {
        UIView.animateWithDuration(0.2, animations: {
            self.popoverView.transform = CGAffineTransformScale(CGAffineTransformTranslate(self.popoverView.transform, 0, -(self.popoverView.bounds.height / 2)), 0.01, 0.01)
            self.view.backgroundColor = UIColor.clearColor()
        }) { result in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }
    }
	
	func calculatePopoverViewFrame() -> CGRect {
		let popoverY = self.fromView.convertPoint(self.fromView.frame.origin, toView: self.view).y + self.fromView.bounds.height

		var popoverWidth = self.contentViewController.preferredContentSize.width
		if popoverWidth == UIViewNoIntrinsicMetric {
			if UI_USER_INTERFACE_IDIOM() == .Pad {
				popoverWidth = self.view.bounds.width * 0.6
			} else {
				popoverWidth = self.view.bounds.width
			}
		}
		
		let popoverHeight = min(self.contentViewController.preferredContentSize.height + self.popoverView.arrowHeight, view.bounds.height - popoverY - 40)
		
		return CGRect(
			x: (self.view.bounds.width - popoverWidth) / 2,
			y: popoverY,
			width: popoverWidth,
			height: popoverHeight
		)
	}
}
