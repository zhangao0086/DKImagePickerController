//
//  DKImagePickerController.swift
//  CustomImagePicker
//
//  Created by ZhangAo on 14-10-2.
//  Copyright (c) 2014年 ZhangAo. All rights reserved.
//

import UIKit
import AssetsLibrary


// Delegate
@objc public protocol DKImagePickerControllerDelegate : NSObjectProtocol {
    /// Called when right button is clicked.
    ///
    /// :param: images Images of selected
    func imagePickerControllerDidSelectedAssets(images: [DKAsset]!)
    
    /// Called when cancel button is clicked.
    func imagePickerControllerCancelled()
}

//////////////////////////////////////////////////////////////////////////////////////////

// Cell Identifier
let GroupCellIdentifier = "GroupCellIdentifier"
let ImageCellIdentifier = "ImageCellIdentifier"

// Nofifications
let DKImageSelectedNotification = "DKImageSelectedNotification"
let DKImageUnselectedNotification = "DKImageUnselectedNotification"

// Group Model
class DKAssetGroup : NSObject {
    var groupName: String!
    var thumbnail: UIImage!
    var group: ALAssetsGroup!
}

// Asset Model
public class DKAsset: NSObject {
    public var thumbnailImage: UIImage?
    public lazy var fullScreenImage: UIImage? = {
        return UIImage(CGImage: self.originalAsset.defaultRepresentation().fullScreenImage().takeUnretainedValue())
    }()
    public lazy var fullResolutionImage: UIImage? = {
        return UIImage(CGImage: self.originalAsset.defaultRepresentation().fullResolutionImage().takeUnretainedValue())
    }()
    public var url: NSURL?
    
    private var originalAsset: ALAsset!
    
    // Compare two assets
    override public func isEqual(object: AnyObject?) -> Bool {
        let other = object as! DKAsset!
        return self.url!.isEqual(other.url!)
    }
}

// Internal
extension UIViewController {
    var imagePickerController: DKImagePickerController? {
        get {
            let nav = self.navigationController
            if nav is DKImagePickerController {
                return nav as? DKImagePickerController
            } else {
                return nil
            }
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Show All Iamges In Group
//////////////////////////////////////////////////////////////////////////////////////////

class DKImageGroupViewController: UICollectionViewController {
    
    class DKImageCollectionCell: UICollectionViewCell {
        var thumbnail: UIImage! {
            didSet {
                self.imageView.image = thumbnail
            }
        }
        
        override var selected: Bool {
            didSet {
                checkView.hidden = !super.selected
            }
        }
        
        private var imageView = UIImageView()
        private var checkView = UIImageView(image: UIImage(named: "DKImagePickerController_PhotoChecked",
            inBundle: NSBundle(forClass: DKImagePickerController.self),
            compatibleWithTraitCollection: nil))
        
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
            checkView.frame.origin = CGPoint(x: self.contentView.bounds.width - checkView.bounds.width, y: 0)
        }
    }
    
    lazy private var groups = [DKAssetGroup]()
    
    lazy var selectGroupButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: "selectGroup", forControlEvents: .TouchUpInside)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.titleLabel!.font = UIFont.boldSystemFontOfSize(16.0)
        return button
    }()
    
    lazy private var library: ALAssetsLibrary = {
        return ALAssetsLibrary()
    }()
    
    var selectedAssetGroup: DKAssetGroup!
    private lazy var imageAssets: NSMutableArray = {
        return NSMutableArray()
    }()
    
