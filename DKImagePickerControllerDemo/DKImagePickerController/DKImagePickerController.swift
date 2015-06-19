//
//  DKImagePickerController.swift
//  CustomImagePicker
//
//  Created by ZhangAo on 14-10-2.
//  Copyright (c) 2014年 ZhangAo. All rights reserved.
//

//  Changes by Oskari Rauta.
//  Popup mod inspired by Tabasoft's simple iOS 8 popDatePicker from URL: http://coding.tabasoft.it/ios/a-simple-ios8-popdatepicker/

import UIKit
import AssetsLibrary

// Delegate
protocol DKImagePickerControllerDelegate : NSObjectProtocol {
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
let DKGroupClicked = "DKGroupClicked"

// Group Model
class DKAssetGroup : NSObject {
    var groupName: String!
    var thumbnail: UIImage!
    var group: ALAssetsGroup!
}

// Asset Model
class DKAsset: NSObject {
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
    
    class DKCheckView : UIView {

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
    
    class DKImageCollectionCell: UICollectionViewCell {
        
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
        private var checkView = DKCheckView()
        
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
    var assetGroup: DKAssetGroup!
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
        self.collectionView!.layer.borderColor = self.collectionView!.backgroundColor!.CGColor
        self.collectionView!.layer.borderWidth = 2.0
        self.collectionView!.allowsMultipleSelection = true
        self.collectionView!.registerClass(DKImageCollectionCell.self, forCellWithReuseIdentifier: ImageCellIdentifier)
        
    }

    func updateTitle() {
        self.title = assetGroup.groupName + ( (self.navigationController! as! DKImagePickerController).groups.count > 1 ? "  \u{25be}" : "" )
    }
    
