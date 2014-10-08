//
//  ViewController.swift
//  CustomImagePicker
//
//  Created by ZhangAo on 14-10-1.
//  Copyright (c) 2014年 ZhangAo. All rights reserved.
//

import UIKit
import MobileCoreServices
import MediaPlayer

class ViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, DKImagePickerControllerDelegate {
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
    
    // 使用系统的图片选取器
    func showSystemController() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        pickerController.mediaTypes = [kUTTypeImage!,kUTTypeMovie!]
        
        self.presentViewController(pickerController, animated: true) {}
    }
    
    // 使用自定义的图片选取器
    func showCustomController() {
        let pickerController = DKImagePickerController()
        pickerController.pickerDelegate = self
        self.presentViewController(pickerController, animated: true) {}
    }
    
    @IBAction func showImagePicker() {
//        showSystemController()
        showCustomController()
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
        let reason = (notification.userInfo!)[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as NSNumber!
        if reason.integerValue == MPMovieFinishReason.UserExited.toRaw() {
            NSNotificationCenter.defaultCenter().removeObserver(self)
            self.player?.view.removeFromSuperview()
            self.player = nil
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as NSString!
        println(mediaType)
        if mediaType.isEqualToString(kUTTypeImage.__conversion()) {
            let selectedImage = info[UIImagePickerControllerOriginalImage] as UIImage!
            imageScrollView.subviews.map(){$0.removeFromSuperview()}
            let imageView = UIImageView(image: selectedImage)
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            imageView.frame = imageScrollView.bounds
            imageScrollView.addSubview(imageView)
        } else {
            self.videoURL = info[UIImagePickerControllerMediaURL] as NSURL!
            let alert = UIAlertView(title: "选择的视频URL", message: videoURL!.absoluteString, delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - DKImagePickerControllerDelegate methods
    // 取消时的回调
    func imagePickerControllerCancelled() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // 选择图片并确定后的回调
    func imagePickerControllerDidSelectedAssets(assets: [DKAsset]!) {
        imageScrollView.subviews.map(){$0.removeFromSuperview}
        
        for (index, asset) in enumerate(assets) {
            let imageHeight: CGFloat = imageScrollView.bounds.height / 2
            
            let imageView = UIImageView(image: asset.thumbnailImage)
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            imageView.frame = CGRect(x: 0, y: CGFloat(index) * imageHeight, width: imageScrollView.bounds.width, height: imageHeight)
            imageScrollView.addSubview(imageView)
            
        }
        imageScrollView.contentSize.height = CGRectGetMaxY((imageScrollView.subviews.last as UIView).frame)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

