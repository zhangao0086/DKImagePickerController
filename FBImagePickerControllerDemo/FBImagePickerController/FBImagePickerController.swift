//
//  FBImagePickerController.swift
//  Facebook Style ImagePicker
//
//  Created by ZhangAo on 14-10-2.
//  Forked by Oskari Rauta.
//  Copyright (c) 2015 ZhangAo & Oskari Rauta. All rights reserved.
//  Popup mod inspired by Tabasoft's simple iOS 8 popDatePicker from URL: http://coding.tabasoft.it/ios/a-simple-ios8-popdatepicker/

import UIKit
import AssetsLibrary
import Photos

// Delegate
protocol FBImagePickerControllerDelegate : NSObjectProtocol {
    /// Called when right button is clicked.
    ///
    /// :param: images Images of selected
    func imagePickerControllerDidSelectedAssets(images: [FBAsset]!)
    
    /// Called when cancel button is clicked.
    func imagePickerControllerCancelled()
}

//////////////////////////////////////////////////////////////////////////////////////////

// Cell Identifier
let GroupCellIdentifier = "GroupCellIdentifier"
let ImageCellIdentifier = "ImageCellIdentifier"

// Nofifications
let FBImageSelectedNotification = "FBImageSelectedNotification"
let FBImageUnselectedNotification = "FBImageUnselectedNotification"
let FBGroupClicked = "FBGroupClicked"

// Group Model
class FBAssetGroup : NSObject {
    var groupName: String!
    var thumbnail: UIImage!
    var group: ALAssetsGroup!
}

// Asset Model
class FBAsset: NSObject {
    var thumbnailImage: UIImage?
    lazy var fullScreenImage: UIImage? = {
        return UIImage(CGImage: self.originalAsset.defaultRepresentation().fullScreenImage().takeUnretainedValue())
    }()
    lazy var fullResolutionImage: UIImage? = {
        return UIImage(CGImage: self.originalAsset.defaultRepresentation().fullResolutionImage().takeUnretainedValue())
    }()
    var url: NSURL?
    
    private var originalAsset: ALAsset!
    
    // Compare two assets
    override func isEqual(object: AnyObject?) -> Bool {
        let other = object as! FBAsset!
        return self.url!.isEqual(other.url!)
    }
}

