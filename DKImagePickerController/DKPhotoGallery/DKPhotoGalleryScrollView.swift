//
//  DKPhotoGalleryScrollView.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 07/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit

class DKPhotoGalleryScrollView: UIScrollView {
    
    private var items = Array<NSObject>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.alwaysBounceHorizontal = true
        self.alwaysBounceVertical = false
        self.isPagingEnabled = true
        self.delaysContentTouches = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(_ itemCount: Int) {
        self.contentSize = CGSize(width: CGFloat(itemCount * Int((screenWidth() + 20))),
                                  height: screenHeight())
        self.items = []
        
        for _ in 0 ..< itemCount {
            self.items.append(NSNull())
        }
    }
    
    public func set(_ vc: UIViewController, atIndex index: Int) {
        if self.items[index] != vc.view {
            self.items[index] = vc.view
            
            if vc.view.superview == nil {
                self.addSubview(vc.view)
            } else {
                vc.viewWillAppear(true)
                vc.view.isHidden = false
                vc.viewDidAppear(true)
            }
            vc.view.frame = CGRect(x: CGFloat(index) * (screenWidth() + 20), y: 0,
                                   width: screenWidth(), height: screenHeight())
        }
    }
    
    public func remove(_ vc: UIViewController, atIndex index: Int) {
        if self.items[index] == vc.view {
            self.items[index] = NSNull()
            vc.viewWillDisappear(true)
            vc.view.isHidden = true
            vc.viewDidDisappear(true)
        }
    }
    
    private func screenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }

    private func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitTestingView = super.hitTest(point, with: event) {
            if hitTestingView.isKind(of: UISlider.self) {
                self.isScrollEnabled = false
            } else {
                self.isScrollEnabled = true
            }
            
            return hitTestingView
        } else {
            return nil
        }
    }
    
}
