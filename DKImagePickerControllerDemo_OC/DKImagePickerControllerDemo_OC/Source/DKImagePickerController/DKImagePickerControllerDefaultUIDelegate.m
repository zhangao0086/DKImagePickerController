//
//  DKImagePickerControllerDefaultUIDelegate.m
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/26.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKImagePickerControllerDefaultUIDelegate.h"
#import "DKAssetGroupGridLayout.h"
#import "DKImageResource.h"
#import "DKAssetGroupDetailCameraCell.h"
#import "DKAssetGroupDetailVideoCell.h"
#import "DKAssetGroupDetailImageCell.h"
#import "DKPermissionView.h"
@implementation DKImagePickerControllerDefaultUIDelegate
- (UIButton *)createDoneButtonIfNeeded{
    if (!self.doneButton) {
        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.doneButton setTitleColor:[UINavigationBar appearance].tintColor?:self.imagePickerController.navigationBar.tintColor forState:UIControlStateNormal];
        [self.doneButton addTarget:self.imagePickerController action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        [self updateDoneButtonTitle:self.doneButton];
    }
       return self.doneButton;
}

- (void)updateDoneButtonTitle:(UIButton *)button{
    if (self.imagePickerController.selectedAssets.count > 0) {
    [button setTitle:[NSString stringWithFormat:[DKImageLocalizedString localizedStringForKey:@"select"], self.imagePickerController.selectedAssets.count] forState:UIControlStateNormal];
    }else{
        [button setTitle:[DKImageLocalizedString localizedStringForKey:@"done"]forState:UIControlStateNormal];
    }
    [button sizeToFit];
}

#pragma mark -- DKImagePickerControllerUIDelegate
- (void)prepareLayout:(DKImagePickerController *)imagePickerController
                   vc:(UIViewController *)vc{
    self.imagePickerController = imagePickerController;
    vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self createDoneButtonIfNeeded]];
    
}

- (UICollectionViewLayout *)layoutForImagePickerController:(DKImagePickerController *)imagePickerController {
    return [DKAssetGroupGridLayout new];
}

- (void)imagePickerController:(DKImagePickerController *)imagePickerController
       showsCancelButtonForVC:(UIViewController *)vc{
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:imagePickerController action:@selector(dismiss)];
}
- (void)imagePickerController:(DKImagePickerController *)imagePickerController
       hidesCancelButtonForVC:(UIViewController *)vc{
    vc.navigationItem.leftBarButtonItem = nil;
}

- (void)imagePickerController:(DKImagePickerController *)imagePickerController
              didSelectAssets:(NSArray <DKAsset *> *)didSelectAssets{
    [self updateDoneButtonTitle:[self createDoneButtonIfNeeded]];
}
- (void)imagePickerController:(DKImagePickerController *)imagePickerController
            didDeselectAssets:(NSArray <DKAsset *> *)didDeselectAssets{
    [self updateDoneButtonTitle:[self createDoneButtonIfNeeded]];

}

- (void)imagePickerControllerDidReachMaxLimit:(DKImagePickerController *)imagePickerController{
    UIAlertController * alert = [UIAlertController  alertControllerWithTitle:[DKImageLocalizedString localizedStringForKey:@"maxLimitReached"] message:[NSString stringWithFormat:@"%@", [DKImageLocalizedString localizedStringForKey:@"maxLimitReachedMessage"]] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:[DKImageLocalizedString localizedStringForKey:@"ok"] style:UIAlertActionStyleCancel handler:nil]];
    [imagePickerController presentViewController:alert animated:YES completion:nil];
}


- (UIColor *)imagePickerControllerCollectionViewBackgroundColor {
    return [UIColor whiteColor];
}
- (UIView *)imagePickerControllerFooterView:(DKImagePickerController *)imagePickerController{
    return  nil;
}

- (UIViewController <DKImagePickerControllerCameraProtocol> *)imagePickerControllerCreateCamera:(DKImagePickerController *)imagePickerController{
    DKImagePickerControllerCamera  * camera = [DKImagePickerControllerCamera new];
    [self checkCameraPermission:camera];
    return camera;
}

- (void)checkCameraPermission:(DKCamera *)camera{
    [DKCamera checkCameraPermission:^(BOOL granted) {
        if (granted) {
            camera.cameraOverlayView = nil;
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
               DKPermissionView * permissionView = [DKPermissionView permissionView:DKImagePickerControllerSourceCameraType];
                camera.cameraOverlayView = permissionView;
            });
        }
    }];
}
- (Class)imagePickerControllerCollectionImageCell{
    return [DKAssetGroupDetailImageCell class];
}
- (Class)imagePickerControllerCollectionCameraCell{
    return [DKAssetGroupDetailCameraCell class];
}
- (Class)imagePickerControllerCollectionVideoCell{
    return [DKAssetGroupDetailVideoCell class];
}
//- (DKAssetGroupDetailBaseCell *)imagePickerControllerCollectionImageCellForCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath{
//    DKAssetGroupDetailBaseCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DKAssetGroupDetailImageCell cellReuseIdentifier] forIndexPath:indexPath];
////    if (!cell) {
////        <#statements#>
////    }
//}

@end


@implementation DKImagePickerControllerCamera

- (void)setDidCancel:(void(^)())block{
    super.didCancel = block;
}
- (void)setDidFinishCapturingImage:(void(^)(UIImage * image))block{
    super.didFinishCapturingImage = block;
}
- (void)setDidFinishCapturingVideo:(void(^)(NSURL * videoURL))videoURL{
    
}
@end
