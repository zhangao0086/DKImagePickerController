//
//  DKPhotoGalleryInteractiveTransition.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 09/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit

class DKPhotoGalleryInteractiveTransition: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate {

    private var gallery: DKPhotoGallery!
    
    private var fromContentView: UIView?
    private var fromRect: CGRect!
    
    internal var isInteracting = false
    private var percent: CGFloat = 0
    private var toImageView: UIImageView?
    
    convenience init(gallery: DKPhotoGallery) {
        self.init()
        
        self.gallery = gallery
        self.setupGesture()
    }
    
    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        panGesture.delegate = self
        self.gallery.view.addGestureRecognizer(panGesture)
    }
    
    @objc private func handleGesture(_ recognizer: UIPanGestureRecognizer) {
        let offset = recognizer.translation(in: recognizer.view?.superview)
        
        switch recognizer.state {
        case .began:
            self.isInteracting = true
            self.fromContentView = self.gallery.currentContentView()
            self.fromRect = self.fromContentView?.frame
            
            self.toImageView = self.gallery.finishedBlock?(self.gallery.currentIndex())
            self.toImageView?.isHidden = true
        case .changed:
            let fraction = CGFloat(fabsf(Float(offset.y / 200)))
            self.percent = fmin(fraction, 1.0)
            
            if let fromContentView = self.fromContentView {
                let currentLocation = recognizer.location(in: nil)
                let originalLocation = CGPoint(x: currentLocation.x - offset.x, y: currentLocation.y - offset.y)
                var percent = CGFloat(1.0)
                percent = fmax(offset.y > 0 ? 1 - self.percent : CGFloat(1), 0.5)
                let currentWidth = self.fromRect.width * percent
                let currentHeight = self.fromRect.height * percent
                
                let result = CGRect(x: currentLocation.x - (originalLocation.x - self.fromRect.origin.x) * percent,
                                    y: currentLocation.y - (originalLocation.y - self.fromRect.origin.y) * percent,
                                    width: currentWidth,
                                    height: currentHeight)
                fromContentView.frame = (fromContentView.superview?.convert(result, from: nil))!
                
                if offset.y < 0 {
                    self.percent = -self.percent
                }
                
                self.gallery.updateContextBackground(alpha: CGFloat(fabsf(Float(1 - self.percent))), animated: true)
            }
        case .ended,
             .cancelled:
            self.isInteracting = false
            let shouldComplete = self.percent > 0.35
            if !shouldComplete || recognizer.state == .cancelled {
                if let fromContentView = self.fromContentView {
                    let toImageView = self.toImageView
                    let contentMode = fromContentView.contentMode
                    UIView.animate(withDuration: 0.3, animations: {
                        fromContentView.frame = self.fromRect
                        fromContentView.contentMode = contentMode
                        self.gallery.updateContextBackground(alpha: 1, animated: false)
                    }) { (finished) in
                        toImageView?.isHidden = false
                    }
                }
            } else {
                self.gallery.dismissGallery()
                self.finish()
            }
            self.fromContentView = nil
            self.percent = 0
            self.toImageView = nil
        default:
            break
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureView = gestureRecognizer.view else { return true }
        
        let location = gestureRecognizer.location(in: gestureView)
        
        if let hitTestingView = gestureView.hitTest(location, with: nil), hitTestingView.isKind(of: UISlider.self) {
            return false
        } else {
            return true
        }
    }

}
