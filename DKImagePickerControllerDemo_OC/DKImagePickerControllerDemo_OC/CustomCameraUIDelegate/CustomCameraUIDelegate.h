//
//  CustomCameraUIDelegate.h
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/7/7.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKImagePickerControllerDefaultUIDelegate.h"

@interface CustomCameraUIDelegate : DKImagePickerControllerDefaultUIDelegate
- (UIViewController *)imagePickerControllerCreateCamera:(DKImagePickerController *)imagePickerController;
@end
