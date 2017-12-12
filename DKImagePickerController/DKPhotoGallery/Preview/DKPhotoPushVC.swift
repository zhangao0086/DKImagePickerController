//
//  DKPhotoPushVC.swift
//  DKPhotoGalleryDemo
//
//  Created by ZhangAo on 15/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit

class DKPhotoPushVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if let photoGallery = self.navigationController as? DKPhotoGallery {
            UIView.animate(withDuration: 0.1, animations: {
                photoGallery.statusBar?.alpha = 1
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if let photoGallery = self.navigationController as? DKPhotoGallery {
            UIView.animate(withDuration: 0.1, animations: {
                photoGallery.statusBar?.alpha = 0
            })
        }
    }
    
}
