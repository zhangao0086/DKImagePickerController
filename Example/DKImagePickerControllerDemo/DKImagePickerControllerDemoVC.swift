//
//  DKImagePickerControllerDemoVC.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 03/01/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import DKImagePickerController
import Photos

class DKImagePickerControllerDemoVC: UITableViewController {
    
    fileprivate func imageOnlyAssetFetchOptions() -> PHFetchOptions {
        let assetFetchOptions = PHFetchOptions()
        assetFetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        return assetFetchOptions
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        
        let destination = segue.destination as! ViewController
        destination.title = cell.textLabel?.text
        
        switch segue.identifier! {
            
        case "Pick Any":
            let pickerController = DKImagePickerController()
            
            destination.pickerController = pickerController
            
        case "Pick Photos Only":
            let pickerController = DKImagePickerController()
            pickerController.assetType = .allPhotos
            
            destination.pickerController = pickerController
            
        case "Pick Videos Only":
            let pickerController = DKImagePickerController()
            pickerController.assetType = .allVideos
            
            destination.pickerController = pickerController
            
        case "Pick Any (Only Photos Or Videos)":
            let pickerController = DKImagePickerController()
            pickerController.allowMultipleTypes = false
            
            destination.pickerController = pickerController
            
        case "Take A Picture":
            let pickerController = DKImagePickerController()
            pickerController.sourceType = .camera
            
            destination.pickerController = pickerController
            
        case "Hides Camera":
            let pickerController = DKImagePickerController()
            pickerController.sourceType = .photo
            
            destination.pickerController = pickerController
            
        case "With GPS":
            let pickerController = DKImagePickerController()
            pickerController.containsGPSInMetadata = true
            
            destination.pickerController = pickerController
            
        case "Allows Landscape":
            let pickerController = DKImagePickerController()
            pickerController.allowsLandscape = true
            
            destination.pickerController = pickerController
            
        case "Single Select":
            let pickerController = DKImagePickerController()
            pickerController.singleSelect = true
            pickerController.autoCloseOnSingleSelect = true
            
            destination.pickerController = pickerController
            
        case "Swiping to select":
            let pickerController = DKImagePickerController()
            pickerController.allowSwipeToSelect = true
            
            destination.pickerController = pickerController
            
        case "Select All":
            let pickerController = DKImagePickerController()
            pickerController.allowSelectAll = true
            destination.pickerController = pickerController
            
        case "Custom Camera":
            let pickerController = DKImagePickerController()
            
            DKImageExtensionController.registerExtension(extensionClass: CustomCameraExtension.self, for: .camera)
            
            destination.pickerController = pickerController
            
        case "Custom Inline Camera":
            let pickerController = DKImagePickerController()
            pickerController.sourceType = .camera
            pickerController.modalPresentationStyle = .overCurrentContext
            
            DKImageExtensionController.registerExtension(extensionClass: CustomCameraExtension.self, for: .inlineCamera)
            
            destination.pickerController = pickerController

        case "Custom UI":
            let pickerController = DKImagePickerController()
            pickerController.sourceType = .photo
            pickerController.UIDelegate = CustomUIDelegate()
            pickerController.showsCancelButton = true
            
            destination.pickerController = pickerController
            
        case "Custom Layout":
            let pickerController = DKImagePickerController()
            pickerController.UIDelegate = CustomLayoutUIDelegate()
            
            destination.pickerController = pickerController
            
        case "Inline":
            let groupDataManagerConfiguration = DKImageGroupDataManagerConfiguration()
            groupDataManagerConfiguration.fetchLimit = 10
            groupDataManagerConfiguration.assetGroupTypes = [.smartAlbumUserLibrary]
            // To specify photos only, we'd typically use pickerController.assetType = .allPhotos.
            // Because we're specifying a custom DKImageGroupDataManager, that doesn't work,
            // and we have to specify it using assetFetchOptions.
            groupDataManagerConfiguration.assetFetchOptions = imageOnlyAssetFetchOptions()
            
            let groupDataManager = DKImageGroupDataManager(configuration: groupDataManagerConfiguration)
            
            let pickerController = DKImagePickerController(groupDataManager: groupDataManager)
            pickerController.inline = true
            pickerController.UIDelegate = CustomInlineLayoutUIDelegate()
            pickerController.sourceType = .photo
            
            destination.pickerController = pickerController
            
        case "Export automatically":
            let pickerController = DKImagePickerController()
            pickerController.exportsWhenCompleted = true
            
            destination.pickerController = pickerController
            
        case "Export manually":
            let pickerController = DKImagePickerController()
            destination.exportManually = true
            
            destination.pickerController = pickerController
        
        case "Custom localized strings":
            DKImagePickerControllerResource.customLocalizationBlock = { title in
                if title == "picker.select.title" {
                    return "Test(%@)"
                } else {
                    return nil
                }
            }
            
            let pickerController = DKImagePickerController()
            
            destination.pickerController = pickerController

        case "Custom localized images":
            DKImagePickerControllerResource.customImageBlock = { imageName in
                if imageName == "camera" {
                    return DKImagePickerControllerResource.photoGalleryCheckedImage()
                } else {
                    return nil
                }
            }
            
            let pickerController = DKImagePickerController()
            
            destination.pickerController = pickerController
        case "Reload":
            let pickerController = DKImagePickerController()
            pickerController.UIDelegate = ReloadUIDelegate()
            
            destination.pickerController = pickerController
            
        default:
            assert(false)
        }
    }
}
