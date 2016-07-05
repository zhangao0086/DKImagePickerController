//
//  STTimeSlider.h
//  STTimeSliderExample
//
//  Created by Sebastien Thiebaud on 4/1/13.
//  Copyright (c) 2013 Sebastien Thiebaud. All rights reserved.
//

typedef NS_ENUM(NSInteger, STTimeSliderMode) {
    STTimeSliderModeSolo,
    STTimeSliderModeMulti
};

#import <QuartzCore/QuartzCore.h>
#import "STTimeSliderMoveView.h"
#import "STUIView.h"

@class STTimeSlider;

@protocol STTimeSliderDelegate <NSObject>

@optional
- (void)timeSlider:(STTimeSlider *)timeSlider didSelectPointAtIndex:(int)index;
- (void)timeSlider:(STTimeSlider *)timeSlider didMoveToPointAtIndex:(int)index;

@end

@interface STTimeSlider : STUIView

@property (nonatomic, assign) float spaceBetweenPoints DEPRECATED_ATTRIBUTE;
@property (nonatomic, assign) float spaceBetweenPointsPortrait;
@property (nonatomic, assign) float spaceBetweenPointsLandscape;
@property (nonatomic, assign) float numberOfPoints;
@property (nonatomic, assign) float heightLine;
@property (nonatomic, assign) float radiusPoint;
@property (nonatomic, assign) CGSize shadowSize;
@property (nonatomic, assign) float shadowBlur;
@property (nonatomic, assign) float strokeSize;
@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic, retain) UIColor *shadowColor;
@property (nonatomic, assign) CGGradientRef gradient;
@property (nonatomic, assign) BOOL touchEnabled;
@property (nonatomic, assign, readonly) int currentIndex;
@property (nonatomic, assign) STTimeSliderMode mode;
@property (nonatomic, assign) int startIndex;
@property (nonatomic, assign) CGGradientRef gradientForeground;
@property (nonatomic, assign) float strokeSizeForeground;
@property (nonatomic, retain) UIColor *strokeColorForeground;
@property (nonatomic, assign) float radiusCircle;
@property (nonatomic, assign) id<STTimeSliderDelegate> delegate;

- (void)moveToIndex:(int)index;
- (CGPoint)positionForPointAtIndex:(int)index;

@end
