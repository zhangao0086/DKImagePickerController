//
//  DKCameraResource.swift
//  DKCameraDemo
//
//  Created by Michal Tomaszewski on 15.03.2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import Foundation
import UIKit

public protocol DKCameraResource {
   
     func cameraCancelImage() -> UIImage
     func cameraFlashOnImage() -> UIImage
     func cameraFlashAutoImage() -> UIImage
     func cameraFlashOffImage() -> UIImage
     func cameraSwitchImage() -> UIImage
}
