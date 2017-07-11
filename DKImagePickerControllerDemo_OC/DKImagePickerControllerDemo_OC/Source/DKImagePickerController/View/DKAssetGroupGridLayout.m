//
//  DKAssetGroupGridLayout.m
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/6/26.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKAssetGroupGridLayout.h"

@implementation DKAssetGroupGridLayout
- (void)prepareLayout{
    [super prepareLayout];
    CGFloat minItemWidth = 80.0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        minItemWidth = 100.0;
    }
    
    CGFloat interval  = 1.0;
    self.minimumInteritemSpacing = interval;
    self.minimumLineSpacing = interval;
    
    CGFloat contentWidth = self.collectionView.bounds.size.width;
    NSInteger itemCount =  floor(contentWidth / minItemWidth);
    CGFloat itemWidth = (contentWidth - (interval * (itemCount - 1))) / itemCount;
    CGFloat actualInterval =( contentWidth - itemCount * itemWidth ) / (itemCount - 1);
    
    itemWidth += actualInterval - interval;
    
    self.itemSize = CGSizeMake(itemWidth, itemWidth);
    
}
@end
