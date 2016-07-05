//
// Created by BLACKGENE on 2016. 1. 8..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <UIKit/UIGestureRecognizerSubclass.h>
#import "UITouchLongPressGestureRecognizer.h"
#import "UIView+STUtil.h"

@implementation UITouchLongPressGestureRecognizer {

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self setProperties:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self setProperties:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self setProperties:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self setProperties:touches withEvent:event];
    [super touchesCancelled:touches withEvent:event];
}

- (void)setProperties:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _touch = touches.anyObject;
    _event = event;

    BOOL touchInside = CGPointLengthBetween(self.view.st_halfXY, [self locationInView:self.view]) <= self.view.width;
    if(_touchInside!=touchInside){
        [self willChangeValueForKey:@keypath(self.touchInside)];
        _touchInside = touchInside;
        [self didChangeValueForKey:@keypath(self.touchInside)];
    }
}

@end