// Internal
extension UIViewController {
    var imagePickerController: FBImagePickerController? {
        get {
            let nav = self.navigationController
            if nav is FBImagePickerController {
                return nav as? FBImagePickerController
            } else {
                return nil
            }
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Show All Iamges In Group
//////////////////////////////////////////////////////////////////////////////////////////

class FBImageGroupViewController: UICollectionViewController {
    
    class FBCheckView : UIView {

        var num : Int = 0 {
            didSet {
                self.text = NSString(format: "%d", num)
                if !self.hidden {
                    self.setNeedsDisplay()
                }
            }
        }

        var textColor : UIColor = UIColor.whiteColor() {
            didSet {
                
                self.updateAttrs()
                
                if !self.hidden {
                    self.setNeedsDisplay()
                }
            }
        }
        
        var selectedColor : UIColor = UIColor(red: 0, green: 132 / 255, blue: 245 / 255, alpha: 1.0) {
            didSet {

                self.updateColors()
                
                if !self.hidden {
                    self.setNeedsDisplay()
                }
            }
        }
        
        override var hidden : Bool {
            didSet {
                self.setNeedsDisplay()
            }
        }

        private var text : NSString = NSString()
        private var attrs : NSDictionary = NSDictionary()
        private var selectedRed : CGFloat = 0
        private var selectedGreen : CGFloat = 0
        private var selectedBlue : CGFloat = 0
        private var selectedAlpha : CGFloat = 0
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func updateColors() {
            self.selectedColor.getRed(&self.selectedRed, green: &self.selectedGreen, blue: &self.selectedBlue, alpha: &self.selectedAlpha)
        }
        
        private func updateAttrs() {
            var paragraph : NSMutableParagraphStyle = NSMutableParagraphStyle()
            paragraph.alignment = NSTextAlignment.Center
            
            self.attrs = NSDictionary(objectsAndKeys:
                UIFont.boldSystemFontOfSize(12.0), NSFontAttributeName,
                self.textColor, NSForegroundColorAttributeName,
                paragraph, NSParagraphStyleAttributeName
            )
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.updateAttrs()
            self.updateColors()
            self.backgroundColor = UIColor.clearColor()
        }
        
        override func drawRect(rect: CGRect) {
            super.drawRect(rect)

            var ctx : CGContextRef = UIGraphicsGetCurrentContext()
            let width: CGFloat = 21.0
            let height: CGFloat = 21.0
            let textRect : CGRect = CGRectMake(rect.width - width, 0, width, height)
            
            CGContextSetRGBFillColor(ctx, self.selectedRed, self.selectedGreen, self.selectedBlue, self.selectedAlpha)
            CGContextSetRGBStrokeColor(ctx, self.selectedRed, self.selectedGreen, self.selectedBlue, self.selectedAlpha)

            CGContextStrokeRectWithWidth(ctx, CGRectInset(rect, 1.0, 1.0), 1.5)
            CGContextFillRect(ctx, textRect)

            if num > 0 {
                let textHeight: CGFloat = text.sizeWithAttributes(self.attrs as [NSObject : AnyObject]).height
                text.drawInRect(CGRectInset(textRect, 0, (height - textHeight) / 2), withAttributes: self.attrs as [NSObject : AnyObject])
            }
        }
        
    }
    
    class FBImageCollectionCell: UICollectionViewCell {
        
        var num : Int = 0 {
            didSet {
                self.checkView.num = self.num
            }
        }
        
        var thumbnail: UIImage! {
            didSet {
                self.imageView.image = thumbnail
            }
        }
        
        override var selected: Bool {
            didSet {
                if super.selected {
                    
                }
                checkView.hidden = !super.selected
            }
        }
        
        private var imageView = UIImageView()
        private var checkView = FBCheckView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)

            imageView.frame = CGRectInset(self.bounds, 1, 1)
            self.checkView.frame = self.imageView.frame
            
            self.contentView.addSubview(imageView)
            self.contentView.addSubview(checkView)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            imageView.frame = CGRectInset(self.bounds, 1, 1)
            checkView.frame = imageView.frame
        }
    }
    

    var groups : NSArray = NSArray()
    var assetGroup: FBAssetGroup!
    private lazy var imageAssets: NSMutableArray = {
        return NSMutableArray()
    }()
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        
        let interval: CGFloat = 3
        layout.minimumInteritemSpacing = interval
        layout.minimumLineSpacing = interval
        
        let screenWidth = UIScreen.mainScreen().bounds.width > UIScreen.mainScreen().bounds.height ? UIScreen.mainScreen().bounds.height : UIScreen.mainScreen().bounds.width
        let itemWidth = (screenWidth - interval * 3) / 4
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)

