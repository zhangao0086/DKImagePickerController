//
// Created by BLACKGENE on 15. 5. 12..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STExposurePointLayer.h"

@implementation STExposurePointLayer

- (instancetype)init; {
    self = [super init];
    if (self) {
        _exposureIntensityValue = 1;
    }
    return self;
}

- (void)startExposure; {
    self.hidden = NO;
    self.opacity = 1;
}

- (void)finishExposure; {
    self.opacity = 0;
    self.hidden = YES;
}

- (void)setExposureIntensityValue:(CGFloat)exposureIntensityValue; {
    _exposureIntensityValue = exposureIntensityValue;
    [self setNeedsDisplay];
}

- (void)st_drawInContext:(CGContextRef)ctx; {
    CGRect rect = CGRectMakeWithSize_AGK(self.boundsSize);
    UIBezierPath* path  = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:rect.size.width/2];

    CGFloat value = (rect.size.width/2.5f) * _exposureIntensityValue;//AGKRemapAndClamp(_exposureIntensityValue, 0, 1, .15f, 1);
    CGRect innerRect = CGRectInset(rect, value, value);
    [path appendPath:[UIBezierPath bezierPathWithRoundedRect:innerRect cornerRadius:innerRect.size.width/2]];
    path.usesEvenOddFillRule = YES;
    [path fill];
}

@end