//
//  CustomCameraUIDelegate.m
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/7/7.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "CustomCameraUIDelegate.h"
#import "CustomCamera.h"
@implementation CustomCameraUIDelegate
- (UIViewController *)imagePickerControllerCreateCamera:(DKImagePickerController *)imagePickerController  {
    
    UIViewController * picker = [CustomCamera new];
    return picker;
}
@end
