//
//  DKImageExtensionGallery.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 16/12/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import Foundation
import DKPhotoGallery

class DKImageExtensionGallery: DKImageBaseExtension, DKPhotoGalleryDelegate {
    
    private weak var gallery: DKPhotoGallery?
    private var group: DKAssetGroup!
    
    override class func extensionType() -> DKImageExtensionType {
        return .gallery
    }
        
    override func perform(with extraInfo: [AnyHashable: Any]) {
        guard let groupDetailVC = self.context.groupDetailVC
            , let groupId = extraInfo["groupId"] as? String else { return }
        
        let presentationIndex = extraInfo["presentationIndex"] as? Int
        let presentingFromImageView = extraInfo["presentingFromImageView"] as? UIImageView
        
        var items = [DKPhotoGalleryItem]()
        let group = context.imagePickerController.groupDataManager.fetchGroupWithGroupId(groupId)
                
        for i in 0..<group.totalCount {
            let phAsset = context.imagePickerController.groupDataManager.fetchPHAsset(group, index: i)
            
            let item = DKPhotoGalleryItem(asset: phAsset)
            
            if i == presentationIndex, let presentingFromImage = presentingFromImageView?.image {
                item.thumbnail = presentingFromImage
            }
            
            items.append(item)
        }
        
        let gallery = DKPhotoGallery()
        gallery.singleTapMode = .toggleControlView
        gallery.items = items
        gallery.galleryDelegate = self
        gallery.presentingFromImageView = presentingFromImageView
        gallery.presentationIndex = presentationIndex ?? 0
        gallery.finishedBlock = { index in
            let cellIndex = groupDetailVC.adjustAssetIndex(index)
            let cellIndexPath = IndexPath(row: cellIndex, section: 0)
            groupDetailVC.scrollIndexPathToVisible(cellIndexPath)
            
            return groupDetailVC.thumbnailImageView(for: cellIndexPath)
        }
        
        self.gallery = gallery
        self.group = group
        
        if context.imagePickerController.inline {
            UIApplication.shared.keyWindow!.rootViewController!.present(photoGallery: gallery)
        } else {
            groupDetailVC.present(photoGallery: gallery)
        }
    }
    
    // MARK: - DKPhotoGalleryDelegate
    
    private var backItem = UIBarButtonItem(image: DKImagePickerControllerResource.photoGalleryBackArrowImage(),
                                           style: .plain,
                                           target: self,
                                           action: #selector(dismissGallery))
    
    func photoGallery(_ gallery: DKPhotoGallery, didShow index: Int) {
        if let viewController = gallery.topViewController {
            if viewController.navigationItem.rightBarButtonItem == nil {
                let button = UIButton(type: .custom)
                button.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 13)
                button.addTarget(self, action: #selector(DKImageExtensionGallery.selectAssetFromGallery(button:)), for: .touchUpInside)
                button.setTitle("", for: .normal)
                
                button.setBackgroundImage(DKImagePickerControllerResource.photoGalleryCheckedImage(), for: .selected)
                button.setBackgroundImage(DKImagePickerControllerResource.photoGalleryUncheckedImage(), for: .normal)
                
                button.bounds = CGRect(x: 0, y: 0,
                                       width: DKImagePickerControllerResource.photoGalleryCheckedImage().size.width,
                                       height: DKImagePickerControllerResource.photoGalleryCheckedImage().size.height)
                
                let item = UIBarButtonItem(customView: button)
                viewController.navigationItem.rightBarButtonItem = item
            }
            
            if viewController.navigationItem.leftBarButtonItem != self.backItem {
                viewController.navigationItem.leftBarButtonItem = self.backItem
            }
            
            self.updateGalleryAssetSelection()
        }
    }
    
    // MARK: - Private
    
    @objc func selectAssetFromGallery(button: UIButton) {
        if let gallery = self.gallery {
            let currentIndex = gallery.currentIndex()
            let asset = self.context.imagePickerController.groupDataManager.fetchAsset(self.group,
                                                                                       index: currentIndex)
            
            if button.isSelected {
                self.context.imagePickerController.deselect(asset: asset)
            } else {
                self.context.imagePickerController.select(asset: asset)
            }
            
            self.updateGalleryAssetSelection()
        }
    }
    
    open func updateGalleryAssetSelection() {
        if let gallery = self.gallery, let button = gallery.topViewController?.navigationItem.rightBarButtonItem?.customView as? UIButton {
            let currentIndex = gallery.currentIndex()
            
            let asset = self.context.imagePickerController.groupDataManager.fetchAsset(self.group,
                                                                                       index: currentIndex)
            
            var labelWidth: CGFloat = 0.0
            if let selectedIndex = self.context.imagePickerController.index(of: asset) {
                let title = "\(selectedIndex + 1)"
                button.setTitle(title, for: .selected)
                button.isSelected = true
                
                labelWidth = button.titleLabel!.sizeThatFits(CGSize(width: 100, height: 50)).width + 10
            } else {
                button.isSelected = false
                button.sizeToFit()
            }
            
            button.bounds = CGRect(x: 0, y: 0,
                                   width: max(button.backgroundImage(for: .normal)!.size.width, labelWidth),
                                   height: button.bounds.height)
        }
    }
    
    @objc open func dismissGallery() {
        self.gallery?.dismissGallery()
    }

}
