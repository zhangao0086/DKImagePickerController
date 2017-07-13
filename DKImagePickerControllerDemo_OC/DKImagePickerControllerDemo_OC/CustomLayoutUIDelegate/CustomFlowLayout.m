//
//  CustomFlowLayout.m
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/7/10.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "CustomFlowLayout.h"

@implementation CustomFlowLayout
- (void)prepareLayout{
    [super prepareLayout];
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGFloat contentWidth = self.collectionView.bounds.size.width * 0.7;
    self.itemSize = CGSizeMake(contentWidth, contentWidth);
    
    self.minimumInteritemSpacing = 999;
    
}
@end
