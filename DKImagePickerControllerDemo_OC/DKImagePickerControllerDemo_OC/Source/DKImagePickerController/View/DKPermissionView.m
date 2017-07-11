//
//  DKPermissionView.m
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/7/5.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKPermissionView.h"
#import "DKImageResource.h"

@interface DKPermissionView()
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIButton * permitButton;
@end

@implementation DKPermissionView
- (instancetype)init{
    if (self = [super init]) {
        _titleLabel = [UILabel new];
        _permitButton = [UIButton new];
    }
    return self;
}

+ (instancetype)permissionView:(DKImagePickerControllerSourceType)style{
    DKPermissionView * permissionView = [DKPermissionView  new];
    [permissionView addSubview:permissionView.titleLabel];
    [permissionView addSubview:permissionView.permitButton];
    if (style == DKImagePickerControllerSourcePhotoType) {
        permissionView.titleLabel.text = [DKImageLocalizedString localizedStringForKey:@"permissionPhoto"];
        permissionView.titleLabel.textColor = [UIColor grayColor];
    }else{
        permissionView.titleLabel.textColor = [UIColor whiteColor];
        permissionView.titleLabel.text = [DKImageLocalizedString localizedStringForKey:@"permissionCamera"];
    }
    
    [permissionView.titleLabel sizeToFit];
    
    [permissionView.permitButton setTitle:[DKImageLocalizedString localizedStringForKey:@"permit"] forState:UIControlStateNormal];
    
    [permissionView.permitButton setTitleColor:[UIColor colorWithRed:0 green:122/255 blue:1 alpha:1] forState:UIControlStateNormal];
    [permissionView.permitButton addTarget:permissionView action:@selector(gotoSettings) forControlEvents:UIControlEventTouchUpInside];
    permissionView.permitButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [permissionView.permitButton sizeToFit];
    permissionView.permitButton.center = CGPointMake(permissionView.titleLabel.center.x, permissionView.titleLabel.bounds.size.height + 40);
    permissionView.frame = CGRectMake(0, 0, MAX(permissionView.titleLabel.bounds.size.width, permissionView.permitButton.bounds.size.width), CGRectGetMaxY(permissionView.permitButton.frame));
    return permissionView;
    
}

- (void)didMoveToWindow{
    [super didMoveToWindow];
    self.center = self.superview.center;
}
- (void)gotoSettings{
   NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:url];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
