//
//  DKImagePickerController.swift
//  CustomImagePicker
//
//  Created by ZhangAo on 14-10-2.
//  Copyright (c) 2014年 ZhangAo. All rights reserved.
//

import UIKit
import AssetsLibrary

// Cell Identifier
let GroupCellIdentifier = "GroupCellIdentifier"
let ImageCellIdentifier = "ImageCellIdentifier"

// Nofifications
let DKImageSelectedNotification = "DKImageSelectedNotification"
let DKImageUnselectedNotification = "DKImageUnselectedNotification"

// Group Model
class DKAssetGroup : NSObject {
    var groupName: NSString!
    var thumbnail: UIImage!
    var group: ALAssetsGroup!
}

protocol DKImagePickerControllerDelegate : NSObjectProtocol {
    func imagePickerControllerCancelled()
}

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

class DKImageGroupViewController: UICollectionViewController {
    
    class DKImageCollectionCell: UICollectionViewCell {
        var thumbnail: UIImage! {
            didSet {
                self.imageView.image = thumbnail
            }
        }
        
        override var selected: Bool {
            get {
                return super.selected
            }
            set {
                super.selected = newValue
                checkView.hidden = !super.selected
            }
        }
        
        private var imageView = UIImageView()
        private var checkView = UIView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            imageView.frame = self.bounds
            self.contentView.addSubview(imageView)
            
            checkView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            checkView.backgroundColor = UIColor.redColor()
            self.contentView.addSubview(checkView)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            imageView.frame = self.bounds
        }
    }
    
    var assetGroup: DKAssetGroup!
    private lazy var images: NSMutableArray = {
        return NSMutableArray()
    }()
    
    override init() {
        let layout = UICollectionViewFlowLayout()
        
        let interval: CGFloat = 3
        layout.minimumInteritemSpacing = interval
        layout.minimumLineSpacing = interval
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        let itemWidth = (screenWidth - interval * 3) / 4
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        super.init(collectionViewLayout: layout)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(assetGroup != nil, "assetGroup is nil")
        
        self.title = assetGroup.groupName
        
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.collectionView?.allowsMultipleSelection = true
        self.collectionView?.registerClass(DKImageCollectionCell.self, forCellWithReuseIdentifier: ImageCellIdentifier)
        
        assetGroup.group.enumerateAssetsUsingBlock {[unowned self](result: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if result != nil {
                self.images.addObject(UIImage(CGImage:result.thumbnail().takeUnretainedValue()))
            } else {
                self.collectionView!.reloadData()
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView!.scrollToItemAtIndexPath(NSIndexPath(forRow: self.images.count-1, inSection: 0),
                        atScrollPosition: UICollectionViewScrollPosition.Bottom,
                        animated: false)
                }
            }
        }
    }
    
    //Mark: - UICollectionViewDelegate, UICollectionViewDataSource methods
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ImageCellIdentifier, forIndexPath: indexPath) as DKImageCollectionCell
        
        cell.thumbnail = images[indexPath.row] as UIImage
        
        if self.imagePickerController?.selectedImages?.containsObject(cell.thumbnail) == true {
            cell.selected = true
        } else {
            cell.selected = false
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as DKImageCollectionCell
        NSNotificationCenter.defaultCenter().postNotificationName(DKImageSelectedNotification, object: cell.thumbnail)
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as DKImageCollectionCell
        NSNotificationCenter.defaultCenter().postNotificationName(DKImageUnselectedNotification, object: cell.thumbnail)
    }
}

class DKAssetsLibraryController: UITableViewController {
    weak var delegate: DKImagePickerControllerDelegate?
    
    lazy var groups: NSMutableArray = {
        return NSMutableArray()
    }()
    
