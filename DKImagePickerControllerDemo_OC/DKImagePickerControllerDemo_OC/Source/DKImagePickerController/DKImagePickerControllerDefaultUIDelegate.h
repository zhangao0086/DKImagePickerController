//
//  DKImagePickerControllerDefaultUIDelegate.h
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/26.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DKImagePickerController.h"
#import "DKCamera.h"
@interface DKImagePickerControllerDefaultUIDelegate : NSObject<DKImagePickerControllerUIDelegate>
@property (nonatomic, weak) DKImagePickerController * imagePickerController;
@property (nonatomic, strong) UIButton * doneButton;

- (UIButton *)createDoneButtonIfNeeded;
- (void)updateDoneButtonTitle:(UIButton *)button;
@end

@interface DKImagePickerControllerCamera : DKCamera<DKImagePickerControllerCameraProtocol>

@end
