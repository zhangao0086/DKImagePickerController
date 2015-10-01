//
//  ViewController.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 14-10-1.
//  Copyright (c) 2014年 ZhangAo. All rights reserved.
//

import UIKit
import MediaPlayer

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
    
    func showImagePickerWithAssetType(assetType: DKImagePickerControllerAssetType,
        allowMultipleType: Bool = true,
        sourceType: DKImagePickerControllerSourceType = [.Camera, .Photo]) {
            
            let pickerController = DKImagePickerController()
            pickerController.assetType = assetType
            pickerController.allowMultipleTypes = allowMultipleType
            pickerController.sourceType = sourceType
            
            pickerController.didCancel = {
                print("didCancel")
            }
            
            pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
                print("didSelectAssets")
                print(assets.map({ $0.url}))
                
                self.assets = assets
                self.previewView?.reloadData()
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
            ["Pick All", "Pick photos only", "Pick videos only"],
            ["Pick All (only photos or videos)"],
            ["Take a picture"],
            ["Hides camera"]
        ]
        static let types: [DKImagePickerControllerAssetType] = [.allAssets, .allPhotos, .allVideos]
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
        let allowMultipleType = indexPath.section == 0
        let sourceType: DKImagePickerControllerSourceType = indexPath.section == 2 ? .Camera :
            (indexPath.section == 3 ? .Photo : [.Camera, .Photo])
        
        showImagePickerWithAssetType(assetType,
            allowMultipleType: allowMultipleType,
            sourceType: sourceType)
    }
    
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let asset = self.assets![indexPath.row]
        
        if asset.isVideo {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellVideo", forIndexPath: indexPath) 
            
            let imageView = cell.contentView.viewWithTag(1) as! UIImageView
            imageView.image = asset.thumbnailImage
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellImage", forIndexPath: indexPath) 
            
            let imageView = cell.contentView.viewWithTag(1) as! UIImageView
            imageView.image = asset.thumbnailImage
            
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let asset = self.assets![indexPath.row]

        playVideo(asset.url!)
    }
}

