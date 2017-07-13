//
//  CustomUIDelegate.m
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/7/7.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "CustomUIDelegate.h"
#import "CustomGroupDetailImageCell.h"
#import "CustomGroupDetailCameraCell.h"
@interface CustomUIDelegate()

@property (nonatomic, strong) UIToolbar * footer;

@end


@implementation CustomUIDelegate
- (UIToolbar *)footer{
    if (!_footer) {
        _footer = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
        _footer.translucent = NO;
        _footer.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], [[UIBarButtonItem alloc] initWithCustomView:[self createDoneButtonIfNeeded]]];
        [self updateDoneButtonTitle:[self createDoneButtonIfNeeded]];
    }
    return _footer;
}



- (UIButton *)createDoneButtonIfNeeded{
    if (!self.doneButton) {
        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.doneButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.doneButton setTitleColor:[UIColor colorWithRed:85/255 green:184/255 blue:44/255 alpha:1.0] forState:UIControlStateNormal];
        [self.doneButton setTitleColor:[UIColor colorWithRed:85/255 green:183/255 blue:44/255 alpha:0.4] forState:UIControlStateDisabled];
        [self.doneButton addTarget:self.imagePickerController action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    }
    return self.doneButton;
}

- (void)prepareLayout:(DKImagePickerController *)imagePickerController vc:(UIViewController *)vc{
    self.imagePickerController = imagePickerController;
}
- (void)imagePickerController:(DKImagePickerController *)imagePickerController showsCancelButtonForVC:(UIViewController *)vc{
    vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:imagePickerController action:@selector(dismiss)];
}
- (void)imagePickerController:(DKImagePickerController *)imagePickerController hidesCancelButtonForVC:(UIViewController *)vc    {
    vc.navigationItem.rightBarButtonItem = nil;
}
- (UIView *)imagePickerControllerFooterView:(DKImagePickerController *)imagePickerController{
    return self.footer;
}

- (void)updateDoneButtonTitle:(UIButton *)button{
    if (self.imagePickerController.selectedAssets.count > 0) {
        [button setTitle:[NSString stringWithFormat:@"Send(%lu)", (unsigned long)self.imagePickerController.selectedAssets.count] forState:UIControlStateNormal];
        button.enabled = YES;
    }else{
        [button setTitle:@"Send" forState:UIControlStateNormal];
        button.enabled = NO;
    }
    [button sizeToFit];
    
}

- (Class)imagePickerControllerCollectionCameraCell{
    return [CustomGroupDetailCameraCell class];
}

- (Class)imagePickerControllerCollectionImageCell{
    return [CustomGroupDetailImageCell class];
}


@end
