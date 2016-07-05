//
//  UIColor+LEColorPicker.h
//  LEColorPicker
//
//  Created by Luis Enrique Espinoza Severino on 03-12-12.
//  Copyright (c) 2012 Luis Espinoza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (YUVSpace)

+ (float) yComponentFromColor:(UIColor*)color;
+ (float) uComponentFromColor:(UIColor*)color;
+ (float) vComponentFromColor:(UIColor*)color;
+ (float) YUVSpaceDistanceToColor:(UIColor*)toColor fromColor:(UIColor*)fromColor;
+ (float) YUVSpaceSquareDistanceToColor:(UIColor *)toColor fromColor:(UIColor *)fromColor;

@end

