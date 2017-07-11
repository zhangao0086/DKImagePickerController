//
//  DKAssetGroupListVC.h
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/29.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface DKAssetGroupListVC : UITableViewController
@property (nonatomic, assign) PHAssetCollectionSubtype defaultAssetGroup;
@property (nonatomic, copy) void(^selectedGroupDidChangeBlock)(NSString * groupId);
- (instancetype)initWithSelectedGroupDidChangeBlock:(void(^)(NSString * groupId))selectedGroupDidChangeBlock
                                  defaultAssetGroup:(PHAssetCollectionSubtype)defaultAssetGroup;

- (void)loadGroups;
@end