    func updateCollectionView() {
        
        assetGroup.group.enumerateAssetsUsingBlock {[unowned self](result: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if result != nil {
                let asset = DKAsset()
                asset.thumbnailImage = UIImage(CGImage:result.thumbnail().takeUnretainedValue())
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
        
        assert(assetGroup != nil, "assetGroup is nil")
        
        self.updateTitle()
        self.updateCollectionView()
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

        NSNotificationCenter.defaultCenter().postNotificationName(DKImageSelectedNotification, object: imageAssets[indexPath.row])
        
        let asset = imageAssets[indexPath.row] as! DKAsset
        
        if find(self.imagePickerController!.selectedAssets, asset) != nil {
            (self.collectionView!.cellForItemAtIndexPath(indexPath) as! DKImageCollectionCell).num = (self.imagePickerController!.selectedAssets as NSArray).indexOfObject(asset) + 1
        }
        
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().postNotificationName(DKImageUnselectedNotification, object: imageAssets[indexPath.row])
        
        for var i = 0; i < self.collectionView!.numberOfItemsInSection(indexPath.section); i++ {

            let asset = imageAssets[i] as! DKAsset
            
            if find(self.imagePickerController!.selectedAssets, asset) != nil {
                (self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: i, inSection: indexPath.section)) as! DKImageCollectionCell).num = (self.imagePickerController!.selectedAssets as NSArray).indexOfObject(asset) + 1
            }
            
        }
        
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Group selector
//////////////////////////////////////////////////////////////////////////////////////////

class DKGroupSelectController : UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var groups : NSArray = NSArray()
    
    convenience init() {
        
        self.init(nibName: "DKGroupSelectController", bundle: nil)
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 32.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        let assetGroup : DKAssetGroup = self.groups.objectAtIndex(indexPath.row) as! DKAssetGroup
        cell.textLabel!.text = assetGroup.groupName
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        self.dismissViewControllerAnimated(true, completion: nil)
        let assetGroup : DKAssetGroup = self.groups.objectAtIndex(indexPath.row) as! DKAssetGroup
        NSNotificationCenter.defaultCenter().postNotificationName(DKGroupClicked, object: self.groups.objectAtIndex(indexPath.row) as! DKAssetGroup)
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        updateMenu()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
}


//////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Main Controller
//////////////////////////////////////////////////////////////////////////////////////////

class DKImagePickerController: UINavigationController {
    
    /// Displayed when denied access
    var noAccessView: UIView = {
        let label = UILabel()
        label.text = "User has denied access"
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.lightGrayColor()
        return label
    }()
    
    class DKContentWrapperViewController: UIViewController, UIPopoverPresentationControllerDelegate {
        var contentViewController: UIViewController
        var offset : CGFloat = 8.0
        var titlebtn: UIButton = UIButton()
        var popover : UIPopoverPresentationController?
        
        lazy private var groupSelectController : DKGroupSelectController = {
            return DKGroupSelectController()
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
            groupSelectController.modalPresentationStyle = .Popover
            groupSelectController.preferredContentSize = CGSizeMake(500, 168)
            popover = groupSelectController.popoverPresentationController
            if let _popover = popover {
                
                _popover.sourceView = self.titlebtn
                _popover.sourceRect = CGRectMake(self.offset, self.titlebtn.bounds.size.height, self.titlebtn.bounds.size.width, 0)
                _popover.delegate = self
                
                groupSelectController.groups = NSArray(array: ( self.navigationController! as! DKImagePickerController ).groups)
                
                inViewController.presentViewController(groupSelectController, animated: true, completion: nil)
            }
        }

        func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle {
            
            return .None
        }
        
        func onGroupClicked() {
            self.pickGroup(self)
        }
    }
    
    var selectedGroupIndex : Int = 0
    
    internal var selectedAssets: [DKAsset]!
    internal  weak var pickerDelegate: DKImagePickerControllerDelegate?
    
    lazy private var groups: NSMutableArray = {
        return NSMutableArray()
        }()
    
    lazy private var library: ALAssetsLibrary = {
        return ALAssetsLibrary()
        }()
    
    lazy private var imageGroupController: DKImageGroupViewController = {
        return DKImageGroupViewController()
    }()
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        var initialView =  UIViewController() // This is a bit dirty hack that propably could be done better..
        var wrapperVC = DKContentWrapperViewController(initialView)
        
        self.init(rootViewController: wrapperVC)
        
        selectedAssets = [DKAsset]()
        
        self.updateAssetGroups()
        
        var wrapperVC2 = DKContentWrapperViewController(self.imageGroupController)
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
                                                                   name: DKImageSelectedNotification,
                                                                 object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unselectedImage:",
                                                                   name: DKImageUnselectedNotification,
                                                                 object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectedGroup:",
                                                                   name: DKGroupClicked,
                                                                 object: nil)

    }

    func updateAssetGroups() {
        
        self.groups.removeAllObjects()
        
        library.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: {(group: ALAssetsGroup! , stop: UnsafeMutablePointer<ObjCBool>) in
            if group != nil {
                if group.numberOfAssets() != 0 {
                    let groupName = group.valueForProperty(ALAssetsGroupPropertyName) as! String
                    
                    let assetGroup = DKAssetGroup()
                    assetGroup.groupName = groupName
                    assetGroup.thumbnail = UIImage(CGImage: group.posterImage().takeUnretainedValue())
                    assetGroup.group = group
                    self.groups.insertObject(assetGroup, atIndex: 0)
                    self.imageGroupController.assetGroup = assetGroup
                }
            } else {
                
                if self.groups.count > self.selectedGroupIndex {
                    self.imageGroupController.assetGroup = self.groups[self.selectedGroupIndex] as! DKAssetGroup
                }

                self.imageGroupController.updateTitle()
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

        if let asset = noti.object as? DKAssetGroup {
            
            self.selectedAssets.removeAll(keepCapacity: true)
            self.imageGroupController.imageAssets.removeAllObjects()

            self.imageGroupController.assetGroup = asset
            self.imageGroupController.updateTitle()
            self.imageGroupController.updateCollectionView()
            
            self.selectedGroupIndex = self.groups.indexOfObject(asset)
            
        }
        
    }
    
    func selectedImage(noti: NSNotification) {
        if let asset = noti.object as? DKAsset {
            selectedAssets.append(asset)
            self.topViewController.navigationItem.rightBarButtonItem!.enabled = true
        }
    }
    
    func unselectedImage(noti: NSNotification) {
        if let asset = noti.object as? DKAsset {
            selectedAssets.removeAtIndex(find(selectedAssets, asset)!)
            self.topViewController.navigationItem.rightBarButtonItem!.enabled = self.selectedAssets.count > 0 ? true : false
        }
    }
}
