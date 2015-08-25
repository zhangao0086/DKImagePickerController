//
//  DKImagePickerController.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 14-10-2.
//  Copyright (c) 2014年 ZhangAo. All rights reserved.
//

import UIKit
import AssetsLibrary

//////////////////////////////////////////////////////////////////////////////////////////

// Asset Model
public class DKAsset: NSObject {
    
    private(set) public lazy var fullScreenImage: UIImage? = {
        return UIImage(CGImage: self.originalAsset?.defaultRepresentation().fullScreenImage().takeUnretainedValue())
    }()
    private(set) public lazy var fullResolutionImage: UIImage? = {
        return UIImage(CGImage: self.originalAsset?.defaultRepresentation().fullResolutionImage().takeUnretainedValue())
    }()
    private(set) public var url: NSURL?
    
    private(set) public var thumbnailImage: UIImage?
    
    private(set) public var isVideo: Bool = false
    
    // play time duration(seconds) of a video.
    public var duration = 0.0
    
    internal var isFromCamera: Bool = false
    internal var originalAsset: ALAsset?
    
    internal init(originalAsset: ALAsset) {
        super.init()
        
        self.thumbnailImage = UIImage(CGImage:originalAsset.thumbnail().takeUnretainedValue())
        self.url = originalAsset.valueForProperty(ALAssetPropertyAssetURL) as? NSURL
        self.originalAsset = originalAsset
        
        let assetType = originalAsset.valueForProperty(ALAssetPropertyType) as! NSString
        if assetType == ALAssetTypeVideo {
            let duration = originalAsset.valueForProperty(ALAssetPropertyDuration) as! NSNumber
            
            self.isVideo = true
            self.duration = duration.doubleValue
        }
    }
    
    internal init(image: UIImage) {
        super.init()
        
        self.isFromCamera = true
        self.fullScreenImage = image
        self.fullResolutionImage = image
        self.thumbnailImage = image
    }
    
    // Compare two DKAssets
    override public func isEqual(object: AnyObject?) -> Bool {
        let another = object as! DKAsset!
        
        if let url = self.url, anotherUrl = another.url {
            return url.isEqual(anotherUrl)
        } else {
            return false
        }
    }
}

internal extension UIViewController {
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
// MARK: - Main Controller
//////////////////////////////////////////////////////////////////////////////////////////

public class DKImagePickerController: UINavigationController {
    
    public var maxSelectableCount = 999
    
    public var didSelectedAssets: ((assets: [DKAsset]) -> Void)?
    public var didCancelled: (() -> Void)?
    
    public var defaultSelectedAssets: [DKAsset]? {
        didSet {
            if let defaultSelectedAssets = self.defaultSelectedAssets {
                for (index, asset) in enumerate(defaultSelectedAssets) {
                    if asset.isFromCamera {
                        self.defaultSelectedAssets!.removeAtIndex(index)
                    }
                }
                
                self.selectedAssets = defaultSelectedAssets
                self.updateDoneButtonTitle()
            }
        }
    }
    
    internal var selectedAssets = [DKAsset]()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        button.setTitle("", forState: UIControlState.Normal)
        button.setTitleColor(self.navigationBar.tintColor, forState: UIControlState.Normal)
        button.reversesTitleShadowWhenHighlighted = true
        button.addTarget(self, action: "done", forControlEvents: UIControlEvents.TouchUpInside)
        
        return button
    }()
    
    public convenience init() {
        let rootVC = DKAssetGroupDetailVC()
        self.init(rootViewController: rootVC)
        
        rootVC.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.doneButton)
        rootVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel,
            target: self,
            action: "dismiss")
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
    
    private func updateDoneButtonTitle() {
        if self.selectedAssets.count > 0 {
            self.doneButton.setTitle(DKImageLocalizedString.localizedStringForKey("select") + "(\(selectedAssets.count))", forState: UIControlState.Normal)
        } else {
            self.doneButton.setTitle("", forState: UIControlState.Normal)
        }
        self.doneButton.sizeToFit()
    }
    
    internal func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
        if let didCancelled = self.didCancelled {
            didCancelled()
        }
    }
    
    internal func done() {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if let didSelectedAssets = self.didSelectedAssets {
            didSelectedAssets(assets: self.selectedAssets)
        }
    }
    
    // MARK: - Notifications
    /**/
    
    internal func selectedImage(noti: NSNotification) {
        if let asset = noti.object as? DKAsset {
            selectedAssets.append(asset)
            if asset.isFromCamera {
                self.done()
            } else {
                updateDoneButtonTitle()
            }
        }
    }
    
    internal func unselectedImage(noti: NSNotification) {
        if let asset = noti.object as? DKAsset {
            selectedAssets.removeAtIndex(find(selectedAssets, asset)!)
            updateDoneButtonTitle()
        }
    }
}
