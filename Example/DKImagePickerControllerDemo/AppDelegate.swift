//
//  AppDelegate.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 14-10-1.
//  Copyright (c) 2014年 ZhangAo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        print("temp path: \(NSTemporaryDirectory())")
        
        return true
    }

}
