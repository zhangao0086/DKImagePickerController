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

private let DKImageCameraIdentifier = "DKImageCameraIdentifier"
private let DKImageAssetIdentifier = "DKImageAssetIdentifier"
private let DKVideoAssetIdentifier = "DKVideoAssetIdentifier"

// Show all images in the asset group
internal class DKAssetGroupDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DKGroupDataManagerObserver {

    class DKImageCameraCell: UICollectionViewCell {
        
        var didCameraButtonClicked: (() -> Void)?
		
		private weak var cameraButton: UIButton!
		
		override init(frame: CGRect) {
			super.init(frame: frame)
			
			let cameraButton = UIButton(frame: frame)
			cameraButton.addTarget(self, action: #selector(DKImageCameraCell.cameraButtonClicked), forControlEvents: .TouchUpInside)
			cameraButton.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
			self.contentView.addSubview(cameraButton)
			self.cameraButton = cameraButton
			
			self.contentView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		func setCameraImage(cameraImage: UIImage) {
			self.cameraButton.setImage(cameraImage, forState: .Normal)
		}
		
        func cameraButtonClicked() {
            if let didCameraButtonClicked = self.didCameraButtonClicked {
                didCameraButtonClicked()
            }
        }
        
    } /* DKImageCameraCell */

    
    class DKAssetCell: UICollectionViewCell {
        
        class DKImageCheckView: UIView {

            internal lazy var checkImageView: UIImageView = {
                let imageView = UIImageView(image: DKImageResource.checkedImage().imageWithRenderingMode(.AlwaysTemplate))
                return imageView
            }()
            
            internal lazy var checkLabel: UILabel = {
                let label = UILabel()
                label.textAlignment = .Right
                
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
		
		private var asset: DKAsset!
		
        private let thumbnailImageView: UIImageView = {
            let thumbnailImageView = UIImageView()
            thumbnailImageView.contentMode = .ScaleAspectFill
            thumbnailImageView.clipsToBounds = true
            
            return thumbnailImageView
        }()
        
        private let checkView = DKImageCheckView()
        
        override var selected: Bool {
            didSet {
                checkView.hidden = !super.selected
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.thumbnailImageView.frame = self.bounds
            self.contentView.addSubview(self.thumbnailImageView)
            self.contentView.addSubview(checkView)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
			
            self.thumbnailImageView.frame = self.bounds
            checkView.frame = self.thumbnailImageView.frame
        }
		
    } /* DKAssetCell */
    
    class DKVideoAssetCell: DKAssetCell {
		
		override var asset: DKAsset! {
			didSet {
				let videoDurationLabel = self.videoInfoView.viewWithTag(-1) as! UILabel
				let minutes: Int = Int(asset.duration!) / 60
				let seconds: Int = Int(round(asset.duration!)) % 60
				videoDurationLabel.text = String(format: "\(minutes):%02d", seconds)
			}
		}
		
        override var selected: Bool {
            didSet {
                if super.selected {
                    self.videoInfoView.backgroundColor = UIColor(red: 20 / 255, green: 129 / 255, blue: 252 / 255, alpha: 1)
                } else {
                    self.videoInfoView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
                }
            }
        }
        
        private lazy var videoInfoView: UIView = {
            let videoInfoView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 0))

            let videoImageView = UIImageView(image: DKImageResource.videoCameraIcon())
            videoInfoView.addSubview(videoImageView)
            videoImageView.center = CGPoint(x: videoImageView.bounds.width / 2 + 7, y: videoInfoView.bounds.height / 2)
            videoImageView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleTopMargin]
            
            let videoDurationLabel = UILabel()
            videoDurationLabel.tag = -1
            videoDurationLabel.textAlignment = .Right
            videoDurationLabel.font = UIFont.systemFontOfSize(12)
            videoDurationLabel.textColor = UIColor.whiteColor()
            videoInfoView.addSubview(videoDurationLabel)
            videoDurationLabel.frame = CGRect(x: 0, y: 0, width: videoInfoView.bounds.width - 7, height: videoInfoView.bounds.height)
            videoDurationLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            return videoInfoView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.contentView.addSubview(videoInfoView)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let height: CGFloat = 30
            self.videoInfoView.frame = CGRect(x: 0, y: self.contentView.bounds.height - height,
                width: self.contentView.bounds.width, height: height)
        }
        
    } /* DKVideoAssetCell */
	
    private lazy var selectGroupButton: UIButton = {
        let button = UIButton()
		
		let globalTitleColor = UINavigationBar.appearance().titleTextAttributes?[NSForegroundColorAttributeName] as? UIColor
		button.setTitleColor(globalTitleColor ?? UIColor.blackColor(), forState: .Normal)
		
		let globalTitleFont = UINavigationBar.appearance().titleTextAttributes?[NSFontAttributeName] as? UIFont
		button.titleLabel!.font = globalTitleFont ?? UIFont.boldSystemFontOfSize(18.0)
		
		button.addTarget(self, action: #selector(DKAssetGroupDetailVC.showGroupSelector), forControlEvents: .TouchUpInside)
        return button
    }()
		
    internal var selectedGroupId: String?
	
	internal weak var imagePickerController: DKImagePickerController!
	
	private var groupListVC: DKAssetGroupListVC!
    
    private var hidesCamera: Bool = false
	
	internal var collectionView: UICollectionView!
    
	private var footerView: UIView?
	
	private var currentViewSize: CGSize!
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		if let currentViewSize = self.currentViewSize where CGSizeEqualToSize(currentViewSize, self.view.bounds.size) {
			return
		} else {
			currentViewSize = self.view.bounds.size
		}

		self.collectionView?.collectionViewLayout.invalidateLayout()
	}
	
	private lazy var groupImageRequestOptions: PHImageRequestOptions = {
		let options = PHImageRequestOptions()
		options.deliveryMode = .HighQualityFormat
		options.resizeMode = .Exact
		
		return options
	}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let layout = self.imagePickerController.UIDelegate.layoutForImagePickerController(self.imagePickerController).init()
		self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = self.imagePickerController.UIDelegate.imagePickerControllerCollectionViewBackgroundColor()
        self.collectionView.allowsMultipleSelection = true
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
        self.collectionView.registerClass(DKImageCameraCell.self, forCellWithReuseIdentifier: DKImageCameraIdentifier)
        self.collectionView.registerClass(DKAssetCell.self, forCellWithReuseIdentifier: DKImageAssetIdentifier)
        self.collectionView.registerClass(DKVideoAssetCell.self, forCellWithReuseIdentifier: DKVideoAssetIdentifier)
		self.view.addSubview(self.collectionView)
		
		self.footerView = self.imagePickerController.UIDelegate.imagePickerControllerFooterView(self.imagePickerController)
		if let footerView = self.footerView {
			self.view.addSubview(footerView)
		}
		
		self.hidesCamera = self.imagePickerController.sourceType == .Photo
		self.checkPhotoPermission()
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if let footerView = self.footerView {
			footerView.frame = CGRectMake(0, self.view.bounds.height - footerView.bounds.height, self.view.bounds.width, footerView.bounds.height)
			self.collectionView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - footerView.bounds.height)
			
		} else {
			self.collectionView.frame = self.view.bounds
		}
	}
	
