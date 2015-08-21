//
//  ViewController.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 14-10-1.
//  Copyright (c) 2014年 ZhangAo. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController {
    @IBOutlet var imageScrollView: UIScrollView!
    var player: MPMoviePlayerController?
    var videoURL: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showImagePicker() {
        
        let pickerController = DKImagePickerController()
        
        pickerController.didCancelled = { () in
            println("didCancelled")
        }
        
        pickerController.didSelectedAssets = { [unowned self] (assets: [DKAsset]) in
            println("didSelectedAssets")
            
            self.imageScrollView.subviews.map(){$0.removeFromSuperview()}

            var y: CGFloat = 0
            for (index, asset) in enumerate(assets) {
                if let lastView = self.imageScrollView.subviews.last as? UIView {
                    y += lastView.bounds.size.height
                }
                let image = asset.thumbnailImage!
                
                let imageView = UIImageView(image: image)
                imageView.contentMode = UIViewContentMode.ScaleAspectFit
                
                let imageWidth = min(image.size.width, self.imageScrollView.bounds.width)
                imageView.frame = CGRect(x: 0, y: y, width: imageWidth, height: imageWidth / image.size.width * image.size.height)
                self.imageScrollView.addSubview(imageView)
                
            }
            self.imageScrollView.contentSize.height = CGRectGetMaxY((self.imageScrollView.subviews.last as! UIView).frame)
        }
        
        self.presentViewController(pickerController, animated: true) {}
    }
    
    // 使用系统的播放器播放视频
    @IBAction func playVideo() {
        if let videoURL = self.videoURL {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "exitPlayer:", name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
            
            let player = MPMoviePlayerController(contentURL: videoURL)
            player.movieSourceType = MPMovieSourceType.File
            player.controlStyle = MPMovieControlStyle.Fullscreen
            player.fullscreen = true
            player.scalingMode = MPMovieScalingMode.Fill
            
            player.view.frame = view.bounds
            view.addSubview(player.view)
            
            player.prepareToPlay()
            player.play()

            self.player = player
        }
    }
    
    // 退出播放器
    func exitPlayer(notification: NSNotification) {
        let reason = (notification.userInfo!)[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as! NSNumber!
        if reason.integerValue == MPMovieFinishReason.UserExited.rawValue {
            NSNotificationCenter.defaultCenter().removeObserver(self)
            self.player?.view.removeFromSuperview()
            self.player = nil
        }
    }
    
}

