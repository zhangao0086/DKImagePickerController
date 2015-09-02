//
//  DKAssetGroupDetailVC.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/8/10.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit
import AssetsLibrary
import AVFoundation

private let DKImageCameraIdentifier = "DKImageCameraIdentifier"
private let DKImageAssetIdentifier = "DKImageAssetIdentifier"
private let DKVideoAssetIdentifier = "DKVideoAssetIdentifier"

// Nofifications
internal let DKImageSelectedNotification = "DKImageSelectedNotification"
internal let DKImageUnselectedNotification = "DKImageUnselectedNotification"

// Group Model
internal class DKAssetGroup : NSObject {
    var groupName: String!
    var thumbnail: UIImage!
    var totalCount: Int!
    var group: ALAssetsGroup!
}

private extension DKImagePickerControllerAssetType {

    func toALAssetsFilter() -> ALAssetsFilter {
        switch self {
        case .allPhotos:
            return ALAssetsFilter.allPhotos()
        case .allVideos:
            return ALAssetsFilter.allVideos()
        case .allAssets:
            return ALAssetsFilter.allAssets()
        }
    }
}

private let DKImageSystemVersionLessThan8 = UIDevice.currentDevice().systemVersion.compare("8.0.0", options: .NumericSearch) == .OrderedAscending

// Show all images in the asset group
internal class DKAssetGroupDetailVC: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    class DKImageCameraCell: UICollectionViewCell {
        
        var cameraButtonClicked: (() -> Void)?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let cameraButton = UIButton(frame: frame)
            cameraButton.addTarget(self, action: "takePicture", forControlEvents: .TouchUpInside)
            cameraButton.setImage(DKImageResource.cameraImage(), forState: .Normal)
            cameraButton.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            self.contentView.addSubview(cameraButton)
            
