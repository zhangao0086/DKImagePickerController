//
// Created by BLACKGENE on 15. 5. 11..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STViewFinderPointLayer.h"
#import "STAFCompleteRectLayer.h"
#import "CALayer+STUtil.h"
#import "STExposurePointLayer.h"


@implementation STViewFinderPointLayer {
    //focus
    STAFCompleteRectLayer * _completeRectLayer;
    STDrawableLayer *_outterCircle;
    STDrawableLayer *_outterCircleMask;
    BOOL _outterCircleOpened;
    BOOL _focusingStarted;
    BOOL _focusLocked;
    BOOL _fillOutterCircle;

    //exposure
    STExposurePointLayer * _exposureLayer;
    BOOL _exposureStarted;
}

- (instancetype)init; {
    self = [super init];
    if (self) {
        //Variables
        CGSize pointSize = CGSizeMakeValue([STStandardLayout widthFocusPointLayer]);
        CGRect pointRect = CGRectMakeWithSize_AGK(pointSize);
        CGFloat outterCircleStrokeWidth = pointSize.width/30;
        CGRect innerPointRect = CGRectInset(pointRect, outterCircleStrokeWidth, outterCircleStrokeWidth);

        //Center
        _completeRectLayer = [STAFCompleteRectLayer layerWithSize:CGSizeMakeValue([STStandardLayout widthAFCompleteRectLayer])];
        _completeRectLayer.hidden = YES;
        _completeRectLayer.position = self.boundsCenter;

        //Outter Circle
        Weaks
        _outterCircle = [STDrawableLayer layerWithSize:pointSize];
        _outterCircle.lineWidth = 0;
        _outterCircle.blockForDraw = ^(CGContextRef ctx) {
            Strongs
            UIBezierPath* path  = [UIBezierPath bezierPathWithRoundedRect:pointRect cornerRadius:pointRect.size.width / 2];
            [path appendPath:[UIBezierPath bezierPathWithRoundedRect:innerPointRect cornerRadius:innerPointRect.size.width / 2]];
            if(!Sself->_fillOutterCircle){
                path.usesEvenOddFillRule = YES;
            }
            [path fill];
        };
        _outterCircleMask = [STDrawableLayer layerWithSize:pointSize];
        _outterCircleMask.lineWidth = 0;
        _outterCircleMask.blockForDraw = ^(CGContextRef ctx) {
            Strongs
            CGRect divideRect = CGRectMakeWithSize_AGK(pointSize);
            CGFloat gapFromCenter = Sself->_outterCircleOpened ? 5 : 0;
            divideRect.size.height = (pointSize.height/2) - gapFromCenter;

            [[UIColor blackColor] setFill];

            [[UIBezierPath bezierPathWithRect:divideRect] fill];

            [[UIBezierPath bezierPathWithRect:CGRectModified_AGK(divideRect, ^CGRect(CGRect _rect) {
                _rect.origin.y = pointSize.height/2 + gapFromCenter;
                return _rect;
            })] fill];
        };

        _outterCircle.mask = _outterCircleMask;

        //Exposure Pointer
        _exposureLayer = [STExposurePointLayer layerWithSize:CGRectInset(innerPointRect, 1,1).size];
        _exposureLayer.fillColor = [[UIColor clearColor] CGColor];
        _exposureLayer.position = self.boundsCenter;

        [self addSublayer:_completeRectLayer];
        [self addSublayer:_outterCircle];
        [self addSublayer:_exposureLayer];

        [self finishFocusing];
        [self finishExposure];
    }
    return self;
}

- (void)st_drawInContext:(CGContextRef)ctx; {}

- (void)layoutSublayers; {
    [super layoutSublayers];
    _completeRectLayer.position = self.boundsCenter;
    _exposureLayer.position = self.boundsCenter;
}

#pragma mark Focus
- (void)startFocusing {
    if(_focusingStarted){
        return;
    }
    _focusingStarted = YES;

    [self activeOutterCircle];

    [self startPointer];

    [self setOutterCircleOpen:YES];
}

- (void)finishFocusing {
    _focusLocked = NO;

    [self _finishedFocusing];
}

- (void)finishFocusingWithLocked; {
    _focusLocked = YES;

    [self _finishedFocusing];
}

- (void)_finishedFocusing{
    if(!_focusingStarted){
        return;
    }
    _focusingStarted = NO;

    [self deactiveOutterCircle];

    [self stopPointer];

    [self setOutterCircleOpen:NO];
}

#pragma mark Accesary
- (void)setOutterCircleOpen:(BOOL)open{
    _outterCircleOpened = open;
    [_outterCircleMask setNeedsDisplay];
}

- (void)setOutterCicleFill:(BOOL)fill{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    if(fill){
        [self _finishedFocusing];
    }

    _fillOutterCircle = fill;
    [_outterCircle setNeedsDisplay];

    [CATransaction commit];
}

- (void)activeOutterCircle{
    _outterCircle.spring.scaleXYValue = 1;
}

- (void)deactiveOutterCircle{
    _outterCircle.spring.scaleXYValue = .6f;
}

- (void)startPointer{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    _completeRectLayer.hidden = NO;

    CAKeyframeAnimation *animateOpacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animateOpacity.values  = @[@0, @1];
    animateOpacity.duration = .15;
    animateOpacity.autoreverses = YES;
    animateOpacity.repeatCount = CGFLOAT_MAX;
    [_completeRectLayer addAnimation:animateOpacity forKey:@"opacity"];
    [CATransaction commit];
}

- (void)stopPointer{
    [CATransaction begin];
    [_completeRectLayer removeAllAnimations];
    _completeRectLayer.hidden = !_focusLocked;
    [CATransaction commit];
}

#pragma mark Exposure
- (void)startExposure{
    if(_exposureStarted){
        return;
    }
    _exposureStarted = YES;

    [_exposureLayer startExposure];

    [self activeOutterCircle];

    [self setOutterCircleOpen:NO];

    [self stopPointer];
}

- (void)finishExposure{
    _exposureStarted = NO;

    [_exposureLayer finishExposure];

    if(!_focusingStarted){
        [self deactiveOutterCircle];

        [self setOutterCircleOpen:NO];
    }
}

- (CGFloat)exposureIntensityValue; {
    return _exposureLayer.exposureIntensityValue;
}

- (void)setExposureIntensityValue:(CGFloat)exposureIntensityValue; {
    _exposureLayer.exposureIntensityValue = exposureIntensityValue;
}

@end