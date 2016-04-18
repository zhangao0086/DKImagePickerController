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
internal class DKAssetGroupDetailVC: UICollectionViewController, DKGroupDataManagerObserver {
    
    class DKImageCameraCell: UICollectionViewCell {
        
        var didCameraButtonClicked: (() -> Void)?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let cameraButton = UIButton(frame: frame)
            cameraButton.addTarget(self, action: #selector(DKImageCameraCell.cameraButtonClicked), forControlEvents: .TouchUpInside)
            cameraButton.setImage(DKImagePickerController.sharedInstance().UIDelegate.imagePickerControllerCameraImage(), forState: .Normal)
            cameraButton.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            self.contentView.addSubview(cameraButton)
            
            self.contentView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func cameraButtonClicked() {
            if let didCameraButtonClicked = self.didCameraButtonClicked {
                didCameraButtonClicked()
            }
        }
        
    } /* DKImageCameraCell */

    class DKAssetCell: UICollectionViewCell {
        
        class DKImageCheckView: UIView {
            
            private lazy var checkImageView: UIImageView = {
                let imageView = UIImageView(image: DKImageResource.checkedImage())
                
                return imageView
            }()
            
            private lazy var checkLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.boldSystemFontOfSize(14)
                label.textColor = UIColor.whiteColor()
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
				let seconds: Int = Int(asset.duration!) % 60
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
    
	private var groupListVC: DKAssetGroupListVC!
    
    private var hidesCamera :Bool = false
	
    convenience init() {
        let layout = DKAssetGroupGridLayout()
        self.init(collectionViewLayout: layout)
    }
	
	override init(collectionViewLayout layout: UICollectionViewLayout) {
		super.init(collectionViewLayout: layout)
	}
	
	private var currentViewSize: CGSize!
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		if let currentViewSize = self.currentViewSize where CGSizeEqualToSize(currentViewSize, self.view.bounds.size) {
			return
		} else {
			currentViewSize = self.view.bounds.size
		}
		
		let layout = DKAssetGroupGridLayout(contentSize: self.view.bounds.size)
		self.collectionView!.setCollectionViewLayout(layout, animated: true) { completed in
			self.collectionView!.reloadItemsAtIndexPaths(self.collectionView!.indexPathsForVisibleItems())
		}
	}
	
	private lazy var groupImageRequestOptions: PHImageRequestOptions = {
		let options = PHImageRequestOptions()
		options.deliveryMode = .Opportunistic
		options.resizeMode = .Exact;
		
		return options
	}()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.collectionView!.backgroundColor = UIColor.whiteColor()
        self.collectionView!.allowsMultipleSelection = true
        self.collectionView!.registerClass(DKImageCameraCell.self, forCellWithReuseIdentifier: DKImageCameraIdentifier)
        self.collectionView!.registerClass(DKAssetCell.self, forCellWithReuseIdentifier: DKImageAssetIdentifier)
        self.collectionView!.registerClass(DKVideoAssetCell.self, forCellWithReuseIdentifier: DKVideoAssetIdentifier)
		
		self.hidesCamera = !DKImagePickerController.sharedInstance().sourceType.contains(.Camera)
		self.checkPhotoPermission()
    }
	