            self.contentView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        }

        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func takePicture() {
            if let cameraButtonClicked = self.cameraButtonClicked {
                cameraButtonClicked()
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

            required init(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func layoutSubviews() {
                super.layoutSubviews()
                
                self.checkImageView.frame = self.bounds
                self.checkLabel.frame = CGRect(x: 0, y: 5, width: self.bounds.width - 5, height: 20)
            }
            
        } /* DKImageCheckView */
        
        private var imageView = UIImageView()
        
        var thumbnail: UIImage! {
            didSet {
                self.imageView.image = thumbnail
            }
        }
        
        private lazy var checkView = DKImageCheckView()
        
        override var selected: Bool {
            didSet {
                checkView.hidden = !super.selected
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            imageView.frame = self.bounds
            self.contentView.addSubview(imageView)
            self.contentView.addSubview(checkView)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            imageView.frame = self.bounds
            checkView.frame = imageView.frame
        }
        
    } /* DKAssetCell */
    
    class DKVideoAssetCell: DKAssetCell {
        
        var duration: Double = 0 {
            didSet {
                let videoDurationLabel = self.videoInfoView.viewWithTag(-1) as! UILabel
                let minutes: Int = Int(duration) / 60
                let seconds: Int = Int(duration) % 60
                videoDurationLabel.text = "\(minutes):\(seconds)"
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
            videoImageView.autoresizingMask = .FlexibleBottomMargin | .FlexibleTopMargin
            
            let videoDurationLabel = UILabel()
            videoDurationLabel.tag = -1
            videoDurationLabel.textAlignment = .Right
            videoDurationLabel.font = UIFont.systemFontOfSize(12)
            videoDurationLabel.textColor = UIColor.whiteColor()
            videoInfoView.addSubview(videoDurationLabel)
            videoDurationLabel.frame = CGRect(x: 0, y: 0, width: videoInfoView.bounds.width - 7, height: videoInfoView.bounds.height)
            videoDurationLabel.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            
            return videoInfoView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.contentView.addSubview(videoInfoView)
        }

        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let height: CGFloat = 30
            self.videoInfoView.frame = CGRect(x: 0, y: self.contentView.bounds.height - height,
                width: self.contentView.bounds.width, height: height)
        }
        
    } /* DKVideoAssetCell */
    
    class DKPermissionView: UIView {
        
        enum DKPermissionViewStyle : Int {
            
            case Photo, Camera
        }
        
        let titleLabel = UILabel()
        let permitButton = UIButton()
        
        class func permissionView(style: DKPermissionViewStyle) -> DKPermissionView {
            
            let permissionView = DKPermissionView()
            permissionView.addSubview(permissionView.titleLabel)
            permissionView.addSubview(permissionView.permitButton)
            
            if style == .Photo {
                permissionView.titleLabel.text = DKImageLocalizedString.localizedStringForKey("permissionPhoto")
                permissionView.titleLabel.textColor = UIColor.grayColor()
            } else {
                permissionView.titleLabel.textColor = UIColor.whiteColor()
                permissionView.titleLabel.text = DKImageLocalizedString.localizedStringForKey("permissionCamera")
            }
            permissionView.titleLabel.sizeToFit()
            
            if DKImageSystemVersionLessThan8 {
                permissionView.permitButton.setTitle(DKImageLocalizedString.localizedStringForKey("gotoSettings"), forState: .Normal)
            } else {
                permissionView.permitButton.setTitle(DKImageLocalizedString.localizedStringForKey("permit"), forState: .Normal)
                permissionView.permitButton.setTitleColor(UIColor(red: 0, green: 122.0 / 255, blue: 1, alpha: 1), forState: .Normal)
                permissionView.permitButton.addTarget(permissionView, action: "gotoSettings", forControlEvents: .TouchUpInside)
            }
            permissionView.permitButton.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
            permissionView.permitButton.sizeToFit()
            permissionView.permitButton.center = CGPoint(x: permissionView.titleLabel.center.x,
                y: permissionView.titleLabel.bounds.height + 40)
            
            permissionView.frame.size = CGSize(width: max(permissionView.titleLabel.bounds.width, permissionView.permitButton.bounds.width),
                height: permissionView.permitButton.frame.maxY)
            
            return permissionView
        }
        
        override func didMoveToWindow() {
            super.didMoveToWindow()
            
            self.center = self.superview!.center
        }
        
        func gotoSettings() {
            if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(appSettings)
            }
        }
        
    } /* DKNoPermissionView */
    
    private lazy var groups = [DKAssetGroup]()
    
    private lazy var selectGroupButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: "showGroupSelector", forControlEvents: .TouchUpInside)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.titleLabel!.font = UIFont.boldSystemFontOfSize(18.0)
        return button
    }()
    
    private lazy var library: ALAssetsLibrary = {
        return ALAssetsLibrary()
    }()
    
    internal var selectedAssetGroup: DKAssetGroup?
    private lazy var imageAssets: NSMutableArray = {
        return NSMutableArray()
    }()
    
    private lazy var selectGroupVC: DKAssetGroupVC = {
        var groupVC = DKAssetGroupVC()
        groupVC.selectedGroupBlock = {[unowned self] (assetGroup: DKAssetGroup) in
            self.selectAssetGroup(assetGroup)
        }
        return groupVC
    }()
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        
        let interval: CGFloat = 3
        layout.minimumInteritemSpacing = interval
        layout.minimumLineSpacing = interval
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        let itemWidth = (screenWidth - interval * 3) / 3
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        self.init(collectionViewLayout: layout)
    }
    
    required init(coder aDecoder: NSCoder) {
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
        
        self.library.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: {(group: ALAssetsGroup! , stop: UnsafeMutablePointer<ObjCBool>) in
            if group != nil {
                group.setAssetsFilter(self.imagePickerController!.assetType.toALAssetsFilter())
                
                if group.numberOfAssets() != 0 {
                    let groupName = group.valueForProperty(ALAssetsGroupPropertyName) as! String
                    
                    let assetGroup = DKAssetGroup()
                    assetGroup.groupName = groupName
                    
                    group.enumerateAssetsAtIndexes(NSIndexSet(index: group.numberOfAssets() - 1),
                                                options: .Reverse,
                                                usingBlock: { (asset: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                        if asset != nil {
                            assetGroup.thumbnail = UIImage(CGImage:asset.thumbnail().takeUnretainedValue())
                        }
                    })
                    
                    assetGroup.group = group
                    assetGroup.totalCount = group.numberOfAssets()
                    self.groups.insert(assetGroup, atIndex: 0)
                }
            } else {
                if let assetGroup = self.groups.first {
                    self.selectAssetGroup(assetGroup)
                }
                
                self.selectGroupButton.enabled = self.groups.count > 1
            }
        }, failureBlock: {(error: NSError!) in
            self.collectionView?.hidden = true
            self.view.addSubview(DKPermissionView.permissionView(.Photo))
        })
    }
    
    func selectAssetGroup(assetGroup: DKAssetGroup) {
        if self.selectedAssetGroup == assetGroup {
            return
        }
        
        self.selectedAssetGroup = assetGroup
        self.title = assetGroup.groupName
        
        self.imageAssets.removeAllObjects()
        
        assetGroup.group.enumerateAssetsWithOptions(.Reverse) {[unowned self](result: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if result != nil {
                let asset = DKAsset(originalAsset: result)
                self.imageAssets.addObject(asset)
            } else {
                self.collectionView!.reloadData()
                self.collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
            }
        }
        
        self.selectGroupButton.setTitle(assetGroup.groupName + (self.groups.count > 1 ? "  \u{25be}" : "" ), forState: .Normal)
        self.selectGroupButton.sizeToFit()
        self.navigationItem.titleView = self.selectGroupButton
    }
    
    func showGroupSelector() {
        self.selectGroupVC.groups = groups
        
        DKPopoverViewController.popoverViewController(self.selectGroupVC, fromView: self.selectGroupButton)
    }

    func cameraCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(DKImageCameraIdentifier, forIndexPath: indexPath) as! DKImageCameraCell
        
        cell.cameraButtonClicked = { [unowned self] () in
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                
                /* 
                    There is a bug in iOS 8 about:
                        "Snapshotting a view that has not been rendered results in an empty snapshot.
                        Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates."
                    I've tried all solutions suggested by this thread:
                    http://stackoverflow.com/questions/25884801/ios-8-snapshotting-a-view-that-has-not-been-rendered-results-in-an-empty-snapsho
                    But no luck.
                */
                let pickerController = UIImagePickerController()
                pickerController.sourceType = .Camera
                pickerController.allowsEditing = false
                pickerController.delegate = self
                
                if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) != .Authorized {
                    let permissionView = DKPermissionView.permissionView(.Camera)
                    pickerController.cameraOverlayView = permissionView
                }
                
                self.presentViewController(pickerController, animated: true, completion: nil)
            }
        }

        return cell
    }

    func assetCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let asset = imageAssets[indexPath.row - 1] as! DKAsset
        
        var identifier: String!
        if asset.isVideo {
            identifier = DKVideoAssetIdentifier
        } else {
            identifier = DKImageAssetIdentifier
        }
        
        let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! DKAssetCell
        if let videoAssetCell = cell as? DKVideoAssetCell {
            videoAssetCell.duration = asset.duration!
        }
        
        cell.thumbnail = asset.thumbnailImage
        
        if let index = find(self.imagePickerController!.selectedAssets, asset) {
            cell.selected = true
            cell.checkView.checkLabel.text = "\(index + 1)"
            collectionView!.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
        } else {
            cell.selected = false
            collectionView!.deselectItemAtIndexPath(indexPath, animated: false)
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource methods

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageAssets.count + 1
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            return self.cameraCellForIndexPath(indexPath)
        } else {
            return self.assetCellForIndexPath(indexPath)
        }
    }
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let firstSelectedAsset = self.imagePickerController?.selectedAssets.first,
            selectedAsset = imageAssets[indexPath.row - 1] as? DKAsset
            where self.imagePickerController?.allowMultipleTypes == false && firstSelectedAsset.isVideo != selectedAsset.isVideo {
                
                UIAlertView(title: DKImageLocalizedString.localizedStringForKey("selectPhotosOrVideos"),
                    message: DKImageLocalizedString.localizedStringForKey("selectPhotosOrVideosError"),
                    delegate: nil,
                    cancelButtonTitle: DKImageLocalizedString.localizedStringForKey("ok")).show()
                
                return false
        }
        
        return self.imagePickerController!.selectedAssets.count < self.imagePickerController!.maxSelectableCount
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().postNotificationName(DKImageSelectedNotification, object: imageAssets[indexPath.row - 1])
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! DKAssetCell
        cell.checkView.checkLabel.text = "\(self.imagePickerController!.selectedAssets.count)"
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let removedAsset = imageAssets[indexPath.row - 1] as! DKAsset
        let removedIndex = find(self.imagePickerController!.selectedAssets, removedAsset)!
    
        /// Minimize the number of cycles.
        let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems() as! [NSIndexPath]
        let indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems() as! [NSIndexPath]
        
        let intersect = Set(indexPathsForVisibleItems).intersect(Set(indexPathsForSelectedItems))

        for selectedIndexPath in intersect {
            let selectedAsset = imageAssets[selectedIndexPath.row - 1] as! DKAsset
            let selectedIndex = find(self.imagePickerController!.selectedAssets, selectedAsset)!
            
            if selectedIndex > removedIndex {
                let cell = collectionView.cellForItemAtIndexPath(selectedIndexPath) as! DKAssetCell
                cell.checkView.checkLabel.text = "\(cell.checkView.checkLabel.text!.toInt()! - 1)"
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(DKImageUnselectedNotification, object: imageAssets[indexPath.row - 1])
    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        NSNotificationCenter.defaultCenter().postNotificationName(DKImageSelectedNotification, object: DKAsset(image: pickedImage))
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
