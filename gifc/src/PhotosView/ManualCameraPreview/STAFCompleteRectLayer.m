//
// Created by BLACKGENE on 15. 5. 12..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STAFCompleteRectLayer.h"
#import "CAShapeLayer+STUtil.h"


@implementation STAFCompleteRectLayer {

}

- (void)st_drawInContext:(CGContextRef)ctx; {
    UIColor* fillColor = [UIColor whiteColor];
    UIColor* strokeColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];

    CGFloat rectWidth = [STStandardLayout widthAFCompleteRectLayer];
    UIBezierPath* path  = [UIBezierPath bezierPathWithRoundedRect:CGRectMakeWithSize_AGK(CGSizeMakeValue(rectWidth)) cornerRadius:rectWidth/3.5f];
    [fillColor setFill];
    [path fill];

}

@end