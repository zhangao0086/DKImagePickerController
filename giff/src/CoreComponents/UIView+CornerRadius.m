//
// Created by BLACKGENE on 2014. 9. 2..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import "UIView+CornerRadius.h"


@implementation UIView (CornerRadius)

- (void)setCornerRadiusAsMask:(CGFloat)radius{
    if(radius==0.0){
        self.layer.mask = nil;
    }else{
        [self setCornerRadiusAsMask:YES topRight:YES bottomLeft:YES bottomRight:YES radius:radius];
    }
}

-(UIView *)setCornerRadiusAsMask:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius {
    if (tl || tr || bl || br) {
        UIRectCorner corner = 0;
        if (tl) {
            corner = corner | UIRectCornerTopLeft;
        }
        if (tr) {
            corner = corner | UIRectCornerTopRight;
        }
        if (bl) {
            corner = corner | UIRectCornerBottomLeft;
        }
        if (br) {
            corner = corner | UIRectCornerBottomRight;
        }

        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;

        return self;

    } else {
        return self;
    }

}
@end