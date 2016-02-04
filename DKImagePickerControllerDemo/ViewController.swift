//
//  ViewController.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 14-10-1.
//  Copyright (c) 2014年 ZhangAo. All rights reserved.
//

import UIKit
import MediaPlayer
import Photos

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    var player: MPMoviePlayerController?
    
    @IBOutlet var previewView: UICollectionView?
    var assets: [DKAsset]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showImagePickerWithAssetType(
		assetType: DKImagePickerControllerAssetType,
        allowMultipleType: Bool,
        sourceType: DKImagePickerControllerSourceType = [.Camera, .Photo],
		allowsLandscape: Bool,
		singleSelect: Bool,
        shouldDeselect: Bool) {
            
            let pickerController = DKImagePickerController()
            pickerController.assetType = assetType
			pickerController.allowsLandscape = allowsLandscape
			pickerController.allowMultipleTypes = allowMultipleType
			pickerController.sourceType = sourceType
			pickerController.singleSelect = singleSelect
//			pickerController.showsCancelButton = true
//			pickerController.showsEmptyAlbums = false
//			pickerController.defaultAssetGroup = PHAssetCollectionSubtype.SmartAlbumFavorites
			pickerController.defaultSelectedAssets = self.assets
            pickerController.shouldDeselectAssets = shouldDeselect
            
            pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
                print("didSelectAssets")
				
                self.assets = assets
                self.previewView?.reloadData()
            }
			
			if UI_USER_INTERFACE_IDIOM() == .Pad {
				pickerController.modalPresentationStyle = .FormSheet;
			}

            self.presentViewController(pickerController, animated: true) {}
    }
    
    func playVideo(videoURL: NSURL) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "exitPlayer:", name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
        
        let player = MPMoviePlayerController(contentURL: videoURL)
        player.movieSourceType = .File
        player.controlStyle = .Fullscreen
        player.fullscreen = true
        
        player.view.frame = view.bounds
        view.addSubview(player.view)
        
        player.prepareToPlay()
        player.play()
        
        self.player = player
    }
    
    func exitPlayer(notification: NSNotification) {
        let reason = (notification.userInfo!)[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as! NSNumber!
        if reason.integerValue == MPMovieFinishReason.UserExited.rawValue {
            NSNotificationCenter.defaultCenter().removeObserver(self)
            self.player?.view.removeFromSuperview()
            self.player = nil
        }
    }
    
    // MARK: - UITableViewDataSource, UITableViewDelegate methods
    
    struct Demo {
        static let titles = [
            ["Pick All", "Pick photos only", "Pick videos only", "Pick All (only photos or videos)", "Pick All (new selection each time)"],
            ["Take a picture"],
            ["Hides camera"],
			["Allows landscape"],
			["Single select"]
        ]
        static let types: [DKImagePickerControllerAssetType] = [.AllAssets, .AllPhotos, .AllVideos, .AllAssets, .AllAssets]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Demo.titles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Demo.titles[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        
        cell.textLabel?.text = Demo.titles[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
        let assetType = Demo.types[indexPath.row]
        let allowMultipleType = !(indexPath.row == 0 && indexPath.section == 3)
        let sourceType: DKImagePickerControllerSourceType = indexPath.section == 1 ? .Camera :
			(indexPath.section == 2 ? .Photo : [.Camera, .Photo])
		let allowsLandscape = indexPath.section == 3
		let singleSelect = indexPath.section == 4
		let shouldDeselect = indexPath.section == 0 && indexPath.row == 4

		showImagePickerWithAssetType(
			assetType,
			allowMultipleType: allowMultipleType,
			sourceType: sourceType,
			allowsLandscape: allowsLandscape,
			singleSelect: singleSelect,
            shouldDeselect: shouldDeselect
		)
	}
	
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let asset = self.assets![indexPath.row]
		var cell: UICollectionViewCell?
		var imageView: UIImageView?
		
        if asset.isVideo {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellVideo", forIndexPath: indexPath)
			imageView = cell?.contentView.viewWithTag(1) as? UIImageView
        } else {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellImage", forIndexPath: indexPath)
            imageView = cell?.contentView.viewWithTag(1) as? UIImageView
        }
		
		if let cell = cell, imageView = imageView {
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
	
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let asset = self.assets![indexPath.row]
		asset.fetchAVAssetWithCompleteBlock { (avAsset) in
			dispatch_async(dispatch_get_main_queue(), { () in
				self.playVideo(avAsset!.URL)
			})
		}
    }
}

