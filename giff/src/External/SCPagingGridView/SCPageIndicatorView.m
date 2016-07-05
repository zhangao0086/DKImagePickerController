//
//  Created by Jesse Andersen on 11/1/12.
//  Copyright (c) 2012 Scribd. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "SCPageIndicatorView.h"

@interface SCPageIndicatorView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UIView *filledView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, assign) CGSize dotSizeWithPadding;

@end

@implementation SCPageIndicatorView {
    NSInteger _lastDispatchedPage;
    BOOL _panningActivated;
}

@synthesize numberOfPages = _numberOfPages;
@synthesize currentPage = _currentPage;
@synthesize pageIndicatorDelegate = _pageIndicatorDelegate;

+ (UIImage *)emptyImageWithColor:(UIColor *)color size:(CGSize)size padding:(CGFloat)padding lineWidth:(CGFloat)lineWidth {
    CGFloat x = ceilf(lineWidth/2.0f);
    CGFloat y = ceilf(lineWidth/2.0f);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width + padding, size.height), NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, lineWidth);
    [color setStroke];
    CGContextAddPath(context, [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x, y, size.width - (x*2.0f), size.height - (y*2.0f))].CGPath);
    CGContextStrokePath(context);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

+ (UIImage *)filledImageWithColor:(UIColor *)color size:(CGSize)size padding:(CGFloat)padding {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width + padding, size.height), NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextAddPath(context, [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)].CGPath);
    CGContextFillPath(context);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _dotSize = CGSizeMake(10.0f, 10.0f);
        _dotColor = [UIColor whiteColor];
        _dotPadding = 3.0f;
        _dotLineWidth = 1.0f;
//        self.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
                
        _emptyView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_emptyView];
        
        _filledView = [[UIView alloc] init];
        [_emptyView addSubview:_filledView];
        
        // gesture recognizers
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTap:)];
        _tapGesture.delegate = self;
        [self addGestureRecognizer:_tapGesture];
        
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePan:)];
        _panGesture.delegate = self;
        [self addGestureRecognizer:_panGesture];
        
        [self _updateDotSizes];
    }
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    CGSize size = CGSizeMake(self.dotSizeWithPadding.width * self.numberOfPages, _dotSize.height);
    CGPoint origin = CGPointMake(10.0f, floorf((self.bounds.size.height - size.height)/2.0f));
    self.emptyView.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
        
    if (self.panGesture.state != UIGestureRecognizerStateBegan && self.panGesture.state != UIGestureRecognizerStateChanged) {
        [self _placeCurrentPageIndicator:NO];
    }
}

- (void)setNumberOfPages:(NSUInteger)numberOfPages {
    if (numberOfPages != _numberOfPages) {
        _numberOfPages = numberOfPages;
        self.emptyView.hidden = _numberOfPages <= 1;
        [self setNeedsLayout];
    }
}

- (void)setCurrentPage:(NSUInteger)currentPage {
    if (currentPage != _currentPage) {
        _currentPage = currentPage;
        if (self.panGesture.state != UIGestureRecognizerStateBegan && self.panGesture.state != UIGestureRecognizerStateChanged) {
            [self _placeCurrentPageIndicator:YES];
        }
    }
}

- (void)_placeCurrentPageIndicator:(BOOL)animate {
    [UIView animateWithDuration:animate ? 0.3f : 0.0f animations:^{
        self.filledView.frame = CGRectMake(self.currentPage * self.dotSizeWithPadding.width, 0.0f, self.dotSizeWithPadding.width, _dotSize.height);
    }];
}

#pragma mark - Dot Config

- (void)setDotColor:(UIColor *)dotColor {
    if (dotColor != _dotColor) {
        _dotColor = dotColor;
        [self _updateDotImages];
    }
}

- (void)setDotSize:(CGSize)dotSize {
    if (!CGSizeEqualToSize(dotSize, _dotSize)) {
        _dotSize = dotSize;
        [self _updateDotSizes];
    }
}

- (void)setDotPadding:(CGFloat)dotPadding {
    if (dotPadding != _dotPadding) {
        _dotPadding = dotPadding;
        [self _updateDotSizes];
    }
}

- (void)setDotLineWidth:(CGFloat)dotLineWidth {
    if (dotLineWidth != _dotLineWidth) {
        _dotLineWidth = dotLineWidth;
        [self _updateDotImages];
    }
}

#pragma mark - Dot Images

- (UIImage *)createEmptyImage {
    return [[self class] emptyImageWithColor:self.dotColor size:self.dotSize padding:self.dotPadding lineWidth:self.dotLineWidth];
}

- (UIImage *)createFilledImage {
    return [[self class] filledImageWithColor:self.dotColor size:self.dotSize padding:self.dotPadding];
}

- (void)_updateDotSizes {
    self.dotSizeWithPadding = CGSizeMake(self.dotSize.width + self.dotPadding, self.dotSize.height);
    CGRect rect = self.filledView.frame;
    rect.size = self.dotSizeWithPadding;
    self.filledView.frame = rect;
    
    [self _updateDotImages];
    [self setNeedsLayout];
}

- (void)_updateDotImages {
    _emptyView.backgroundColor = [UIColor colorWithPatternImage:[self createEmptyImage]];
    _filledView.backgroundColor = [UIColor colorWithPatternImage:[self createFilledImage]];
}

#pragma mark - Gesture Wrecka Nizers

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return [self _validateGestureLocation:gestureRecognizer];
    }
    return YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

- (void)_handleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized && [self.pageIndicatorDelegate respondsToSelector:@selector(requestPageChangeTo:panning:)]) {
        CGPoint loc = [gestureRecognizer locationInView:self.emptyView];
        NSUInteger page = floorf(loc.x / self.dotSizeWithPadding.width);
        self.currentPage = page;
        [self.pageIndicatorDelegate requestPageChangeTo:page panning:NO];
    }
}

- (void)_handlePan:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _lastDispatchedPage = -1;
        _panningActivated = [self _validateGestureLocation:gestureRecognizer];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged && [self.pageIndicatorDelegate respondsToSelector:@selector(requestPageChangeTo:panning:)]) {
        if (!_panningActivated && [self _validateGestureLocation:gestureRecognizer]) {
            _panningActivated = YES;
        }
        if (_panningActivated) {
            CGPoint loc = [gestureRecognizer locationInView:self.emptyView];
            loc.x -= floorf(self.dotSizeWithPadding.width/2.0f);
            if (loc.x < 0.0f) {
                loc.x = 0.0f;
            } else if (loc.x > self.emptyView.bounds.size.width - self.dotSizeWithPadding.width) {
                loc.x = self.emptyView.bounds.size.width - self.dotSizeWithPadding.width;
            }
            NSInteger page = floorf(loc.x / self.dotSizeWithPadding.width);
            if (page >= 0 && page < self.numberOfPages) {
                CGRect frame = self.filledView.frame;
                frame.origin.x = loc.x;
                self.filledView.frame = frame;
                if (page != _lastDispatchedPage) {
                    _lastDispatchedPage = page;
                    _currentPage = page;
                    [self.pageIndicatorDelegate requestPageChangeTo:page panning:YES];
                }
            }
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self _placeCurrentPageIndicator:YES];
    }
}

#pragma mark - Validation

- (BOOL)_validateGestureLocation:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint loc = [gestureRecognizer locationInView:self.emptyView];
    loc.y = 0.0f;
    return [self.emptyView pointInside:loc withEvent:nil];
}

@end
