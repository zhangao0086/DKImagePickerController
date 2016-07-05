//
//  STTimeSlider.m
//  STTimeSliderExample
//
//  Created by Sebastien Thiebaud on 4/1/13.
//  Copyright (c) 2013 Sebastien Thiebaud. All rights reserved.
//

#import "STTimeSlider.h"

@interface STTimeSlider ()

@property (strong) UIBezierPath *drawPath;
@property (strong) UIBezierPath *movePath;
@property (assign) CGContextRef context;
@property (strong) STTimeSliderMoveView *moveView;
@property (strong) NSMutableArray *positionPoints;

- (UIBezierPath *)backgroundPath;
- (UIBezierPath *)movingPath;

@end

@implementation STTimeSlider

#pragma mark - Init

- (void)defaultInitialization {
    [self setBackgroundColor:[UIColor clearColor]];
    [self setContentMode:UIViewContentModeRedraw];
    
    _spaceBetweenPointsPortrait = 40.0f;
    _spaceBetweenPointsLandscape = 40.0f;
    _numberOfPoints = 5.0;
    _heightLine = 10.0;
    _radiusPoint = 10.0;
    _shadowSize = CGSizeMake(2.0, 2.0);
    _shadowBlur = 2.0;
    _strokeSize = 1.0;
    _strokeColor = [UIColor blackColor];
    _shadowColor = [UIColor colorWithWhite:0.0 alpha:0.30];
    _radiusCircle = 2.0;
    _mode = STTimeSliderModeMulti;
    _startIndex = 0;
    _touchEnabled = YES;
    _currentIndex = 0;
    
    _strokeColorForeground = [UIColor colorWithWhite:0.3 alpha:1.0];
    _strokeSizeForeground = 1.0;
    
    _moveView = [[STTimeSliderMoveView alloc] initWithFrame:self.bounds];
    [_moveView setDelegate:self];
    [self addSubview:_moveView];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSArray *gradientColors = @[(id)[UIColor whiteColor].CGColor, (id)[UIColor colorWithWhite:0.793 alpha:1.000].CGColor];
    
    CGFloat gradientLocations[] = {0, 1};
    _gradientForeground = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    gradientColors = @[(id)[UIColor colorWithRed:0.571 green:0.120 blue:0.143 alpha:1.000].CGColor, (id)[UIColor colorWithRed:0.970 green:0.264 blue:0.370 alpha:1.000].CGColor];
    _gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    _positionPoints = [NSMutableArray array];
    
    CGColorSpaceRelease(colorSpace);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultInitialization];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultInitialization];
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    [_moveView setFrame:self.bounds];
    _context = UIGraphicsGetCurrentContext();
    
    CGRect timelineRect = CGRectMake(self.bounds.origin.x + _strokeSize, self.bounds.origin.y + _strokeSize, [self spaceBetweenPointsCurrent] * (_numberOfPoints + 1) + _radiusPoint * 2.0 * (_numberOfPoints + 2), _radiusPoint * 2.0);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(timelineRect), CGRectGetMinY(timelineRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(timelineRect), CGRectGetMaxY(timelineRect));

    _drawPath = [self backgroundPath];
    _movePath = [self movingPath];

    [_strokeColor setStroke];

    CGContextSaveGState(_context);
    CGContextSetShadowWithColor(_context, _shadowSize, _shadowBlur, _shadowColor.CGColor);
    [_drawPath setLineWidth:_strokeSize];
    [_drawPath fill];
    [_drawPath stroke];
    [_drawPath addClip];
    CGContextDrawLinearGradient(_context, _gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(_context);
    
    [_moveView setMovePath:_movePath];
    [_moveView setStartPoint:startPoint];
    [_moveView setEndPoint:endPoint];
    [_moveView setNeedsDisplay];
}

- (float)spaceBetweenPointsCurrent {
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (!UIInterfaceOrientationIsLandscape (interfaceOrientation))
        return _spaceBetweenPointsPortrait;
    return _spaceBetweenPointsLandscape;
}

