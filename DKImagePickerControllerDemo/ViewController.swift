//
//  ViewController.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 14-10-1.
//  Copyright (c) 2014年 ZhangAo. All rights reserved.
//

import UIKit
import Photos
import AVKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var previewView: UICollectionView?
    var assets: [DKAsset]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	func showImagePickerWithAssetType(_ assetType: DKImagePickerControllerAssetType,
	                                  allowMultipleType: Bool,
	                                  sourceType: DKImagePickerControllerSourceType = .both,
	                                  allowsLandscape: Bool,
	                                  singleSelect: Bool) {
		
		let pickerController = DKImagePickerController()
		
		// Custom camera
//		pickerController.UIDelegate = CustomUIDelegate()
//		pickerController.modalPresentationStyle = .OverCurrentContext
		
		pickerController.assetType = assetType
		pickerController.allowsLandscape = allowsLandscape
		pickerController.allowMultipleTypes = allowMultipleType
		pickerController.sourceType = sourceType
		pickerController.singleSelect = singleSelect
		
//		pickerController.showsCancelButton = true
//		pickerController.showsEmptyAlbums = false
//		pickerController.defaultAssetGroup = PHAssetCollectionSubtype.SmartAlbumFavorites
		
		// Clear all the selected assets if you used the picker controller as a single instance.
//		pickerController.defaultSelectedAssets = nil
		
		pickerController.defaultSelectedAssets = self.assets
		
		pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
			print("didSelectAssets")
			
			self.assets = assets
			self.previewView?.reloadData()
		}
		
		if UI_USER_INTERFACE_IDIOM() == .pad {
			pickerController.modalPresentationStyle = .formSheet
		}
		
		self.present(pickerController, animated: true) {}
	}
	
    func playVideo(_ asset: AVAsset) {
		let avPlayerItem = AVPlayerItem(asset: asset)
		
		let avPlayer = AVPlayer(playerItem: avPlayerItem)
		let player = AVPlayerViewController()
		player.player = avPlayer
		
        avPlayer.play()
		
		self.present(player, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource, UITableViewDelegate methods
    
    struct Demo {
        static let titles = [
            ["Pick All", "Pick photos only", "Pick videos only", "Pick All (only photos or videos)"],
            ["Take a picture"],
            ["Hides camera"],
			["Allows landscape"],
			["Single select"]
        ]
        static let types: [DKImagePickerControllerAssetType] = [.allAssets, .allPhotos, .allVideos, .allAssets]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Demo.titles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Demo.titles[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        
        cell.textLabel?.text = Demo.titles[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
        let assetType = Demo.types[indexPath.row]
        let allowMultipleType = !(indexPath.row == 0 && indexPath.section == 3)
        let sourceType: DKImagePickerControllerSourceType = indexPath.section == 1 ? .camera :
			(indexPath.section == 2 ? .photo : .both)
		let allowsLandscape = indexPath.section == 3
		let singleSelect = indexPath.section == 4
		
		showImagePickerWithAssetType(
			assetType,
			allowMultipleType: allowMultipleType,
			sourceType: sourceType,
			allowsLandscape: allowsLandscape,
			singleSelect: singleSelect
		)
	}
	
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = self.assets![indexPath.row]
		var cell: UICollectionViewCell?
		var imageView: UIImageView?
		
        if asset.isVideo {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellVideo", for: indexPath)
			imageView = cell?.contentView.viewWithTag(1) as? UIImageView
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellImage", for: indexPath)
            imageView = cell?.contentView.viewWithTag(1) as? UIImageView
        }
		
		if let cell = cell, let imageView = imageView {
			let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
			let tag = indexPath.row + 1
			cell.tag = tag
			asset.fetchImageWithSize(layout.itemSize.toPixel(), completeBlock: { image, info in
				if cell.tag == tag {
					imageView.image = image
				}
			})
		}
		
		return cell!
    }
	
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = self.assets![indexPath.row]
		asset.fetchAVAssetWithCompleteBlock { (avAsset, info) in
			DispatchQueue.main.async(execute: { () in
				self.playVideo(avAsset!)
			})
		}
    }
}

