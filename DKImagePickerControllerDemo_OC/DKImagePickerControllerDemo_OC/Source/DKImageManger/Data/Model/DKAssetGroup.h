//
//  DKAssetGroup.h
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/6/26.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Photos/Photos.h>

@interface DKAssetGroup : NSObject
@property (nonatomic, copy) NSString * groupId;
@property (nonatomic, copy) NSString * groupName;
@property (nonatomic, assign) NSInteger totalCount;

@property (nonatomic, strong) PHAssetCollection * originalCollection;
@property (nonatomic, strong) PHFetchResult <PHAsset *> * fetchResult;
@end