- (float)spaceBetweenPoints {
    return [self spaceBetweenPointsCurrent];
}

- (UIBezierPath *)backgroundPath {
    [_positionPoints removeAllObjects];
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    float angle = _heightLine / 2.0 / _radiusPoint;
    float spaceBetweenPoints = [self spaceBetweenPointsCurrent];
    
    for (int i = 0; i < (_numberOfPoints - 2) * 2 + 2; i++) {
        int pointNbr = (i >= _numberOfPoints) ? (_numberOfPoints - 2) - (i - _numberOfPoints) : i;
        
        CGPoint centerPoint = CGPointMake(_radiusPoint + spaceBetweenPoints * pointNbr + _radiusPoint * 2.0 * pointNbr + _strokeSize, _radiusPoint + _strokeSize);
        
        if (i == 0) {
            [_positionPoints addObject:[NSValue valueWithCGPoint:centerPoint]];
            [path addArcWithCenter:centerPoint radius:_radiusPoint startAngle:angle endAngle:angle * -1.0 clockwise:YES];
            [path addLineToPoint:CGPointMake(centerPoint.x + _radiusPoint + spaceBetweenPoints, centerPoint.y - _heightLine / 2.0)];
        } else if (i == _numberOfPoints - 1) {
            [_positionPoints addObject:[NSValue valueWithCGPoint:centerPoint]];
            [path addArcWithCenter:centerPoint radius:_radiusPoint startAngle:M_PI + angle endAngle:M_PI - angle clockwise:YES];
            [path addLineToPoint:CGPointMake(centerPoint.x - _radiusPoint - spaceBetweenPoints - ((i == (_numberOfPoints - 2) * 2 + 1) ? (_radiusPoint * (1.0 - cosf(angle))) : 0 ), centerPoint.y + _heightLine / 2.0)];
        } else if (i < _numberOfPoints - 1) {
            [_positionPoints addObject:[NSValue valueWithCGPoint:centerPoint]];
            [path addArcWithCenter:centerPoint radius:_radiusPoint startAngle:M_PI + angle endAngle:angle * -1.0 clockwise:YES];
            [path addLineToPoint:CGPointMake(centerPoint.x + _radiusPoint + spaceBetweenPoints, centerPoint.y - _heightLine / 2.0)];
        } else if (i >= _numberOfPoints) {
            [_positionPoints addObject:[NSValue valueWithCGPoint:centerPoint]];
            [path addArcWithCenter:centerPoint radius:_radiusPoint startAngle:angle endAngle:M_PI - angle clockwise:YES];
            [path addLineToPoint:CGPointMake(centerPoint.x - _radiusPoint - spaceBetweenPoints - ((i == (_numberOfPoints - 2) * 2 + 1) ? (_radiusPoint * (1.0 - cosf(angle))) : 0 ), centerPoint.y + _heightLine / 2.0)];
        }
    }
            
    return path;
}

