//
//  CustomCamera.h
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/7/7.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "DKImagePickerController.h"
@interface CustomCamera : UIImagePickerController<DKImagePickerControllerCameraProtocol, UIImagePickerControllerDelegate    , UINavigationControllerDelegate>
@property (nonatomic, copy) void(^didCancel)();
@property (nonatomic, copy) void(^didFinishCapturingImage)(UIImage * image);
@property (nonatomic, copy) void(^didFinishCapturingVideo)(NSURL * videoURL);

@end