    lazy var library: ALAssetsLibrary = {
        return ALAssetsLibrary()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: GroupCellIdentifier)
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel,
            target: self,
            action: "onCancelClicked")
        
        library.enumerateGroupsWithTypes(0xFFFFFFFF, usingBlock: {(group: ALAssetsGroup! , stop: UnsafeMutablePointer<ObjCBool>) in
            if group != nil {
                if group.numberOfAssets() != 0 {
                    let groupName = group.valueForProperty(ALAssetsGroupPropertyName) as NSString
                    
                    let assetGroup = DKAssetGroup()
                    assetGroup.groupName = groupName
                    assetGroup.thumbnail = UIImage(CGImage: group.posterImage().takeUnretainedValue())
                    assetGroup.group = group
                    self.groups.insertObject(assetGroup, atIndex: 0)
                }
            } else {
                self.tableView.reloadData()
            }
        }, failureBlock: {(error: NSError!) in
                println(error.localizedDescription)
        })
    }
    
    // MARK: - Delegate methods
    func onCancelClicked() {
        if let delegate = self.delegate {
            delegate.imagePickerControllerCancelled()
        }
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(GroupCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let assetGroup = groups[indexPath.row] as DKAssetGroup
        cell.textLabel?.text = assetGroup.groupName
        cell.imageView?.image = assetGroup.thumbnail
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let assetGroup = groups[indexPath.row] as DKAssetGroup
        let imageGroupController = DKImageGroupViewController()
        imageGroupController.assetGroup = assetGroup
        self.navigationController?.pushViewController(imageGroupController, animated: true)
    }
}

class DKImagePickerController: UINavigationController {
    
    class DKPreviewView: UIScrollView {
        let interval: CGFloat = 5
        private var imageLengthOfSide: CGFloat!
        private var imageViews = [UIImageView]()
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            imageLengthOfSide = self.bounds.height - interval * 2
        }
        
        func imageFrameForIndex(index: Int) -> CGRect {
            return CGRect(x: CGFloat(index) * imageLengthOfSide + CGFloat(index + 1) * interval,
                y: (self.bounds.height - imageLengthOfSide)/2,
                width: imageLengthOfSide, height: imageLengthOfSide)
        }
        
        func insertImage(image: UIImage) {
            let imageView = UIImageView(image: image)
            imageView.frame = imageFrameForIndex(imageViews.count)
            
            self.addSubview(imageView)
            imageViews.append(imageView)
            setupContent(true)
        }
        
        func removeImage(image: UIImage) {
            for (index,imageView) in enumerate(imageViews) {
                if image == imageView.image {
                    imageView.removeFromSuperview()
                    imageViews.removeAtIndex(index)
                    
                    setupContent(false)
                    break;
                }
            }
        }
        
        private func setupContent(isInsert: Bool) {
            if isInsert == false {
                for (index,imageView) in enumerate(imageViews) {
                    imageView.frame = imageFrameForIndex(index)
                }
            }
            self.contentSize = CGSize(width: CGRectGetMaxX((self.subviews.last as UIView).frame) + interval,
                height: self.bounds.height)
        }
    }
    
    private var libraryController: DKAssetsLibraryController!
    private var selectedImages: NSArray!
    
    let previewHeight: CGFloat = 80
    private var imagesPreviewView = DKPreviewView()
    
    weak var pickerDelegate: DKImagePickerControllerDelegate? {
        didSet {
            self.libraryController.delegate = pickerDelegate
        }
    }
    
    convenience override init() {
        var libraryController = DKAssetsLibraryController()
        self.init(rootViewController: libraryController)
        self.libraryController = libraryController
        
        selectedImages = NSMutableArray()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagesPreviewView.hidden = true
        imagesPreviewView.backgroundColor = UIColor(white: 0.667, alpha: 0.8)
        
        imagesPreviewView.frame = CGRect(x: 0, y: view.bounds.height - previewHeight, width: view.bounds.width, height: previewHeight)
        imagesPreviewView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin
        view.addSubview(imagesPreviewView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectedImage:", name: DKImageSelectedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unselectedImage:", name: DKImageUnselectedNotification, object: nil)
    }
    
    // MARK: - Notifications
    func selectedImage(noti: NSNotification) {
        if let image = noti.object as? UIImage {
            (selectedImages as NSMutableArray).addObject(image)
            imagesPreviewView.insertImage(image)
            imagesPreviewView.hidden = false
            
            for vc: UIViewController in self.viewControllers as [UIViewController]! {
                vc.view.frame.size.height -= previewHeight
            }
        }
    }
    
    func unselectedImage(noti: NSNotification) {
        if let image = noti.object as? UIImage {
            (selectedImages as NSMutableArray).removeObject(image)
            imagesPreviewView.removeImage(image)
            
            if selectedImages.count <= 0 {
                imagesPreviewView.hidden = true
                
                for vc: UIViewController in self.viewControllers as [UIViewController]! {
                    vc.view.frame.size.height += previewHeight
                }
            }
        }
    }
}
