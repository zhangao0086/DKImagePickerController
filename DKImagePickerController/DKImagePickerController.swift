//
//  DKImagePickerController.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 14-10-2.
//  Copyright (c) 2014年 ZhangAo. All rights reserved.
//

import UIKit
import AssetsLibrary

// MARK: - Public DKAsset

/**
 * An `DKAsset` object represents a photo or a video managed by the `DKImagePickerController`.
 */
public class DKAsset: NSObject {
    
    /// Returns a CGImage of the representation that is appropriate for displaying full screen.
    public private(set) lazy var fullScreenImage: UIImage? = {
        return UIImage(CGImage: (self.originalAsset?.defaultRepresentation().fullScreenImage().takeUnretainedValue())!)
    }()
    
    /// Returns a CGImage representation of the asset.
    public private(set) lazy var fullResolutionImage: UIImage? = {
        return UIImage(CGImage: (self.originalAsset?.defaultRepresentation().fullResolutionImage().takeUnretainedValue())!)
    }()
    
    /// The url uniquely identifies an asset that is an image or a video.
    public private(set) var url: NSURL?
    
    /// It's a square thumbnail of the asset.
    public private(set) var thumbnailImage: UIImage?
    
    /// When the asset was an image, it's false. Otherwise true.
    public private(set) var isVideo: Bool = false
    
    /// play time duration(seconds) of a video.
    public private(set) var duration: Double?
    
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

/**

 * allPhotos: Get all photos assets in the assets group.
 * allVideos: Get all video assets in the assets group.
 * allAssets: Get all assets in the group.
 */
public enum DKImagePickerControllerAssetType : Int {

    case allPhotos, allVideos, allAssets
}

public struct DKImagePickerControllerSourceType : OptionSetType {
    
    private var value: UInt = 0
    init(_ value: UInt) { self.value = value }
    // MARK: _RawOptionSetType
    public init(rawValue value: UInt) { self.value = value }
    // MARK: NilLiteralConvertible
    public init(nilLiteral: ()) { self.value = 0 }
    // MARK: RawRepresentable
    public var rawValue: UInt { return self.value }
    // MARK: BitwiseOperationsType
    public static var allZeros: DKImagePickerControllerSourceType { return self.init(0) }
    
    public static var Camera: DKImagePickerControllerSourceType { return self.init(1 << 0) }
    public static var Photo: DKImagePickerControllerSourceType { return self.init(1 << 1) }
}

// MARK: - Public DKImagePickerController

/**
 * The `DKImagePickerController` class offers the all public APIs which will affect the UI.
 */
public class DKImagePickerController: UINavigationController {
    
    /// The maximum count of assets which the user will be able to select.
    public var maxSelectableCount = 999
    
    /// The type of picker interface to be displayed by the controller.
    public var assetType = DKImagePickerControllerAssetType.allAssets
    
    /// If sourceType is Camera will cause the assetType & maxSelectableCount & allowMultipleTypes & defaultSelectedAssets to be ignored.
    public var sourceType: DKImagePickerControllerSourceType = [.Camera, .Photo]
    
    /// Whether allows to select photos and videos at the same time.
    public var allowMultipleTypes = true
    
    /// The callback block is executed when user pressed the select button.
    public var didSelectAssets: ((assets: [DKAsset]) -> Void)?
    
    /// The callback block is executed when user pressed the cancel button.
    public var didCancel: (() -> Void)?
    
    /// It will have selected the specific assets.
    public var defaultSelectedAssets: [DKAsset]? {
        didSet {
            if let defaultSelectedAssets = self.defaultSelectedAssets {
                for (index, asset) in defaultSelectedAssets.enumerate() {
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
        let button = UIButton(type: UIButtonType.Custom)
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
        self.didCancel?()
    }
    
    internal func done() {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.didSelectAssets?(assets: self.selectedAssets)
    }
    
    // MARK: - Notifications
    
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
            selectedAssets.removeAtIndex(selectedAssets.indexOf(asset)!)
            updateDoneButtonTitle()
        }
    }
    
    // MARK: - Handles Orientation

    public override func shouldAutorotate() -> Bool {
        return false
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

}

// MARK: - Utilities

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