	internal func checkPhotoPermission() {
		func photoDenied() {
			self.view.addSubview(DKPermissionView.permissionView(.Photo))
			self.view.backgroundColor = UIColor.blackColor()
			self.collectionView?.hidden = true
		}
		
		func setup() {
			getImageManager().groupDataManager.addObserver(self)
			self.groupListVC = DKAssetGroupListVC(selectedGroupDidChangeBlock: { [unowned self] groupId in
				self.selectAssetGroup(groupId)
			}, defaultAssetGroup: self.imagePickerController.defaultAssetGroup)
			self.groupListVC.loadGroups()
		}
		
		DKImageManager.checkPhotoPermission { granted in
			granted ? setup() : photoDenied()
		}
	}
	
    func selectAssetGroup(groupId: String?) {
        if self.selectedGroupId == groupId {
            return
        }
        
        self.selectedGroupId = groupId
		self.updateTitleView()
		self.collectionView!.reloadData()
    }
	
	func updateTitleView() {
		let group = getImageManager().groupDataManager.fetchGroupWithGroupId(self.selectedGroupId!)
		self.title = group.groupName
		
		let groupsCount = getImageManager().groupDataManager.groupIds?.count
		self.selectGroupButton.setTitle(group.groupName + (groupsCount > 1 ? "  \u{25be}" : "" ), forState: .Normal)
		self.selectGroupButton.sizeToFit()
		self.selectGroupButton.enabled = groupsCount > 1
		
		self.navigationItem.titleView = self.selectGroupButton
	}
    
    func showGroupSelector() {
        DKPopoverViewController.popoverViewController(self.groupListVC, fromView: self.selectGroupButton)
    }
	
    // MARK: - Cells

    func cameraCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(DKImageCameraIdentifier, forIndexPath: indexPath) as! DKImageCameraCell
		cell.setCameraImage(self.imagePickerController.UIDelegate.imagePickerControllerCameraImage())
        
