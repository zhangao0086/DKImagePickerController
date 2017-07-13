//
//  DKPopoverViewController.h
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/7/3.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DKPopoverViewController : UIViewController
+ (void)popoverViewController:(UIViewController *)viewController
                     fromView:(UIView *)fromView;
+ (void)dismissPopoverViewController;
@end
