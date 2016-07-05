//
//  CKRadialView.m
//  CKRadialMenu
//
//

#import "STRadialView.h"

@implementation STRadialView

- (void)setToDefault{
    _distanceFromCenter = self.boundsWidthHalf;

    self.autofitDistanceFromCenter = YES;
    self.autofitDegree = YES;
    self.startDegree = 0;
    self.totalDegreeForAllItems = 0;
    self.distanceCenterToCenterBetweenItems = 0;

    self.expandingItemViewsInterval = 0;
    self.expandingAnimationDuration = 0.4;
}

#pragma mark Values
- (void)setDistanceFromCenter:(CGFloat)distanceFromCenter; {
    _distanceFromCenter = distanceFromCenter;

    self.autofitDistanceFromCenter = NO;
}

- (void)setDegreeForEachItems:(CGFloat)degreeForEachItems; {
    _degreeForEachItems = degreeForEachItems;

    self.autofitDegree = NO;
}

- (void)setTotalDegreeForAllItems:(CGFloat)totalDegreeForAllItems; {
    NSParameterAssert(totalDegreeForAllItems>=0);

    _totalDegreeForAllItems = totalDegreeForAllItems;

    self.autofitDegree = NO;
}

- (CGAffineTransform)transformForItemViewAtIndex:(UIView *)itemView index:(NSInteger) index {
    CGFloat distanceCenterToCenterBetweenItems = self.distanceCenterToCenterBetweenItems ? self.distanceCenterToCenterBetweenItems : MIN([itemView boundsWidth], [itemView boundsHeight]);
    NSInteger count = self.count - self.viewsNotShowing.count;

    //autofit distance
    if(self.autofitDistanceFromCenter){
        CGFloat distanceFromCenter = self.boundsWidthHalf + (distanceCenterToCenterBetweenItems/2);
        _distanceFromCenter = distanceFromCenter + self.paddingForAutofitDistance;
    }

    //degree by autofit
    if(self.autofitDegree){
        //Angle in Radians = 2 * ASIN( (Chord Length) / (2 * Arc Radius))
        //Arc Length = Arc Radius * Angle in Radians
        _degreeForEachItems = AGKRadiansToDegrees((CGFloat)(2*asin( distanceCenterToCenterBetweenItems / (2*_distanceFromCenter) )));
        _degreeForEachItems += self.paddingForAutofitDegree;

    }else{
        //degree by total degree
        if(_totalDegreeForAllItems && count){
            _degreeForEachItems = _totalDegreeForAllItems / count;
        }
    }

    //transfrom X,Y
    CGFloat radian = AGKDegreesToRadians(self.startDegree + (_degreeForEachItems * index));
    CGFloat tX = (CGFloat) (_distanceFromCenter * sin(radian) * (self.directionToLeft ? -1 : 1));
    CGFloat tY = (CGFloat) (_distanceFromCenter * cos(radian) * (self.directionFromBottom ? 1 : -1));

    return CGAffineTransformMakeTranslation(tX, tY);
}

@end
