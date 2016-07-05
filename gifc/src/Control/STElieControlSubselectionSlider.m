//
// Created by BLACKGENE on 2014. 9. 11..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import "STElieControlSubselectionSlider.h"


@implementation STElieControlSubselectionSlider {

}

- (id)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}


- (UIBezierPath *)backgroundPath; {
    return [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.bounds.size.width/2];
}

- (void)createContent; {
    [super createContent];

    CGRect thumbRect = ST_RS(50);
    CAShapeLayer *thumbLayer = [CAShapeLayer layer];
    thumbLayer.fillColor = self.tintColor.CGColor;
    thumbLayer.strokeColor = self.tintColor.CGColor;
    thumbLayer.lineWidth = 2;
    thumbLayer.opacity = 1.0;
    thumbLayer.shouldRasterize = YES;
    thumbLayer.rasterizationScale = [UIScreen mainScreen].scale;
    thumbLayer.path = [UIBezierPath bezierPathWithRoundedRect:thumbRect cornerRadius:thumbRect.size.width/2].CGPath;

//    self.thumbView.frame = thumbRect;

    [self.thumbView.layer addSublayer:thumbLayer];

    [self setNeedsDisplay];
}

@end