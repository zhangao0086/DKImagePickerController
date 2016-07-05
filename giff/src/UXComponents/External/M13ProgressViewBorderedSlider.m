//
// Created by BLACKGENE on 15. 5. 19..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "M13ProgressViewBorderedSlider.h"
#import "M13ProgressViewBorderedCenterBar.h"
#import "M13ProgressViewBorderedBar.h"


@interface M13ProgressViewBorderedBar()
@property (nonatomic, retain) CAShapeLayer *progressLayer;
- (void)drawProgress;
- (void)setup;
@end

@implementation M13ProgressViewBorderedSlider

- (void)drawProgress{
    CGFloat cornerRadius = self.cornerRadius;
    CGRect rect = CGRectInset(self.bounds, 2*self.borderWidth, 2*self.borderWidth);

    rect.size.width = self.thumbWidth ? self.thumbWidth : (self.boundsWidth / 3);
    rect = CGRectWithOriginMidX_AGK(rect, self.boundsWidthHalf);

    CGFloat boundsWidthDiff = self.boundsWidth-rect.size.width;

    if(boundsWidthDiff<=0){
        self.progressLayer.path = nil;
    }else{
        rect.origin.x = AGKRemap(self.progress, 0, 1, 0, boundsWidthDiff);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
        self.progressLayer.path = path.CGPath;
    }

}
@end