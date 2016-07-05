//
// Created by BLACKGENE on 15. 5. 6..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "M13ProgressViewBorderedCenterBar.h"

@interface M13ProgressViewBorderedBar()
@property (nonatomic, retain) CAShapeLayer *progressLayer;
- (void)drawProgress;
@end

@implementation M13ProgressViewBorderedCenterBar

- (void)drawProgress{
    CGFloat cornerRadius = self.cornerRadius;

    CGRect rect = CGRectInset(self.bounds, 2*self.borderWidth, 2*self.borderWidth);
    rect.origin.x = self.boundsWidthHalf - (rect.size.width / 2.0f);
    rect.size.width = self.boundsWidth * self.progress;

    rect = CGRectWithOriginMidX_AGK(rect, self.boundsWidthHalf);

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    [self.progressLayer setPath:path.CGPath];
}
@end