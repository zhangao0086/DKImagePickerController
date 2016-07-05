//
// Created by BLACKGENE on 2014. 9. 2..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (CornerRadius)
- (void)setCornerRadiusAsMask:(CGFloat)radius;

- (UIView *)setCornerRadiusAsMask:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius;
@end