        self.init(collectionViewLayout: layout)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.backgroundColor = UIColor.blackColor()
        self.collectionView!.layer.borderColor = self.collectionView!.backgroundColor!.CGColor
        self.collectionView!.layer.borderWidth = 2.0
        self.collectionView!.allowsMultipleSelection = true
        self.collectionView!.registerClass(FBImageCollectionCell.self, forCellWithReuseIdentifier: ImageCellIdentifier)
        
    }

    func updateTitle() {
        self.title = assetGroup.groupName + ( (self.navigationController! as! FBImagePickerController).groups.count > 1 ? "  \u{25be}" : "" )
    }
    
    func updateCollectionView() {
        assetGroup.group.enumerateAssetsUsingBlock {[unowned self](result: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if result != nil {
                let asset = FBAsset()
                asset.thumbnailImage = UIImage(CGImage: UIDevice.currentDevice().model.rangeOfString("iPad") != nil ? result.defaultRepresentation().fullScreenImage().takeUnretainedValue() : result.thumbnail().takeUnretainedValue())
                asset.url = result.valueForProperty(ALAssetPropertyAssetURL) as? NSURL
                asset.originalAsset = result
                self.imageAssets.addObject(asset)
            } else {
                self.collectionView!.reloadData()
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView!.scrollToItemAtIndexPath(NSIndexPath(forRow: self.imageAssets.count-1, inSection: 0),
                        atScrollPosition: UICollectionViewScrollPosition.Bottom,
                        animated: false)
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if assetGroup != nil {
            self.updateTitle()
            self.updateCollectionView()
        } else {
            self.dismissViewControllerAnimated(true, completion: {})
        }
        
    }
    
    //Mark: - UICollectionViewDelegate, UICollectionViewDataSource methods
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageAssets.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ImageCellIdentifier, forIndexPath: indexPath) as! FBImageCollectionCell
        
        let asset = imageAssets[indexPath.row] as! FBAsset
        cell.thumbnail = asset.thumbnailImage
        
        if find(self.imagePickerController!.selectedAssets, asset) != nil {
            cell.num = ( self.imagePickerController!.selectedAssets as NSArray).indexOfObject(asset) + 1
            cell.selected = true
            collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
        } else {
            cell.selected = false
            collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        NSNotificationCenter.defaultCenter().postNotificationName(FBImageSelectedNotification, object: imageAssets[indexPath.row])
        
        let asset = imageAssets[indexPath.row] as! FBAsset
        
        if find(self.imagePickerController!.selectedAssets, asset) != nil {
            (self.collectionView!.cellForItemAtIndexPath(indexPath) as! FBImageCollectionCell).num = (self.imagePickerController!.selectedAssets as NSArray).indexOfObject(asset) + 1
        }
        
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().postNotificationName(FBImageUnselectedNotification, object: imageAssets[indexPath.row])
        
        for var i = 0; i < self.collectionView!.numberOfItemsInSection(indexPath.section); i++ {

            let asset = imageAssets[i] as! FBAsset
            
            if find(self.imagePickerController!.selectedAssets, asset) != nil {
                (self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: i, inSection: indexPath.section)) as! FBImageCollectionCell).num = (self.imagePickerController!.selectedAssets as NSArray).indexOfObject(asset) + 1
            }
            
        }
        
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Group selector
//////////////////////////////////////////////////////////////////////////////////////////

class FBGroupSelectController : UIViewController, UITableViewDelegate, UITableViewDataSource {

    class FBGroupCell : UITableViewCell {
        
        var name : String = "" {
            didSet {
                self.nameLabel.text = self.name
            }
        }
        
        var count : Int = 0 {
            didSet {
                self.countLabel.text = String(format: "%d", self.count)
            }
        }
        
        var thumbnail: UIImageView = UIImageView()
        var nameLabel: UILabel = UILabel()
        var countLabel: UILabel = UILabel()

        private var didSetConstraints : Bool = false
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            self.thumbnail.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.nameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.countLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            self.contentView.addSubview(self.thumbnail)
            self.contentView.addSubview(self.nameLabel)
            self.contentView.addSubview(self.countLabel)

            self.nameLabel.textAlignment = .Left
            self.countLabel.textAlignment = .Right
            
        }
        
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override func awakeFromNib() {
            super.awakeFromNib()
        }
        
        override func updateConstraints() {

            if ( !didSetConstraints ) {
                
                didSetConstraints = true
                
                self.contentView.addConstraint(NSLayoutConstraint(item: self.thumbnail, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .Leading, multiplier: 1.0, constant: 2.0))

                self.contentView.addConstraint(NSLayoutConstraint(item: self.thumbnail, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: 2.0))

                self.contentView.addConstraint(NSLayoutConstraint(item: self.thumbnail, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: -2.0))
                
                self.contentView.addConstraint(NSLayoutConstraint(item: self.thumbnail, attribute: .Width, relatedBy: .Equal, toItem: self.thumbnail, attribute: .Height, multiplier: 1.0, constant: 0.0))
                
                self.contentView.addConstraint(NSLayoutConstraint(item: self.nameLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.thumbnail, attribute: .Trailing, multiplier: 1.0, constant: 5.0))
                
                self.contentView.addConstraint(NSLayoutConstraint(item: self.nameLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: self.thumbnail, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
                
                self.contentView.addConstraint(NSLayoutConstraint(item: self.countLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: self.nameLabel, attribute: .CenterY, multiplier: 1.0, constant: 0.0))

                self.contentView.addConstraint(NSLayoutConstraint(item: self.countLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Trailing, multiplier: 1.0, constant: -5.0))
                
                self.contentView.addConstraint(NSLayoutConstraint(item: self.nameLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.countLabel, attribute: .Leading, multiplier: 1.0, constant: -5.0))
            }
            
            super.updateConstraints()
            
            
        }

        override func intrinsicContentSize() -> CGSize {
            return CGSizeMake(UIViewNoIntrinsicMetric, 32.0)
        }
        
    }
    
    var tableView: UITableView = UITableView()
    var groups : NSArray = NSArray()
    private var didSetConstraints : Bool = false

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        updateMenu()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = 50
        
        self.tableView.registerClass(FBGroupCell.self, forCellReuseIdentifier: "groupCell")
        
        self.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.tableView)
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateViewConstraints()
    }
    
    override func updateViewConstraints() {
        
        if !self.didSetConstraints {
            
            self.didSetConstraints = true
            
            self.view.addConstraint(NSLayoutConstraint(item: self.tableView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 8.0))

            self.view.addConstraint(NSLayoutConstraint(item: self.tableView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: -8.0))

            self.view.addConstraint(NSLayoutConstraint(item: self.tableView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0.0))
            
            self.view.addConstraint(NSLayoutConstraint(item: self.tableView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
            
        }
        
        super.updateViewConstraints()
        
    }
    
    func updateMenu() {
        self.tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell:FBGroupCell = self.tableView.dequeueReusableCellWithIdentifier("groupCell") as! FBGroupCell
        let assetGroup : FBAssetGroup = self.groups.objectAtIndex(indexPath.row) as! FBAssetGroup
        
        cell.name = assetGroup.groupName
        cell.count = assetGroup.group.numberOfAssets()
        cell.thumbnail.image = assetGroup.thumbnail
        
        cell.setNeedsUpdateConstraints()
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        FBPopoverViewController.dismissPopoverViewController()
        let assetGroup : FBAssetGroup = self.groups.objectAtIndex(indexPath.row) as! FBAssetGroup
        NSNotificationCenter.defaultCenter().postNotificationName(FBGroupClicked, object: self.groups.objectAtIndex(indexPath.row) as! FBAssetGroup)
    }
    
}


//////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Main Controller
//////////////////////////////////////////////////////////////////////////////////////////

class FBImagePickerController: UINavigationController {
    
    class FBContentWrapperViewController: UIViewController {
        var contentViewController: UIViewController
        var titlebtn: UIButton = UIButton()
        
        lazy private var groupSelectController : FBGroupSelectController = {
            return FBGroupSelectController()
            }()
        
        init(_ viewController: UIViewController) {
            contentViewController = viewController

            super.init(nibName: nil, bundle: nil)
            self.addChildViewController(viewController)
            
            contentViewController.addObserver(self, forKeyPath: "title", options: NSKeyValueObservingOptions.New, context: nil)
            
            self.titlebtn.addTarget(self, action: "onGroupClicked", forControlEvents: .TouchUpInside)
        }
        
        deinit {
            contentViewController.removeObserver(self, forKeyPath: "title")
        }

        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
            if keyPath == "title" {
                self.titlebtn.setTitle(contentViewController.title, forState: .Normal)
                self.titlebtn.titleLabel!.font = UIFont.boldSystemFontOfSize(16.0)
                self.titlebtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
                self.titlebtn.sizeToFit()
                self.navigationItem.titleView = self.titlebtn
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.view.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(contentViewController.view)
            contentViewController.view.frame = view.bounds
        }
        
        private func pickGroup(inViewController : UIViewController) {
            groupSelectController.groups = NSArray(array: ( self.navigationController! as! FBImagePickerController ).groups)
            
            if self.groupSelectController.groups.count == 0 {
                return
            }
            
            groupSelectController.preferredContentSize = CGSizeMake(
                UIViewNoIntrinsicMetric, CGFloat(groupSelectController.groups.count) * 50.0)
            
            FBPopoverViewController.popoverViewController(groupSelectController, fromView: self.titlebtn)
        }
        
        func onGroupClicked() {
            self.pickGroup(self)
        }
    }
    
    var selectedGroupIndex : Int = 0
    
    internal var selectedAssets: [FBAsset]!
    internal  weak var pickerDelegate: FBImagePickerControllerDelegate?
    
    lazy private var groups: NSMutableArray = {
        return NSMutableArray()
        }()
    
    lazy private var library: ALAssetsLibrary = {
        return ALAssetsLibrary()
        }()
    
    lazy private var imageGroupController: FBImageGroupViewController = {
        return FBImageGroupViewController()
    }()
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        var initialView =  UIViewController() // This is a bit dirty hack that propably could be done better..
        var wrapperVC = FBContentWrapperViewController(initialView)
        
        self.init(rootViewController: wrapperVC)
        
        selectedAssets = [FBAsset]()
        
        self.updateAssetGroups()
        
        var wrapperVC2 = FBContentWrapperViewController(self.imageGroupController)
        self.setViewControllers([wrapperVC2], animated: false)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectedImage:",
                                                                   name: FBImageSelectedNotification,
                                                                 object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unselectedImage:",
                                                                   name: FBImageUnselectedNotification,
                                                                 object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectedGroup:",
                                                                   name: FBGroupClicked,
                                                                 object: nil)

    }

    func updateAssetGroups() {
        
        self.groups.removeAllObjects()
        
        library.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: {(group: ALAssetsGroup! , stop: UnsafeMutablePointer<ObjCBool>) in
            if group != nil {
                if group.numberOfAssets() != 0 {
                    let groupName = group.valueForProperty(ALAssetsGroupPropertyName) as! String
                    
                    let assetGroup = FBAssetGroup()
                    assetGroup.groupName = groupName
                    assetGroup.thumbnail = UIImage(CGImage: group.posterImage().takeUnretainedValue())
                    assetGroup.group = group
                    self.groups.insertObject(assetGroup, atIndex: 0)
                    self.imageGroupController.assetGroup = assetGroup
                }
            } else {
                
                if self.groups.count > self.selectedGroupIndex {
                    self.imageGroupController.assetGroup = self.groups[self.selectedGroupIndex] as! FBAssetGroup
                }

                if self.groups.count > 0 {
                    self.imageGroupController.updateTitle()                    
                }
            }
            }, failureBlock: {(error: NSError!) in
        })
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateAssetGroups()
        
        self.topViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "onCancelClicked")
        self.topViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "onDoneClicked")
        self.topViewController.navigationItem.rightBarButtonItem!.enabled = false
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

    func selectedGroup(noti: NSNotification) {
        if let asset = noti.object as? FBAssetGroup {
            
            self.selectedAssets.removeAll(keepCapacity: true)
            self.imageGroupController.imageAssets.removeAllObjects()

            self.imageGroupController.assetGroup = asset
            self.imageGroupController.updateTitle()
            self.imageGroupController.updateCollectionView()
            
            self.selectedGroupIndex = self.groups.indexOfObject(asset)
            
        }
        
    }
    
    func selectedImage(noti: NSNotification) {
        if selectedAssets.count < 99 {
            if let asset = noti.object as? FBAsset {
                selectedAssets.append(asset)
                self.topViewController.navigationItem.rightBarButtonItem!.enabled = true
            }
        }
    }
    
    func unselectedImage(noti: NSNotification) {
        if let asset = noti.object as? FBAsset {
            selectedAssets.removeAtIndex(find(selectedAssets, asset)!)
            self.topViewController.navigationItem.rightBarButtonItem!.enabled = self.selectedAssets.count > 0 ? true : false
        }
    }
}
