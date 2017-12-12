//
//  DKPhotoGallery.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 15/7/20.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit

@objc
public protocol DKPhotoGalleryDelegate : NSObjectProtocol {

    @objc optional func photoGallery(_ gallery: DKPhotoGallery, didShow index: Int)
    
}

@objc
public enum DKPhotoGallerySingleTapMode : Int {
    case dismiss, toggleControlView
}

@objc
open class DKPhotoGallery: UINavigationController, UIViewControllerTransitioningDelegate {
	
    open var items: [DKPhotoGalleryItem]?
    
    open var finishedBlock: ((_ index: Int) -> UIImageView?)?
    
    open var presentingFromImageView: UIImageView?
    open var presentationIndex = 0
    
    open var singleTapMode = DKPhotoGallerySingleTapMode.toggleControlView
    
    weak open var galleryDelegate: DKPhotoGalleryDelegate?
    
    open var customLongPressActions: [UIAlertAction]?
    open var customPreviewActions: [Any]? // [UIPreviewAction]
    
    open var transitionController: DKPhotoGalleryTransitionController?
    
    internal var statusBar: UIView?
    internal weak var contentVC: DKPhotoGalleryContentVC!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        self.navigationBar.barStyle = .blackTranslucent
        
        let contentVC = DKPhotoGalleryContentVC()
        self.contentVC = contentVC
        self.viewControllers = [contentVC]
        
        contentVC.prepareToShow = { [weak self] previewVC in
            self?.setup(previewVC: previewVC)
        }
        
        contentVC.pageChangeBlock = { [weak self] index in
            guard let strongSelf = self else { return }
            
            strongSelf.updateNavigation()
            strongSelf.galleryDelegate?.photoGallery?(strongSelf, didShow: index)
        }
        
        contentVC.items = self.items
        contentVC.currentIndex = min(self.presentationIndex, self.items!.count - 1)
        
        contentVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(DKPhotoGallery.dismissGallery))
        
        let keyData = Data(bytes: [0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72])
        let key = String(data: keyData, encoding: String.Encoding.ascii)!
        if let statusBar = UIApplication.shared.value(forKey: key) as? UIView {
            self.statusBar = statusBar
        }
    }
    
    private lazy var doSetupOnce: () -> Void = {
        self.isNavigationBarHidden = true
        if self.singleTapMode == .toggleControlView {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
                self.setNavigationBarHidden(false, animated: true)
                self.showsControlView()
            })
            self.statusBar?.alpha = 1
        } else {
            self.statusBar?.alpha = 0
        }

        return {}
    }()
    
    private let defaultStatusBarStyle = UIApplication.shared.statusBarStyle
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.doSetupOnce()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.modalPresentationCapturesStatusBarAppearance = true
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.statusBarStyle = self.defaultStatusBarStyle
        
        self.modalPresentationCapturesStatusBarAppearance = false
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.statusBar?.alpha = 1
    }
    
    @objc open func dismissGallery() {
        self.dismiss(animated: true) {
            if self.view.window == nil {
                self.transitionController = nil
            }
        }
    }
    
    open func currentContentView() -> UIView {
        return self.contentVC.currentContentView
    }
    
    open func currentContentVC() -> DKPhotoBasePreviewVC {
        return self.contentVC.currentVC
    }
    
    open func currentIndex() -> Int {
        return self.contentVC.currentIndex
    }
    
    open func updateNavigation() {
        self.contentVC.navigationItem.title = "\(self.contentVC.currentIndex + 1)/\(self.items!.count)"
    }
    
    open func handleSingleTap() {
        switch self.singleTapMode {
        case .toggleControlView:
            self.toggleControlView()
        case .dismiss:
            self.dismissGallery()
        }
    }
    
    open func toggleControlView() {
        if self.isNavigationBarHidden {
            self.showsControlView()
        } else {
            self.hidesControlView()
        }
    }
    
    open func showsControlView () {
        self.isNavigationBarHidden = false
        self.statusBar?.alpha = 1
        
        if let videoPreviewVCs = self.contentVC.filterVisibleVCs(with: DKPhotoPlayerPreviewVC.self) {
            let _ = videoPreviewVCs.map { $0.isControlHidden = false }
        }
    }
    
    open func hidesControlView () {
        self.isNavigationBarHidden = true
        self.statusBar?.alpha = 0
        
        if let videoPreviewVCs = self.contentVC.filterVisibleVCs(with: DKPhotoPlayerPreviewVC.self) {
            let _ = videoPreviewVCs.map { $0.isControlHidden = true }
        }
    }
    
    private func setup(previewVC: DKPhotoBasePreviewVC) {
        previewVC.customLongPressActions = self.customLongPressActions
        previewVC.customPreviewActions = self.customPreviewActions
        previewVC.singleTapBlock = { [weak self] in
            self?.handleSingleTap()
        }
        
        if previewVC.previewType == .video, let videoPreviewVC = previewVC as? DKPhotoPlayerPreviewVC {
            if self.singleTapMode == .dismiss {
                videoPreviewVC.closeBlock = { [weak self] in
                    self?.dismissGallery()
                }
                videoPreviewVC.isControlHidden = true
                videoPreviewVC.autoHidesControlView = true
                videoPreviewVC.tapToToggleControlView = true
            } else {
                videoPreviewVC.isControlHidden = self.isNavigationBarHidden
                videoPreviewVC.autoHidesControlView = false
                videoPreviewVC.tapToToggleControlView = false
                
                videoPreviewVC.beginPlayBlock = { [weak self] in
                    self?.hidesControlView()
                }
            }
        }
    }
    
    internal func updateContextBackground(alpha: CGFloat, animated: Bool) {
        let block = {
            self.currentContentVC().updateContextBackground(alpha: alpha)
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: alpha)
            
            if self.isNavigationBarHidden {
                self.statusBar?.alpha = 1 - alpha
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.1, animations: block)
        } else {
            block()
        }
    }
	
    @available(iOS 9.0, *)
    open override var previewActionItems: [UIPreviewActionItem] {
        return self.contentVC.currentVC.previewActionItems
    }
    
}

//////////////////////////////////////////////////////////////////////////////////////////

public extension UIViewController {
    
    public func present(photoGallery gallery: DKPhotoGallery, completion: (() -> Swift.Void)? = nil) {
        gallery.modalPresentationStyle = .custom
        
        gallery.transitionController = DKPhotoGalleryTransitionController(gallery: gallery, presentedViewController: gallery, presenting: self)
        gallery.transitioningDelegate = gallery.transitionController
        
        gallery.transitionController!.prepareInteractiveGesture()
        
        self.present(gallery, animated: true, completion: completion)
    }
}
