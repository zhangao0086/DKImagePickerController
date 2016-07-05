//
// Created by BLACKGENE on 2015. 7. 1..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor (STUtil)
+ (UIColor *)colorIf:(UIColor *)color or:(UIColor *)defaultColor;

- (UIColor *)negative;
@end