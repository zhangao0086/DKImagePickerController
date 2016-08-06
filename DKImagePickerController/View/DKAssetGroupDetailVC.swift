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
			cameraButton.addTarget(self, action: #selector(DKImageCameraCell.cameraButtonClicked), for: .touchUpInside)
			cameraButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			self.contentView.addSubview(cameraButton)
			self.cameraButton = cameraButton
			
			self.contentView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		func setCameraImage(_ cameraImage: UIImage) {
			self.cameraButton.setImage(cameraImage, for: UIControlState())
		}
		
        func cameraButtonClicked() {
            if let didCameraButtonClicked = self.didCameraButtonClicked {
                didCameraButtonClicked()
            }
        }
        
    } /* DKImageCameraCell */

    
    class DKAssetCell: UICollectionViewCell {
        
        class DKImageCheckView: UIView {
            
            static var numberColor = UIColor.white
            static var numberFont = UIFont.boldSystemFont(ofSize: 14)
            static var checkedBackgroundColor = UIColor.blue

            internal lazy var checkImageView: UIImageView = {
                let imageView = UIImageView(image: DKImageResource.checkedImage().withRenderingMode(.alwaysTemplate))
                imageView.tintColor = checkedBackgroundColor
                return imageView
            }()
            
            internal lazy var checkLabel: UILabel = {
                let label = UILabel()
                label.font = numberFont
                label.textColor = numberColor
                label.textAlignment = .right
                
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
            thumbnailImageView.contentMode = .scaleAspectFill
            thumbnailImageView.clipsToBounds = true
            
            return thumbnailImageView
        }()
        
        private let checkView = DKImageCheckView()
        
        override var isSelected: Bool {
            didSet {
                checkView.isHidden = !super.isSelected
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
		
        override var isSelected: Bool {
            didSet {
                if super.isSelected {
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
            videoImageView.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin]
            
            let videoDurationLabel = UILabel()
            videoDurationLabel.tag = -1
            videoDurationLabel.textAlignment = .right
            videoDurationLabel.font = UIFont.systemFont(ofSize: 12)
            videoDurationLabel.textColor = UIColor.white
            videoInfoView.addSubview(videoDurationLabel)
            videoDurationLabel.frame = CGRect(x: 0, y: 0, width: videoInfoView.bounds.width - 7, height: videoInfoView.bounds.height)
            videoDurationLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
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
		button.setTitleColor(globalTitleColor ?? UIColor.black, for: UIControlState())
		
		let globalTitleFont = UINavigationBar.appearance().titleTextAttributes?[NSFontAttributeName] as? UIFont
		button.titleLabel!.font = globalTitleFont ?? UIFont.boldSystemFont(ofSize: 18.0)
		
		button.addTarget(self, action: #selector(DKAssetGroupDetailVC.showGroupSelector), for: .touchUpInside)
        return button
    }()
		
    internal var selectedGroupId: String?
	
	internal weak var imagePickerController: DKImagePickerController!
	
	private var groupListVC: DKAssetGroupListVC!
    
    private var hidesCamera: Bool = false
	
	internal var collectionView: UICollectionView!
    static var backgroundCollectionViewColor: UIColor! = UIColor.white
	private var footerView: UIView?
	
	private var currentViewSize: CGSize!
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		if let currentViewSize = self.currentViewSize , currentViewSize.equalTo(self.view.bounds.size) {
			return
		} else {
			currentViewSize = self.view.bounds.size
		}

		self.collectionView?.collectionViewLayout.invalidateLayout()
	}
	
	private lazy var groupImageRequestOptions: PHImageRequestOptions = {
		let options = PHImageRequestOptions()
		options.deliveryMode = .highQualityFormat
		options.resizeMode = .exact
		
		return options
	}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		let background = DKAssetGroupDetailVC.backgroundCollectionViewColor
		let layout = self.imagePickerController.UIDelegate.layoutForImagePickerController(self.imagePickerController).init()
		self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = background
        self.collectionView.allowsMultipleSelection = true
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
        self.collectionView.register(DKImageCameraCell.self, forCellWithReuseIdentifier: DKImageCameraIdentifier)
        self.collectionView.register(DKAssetCell.self, forCellWithReuseIdentifier: DKImageAssetIdentifier)
        self.collectionView.register(DKVideoAssetCell.self, forCellWithReuseIdentifier: DKVideoAssetIdentifier)
		self.view.addSubview(self.collectionView)
		
		self.footerView = self.imagePickerController.UIDelegate.imagePickerControllerFooterView(self.imagePickerController)
		if let footerView = self.footerView {
			self.view.addSubview(footerView)
		}
		
		self.hidesCamera = self.imagePickerController.sourceType == .photo
		self.checkPhotoPermission()
    }
	
	override func viewDidLayoutSubviews() {
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
	
    func selectAssetGroup(_ groupId: String?) {
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
		self.selectGroupButton.setTitle(group.groupName + (groupsCount > 1 ? "  \u{25be}" : "" ), for: UIControlState())
		self.selectGroupButton.sizeToFit()
		self.selectGroupButton.isEnabled = groupsCount > 1
		
		self.navigationItem.titleView = self.selectGroupButton
	}
    
    func showGroupSelector() {
        DKPopoverViewController.popoverViewController(self.groupListVC, fromView: self.selectGroupButton)
    }
	
    // MARK: - Cells

    func cameraCellForIndexPath(_ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: DKImageCameraIdentifier, for: indexPath) as! DKImageCameraCell
		cell.setCameraImage(self.imagePickerController.UIDelegate.imagePickerControllerCameraImage())
        
        cell.didCameraButtonClicked = { [unowned self] in
            if UIImagePickerController.isSourceTypeAvailable(.camera) && self.imagePickerController.selectedAssets.count < self.imagePickerController.maxSelectableCount  {
                self.imagePickerController.presentCamera()
			} else {
				self.imagePickerController.UIDelegate.imagePickerControllerDidReachMaxLimit(self.imagePickerController)
			}
        }

        return cell
	}
	
	func assetCellForIndexPath(_ indexPath: IndexPath) -> UICollectionViewCell {
		let assetIndex = ((indexPath as NSIndexPath).row - (self.hidesCamera ? 0 : 1))
		let group = getImageManager().groupDataManager.fetchGroupWithGroupId(self.selectedGroupId!)
		
		let asset = getImageManager().groupDataManager.fetchAssetWithGroup(group, index: assetIndex)
		
		var cell: DKAssetCell!
		var identifier: String!
		if asset.isVideo {
			identifier = DKVideoAssetIdentifier
		} else {
			identifier = DKImageAssetIdentifier
		}
		
		cell = self.collectionView!.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! DKAssetCell
		cell.asset = asset
		let tag = (indexPath as NSIndexPath).row + 1
		cell.tag = tag
		
		let itemSize = self.collectionView!.collectionViewLayout.layoutAttributesForItem(at: indexPath)!.size
		asset.fetchImageWithSize(itemSize.toPixel(), options: self.groupImageRequestOptions, contentMode: .aspectFill) { (image, info) in
			if cell.tag == tag {
				cell.thumbnailImageView.image = image
			}
		}
		
		if let index = self.imagePickerController.selectedAssets.index(of: asset) {
			cell.isSelected = true
			cell.checkView.checkLabel.text = "\(index + 1)"
			self.collectionView!.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
		} else {
			cell.isSelected = false
			self.collectionView!.deselectItem(at: indexPath, animated: false)
		}
		
		return cell
	}

    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let selectedGroup = self.selectedGroupId else { return 0 }
		
		let group = getImageManager().groupDataManager.fetchGroupWithGroupId(selectedGroup)
        return (group.totalCount ?? 0) + (self.hidesCamera ? 0 : 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath as NSIndexPath).row == 0 && !self.hidesCamera {
            return self.cameraCellForIndexPath(indexPath)
        } else {
            return self.assetCellForIndexPath(indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let firstSelectedAsset = self.imagePickerController.selectedAssets.first,
            let selectedAsset = (collectionView.cellForItem(at: indexPath) as? DKAssetCell)?.asset
            , self.imagePickerController.allowMultipleTypes == false && firstSelectedAsset.isVideo != selectedAsset.isVideo {
                
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let selectedAsset = (collectionView.cellForItem(at: indexPath) as? DKAssetCell)?.asset
		self.imagePickerController.selectedImage(selectedAsset!)
        
		let cell = collectionView.cellForItem(at: indexPath) as! DKAssetCell
		cell.checkView.checkLabel.text = "\(self.imagePickerController.selectedAssets.count)"
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		if let removedAsset = (collectionView.cellForItem(at: indexPath) as? DKAssetCell)?.asset {
			let removedIndex = self.imagePickerController.selectedAssets.index(of: removedAsset)!
			
			/// Minimize the number of cycles.
			let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems as [IndexPath]!
			let indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems
			
			let intersect = Set(indexPathsForVisibleItems).intersection(Set(indexPathsForSelectedItems!))
			
			for selectedIndexPath in intersect {
				if let selectedCell = (collectionView.cellForItem(at: selectedIndexPath) as? DKAssetCell) {
					let selectedIndex = self.imagePickerController.selectedAssets.index(of: selectedCell.asset)!
					
					if selectedIndex > removedIndex {
						selectedCell.checkView.checkLabel.text = "\(Int(selectedCell.checkView.checkLabel.text!)! - 1)"
					}
				}
			}
			
			self.imagePickerController.unselectedImage(removedAsset)
		}
    }
	
	// MARK: - DKGroupDataManagerObserver methods
	
	func groupDidUpdate(_ groupId: String) {
		if self.selectedGroupId == groupId {
			self.updateTitleView()
		}
	}
	
	func group(_ groupId: String, didRemoveAssets assets: [DKAsset]) {
		for (_, selectedAsset) in self.imagePickerController.selectedAssets.enumerated() {
			for removedAsset in assets {
				if selectedAsset.isEqual(removedAsset) {
					self.imagePickerController.unselectedImage(selectedAsset)
				}
			}
		}
		if self.selectedGroupId == groupId {
			self.collectionView?.reloadData()
		}
	}
	
	func group(_ groupId: String, didInsertAssets assets: [DKAsset]) {
		self.collectionView?.reloadData()
	}

}
