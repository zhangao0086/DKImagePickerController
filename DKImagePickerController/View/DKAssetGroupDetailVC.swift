//
//  DKAssetGroupDetailVC.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/8/10.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

private extension UICollectionView {
    
    func indexPathsForElements(in rect: CGRect, _ hidesCamera: Bool) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        
        if hidesCamera {
            return allLayoutAttributes.map { $0.indexPath }
        } else {
            return allLayoutAttributes.flatMap { $0.indexPath.item == 0 ? nil : IndexPath(item: $0.indexPath.item - 1, section: $0.indexPath.section) }
        }
    }
    
}

// Show all images in the asset group
open class DKAssetGroupDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DKImageGroupDataManagerObserver, DKPhotoGalleryDelegate, UIGestureRecognizerDelegate {
    	
    public lazy var selectGroupButton: UIButton = {
        let button = UIButton()
		
        #if swift(>=4.0)
        let globalTitleColor = UINavigationBar.appearance().titleTextAttributes?[NSAttributedStringKey.foregroundColor] as? UIColor
        let globalTitleFont = UINavigationBar.appearance().titleTextAttributes?[NSAttributedStringKey.font] as? UIFont
        #else
        let globalTitleColor = UINavigationBar.appearance().titleTextAttributes?[NSForegroundColorAttributeName] as? UIColor
        let globalTitleFont = UINavigationBar.appearance().titleTextAttributes?[NSFontAttributeName] as? UIFont
        #endif
        
        button.setTitleColor(globalTitleColor ?? UIColor.black, for: .normal)
		button.titleLabel!.font = globalTitleFont ?? UIFont.boldSystemFont(ofSize: 18.0)
		
		button.addTarget(self, action: #selector(DKAssetGroupDetailVC.showGroupSelector), for: .touchUpInside)
        return button
    }()
		
    public var selectedGroupId: String?
    internal var collectionView: UICollectionView!
    internal weak var imagePickerController: DKImagePickerController!
	private var groupListVC: DKAssetGroupListVC!
    private var hidesCamera: Bool = false
	private var footerView: UIView?
    private var currentViewSize: CGSize!
    private var registeredCellIdentifiers = Set<String>()
    private var thumbnailSize = CGSize.zero
    private weak var gallery: DKPhotoGallery?
	
	override open func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		if let currentViewSize = self.currentViewSize, currentViewSize.equalTo(self.view.bounds.size) {
			return
		} else {
			currentViewSize = self.view.bounds.size
		}

		self.collectionView?.collectionViewLayout.invalidateLayout()
	}
    
