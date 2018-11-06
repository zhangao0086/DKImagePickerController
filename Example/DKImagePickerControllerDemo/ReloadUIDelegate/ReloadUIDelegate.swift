//
//  ReloadUIDelegate.swift
//  DKImagePickerControllerDemo
//
//  Created by Ao Zhang on 2018/10/18.
//  Copyright © 2018 ZhangAo. All rights reserved.
//

import UIKit
import DKImagePickerController
import Photos

class ReloadUIDelegate: DKImagePickerControllerBaseUIDelegate {

    private var index = 0
    
    override func prepareLayout(_ imagePickerController: DKImagePickerController, vc: UIViewController) {
        super.prepareLayout(imagePickerController, vc: vc)
        
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reload",
                                                              style: .plain,
                                                              target: self,
                                                              action: #selector(switchDataManager))
    }
    
    override func imagePickerController(_ imagePickerController: DKImagePickerController, hidesCancelButtonForVC vc: UIViewController) {
        
    }
    
    @objc private func switchDataManager() {
        var assetGroupTypes: [PHAssetCollectionSubtype]!
        var predicate: NSPredicate!
        if self.index % 2 == 0 {
            assetGroupTypes = [.smartAlbumUserLibrary]
            predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        } else {
            assetGroupTypes = [.smartAlbumFavorites, .smartAlbumRecentlyAdded]
        }
        self.index += 1
        
        let groupDataManagerConfiguration = DKImageGroupDataManagerConfiguration()
        groupDataManagerConfiguration.assetGroupTypes = assetGroupTypes
        
        let assetFetchOptions = PHFetchOptions()
        assetFetchOptions.predicate = predicate
        groupDataManagerConfiguration.assetFetchOptions = assetFetchOptions
        
        let groupDataManager = DKImageGroupDataManager(configuration: groupDataManagerConfiguration)
        self.imagePickerController.reload(with: groupDataManager)
    }

}