        cell.didCameraButtonClicked = { [unowned self] in
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                if self.imagePickerController.selectedAssets.count < self.imagePickerController.maxSelectableCount  {
                    self.imagePickerController.presentCamera()
                } else {
                    self.imagePickerController.UIDelegate.imagePickerControllerDidReachMaxLimit(self.imagePickerController)
                }
            }
        }

        return cell
	}
	
	func assetCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
		let assetIndex = (indexPath.row - (self.hidesCamera ? 0 : 1))
		let group = getImageManager().groupDataManager.fetchGroupWithGroupId(self.selectedGroupId!)
		
		let asset = getImageManager().groupDataManager.fetchAssetWithGroup(group, index: assetIndex)
		
		var cell: DKAssetCell!
		var identifier: String!
		if asset.isVideo {
			identifier = DKVideoAssetIdentifier
		} else {
			identifier = DKImageAssetIdentifier
		}
		
		cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! DKAssetCell
        cell.checkView.checkImageView.tintColor = self.imagePickerController.UIDelegate.imagePickerControllerCheckedImageTintColor()
        cell.checkView.checkLabel.font = self.imagePickerController.UIDelegate.imagePickerControllerCheckedNumberFont()
        cell.checkView.checkLabel.textColor = self.imagePickerController.UIDelegate.imagePickerControllerCheckedNumberColor()

        cell.asset = asset
		let tag = indexPath.row + 1
		cell.tag = tag
		
		let itemSize = self.collectionView!.collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath)!.size
		asset.fetchImageWithSize(itemSize.toPixel(), options: self.groupImageRequestOptions, contentMode: .AspectFill) { (image, info) in
			if cell.tag == tag {
				cell.thumbnailImageView.image = image
			}
		}
		
		if let index = self.imagePickerController.selectedAssets.indexOf(asset) {
			cell.selected = true
			cell.checkView.checkLabel.text = "\(index + 1)"
			self.collectionView!.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
		} else {
			cell.selected = false
			self.collectionView!.deselectItemAtIndexPath(indexPath, animated: false)
		}
		
		return cell
	}

    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource methods

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let selectedGroup = self.selectedGroupId else { return 0 }
		
		let group = getImageManager().groupDataManager.fetchGroupWithGroupId(selectedGroup)
        return (group.totalCount ?? 0) + (self.hidesCamera ? 0 : 1)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 && !self.hidesCamera {
            return self.cameraCellForIndexPath(indexPath)
        } else {
            return self.assetCellForIndexPath(indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let firstSelectedAsset = self.imagePickerController.selectedAssets.first,
            selectedAsset = (collectionView.cellForItemAtIndexPath(indexPath) as? DKAssetCell)?.asset
            where self.imagePickerController.allowMultipleTypes == false && firstSelectedAsset.isVideo != selectedAsset.isVideo {
                
                UIAlertView(title: DKImageLocalizedStringWithKey("selectPhotosOrVideos"),
                    message: DKImageLocalizedStringWithKey("selectPhotosOrVideosError"),
                    delegate: nil,
                    cancelButtonTitle: DKImageLocalizedStringWithKey("ok")).show()
                
                return false
        }
		
		let shouldSelect = self.imagePickerController.selectedAssets.count < self.imagePickerController.maxSelectableCount
		if !shouldSelect {
			self.imagePickerController.UIDelegate.imagePickerControllerDidReachMaxLimit(self.imagePickerController)
		}
		
		return shouldSelect
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let selectedAsset = (collectionView.cellForItemAtIndexPath(indexPath) as? DKAssetCell)?.asset
		self.imagePickerController.selectImage(selectedAsset!)
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? DKAssetCell {
            cell.checkView.checkLabel.text = "\(self.imagePickerController.selectedAssets.count)"
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
		if let removedAsset = (collectionView.cellForItemAtIndexPath(indexPath) as? DKAssetCell)?.asset {
			let removedIndex = self.imagePickerController.selectedAssets.indexOf(removedAsset)!
			
			/// Minimize the number of cycles.
			let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems() as [NSIndexPath]!
			let indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems()
			
			let intersect = Set(indexPathsForVisibleItems).intersect(Set(indexPathsForSelectedItems))
			
			for selectedIndexPath in intersect {
				if let selectedCell = (collectionView.cellForItemAtIndexPath(selectedIndexPath) as? DKAssetCell) {
					let selectedIndex = self.imagePickerController.selectedAssets.indexOf(selectedCell.asset)!
					
					if selectedIndex > removedIndex {
						selectedCell.checkView.checkLabel.text = "\(Int(selectedCell.checkView.checkLabel.text!)! - 1)"
					}
				}
			}
			
			self.imagePickerController.deselectImage(removedAsset)
		}
    }
	
	// MARK: - DKGroupDataManagerObserver methods
	
	func groupDidUpdate(groupId: String) {
		if self.selectedGroupId == groupId {
			self.updateTitleView()
		}
	}
	
	func group(groupId: String, didRemoveAssets assets: [DKAsset]) {
		for (_, selectedAsset) in self.imagePickerController.selectedAssets.enumerate() {
			for removedAsset in assets {
				if selectedAsset.isEqual(removedAsset) {
					self.imagePickerController.deselectImage(selectedAsset)
				}
			}
		}
		if self.selectedGroupId == groupId {
			self.collectionView?.reloadData()
		}
	}
	
	func group(groupId: String, didInsertAssets assets: [DKAsset]) {
		self.collectionView?.reloadData()
	}

}
