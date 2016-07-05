//
//  CKRadialView.h
//  CKRadialMenu
//
//

#import <UIKit/UIKit.h>
#import "STExpandableView.h"

@interface STRadialView : STExpandableView
@property (nonatomic, assign) BOOL autofitDistanceFromCenter;
@property (nonatomic, assign) CGFloat paddingForAutofitDistance;

@property (nonatomic, assign) BOOL autofitDegree;
@property (nonatomic, assign) CGFloat paddingForAutofitDegree;

@property (nonatomic, assign) CGFloat distanceFromCenter;
@property (nonatomic, assign) CGFloat degreeForEachItems;

@property (nonatomic, assign) CGFloat startDegree;
@property (nonatomic, assign) CGFloat totalDegreeForAllItems;

@property (nonatomic, assign) BOOL directionToLeft;
@property (nonatomic, assign) BOOL directionFromBottom;
@end


