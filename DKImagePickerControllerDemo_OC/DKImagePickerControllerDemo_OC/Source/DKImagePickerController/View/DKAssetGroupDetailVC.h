//
//  DKAssetGroupDetailVC.h
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/27.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UICollectionView (DKExtension)
- (NSArray <NSIndexPath *>*)indexPathsForElementsInRect:(CGRect)rect
                                            hidesCamera:(BOOL)hidesCamera;
@end

@class DKImagePickerController;
@interface DKAssetGroupDetailVC : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, weak) DKImagePickerController * imagePickerController;
@end