    lazy var selectGroupVC: DKAssetGroupVC = {
        var groupVC = DKAssetGroupVC()
        groupVC.selectedGroupBlock = {(assetGroup: DKAssetGroup) in
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
        let itemWidth = (screenWidth - interval * 3) / 4
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)

        self.init(collectionViewLayout: layout)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.backgroundColor = UIColor.whiteColor()
        self.collectionView!.allowsMultipleSelection = true
        self.collectionView!.registerClass(DKImageCollectionCell.self, forCellWithReuseIdentifier: ImageCellIdentifier)
        
        self.library.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: {(group: ALAssetsGroup! , stop: UnsafeMutablePointer<ObjCBool>) in
            if group != nil {
                if group.numberOfAssets() != 0 {
                    let groupName = group.valueForProperty(ALAssetsGroupPropertyName) as! String

                    let assetGroup = DKAssetGroup()
                    assetGroup.groupName = groupName
                    assetGroup.thumbnail = UIImage(CGImage: group.posterImage().takeUnretainedValue())
                    assetGroup.group = group
                    self.groups.insert(assetGroup, atIndex: 0)
                }
            } else {
                if let assetGroup = self.groups.first {
                    self.selectAssetGroup(assetGroup)
                }
                
                self.selectGroupButton.enabled = self.groups.count > 1
            }
        }, failureBlock: {(error: NSError!) in
                //                self.noAccessView.frame = self.view.bounds
                //                self.tableView.scrollEnabled = false
                //                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
                //                self.view.addSubview(self.noAccessView)
        })
    }
    
    func selectAssetGroup(assetGroup: DKAssetGroup) {
        self.selectedAssetGroup = assetGroup
        self.title = selectedAssetGroup.groupName
        
        self.imageAssets.removeAllObjects()
        
        assetGroup.group.enumerateAssetsUsingBlock {[unowned self](result: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if result != nil {
                let asset = DKAsset()
                asset.thumbnailImage = UIImage(CGImage:result.thumbnail().takeUnretainedValue())
                asset.url = result.valueForProperty(ALAssetPropertyAssetURL) as? NSURL
                asset.originalAsset = result
                self.imageAssets.addObject(asset)
            } else {
                self.collectionView!.reloadData()
                self.collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
            }
        }
        
        self.selectGroupButton.setTitle(self.selectedAssetGroup.groupName + (self.groups.count > 1 ? "  \u{25be}" : "" ), forState: .Normal)
        self.selectGroupButton.sizeToFit()
        self.navigationItem.titleView = self.selectGroupButton
    }
    
    func selectGroup() {
        self.selectGroupVC.groups = groups
        
        FBPopoverViewController.popoverViewController(self.selectGroupVC, fromView: self.selectGroupButton)
    }
    
    //Mark: - UICollectionViewDelegate, UICollectionViewDataSource methods
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageAssets.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ImageCellIdentifier, forIndexPath: indexPath) as! DKImageCollectionCell
        
        let asset = imageAssets[indexPath.row] as! DKAsset
        cell.thumbnail = asset.thumbnailImage
        
        if find(self.imagePickerController!.selectedAssets, asset) != nil {
            cell.selected = true
            collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
        } else {
            cell.selected = false
            collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.imagePickerController!.selectedAssets.count < self.imagePickerController!.maxSelectableCount
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().postNotificationName(DKImageSelectedNotification, object: imageAssets[indexPath.row])
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().postNotificationName(DKImageUnselectedNotification, object: imageAssets[indexPath.row])
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Main Controller
//////////////////////////////////////////////////////////////////////////////////////////

public class DKImagePickerController: UINavigationController {
    
    public var rightButtonTitle: String = "Select"
    public var maxSelectableCount = 999
    /// Displayed when denied access
    public lazy var noAccessView: UIView = {
        let label = UILabel()
        label.text = "User has denied access"
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.lightGrayColor()
        return label
    }()
    
    public weak var pickerDelegate: DKImagePickerControllerDelegate?
    public var defaultSelectedAssets: [DKAsset]? {
        didSet {
            if let defaultSelectedAssets = self.defaultSelectedAssets {
                self.selectedAssets = defaultSelectedAssets
//                self.imagesPreviewView.replaceAssets(defaultSelectedAssets)
                self.updateSelectionStatus()
            }
        }
    }
    
    var selectedAssets = [DKAsset]()
    
    lazy internal var doneButton: UIButton = {
        let button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        button.setTitle("", forState: UIControlState.Normal)
        button.setTitleColor(self.navigationBar.tintColor, forState: UIControlState.Normal)
        button.reversesTitleShadowWhenHighlighted = true
        button.addTarget(self, action: "onDoneClicked", forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }()
    
    public convenience init() {
        self.init(rootViewController: DKImageGroupViewController())
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectedImage:",
                                                                   name: DKImageSelectedNotification,
                                                                 object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unselectedImage:",
                                                                   name: DKImageUnselectedNotification,
                                                                 object: nil)
    }

    override public func pushViewController(viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)

        self.topViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.doneButton)
        self.updateSelectionStatus()
        
        if self.viewControllers.count == 1 && self.topViewController?.navigationItem.leftBarButtonItem == nil {
            self.topViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel,
                target: self,
                action: "onCancelClicked")
        }
    }
    
    private func updateSelectionStatus() {
        if self.selectedAssets.count > 0 {
            self.doneButton.setTitle(rightButtonTitle + "(\(selectedAssets.count))", forState: UIControlState.Normal)
        } else {
            self.doneButton.setTitle("", forState: UIControlState.Normal)
        }
        self.doneButton.sizeToFit()
    }
    
    // MARK: - Delegate methods
    func onCancelClicked() {
        if let delegate = self.pickerDelegate {
            delegate.imagePickerControllerCancelled()
        }
    }
    
    func onDoneClicked() {
        if let delegate = self.pickerDelegate {
            delegate.imagePickerControllerDidSelectedAssets(self.selectedAssets)
        }
    }
    
    // MARK: - Notifications
    func selectedImage(noti: NSNotification) {
        if let asset = noti.object as? DKAsset {
            selectedAssets.append(asset)
//            imagesPreviewView.insertAsset(asset)
            updateSelectionStatus()
        }
    }
    
    func unselectedImage(noti: NSNotification) {
        if let asset = noti.object as? DKAsset {
            selectedAssets.removeAtIndex(find(selectedAssets, asset)!)
//            imagesPreviewView.removeAsset(asset)
            updateSelectionStatus()
        }
    }
}
