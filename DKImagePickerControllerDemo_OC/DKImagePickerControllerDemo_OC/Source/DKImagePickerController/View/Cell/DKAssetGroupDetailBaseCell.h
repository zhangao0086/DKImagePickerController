//
//  DKAssetGroupDetailBaseCell.h
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/6/26.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DKAsset.h"

//@protocol DKAssetGroupCellItemProtocol <NSObject>
//@property (nonatomic, weak) DKAsset * asset;
//@property (nonatomic, assign) NSInteger index;
//@property (nonatomic, strong) UIImage * thumbnailImage;
//
//
//@end


@interface DKAssetGroupDetailBaseCell : UICollectionViewCell

@property (nonatomic, weak) DKAsset * asset;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIImage * thumbnailImage;

+ (NSString *)cellReuseIdentifier;



@end
