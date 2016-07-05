//
// Created by BLACKGENE on 15. 5. 21..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STStandardSimpleSlider.h"
#import "CAShapeLayer+STUtil.h"
#import "STStandardUX.h"
#import "UIView+STUtil.h"

@interface M13ProgressViewBorderedBar()
@property (nonatomic, retain) CAShapeLayer *progressLayer;
@property (nonatomic, retain) CALayer *progressSuperLayer;
@property (nonatomic, retain) CAShapeLayer *backgroundLayer;
- (void)drawProgress;
- (void)drawBackground;
- (void)setup;
@end

@implementation STStandardSimpleSlider {
    BOOL _activeState;
}

- (void)dealloc {
    self.iconViewOfMaximumSide = nil;
    self.iconViewOfMinimumSide = nil;
}

- (void)setup; {
    [super setup];
    self.borderWidth = 1;
    self.cornerType = M13ProgressViewBorderedBarCornerTypeCircle;
    self.cornerRadius = self.boundsHeightHalf;
    self.primaryColor = [UIColor whiteColor];
    self.secondaryColor = [UIColor whiteColor];
}

- (void)drawProgress; {
    CGFloat cornerRadius = self.cornerRadius;
    CGFloat paddingH = 2*self.borderWidth;
    CGRect bounds = CGRectInset(self.bounds, paddingH, paddingH);
    CGRect rect = bounds;
    rect.size.width = self.thumbWidth ? self.thumbWidth : (self.thumbWidth = (CGRectGetWidth(bounds) / 3));
    rect.origin.x = AGKRemap(self.progress, 0, 1, paddingH, CGRectGetMaxX(bounds)-rect.size.width+paddingH);
//    rect.origin.y = CGRectWithOriginMidX_AGK(rect, CGRectGetWidth(self.bounds)/2);

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];

    self.progressLayer.path = path.CGPath;
}

#define MARGIN_THUMB 3
- (void)drawBackground; {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

    if(_activeState && _shouldSwitchDisplayWhenActivated){
        self.backgroundLayer.fillColor = nil;
        self.backgroundLayer.lineWidth = self.borderWidth;
        [CATransaction commit];

        [super drawBackground];

    }else{
        self.backgroundLayer.lineWidth = 0;
        self.backgroundLayer.fillColor = self.backgroundLayer.strokeColor;

        CGFloat paddingH = 2*self.borderWidth;

        UIBezierPath *path = [UIBezierPath bezierPath];

        CGRect progressRect = [self.progressLayer pathBound];
        CGRect originalRect = CGRectInset(self.bounds, paddingH, self.boundsHeightHalf-1.5f);
        CGRect pathLeft = CGRectModified_AGK(originalRect, ^CGRect(CGRect rect) {
            rect.size.width = CLAMP(progressRect.origin.x-paddingH-MARGIN_THUMB, 0, originalRect.size.width-progressRect.size.width);
            return rect;
        });
        [path appendPath:[UIBezierPath bezierPathWithRoundedRect:pathLeft byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerTopLeft cornerRadii:CGSizeMakeValue(CGRectGetMidY(originalRect))]];

        CGRect pathRight = CGRectModified_AGK(originalRect, ^CGRect(CGRect rect) {
            rect.origin.x = CLAMP(CGRectGetMaxX(progressRect)+MARGIN_THUMB, progressRect.size.width+MARGIN_THUMB, CGRectGetMaxX(originalRect));
            CGFloat width = (CGRectGetMaxX(originalRect)-CGRectGetMaxX(progressRect)) - paddingH;
            rect.size.width = MAX(width, 0);
            return rect;
        });

        [path appendPath:[UIBezierPath bezierPathWithRoundedRect:pathRight byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMakeValue(CGRectGetMidY(originalRect))]];

        self.backgroundLayer.path = [path CGPath];
        [CATransaction commit];
    }
}

- (void)setNeedsActiveStateDisplay:(BOOL)active{
    _activeState = active;
    [self setNeedsDisplay];

    !self.whenChangeActiveState?:self.whenChangeActiveState(self, active);
}

- (void)setShouldSwitchDisplayWhenActivated:(BOOL)shouldSwitchDisplayWhenActivated {
    _shouldSwitchDisplayWhenActivated = shouldSwitchDisplayWhenActivated;
    [self setNeedsActiveStateDisplay:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;{
    NSAssert(!isnan(progress), @"invalid Float progress value");
    BOOL progressChange = self.progress != progress;
    Weaks

    [super setProgress:progress animated:animated];

    if(progressChange && !_activeState){
        [self setNeedsActiveStateDisplay:YES];
    }

    if(progressChange && _activeState){

        [STStandardUX resetAndRevertStateAfterShortDelay:@"hidden_stroke" block:^{
            [Wself setNeedsActiveStateDisplay:NO];
        }];
    }
}

#pragma mark Max/Min side Decoratable Views
- (void)setIconViewOfMinimumSide:(UIView *)iconViewOfMinimumSide {
    if(iconViewOfMinimumSide){
        if(![iconViewOfMinimumSide isEqual:_iconViewOfMinimumSide]){
            [self addSubview:iconViewOfMinimumSide];
            [iconViewOfMinimumSide centerToParentVertical];
            iconViewOfMinimumSide.right = -iconViewOfMinimumSide.width/3;
        }
    }else{
        [_iconViewOfMinimumSide clearAllOwnedImagesIfNeededAndRemoveFromSuperview:NO];
    }
    _iconViewOfMinimumSide = iconViewOfMinimumSide;
}

- (void)setIconViewOfMaximumSide:(UIView *)iconViewOfMaximumSide {
    if(iconViewOfMaximumSide){
        if(![iconViewOfMaximumSide isEqual:_iconViewOfMaximumSide]){
            [self addSubview:iconViewOfMaximumSide];
            [iconViewOfMaximumSide centerToParentVertical];
            iconViewOfMaximumSide.x = self.boundsWidth+iconViewOfMaximumSide.width/3;
        }
    }else{
        [_iconViewOfMaximumSide clearAllOwnedImagesIfNeededAndRemoveFromSuperview:NO];
    }
    _iconViewOfMaximumSide = iconViewOfMaximumSide;
}

@end
