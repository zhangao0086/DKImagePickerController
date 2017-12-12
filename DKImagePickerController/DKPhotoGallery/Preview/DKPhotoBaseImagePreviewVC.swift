//
//  DKPhotoBaseImagePreviewVC.swift
//  DKPhotoGalleryDemo
//
//  Created by ZhangAo on 15/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary
import FLAnimatedImage

open class DKPhotoBaseImagePreviewVC: DKPhotoBasePreviewVC {

    // MARK: - QR Code
    
    private func detectStringFromImage() -> String? {
        guard let contentView = self.contentView as? DKPhotoImageView else { return nil }
        
        guard let targetImage = contentView.image ?? contentView.animatedImage?.posterImage else {
            return nil
        }
        
        if let result = self.detectStringFromCIImage(image: CIImage(image: targetImage)!) {
            return result
        } else {
            return nil
        }
    }
    
    private func detectStringFromCIImage(image: CIImage) -> String? {
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [
            CIDetectorAccuracy : CIDetectorAccuracyHigh
            ])
        
        if let detector = detector {
            let features = detector.features(in: image)
            if let feature = features.first as? CIQRCodeFeature {
                return feature.messageString
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func previewQRCode(with result: String) {
        if let URL = URL(string: result), let _ = URL.scheme, let _ = URL.host {
            let resultVC = DKPhotoWebVC()
            resultVC.urlString = result
            self.navigationController?.pushViewController(resultVC, animated: true)
        } else {
            let resultVC = DKPhotoQRCodeResultVC(result: result)
            self.navigationController?.pushViewController(resultVC, animated: true)
        }
    }
    
    // MARK: - Save Image
    
    private func saveImageToAlbum() {
        guard let contentView = self.contentView as? DKPhotoImageView else { return }
        
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    if let image = contentView.image {
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    } else if let animatedImage = contentView.animatedImage {
                        ALAssetsLibrary().writeImageData(toSavedPhotosAlbum: animatedImage.data, metadata: nil, completionBlock: { (newURL, error) in
                            DispatchQueue.main.async(execute: {
                                if let _ = error {
                                    self.showTips("图片保存失败")
                                } else {
                                    self.showTips("图片保存成功")
                                }
                            })
                        })
                    }
                case .restricted:
                    self.showTips("图片保存权限无法开启")
                case .denied:
                    self.showTips("获取图片保存权限失败")
                default:
                    break
                }
            }
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            self.showTips("图片保存成功")
        } else {
            self.showTips("图片保存失败")
        }
    }
    
    // MARK: - DKPhotoBasePreviewDataSource
    
    override public func createContentView() -> UIView {
        let contentView = DKPhotoImageView()
        return contentView
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        (self.contentView as! DKPhotoImageView).image = nil
        (self.contentView as! DKPhotoImageView).animatedImage = nil
    }
    
    override public func updateContentView(with content: Any) {
        guard let contentView = self.contentView as? DKPhotoImageView else { return }
        
        if let data = content as? Data {
            let imageFormat = NSData.sd_imageFormat(forImageData: data)
            if imageFormat == .GIF {
                contentView.animatedImage = FLAnimatedImage(gifData: data)
            } else {
                contentView.image = UIImage(data: data)
            }
        } else if let image = content as? UIImage {
            contentView.image = image
        } else {
            assertionFailure()
        }
    }
    
    public override func snapshotImage() -> UIImage? {
        if let contentView = self.contentView as? DKPhotoImageView {
            if let image = contentView.image {
                return image
            } else if contentView.animatedImage != nil {
                return contentView.currentFrame
            } else {
                return self.item.thumbnail
            }
        } else {
            return self.item.thumbnail
        }
    }
    
    public override func showError() {
        if self.item.thumbnail != nil { return }
        
        guard let contentView = self.contentView as? DKPhotoImageView else { return }
        
        contentView.image = DKPhotoGalleryResource.downloadFailedImage()
        contentView.contentMode = .center
    }
    
    public override func hidesError() {
        contentView.contentMode = .scaleAspectFit
    }
    
    override public func contentSize() -> CGSize {
        guard let contentView = self.contentView as? DKPhotoImageView else { return CGSize.zero }
        
        if let image = contentView.image {
            return image.size
        } else if let animatedImage = contentView.animatedImage {
            return animatedImage.size
        } else {
            return CGSize.zero
        }
    }
    
    @available(iOS 9.0, *)
    public override func defaultPreviewActions() -> [UIPreviewAction] {
        let saveActionItem = UIPreviewAction(title: "保存", style: .default) { (action, previewViewController) in
            self.saveImageToAlbum()
        }
        
        return [saveActionItem]
    }
    
    public override func defaultLongPressActions() -> [UIAlertAction] {
        var actions = [UIAlertAction]()
        
        if let QRCodeResult = self.detectStringFromImage() {
            let detectQRCodeAction = UIAlertAction(title: "识别图中二维码", style: .default, handler: { [weak self] (action) in
                self?.previewQRCode(with: QRCodeResult)
            })
            actions.append(detectQRCodeAction)
        }
        
        let saveImageAction = UIAlertAction(title: "保存图片", style: .default) { [weak self] (action) in
            self?.saveImageToAlbum()
        }
        actions.append(saveImageAction)
        
        return actions
        
    }
}