    override open func viewDidLoad() {
        super.viewDidLoad()
		
		let layout = self.imagePickerController.UIDelegate.layoutForImagePickerController(self.imagePickerController).init()
		self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = self.imagePickerController.UIDelegate.imagePickerControllerCollectionViewBackgroundColor()
        self.collectionView.allowsMultipleSelection = true
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
		self.view.addSubview(self.collectionView)
		
		self.footerView = self.imagePickerController.UIDelegate.imagePickerControllerFooterView(self.imagePickerController)
		if let footerView = self.footerView {
			self.view.addSubview(footerView)
		}
		
		self.hidesCamera = self.imagePickerController.sourceType == .photo
		self.checkPhotoPermission()
        
        if self.imagePickerController.allowSwipeToSelect {
            let swipeOutGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.swiping(gesture:)))
            swipeOutGesture.delegate = self
            self.collectionView.panGestureRecognizer.require(toFail: swipeOutGesture)
            self.collectionView.addGestureRecognizer(swipeOutGesture)
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateCachedAssets()
    }
	
	override open func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if let footerView = self.footerView {
			footerView.frame = CGRect(x: 0, y: self.view.bounds.height - footerView.bounds.height, width: self.view.bounds.width, height: footerView.bounds.height)
			self.collectionView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - footerView.bounds.height)
			
		} else {
			self.collectionView.frame = self.view.bounds
		}
	}
	
	internal func checkPhotoPermission() {
		func photoDenied() {
			self.view.addSubview(DKPermissionView.permissionView(.photo))
			self.view.backgroundColor = UIColor.black
			self.collectionView?.isHidden = true
		}
        
        func setup() {
            self.resetCachedAssets()
            self.imagePickerController.groupDataManager.add(observer: self)
            self.groupListVC = DKAssetGroupListVC(groupDataManager: self.imagePickerController.groupDataManager,
                                                  imageResource: self.imagePickerController.imageResource,
                                                  defaultAssetGroup: self.imagePickerController.defaultAssetGroup,
                                                  selectedGroupDidChangeBlock: { [unowned self] (groupId) in
                                                    self.selectAssetGroup(groupId)
            })
            self.groupListVC.showsEmptyAlbums = self.imagePickerController.showsEmptyAlbums
            self.groupListVC.loadGroups()
        }
        
		DKImageDataManager.checkPhotoPermission { granted in
			granted ? setup() : photoDenied()
		}
	}
	
    func selectAssetGroup(_ groupId: String?) {
        if self.selectedGroupId == groupId {
            self.updateTitleView()
            return
        }
        
        self.selectedGroupId = groupId
		self.updateTitleView()
		self.collectionView!.reloadData()
    }
    
	open func updateTitleView() {
		let group = self.imagePickerController.groupDataManager.fetchGroupWithGroupId(self.selectedGroupId!)
		self.title = group.groupName
		
		let groupsCount = self.imagePickerController.groupDataManager.groupIds?.count ?? 0
		self.selectGroupButton.setTitle(group.groupName + (groupsCount > 1 ? "  \u{25be}" : "" ), for: .normal)
		self.selectGroupButton.sizeToFit()
		self.selectGroupButton.isEnabled = groupsCount > 1
		
		self.navigationItem.titleView = self.selectGroupButton
	}
    
    @objc func showGroupSelector() {
        DKPopoverViewController.popoverViewController(self.groupListVC, fromView: self.selectGroupButton)
    }
    
    func fetchAsset(for index: Int, ignoreUI : Bool = false) -> DKAsset? {
        var assetIndex = index
        if !ignoreUI {
            if !self.hidesCamera && index == 0 {
                return nil
            }
            
            assetIndex = (index - (self.hidesCamera ? 0 : 1))
        }
        let assetIndex = (index - (self.hidesCamera ? 0 : 1))
        let group = self.imagePickerController.groupDataManager.fetchGroupWithGroupId(self.selectedGroupId!)
        return self.imagePickerController.groupDataManager.fetchAsset(group, index: assetIndex)
    }
    
    // select an asset at a specific index
    public func selectAsset(atIndex indexPath: IndexPath) {
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? DKAssetGroupDetailBaseCell
            , let asset = cell.asset else {
            return
        }
        
        if !self.imagePickerController.contains(asset: asset) {
            self.imagePickerController.select(asset: asset, updateGroupDetailVC: false)
            cell.selectedIndex = self.imagePickerController.selectedAssetIdentifiers.count - 1
            
            if !cell.isSelected {
                self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
            }
        }
    }
    
    public func deselectAsset(atIndex indexPath: IndexPath) {
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? DKAssetGroupDetailBaseCell
            , let asset = cell.asset else {
                return
        }
        
        if let removedIndex = self.imagePickerController.index(of: asset) {
            /// Minimize the number of times.
            let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems!
            let indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems
            
            let intersect = Set(indexPathsForVisibleItems).intersection(Set(indexPathsForSelectedItems))
            
            for selectedIndexPath in intersect {
                if let selectedCell = (collectionView.cellForItem(at: selectedIndexPath) as? DKAssetGroupDetailBaseCell)
                    , let selectedCellAsset = selectedCell.asset
                    , let selectedIndex = self.imagePickerController.index(of: selectedCellAsset) {
                    if selectedIndex > removedIndex {
                        selectedCell.selectedIndex = selectedCell.selectedIndex - 1
                    }
                }
            }
            
            self.imagePickerController.deselect(asset: asset, updateGroupDetailVC: false)
            
            if cell.isSelected {
                self.collectionView.deselectItem(at: indexPath, animated: true)
            }
        }
    }

    func isCameraCell(indexPath: IndexPath) -> Bool {
        return indexPath.row == 0 && !self.hidesCamera
    }
    
    // MARK: - Cells
    
    func registerCellIfNeeded(cellClass: DKAssetGroupDetailBaseCell.Type) {
        let cellReuseIdentifier = cellClass.cellReuseIdentifier()
        
        if !self.registeredCellIdentifiers.contains(cellReuseIdentifier) {
            self.collectionView.register(cellClass, forCellWithReuseIdentifier: cellReuseIdentifier)
            self.registeredCellIdentifiers.insert(cellReuseIdentifier)
        }
    }
    
    func dequeueReusableCell(for indexPath: IndexPath) -> DKAssetGroupDetailBaseCell {
        let asset = self.fetchAsset(for: indexPath.row)!
        
        let cellClass: DKAssetGroupDetailBaseCell.Type!
        if asset.type == .video {
            cellClass = self.imagePickerController.UIDelegate.imagePickerControllerCollectionVideoCell()
        } else {
            cellClass = self.imagePickerController.UIDelegate.imagePickerControllerCollectionImageCell()
        }
        self.registerCellIfNeeded(cellClass: cellClass)
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: cellClass.cellReuseIdentifier(), for: indexPath) as! DKAssetGroupDetailBaseCell
        self.setup(assetCell: cell, for: indexPath, with: asset)
        
        return cell
    }
    
    func dequeueReusableCameraCell(for indexPath: IndexPath) -> DKAssetGroupDetailBaseCell {
        let cellClass = self.imagePickerController.UIDelegate.imagePickerControllerCollectionCameraCell()
        self.registerCellIfNeeded(cellClass: cellClass)
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: cellClass.cellReuseIdentifier(), for: indexPath)
        return cell as! DKAssetGroupDetailBaseCell
    }
	
    func setup(assetCell cell: DKAssetGroupDetailBaseCell, for indexPath: IndexPath, with asset: DKAsset) {
        cell.asset = asset
		let tag = indexPath.row + 1
		cell.tag = tag
		
        if self.thumbnailSize.equalTo(CGSize.zero) {
            self.thumbnailSize = self.collectionView!.collectionViewLayout.layoutAttributesForItem(at: indexPath)!.size.toPixel()
        }
        
        cell.thumbnailImage = nil
        
        asset.fetchImage(with: self.thumbnailSize, options: nil, contentMode: .aspectFill) { (image, info) in
            if cell.tag == tag, let image = image {
                cell.thumbnailImage = image
            }
        }

        if let index = self.imagePickerController.selectedAssets.index(of: asset) {
			cell.isSelected = true
			cell.selectedIndex = selectedIndex
			self.collectionView!.selectItem(at: indexPath, animated: false, scrollPosition: [])
		} else {
			cell.isSelected = false
			self.collectionView!.deselectItem(at: indexPath, animated: false)
		}
	}

    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource methods

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let selectedGroupId = self.selectedGroupId else { return 0 }
		
		let group = self.imagePickerController.groupDataManager.fetchGroupWithGroupId(selectedGroupId)
        
        var totalCount = 0
        if self.imagePickerController.fetchLimit > 0 {
            totalCount = min(group.totalCount ?? 0, self.imagePickerController.fetchLimit)
        } else {
            totalCount = group.totalCount ?? 0
        }
        return totalCount + (self.hidesCamera ? 0 : 1)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DKAssetGroupDetailBaseCell!
        if self.isCameraCell(indexPath: indexPath) {
            cell = self.dequeueReusableCameraCell(for: indexPath)
        } else {
            cell = self.dequeueReusableCell(for: indexPath)
        }
        
        if cell.imagePickerController == nil {
            cell.imagePickerController = self.imagePickerController
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let firstSelectedAsset = self.imagePickerController.selectedAssets.first,
            let selectedAsset = (collectionView.cellForItem(at: indexPath) as? DKAssetGroupDetailBaseCell)?.asset
            , self.imagePickerController.allowMultipleTypes == false && firstSelectedAsset.type != selectedAsset.type {

            let alert = UIAlertController(
                    title: DKImageLocalizedStringWithKey("selectPhotosOrVideos")
                    , message: DKImageLocalizedStringWithKey("selectPhotosOrVideosError")
                    , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: DKImageLocalizedStringWithKey("ok"), style: .cancel) { _ in })
            self.imagePickerController.present(alert, animated: true){}

            return false
        }
		
        if self.imagePickerController.maxSelectableCount > 0 {
            let shouldSelect = self.imagePickerController.selectedAssets.count < self.imagePickerController.maxSelectableCount
            if !shouldSelect {
                self.imagePickerController.UIDelegate.imagePickerControllerDidReachMaxLimit(self.imagePickerController)
            }
            
            return shouldSelect
        } else {
            return true
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isCameraCell(indexPath: indexPath) {
            collectionView .deselectItem(at: indexPath, animated: false)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.presentCamera()
            }
        } else {
            self.selectAsset(atIndex: indexPath)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.deselectAsset(atIndex: indexPath)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateCachedAssets()
    }
    
    // MARK: - Asset Caching
    
    var previousPreheatRect = CGRect.zero
    
    fileprivate func resetCachedAssets() {
        getImageDataManager().stopCachingForAllAssets()
        self.previousPreheatRect = .zero
    }

    func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil && self.selectedGroupId != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let preheatRect = view!.bounds.insetBy(dx: 0, dy: -0.5 * view!.bounds.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - self.previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        let group = self.imagePickerController.groupDataManager.fetchGroupWithGroupId(self.selectedGroupId!)
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = self.differencesBetweenRects(self.previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in self.collectionView!.indexPathsForElements(in: rect, self.hidesCamera) }
            .map { indexPath in self.imagePickerController.groupDataManager.fetchPHAsset(group, index: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in self.collectionView!.indexPathsForElements(in: rect, self.hidesCamera) }
            .map { indexPath in self.imagePickerController.groupDataManager.fetchPHAsset(group, index: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        getImageDataManager().startCachingAssets(for: addedAssets,
                                             targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil)
        getImageDataManager().stopCachingAssets(for: removedAssets,
                                            targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
	
	// MARK: - DKImageGroupDataManagerObserver methods
	
	func groupDidUpdate(groupId: String) {
		if self.selectedGroupId == groupId {
			self.updateTitleView()
		}
	}
	
	func group(groupId: String, didRemoveAssets assets: [DKAsset]) {
        for removedAsset in assets {
            if self.imagePickerController.contains(asset: removedAsset) {
                self.imagePickerController.deselect(asset: removedAsset, updateGroupDetailVC: false)
            }
        }
	}
    
    func groupDidUpdateComplete(groupId: String) {
        if self.selectedGroupId == groupId {
            self.resetCachedAssets()
            self.collectionView?.reloadData()
        }
    }

}
