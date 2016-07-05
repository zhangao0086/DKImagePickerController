//
// Created by BLACKGENE on 15. 5. 21..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STStandardPointableSlider.h"
#import "CAShapeLayer+STUtil.h"

@interface M13ProgressViewBorderedBar()
@property (nonatomic, retain) CAShapeLayer *progressLayer;
@property (nonatomic, retain) CALayer *progressSuperLayer;
@property (nonatomic, retain) CAShapeLayer *backgroundLayer;
- (void)drawProgress;
- (void)drawBackground;
- (void)setup;
@end

@interface STStandardSimpleSlider()
- (void)setNeedsActiveStateDisplay:(BOOL)active;
@end


@implementation STStandardPointableSlider {
    CAShapeLayer * _centerMaker;
}

- (void)setProgressOfPointer:(CGFloat)progressOfPointer {
    _progressOfPointer = progressOfPointer;
    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    _centerMaker.frameMinX = AGKRemap((self.layer.bounds.size.width-_centerMaker.pathSize.width/2)*progressOfPointer, 0, self.layer.bounds.size.width, self.thumbWidth/2,self.layer.bounds.size.width-self.thumbWidth/2);
    [CATransaction commit];
}

- (void)setup; {
    [super setup];

    _centerMaker = [CAShapeLayer circle:4];
    _centerMaker.positionY = -8;
    _centerMaker.hidden = NO;
    [self.layer addSublayer:_centerMaker];
}

- (void)setNeedsActiveStateDisplay:(BOOL)active{
    [super setNeedsActiveStateDisplay:active];
    _centerMaker.hidden = !active;
}

@end