//
//  DKPhotoGalleryContentVC.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 16/6/23.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

import UIKit

@objc
open class DKPhotoGalleryContentVC: UIViewController, UIScrollViewDelegate {
    
    internal var items: [DKPhotoGalleryItem]!
    
    public var pageChangeBlock: ((_ index: Int) -> Void)?
    public var prepareToShow: ((_ previewVC: DKPhotoBasePreviewVC) -> Void)?
    
    open var currentIndex = 0 {
        didSet {
            self.pageChangeBlock?(self.currentIndex)
        }
    }
    
    public var currentVC: DKPhotoBasePreviewVC {
        get { return self.previewVC(at: self.currentIndex) }
    }
    
    public var currentContentView: UIView {
        get { return self.currentVC.contentView }
    }
    
    private let mainView = DKPhotoGalleryScrollView()
    private var reuseableVCs: [ObjectIdentifier : [DKPhotoBasePreviewVC] ] = [:] // DKPhotoBasePreviewVC.Type : [DKPhotoBasePreviewVC]
    private var visibleVCs: [Int : DKPhotoBasePreviewVC] = [:]
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.clear
        
        self.mainView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width + 20, height: self.view.bounds.height)
        self.mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mainView.delegate = self
        self.mainView.update(self.items.count)
        self.view.addSubview(self.mainView)
        
        self.updateWithCurrentIndex(needToSetContentOffset: true, onlyCurrentIndex: true)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.prefillingReuseQueue()
    }
    
    internal func filterVisibleVCs<T>(with className: T.Type) -> [T]? {
        return self.visibleVCs.values.filter { previewVC -> Bool in
            return type(of: previewVC) == className
        } as? [T]
    }
    
    // MARK: - Private
    
    private func updateWithCurrentIndex(needToSetContentOffset need: Bool, onlyCurrentIndex: Bool = false) {
        if need {
            self.mainView.contentOffset = CGPoint(x: CGFloat(self.currentIndex) * self.mainView.bounds.width, y: 0)
        }
        
        if onlyCurrentIndex {
            self.addView(at: self.currentIndex)
        } else {
            let fromIndex = self.currentIndex > 0 ? self.currentIndex - 1 : 0
            let toIndex = min(self.currentIndex + 1, self.items.count - 1)
            
            for i in fromIndex ... toIndex {
                if !self.isVisible(for: i) {
                    self.addView(at: i)
                }
            }
        }
    }
    
    private func addView(at index: Int) {
        let vc = self.previewVC(at: index)
        if vc.parent != self {
            self.addChildViewController(vc)
        }
        self.mainView.set(vc, atIndex: index)
    }
    
    private func isVisible(for index: Int) -> Bool {
        if let vc = self.visibleVCs[index], vc.parent != nil {
            return true
        } else {
            return false
        }
    }
    
    private func previewVC(at index: Int) -> DKPhotoBasePreviewVC {
        if let vc = self.visibleVCs[index] {
            return vc
        }
        
        let item = self.items[index]
        
        let previewVCClass = DKPhotoBasePreviewVC.photoPreviewClass(with: item)
        var vc = self.findPreviewVC(for: previewVCClass)
        if vc == nil {
            vc = previewVCClass.init()
        } else {
            vc!.prepareForReuse()
        }
        
        let previewVC = vc!
        
        self.prepareToShow?(previewVC)
        
        previewVC.item = item
        
        self.visibleVCs[index] = previewVC
        
        return previewVC
    }
    
    private func findPreviewVC(for vcClass: DKPhotoBasePreviewVC.Type) -> DKPhotoBasePreviewVC? {
        let classKey = ObjectIdentifier(vcClass)
        return self.reuseableVCs[classKey]?.popLast()
    }
    
    private func addToReuseQueueFromVisibleQueueIfNeeded(index: Int) {
        guard index >= 0 && index < self.items.count else { return }
        
        if let vc = self.visibleVCs[index] {
            self.addToReuseQueue(vc: vc)
            
            self.mainView.remove(vc, atIndex: index)
            self.visibleVCs.removeValue(forKey: index)
        }
    }
    
    private func addToReuseQueue(vc: DKPhotoBasePreviewVC) {
        let classKey = ObjectIdentifier(type(of: vc))
        var queue: [DKPhotoBasePreviewVC]! = self.reuseableVCs[classKey]
        if queue == nil {
            queue = []
        }
        
        queue.append(vc)
        self.reuseableVCs[classKey] = queue
    }
    
    private var isFilled = false
    private func prefillingReuseQueue() {
        guard !self.isFilled else { return }
        
        self.isFilled = true
        
        let vc1 = DKPhotoImagePreviewVC()
        vc1.view.isHidden = true
        self.mainView.addSubview(vc1.view)
        self.addToReuseQueue(vc: vc1)
        
        let vc2 = DKPhotoImagePreviewVC()
        vc2.view.isHidden = true
        self.mainView.addSubview(vc2.view)
        self.addToReuseQueue(vc: vc2)
        
        let vc3 = DKPhotoPlayerPreviewVC()
        vc3.view.isHidden = true
        self.mainView.addSubview(vc3.view)
        self.addToReuseQueue(vc: vc3)
        
        let vc4 = DKPhotoPlayerPreviewVC()
        vc4.view.isHidden = true
        self.mainView.addSubview(vc4.view)
        self.addToReuseQueue(vc: vc4)
        
        let vc5 = self.currentVC.previewType == .photo ? DKPhotoPlayerPreviewVC() : DKPhotoImagePreviewVC()
        vc5.view.isHidden = true
        self.mainView.addSubview(vc5.view)
        self.addToReuseQueue(vc: vc5)
        
        self.updateWithCurrentIndex(needToSetContentOffset: false)
    }
    
    // MARK: - Orientations & Status Bar
    
    open override var shouldAutorotate: Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
        
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.currentIndex > 0 {
            self.visibleVCs[self.currentIndex - 1]?.resetScale()
        }
        
        if self.currentIndex < self.items.count - 1 {
            self.visibleVCs[self.currentIndex + 1]?.resetScale()
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.x / scrollView.bounds.width
        let offset = abs(CGFloat(self.currentIndex) - position)
        
        if 1 - offset < 0.1 {
            let index = Int(position.rounded())
            if index != self.currentIndex {
                self.currentVC.photoPreviewWillDisappear()
                
                if self.currentIndex < index {
                    self.addToReuseQueueFromVisibleQueueIfNeeded(index: index - 2)
                } else {
                    self.addToReuseQueueFromVisibleQueueIfNeeded(index: index + 2)
                }
                
                self.currentIndex = index
                self.updateWithCurrentIndex(needToSetContentOffset: false)
            }
        }
    }
    
}
