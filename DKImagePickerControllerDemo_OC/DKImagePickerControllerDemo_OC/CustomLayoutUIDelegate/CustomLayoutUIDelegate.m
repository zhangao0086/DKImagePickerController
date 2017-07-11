//
//  CustomLayoutUIDelegate.m
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/7/10.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "CustomLayoutUIDelegate.h"
#import "CustomFlowLayout.h"
@implementation CustomLayoutUIDelegate
- (UICollectionViewLayout *)layoutForImagePickerController:(DKImagePickerController *)imagePickerController{
    return [CustomFlowLayout new];
}


@end