	internal func checkPhotoPermission() {
		func photoDenied() {
			self.view.addSubview(DKPermissionView.permissionView(.Photo))
			self.collectionView?.hidden = true
		}
		
		func setup() {
			getImageManager().groupDataManager.addObserver(self)
			self.groupListVC = DKAssetGroupListVC(selectedGroupDidChangeBlock: { [unowned self] groupId in
				self.selectAssetGroup(groupId)
			}, defaultAssetGroup: DKImagePickerController.sharedInstance().defaultAssetGroup)
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
        
        cell.didCameraButtonClicked = { [unowned self] in 
            if UIImagePickerController.isSourceTypeAvailable(.Camera) &&
            DKImagePickerController.sharedInstance().selectedAssets.count < DKImagePickerController.sharedInstance().maxSelectableCount {
                DKImagePickerController.sharedInstance().presentCamera()
            }else {
                self.showMaxPhotosSelectedAlertView()
            }
        }

        return cell
	}
    
    private func showMaxPhotosSelectedAlertView() {
        UIAlertView(title: "Max photos limit reached", message: "You can select \(DKImagePickerController.sharedInstance().maxSelectableCount) photos", delegate: nil, cancelButtonTitle: "OK").show()
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
		cell.asset = asset
		let tag = indexPath.row + 1
		cell.tag = tag
		
		let itemSize = self.collectionView!.collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath)!.size
		asset.fetchImageWithSize(itemSize.toPixel(), options: self.groupImageRequestOptions) { image, info in
			if cell.tag == tag {
				cell.thumbnailImageView.image = image
			}
		}
		
		if let index = DKImagePickerController.sharedInstance().selectedAssets.indexOf(asset) {
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

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let selectedGroup = self.selectedGroupId else { return 0 }
		
		let group = getImageManager().groupDataManager.fetchGroupWithGroupId(selectedGroup)
        return (group.totalCount ?? 0) + (self.hidesCamera ? 0 : 1)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 && !self.hidesCamera {
            return self.cameraCellForIndexPath(indexPath)
        } else {
            return self.assetCellForIndexPath(indexPath)
        }
    }
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let firstSelectedAsset = DKImagePickerController.sharedInstance().selectedAssets.first,
            selectedAsset = (collectionView.cellForItemAtIndexPath(indexPath) as? DKAssetCell)?.asset
            where DKImagePickerController.sharedInstance().allowMultipleTypes == false && firstSelectedAsset.isVideo != selectedAsset.isVideo {
                
                UIAlertView(title: DKImageLocalizedStringWithKey("selectPhotosOrVideos"),
                    message: DKImageLocalizedStringWithKey("selectPhotosOrVideosError"),
                    delegate: nil,
                    cancelButtonTitle: DKImageLocalizedStringWithKey("ok")).show()
                
                return false
        }
        
        let shouldSelect = DKImagePickerController.sharedInstance().selectedAssets.count < DKImagePickerController.sharedInstance().maxSelectableCount
        if !shouldSelect {
            showMaxPhotosSelectedAlertView()
        }
        return shouldSelect
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let selectedAsset = (collectionView.cellForItemAtIndexPath(indexPath) as? DKAssetCell)?.asset
		DKImagePickerController.sharedInstance().selectedImage(selectedAsset!)
        
		let cell = collectionView.cellForItemAtIndexPath(indexPath) as! DKAssetCell
		cell.checkView.checkLabel.text = "\(DKImagePickerController.sharedInstance().selectedAssets.count)"
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
		if let removedAsset = (collectionView.cellForItemAtIndexPath(indexPath) as? DKAssetCell)?.asset {
			let removedIndex = DKImagePickerController.sharedInstance().selectedAssets.indexOf(removedAsset)!
			
			/// Minimize the number of cycles.
			let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems() as [NSIndexPath]!
			let indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems()
			
			let intersect = Set(indexPathsForVisibleItems).intersect(Set(indexPathsForSelectedItems))
			
			for selectedIndexPath in intersect {
				if let selectedCell = (collectionView.cellForItemAtIndexPath(selectedIndexPath) as? DKAssetCell) {
					let selectedIndex = DKImagePickerController.sharedInstance().selectedAssets.indexOf(selectedCell.asset)!
					
					if selectedIndex > removedIndex {
						selectedCell.checkView.checkLabel.text = "\(Int(selectedCell.checkView.checkLabel.text!)! - 1)"
					}
				}
			}
			
			DKImagePickerController.sharedInstance().unselectedImage(removedAsset)
		}
    }
	
	// MARK: - DKGroupDataManagerObserver methods
	
	func groupDidUpdate(groupId: String) {
		if self.selectedGroupId == groupId {
			self.updateTitleView()
		}
	}
	
	func group(groupId: String, didRemoveAssets assets: [DKAsset]) {
		for (_, selectedAsset) in DKImagePickerController.sharedInstance().selectedAssets.enumerate() {
			for removedAsset in assets {
				if selectedAsset.isEqual(removedAsset) {
					DKImagePickerController.sharedInstance().unselectedImage(selectedAsset)
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
