//
// Created by BLACKGENE on 2016. 4. 4..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STPhotoItem.h"

@interface STPhotoItem (UIAccessory)
- (UIImage *)iconImage;

- (UIImageView *)presentIcon:(UIView *)containerView;

- (void)unpresentIcon:(UIView *)containerView;

- (void)disposeIcon:(UIView *)containerView;
@end