- (UIBezierPath *)movingPath {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    float heightLine = _heightLine - 4.0;
    float radiusPoint = _radiusPoint - 3.0;
    float angle = heightLine / 2.0 / radiusPoint;
    float spaceBetweenPoints = [self spaceBetweenPointsCurrent];
    
    if (_currentIndex == 0 || _mode == STTimeSliderModeSolo || _startIndex == _currentIndex) {
        CGPoint centerPoint = CGPointMake(_radiusPoint + ((_mode == STTimeSliderModeSolo) ? spaceBetweenPoints * _currentIndex + _radiusPoint * 2.0 * _currentIndex : 0) + 1.0, _radiusPoint + 1.0);
        
        if (_startIndex == _currentIndex)
            centerPoint = CGPointMake(_radiusPoint + spaceBetweenPoints * _startIndex + _radiusPoint * 2.0 * _startIndex + 1.0, _radiusPoint + 1.0);

        [path addArcWithCenter:centerPoint radius:radiusPoint startAngle:0.0 endAngle:M_PI * 2.0 clockwise:YES];
        [path addArcWithCenter:centerPoint radius:_radiusCircle startAngle:M_PI * 2.0 endAngle:0.0001 clockwise:NO];
    } else {
        for (int i = _startIndex; i <= _currentIndex; i++) {
            CGPoint centerPoint = CGPointMake(_radiusPoint + spaceBetweenPoints * i + _radiusPoint * 2.0 * i + 1.0, _radiusPoint + 1.0);
            
            if (i == _startIndex) {
                [path addArcWithCenter:centerPoint radius:radiusPoint startAngle:angle endAngle:angle * -1.0 clockwise:YES];
                
                CGPoint currentPoint = path.currentPoint;
                
                [path addArcWithCenter:centerPoint radius:_radiusCircle startAngle:angle * -1.0 - 0.0001 endAngle:angle * -1.0 clockwise:NO];
                [path addLineToPoint:currentPoint];
                [path addLineToPoint:CGPointMake(centerPoint.x + radiusPoint + spaceBetweenPoints, centerPoint.y - heightLine / 2.0)];
            } else if (i == _currentIndex) {
                [path addArcWithCenter:centerPoint radius:radiusPoint startAngle:M_PI + angle endAngle:M_PI - angle clockwise:YES];
                
                CGPoint currentPoint = path.currentPoint;

                [path addArcWithCenter:centerPoint radius:_radiusCircle startAngle:M_PI - angle - 0.0001 endAngle:M_PI - angle clockwise:NO];
                [path addLineToPoint:currentPoint];
                [path addLineToPoint:CGPointMake(centerPoint.x - radiusPoint - spaceBetweenPoints, centerPoint.y + heightLine / 2.0)];
            } else if (i < _currentIndex) {
                [path addArcWithCenter:centerPoint radius:radiusPoint startAngle:M_PI + angle endAngle:angle * -1.0 clockwise:YES];
                
                CGPoint currentPoint = path.currentPoint;
                
                [path addArcWithCenter:centerPoint radius:_radiusCircle startAngle:angle * -1.0 - 0.0001 endAngle:angle * -1.0 clockwise:NO];
                [path addLineToPoint:currentPoint];
                [path addLineToPoint:CGPointMake(centerPoint.x + radiusPoint + spaceBetweenPoints, centerPoint.y - heightLine / 2.0)];
            }
        }
        
        for (int i = _currentIndex - 1; i > _startIndex; i--) {
            CGPoint centerPoint = CGPointMake(_radiusPoint + spaceBetweenPoints * i + _radiusPoint * 2.0 * i + 1.0, _radiusPoint + 1.0);
            
            [path addArcWithCenter:centerPoint radius:radiusPoint startAngle:angle endAngle:M_PI - angle clockwise:YES];
            [path addLineToPoint:CGPointMake(centerPoint.x - radiusPoint - spaceBetweenPoints, centerPoint.y + heightLine / 2.0)];
        }
    }
    
    return path;    
}

#pragma mark - UIResponder

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (_touchEnabled) {
        CGPoint touchPoint = [[touches anyObject] locationInView:self];
        
        float x = touchPoint.x;
        x -= _strokeSize;
        
        for (int i = 0; i < [_positionPoints count]; i++) {
            CGPoint point = [[_positionPoints objectAtIndex:i] CGPointValue];
            
            if (fabs(point.x - x) <= _radiusPoint) {
                if ([_delegate respondsToSelector:@selector(timeSlider:didSelectPointAtIndex:)])
                    [_delegate timeSlider:self didSelectPointAtIndex:i];
                
                [self moveToIndex:i];
                return;
            }
        }
    }
}

#pragma mark - Move the index

