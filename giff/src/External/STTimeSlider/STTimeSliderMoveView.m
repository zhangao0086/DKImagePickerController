//
//  STTimeSliderMoveView.m
//  STTimeSliderExample
//
//  Created by Sebastien Thiebaud on 4/19/13.
//  Copyright (c) 2013 Sebastien Thiebaud. All rights reserved.
//

#import "STTimeSliderMoveView.h"
#import "STTimeSlider.h"

@implementation STTimeSliderMoveView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAutoresizesSubviews:NO];
        [self setAutoresizingMask:UIViewAutoresizingNone];
        [self setContentMode:UIViewContentModeTopLeft];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    [_delegate.strokeColorForeground setStroke];
    [_movePath setLineWidth:_delegate.strokeSizeForeground];
    [_movePath stroke];
    [_movePath addClip];
    CGContextDrawLinearGradient(context, _delegate.gradientForeground, _startPoint, _endPoint, 0);
    CGContextRestoreGState(context);
}

@end
