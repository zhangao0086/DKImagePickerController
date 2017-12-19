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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        
        let destination = segue.destination as! ViewController
        destination.title = cell.textLabel?.text
        
        switch segue.identifier! {
            
        case "Pick All":
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
            
        case "Pick All(Only Photos Or Videos)":
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
            
        case "Allows Landscape":
            let pickerController = DKImagePickerController()
            pickerController.allowsLandscape = true
            
            destination.pickerController = pickerController
            
        case "Single Select":
            let pickerController = DKImagePickerController()
            pickerController.singleSelect = true
            pickerController.autoCloseOnSingleSelect = true
            
            destination.pickerController = pickerController
            
        case "Custom Camera":
            let pickerController = DKImagePickerController()
            
            registerExtension(extensionClass: CustomCameraExtension.self, for: .camera)
            
            destination.pickerController = pickerController
            
        case "Custom Inline Camera":
            let pickerController = DKImagePickerController()
            pickerController.sourceType = .camera
            pickerController.modalPresentationStyle = .overCurrentContext
            
            registerExtension(extensionClass: CustomCameraExtension.self, for: .inlineCamera)
            
            destination.pickerController = pickerController

        case "Custom UI":
            let pickerController = DKImagePickerController()
            pickerController.UIDelegate = CustomUIDelegate(imagePickerController: pickerController)
            pickerController.showsCancelButton = true
            
            destination.pickerController = pickerController
            
        case "Custom Layout":
            let pickerController = DKImagePickerController()
            pickerController.UIDelegate = CustomLayoutUIDelegate(imagePickerController: pickerController)
            
            destination.pickerController = pickerController
            
        case "Inline":
            let groupDataManagerConfiguration = DKImageGroupDataManagerConfiguration()
            groupDataManagerConfiguration.fetchLimit = 10
            groupDataManagerConfiguration.assetGroupTypes = [.smartAlbumUserLibrary]
            
            let groupDataManager = DKImageGroupDataManager(configuration: groupDataManagerConfiguration)
            
            let pickerController = DKImagePickerController(groupDataManager: groupDataManager)
            pickerController.inline = true
            pickerController.UIDelegate = CustomInlineLayoutUIDelegate(imagePickerController: pickerController)
            pickerController.assetType = .allPhotos
            pickerController.sourceType = .photo
            
            destination.pickerController = pickerController
            
        default:
            assert(false)
        }
    }
}
