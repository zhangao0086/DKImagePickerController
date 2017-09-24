//
//  DKImagePickerControllerDemoVC.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 03/01/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit

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
            
        case "Camera Customization":
            let pickerController = DKImagePickerController()
            pickerController.UIDelegate = CustomCameraUIDelegate()
            pickerController.modalPresentationStyle = .overCurrentContext
            
            destination.pickerController = pickerController
            
        case "UI Customization":
            let pickerController = DKImagePickerController()
            pickerController.sourceType = .photo
            pickerController.UIDelegate = CustomUIDelegate()
            pickerController.showsCancelButton = true
            
            destination.pickerController = pickerController
            
        case "Layout Customization":
            let pickerController = DKImagePickerController()
            pickerController.UIDelegate = CustomLayoutUIDelegate()
            
            destination.pickerController = pickerController
            
        case "Inline":
            let pickerController = DKImagePickerController()
            pickerController.inline = true
            pickerController.fetchLimit = 10
            pickerController.UIDelegate = CustomInlineLayoutUIDelegate()
            pickerController.assetType = .allPhotos
            pickerController.sourceType = .photo
            
            destination.pickerController = pickerController
            
        default:
            assert(false)
        }
    }
}