- (void)moveToIndex:(int)index {
    if (index >= _startIndex || _mode == STTimeSliderModeSolo) {
        _currentIndex = index;

        _movePath = [self movingPath];
        [_moveView setMovePath:_movePath];
        [_moveView setNeedsDisplay];
        
        if ([_positionPoints count] > 0 && [_delegate respondsToSelector:@selector(timeSlider:didMoveToPointAtIndex:)])
            [_delegate timeSlider:self didMoveToPointAtIndex:_currentIndex];
    }
}

#pragma mark - Getters

- (CGPoint)positionForPointAtIndex:(int)index {
    return [[_positionPoints objectAtIndex:index] CGPointValue];
}

#pragma mark - Setters

- (void)setGradient:(CGGradientRef)gradient {
    _gradient = gradient;
    [self setNeedsDisplay];
}

- (void)setGradientForeground:(CGGradientRef)gradientForeground {
    _gradientForeground = gradientForeground;
    [self setNeedsDisplay];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    [self setNeedsDisplay];
}

- (void)setShadowColor:(UIColor *)shadowColor {
    _shadowColor = shadowColor;
    [self setNeedsDisplay];
}

- (void)setShadowSize:(CGSize)shadowSize {
    _shadowSize = shadowSize;
    [self setNeedsDisplay];
}

- (void)setShadowBlur:(float)shadowBlur {
    _shadowBlur = shadowBlur;
    [self setNeedsDisplay];
}

- (void)setStrokeSize:(float)strokeSize {
    _strokeSize = strokeSize;
    [self setNeedsDisplay];
}

- (void)setStrokeSizeForeground:(float)strokeSizeForeground {
    _strokeSizeForeground = strokeSizeForeground;
    [self setNeedsDisplay];
}

- (void)setRadiusPoint:(float)radiusPoint {
    if (_radiusCircle > radiusPoint - 4)
        radiusPoint = _radiusCircle + 4;
    
    _radiusPoint = radiusPoint;
    [self setNeedsDisplay];
}

- (void)setNumberOfPoints:(float)numberOfPoints {
    float minNumberOfPoints = (_currentIndex + 1) > 2 ? (_currentIndex + 1) : 2;
    
    if (numberOfPoints < minNumberOfPoints)
        _numberOfPoints = minNumberOfPoints;
    else
        _numberOfPoints = (int)numberOfPoints;
    
    [self setNeedsDisplay];
}

- (void)setHeightLine:(float)heightLine {
    if (heightLine > _radiusPoint * 2)
        heightLine = _radiusPoint * 2;
    
    _heightLine = heightLine;
    [self setNeedsDisplay];
}

- (void)setRadiusCircle:(float)radiusCircle {
    if (radiusCircle > _radiusPoint - 4)
        radiusCircle = _radiusPoint - 4;
    
    _radiusCircle = radiusCircle;
    [self setNeedsDisplay];
}

- (void)setSpaceBetweenPoints:(float)spaceBetweenPoints {
    _spaceBetweenPointsPortrait = spaceBetweenPoints;
    _spaceBetweenPointsLandscape = spaceBetweenPoints;
    [self setNeedsDisplay];
}

- (void)setSpaceBetweenPointsPortrait:(float)spaceBetweenPointsPortrait {
    _spaceBetweenPointsPortrait = spaceBetweenPointsPortrait;
    [self setNeedsDisplay];
}

- (void)setSpaceBetweenPointsLandscape:(float)spaceBetweenPointsLandscape {
    _spaceBetweenPointsLandscape = spaceBetweenPointsLandscape;
    [self setNeedsDisplay];
}

- (void)setMode:(STTimeSliderMode)mode {
    _mode = mode;
    
    if (_currentIndex < _startIndex)
        _startIndex = _currentIndex;
    
    [self setNeedsDisplay];
}

- (void)setStartIndex:(int)startIndex {
    if (startIndex <= _currentIndex) {
        _startIndex = startIndex;
        [self setNeedsDisplay];
    }
}

@end
