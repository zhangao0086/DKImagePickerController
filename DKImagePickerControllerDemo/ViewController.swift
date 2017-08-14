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

    var pickerController: DKImagePickerController!
    
    @IBOutlet var previewView: UICollectionView?
    var assets: [DKAsset]?
    
	func showImagePicker() {
		pickerController.defaultSelectedAssets = self.assets
        
        pickerController.didCancel = { ()
            print("didCancel")
        }
        
		pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
			print("didSelectAssets")
			
			self.assets = assets
			self.previewView?.reloadData()
		}
		
		if UI_USER_INTERFACE_IDIOM() == .pad {
			pickerController.modalPresentationStyle = .formSheet
		}
		
        //turn on the swipe selection feature
        //self.pickerController.allowSwipeToSelect = true
		
        self.present(pickerController, animated: true) {
            //select a specific image via index
            //self.pickerController.selectImage(atIndexPath: IndexPath(item: 1, section: 0))
        }
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        
        cell.textLabel?.text = "Start"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
		
		showImagePicker()
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

