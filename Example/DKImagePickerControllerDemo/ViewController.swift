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
import DKImagePickerController

class ViewController: UIViewController,
    UITableViewDataSource, UITableViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegate,
    DKImageAssetExporterObserver {

    var pickerController: DKImagePickerController!
    
    var exportManually = false
    
    @IBOutlet var previewView: UICollectionView?
    var assets: [DKAsset]?
    
    deinit {
        DKImagePickerControllerResource.customLocalizationBlock = nil
        DKImagePickerControllerResource.customImageBlock = nil
        
        DKImageExtensionController.unregisterExtension(for: .camera)
        DKImageExtensionController.unregisterExtension(for: .inlineCamera)
        
        DKImageAssetExporter.sharedInstance.remove(observer: self)
    }
    
	func showImagePicker() {
        if self.exportManually {
            DKImageAssetExporter.sharedInstance.add(observer: self)
        }
        
        if let assets = self.assets {
            pickerController.select(assets: assets)
        }
        
        pickerController.exportStatusChanged = { status in
            switch status {
            case .exporting:
                print("exporting")
            case .none:
                print("none")
            }
        }
        
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            self.updateAssets(assets: assets)
		}
		
		if UI_USER_INTERFACE_IDIOM() == .pad {
			pickerController.modalPresentationStyle = .formSheet
		}
		
        if pickerController.inline {
            self.showInlinePicker()
        } else {
            self.present(pickerController, animated: true) {}
        }
	}
    
    func updateAssets(assets: [DKAsset]) {
        print("didSelectAssets")
        
        self.assets = assets
        self.previewView?.reloadData()
        
        if pickerController.exportsWhenCompleted {
            for asset in assets {
                if let error = asset.error {
                    print("exporterDidEndExporting with error:\(error.localizedDescription)")
                } else {
                    print("exporterDidEndExporting:\(asset.localTemporaryPath!)")
                }
            }
        }
        
        if self.exportManually {
            DKImageAssetExporter.sharedInstance.exportAssetsAsynchronously(assets: assets, completion: nil)
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
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
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
	
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = self.assets![indexPath.row]
		var cell: UICollectionViewCell?
		var imageView: UIImageView?
        var maskView: UIView?
		
        if asset.type == .video {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellVideo", for: indexPath)
			imageView = cell?.contentView.viewWithTag(1) as? UIImageView
            maskView = cell?.contentView.viewWithTag(2)
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellImage", for: indexPath)
            imageView = cell?.contentView.viewWithTag(1) as? UIImageView
            maskView = cell?.contentView.viewWithTag(2)
        }
		
		if let cell = cell, let imageView = imageView {
			let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
			let tag = indexPath.row + 1
			cell.tag = tag
            asset.fetchImage(with: layout.itemSize.toPixel(), completeBlock: { image, info in
				if cell.tag == tag {
					imageView.image = image
				}
			})
		}
        
        maskView?.isHidden = !self.exportManually
		
		return cell!
    }
	
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = self.assets![indexPath.row]
		asset.fetchAVAsset { (avAsset, info) in
			DispatchQueue.main.async(execute: { () in
				self.playVideo(avAsset!)
			})
		}
    }
    
    // MARK: - Inline Mode
    
    func showInlinePicker() {
        let pickerView = self.pickerController.view!
        pickerView.frame = CGRect(x: 0, y: 170, width: self.view.bounds.width, height: 200)
        self.view.addSubview(pickerView)
        
        let doneButton = UIButton(type: .custom)
        doneButton.setTitleColor(UIColor.blue, for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        doneButton.frame = CGRect(x: 0, y: pickerView.frame.maxY, width: pickerView.bounds.width / 2, height: 50)
        self.view.addSubview(doneButton)
        self.pickerController.selectedChanged = { [unowned self] in
            self.updateDoneButtonTitle(doneButton)
        }
        self.updateDoneButtonTitle(doneButton)
        
        let albumButton = UIButton(type: .custom)
        albumButton.setTitleColor(UIColor.blue, for: .normal)
        albumButton.setTitle("Album", for: .normal)
        albumButton.addTarget(self, action: #selector(showAlbum), for: .touchUpInside)
        albumButton.frame = CGRect(x: doneButton.frame.maxX, y: doneButton.frame.minY, width: doneButton.bounds.width, height: doneButton.bounds.height)
        self.view.addSubview(albumButton)
    }
    
    func updateDoneButtonTitle(_ doneButton: UIButton) {
        doneButton.setTitle("Done(\(self.pickerController.selectedAssets.count))", for: .normal)
    }
    
    @objc func done() {
        self.updateAssets(assets: self.pickerController.selectedAssets)
    }
    
    @objc func showAlbum() {
        let pickerController = DKImagePickerController()
        pickerController.maxSelectableCount = self.pickerController.maxSelectableCount
        pickerController.select(assets: self.pickerController.selectedAssets)
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            self.updateAssets(assets: assets)
            self.pickerController.setSelectedAssets(assets: assets)
        }
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
    // MARK: - DKImageAssetExporterObserver
    
    func exporterWillBeginExporting(exporter: DKImageAssetExporter, asset: DKAsset) {
        if let index = self.assets?.firstIndex(of: asset) {
            if let cell = self.previewView?.cellForItem(at: IndexPath(item: index, section: 0)) {
                if let maskView = cell.contentView.viewWithTag(2) {
                    maskView.frame = CGRect(x: maskView.frame.minX,
                                            y: maskView.frame.minY,
                                            width: maskView.frame.width,
                                            height: maskView.frame.width)
                }
            }
        }
        
        print("exporterWillBeginExporting")
    }
    
    func exporterDidUpdateProgress(exporter: DKImageAssetExporter, asset: DKAsset) {
        if let index = self.assets?.firstIndex(of: asset) {
            if let cell = self.previewView?.cellForItem(at: IndexPath(item: index, section: 0)) {
                if let maskView = cell.contentView.viewWithTag(2) {
                    maskView.frame = CGRect(x: maskView.frame.minX,
                                            y: maskView.frame.minY,
                                            width: maskView.frame.width,
                                            height: maskView.frame.width * (1 - CGFloat(asset.progress)))
                }
            }
            
            print("exporterDidUpdateProgress with \(asset.progress)")
        }
    }
    
    func exporterDidEndExporting(exporter: DKImageAssetExporter, asset: DKAsset) {
        if let index = self.assets?.firstIndex(of: asset) {
            if let cell = self.previewView?.cellForItem(at: IndexPath(item: index, section: 0)) {
                if let maskView = cell.contentView.viewWithTag(2) {
                    maskView.isHidden = true
                }
            }
            
            if let error = asset.error {
                print("exporterDidEndExporting with error:\(error.localizedDescription)")
            } else {
                print("exporterDidEndExporting:\(asset.localTemporaryPath!)")
            }
        }
    }

}

