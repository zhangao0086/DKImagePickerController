//
// Created by BLACKGENE on 2015. 7. 1..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <UIColor+BFPaperColors/UIColor+BFPaperColors.h>
#import "UIColor+STUtil.h"


@implementation UIColor (STUtil)

- (UIColor *) negative{
    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    return [UIColor colorWithRed:1-red green:1-green blue:1-blue alpha:alpha];
}

+ (UIColor *)colorIf:(UIColor *)color or:(UIColor *)defaultColor{
    return (color && ![color isEqual:[NSNull null]]) && ![UIColor isColorClear:color] ? color : defaultColor;
}
@end