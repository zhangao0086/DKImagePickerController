//
//  CustomGroupDetailCameraCell.m
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/7/10.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "CustomGroupDetailCameraCell.h"

@implementation CustomGroupDetailCameraCell
+ (NSString *)cellReuseIdentifier{
    return @"CustomGroupDetailCameraCell";
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame: frame]) {
        UILabel * cameraLabel = [[UILabel alloc] initWithFrame:frame];
        cameraLabel.text = @"Camera";
        cameraLabel.textAlignment = NSTextAlignmentCenter;
        cameraLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:cameraLabel];
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
