//
//  DKAssetGroupDetailCameraCell.m
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/26.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKAssetGroupDetailCameraCell.h"
#import "DKImageResource.h"
@implementation DKAssetGroupDetailCameraCell

+ (NSString *)cellReuseIdentifier{
    return @"DKImageCameraIdentifier";
}

- (instancetype)initWithFrame:(CGRect)frame{
    if ( self = [super initWithFrame:frame]) {
        UIImageView * cameraImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        cameraImageView.contentMode = UIViewContentModeCenter;
        cameraImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cameraImageView.image = [DKImageResource cameraImage];
        
        [self.contentView addSubview:cameraImageView];
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
