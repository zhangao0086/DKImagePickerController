//
// Created by BLACKGENE on 2014. 12. 18..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "STApp.h"
#import "STStandardUI.h"

@class UIColor;

@protocol STStandardColor <NSObject>
- (UIColor *)backgroundColor;

- (UIColor *)foregroundColor;

- (UIColor *)shadowColor;

- (UIColor *)buttonColorBackgroundOverlay;

- (UIColor *)pointColor;

- (UIColor *)pointColorDarken;

- (UIColor *)pointColorLighten;

- (UIColor *)bookmarkColor;

- (UIColor *)vibrancyColorFront;

- (UIColor *)vibrancyColorBack;

- (UIColor *)buttonColorBack;

- (UIColor *)buttonColorForegroundAssistance;

- (UIColor *)buttonColorFrontSecondary;

- (UIColor *)buttonColorBackSecondary;

- (UIColor *)buttonColorBackgroundAssistance;

- (UIColor *)buttonColorFront;

- (UIColor *)strokeColorProgressBackground;

- (NSArray *)colorCollection;

- (UIColor *)strokeColorProgressFront;

- (UIColor *)strokeColorPoint;

- (UIColor *)negativeColor;

- (UIColor *)positiveColor;

- (UIColor *)defaultFilterRepresentationColor;

- (UIColor *)iOSSystemCameraHighlightColor;

- (UIColor *)blankBackgroundColor;

- (UIColor *)blankObjectColor;

- (UIColor *)vibrancyBackgroundLighten;

- (UIColor *)textColorDarken;

- (UIColor *)textColorLighten;
@end

@interface STStandardUI : NSObject

+ (void)registerColorScheme:(id <STStandardColor>)scheme;

#pragma mark Color
+ (UIColor *)colorAtCollectionByIndex:(NSUInteger)index or:(UIColor *)defaultColot;

+ (UIColor *)backgroundColor;

+ (UIColor *)foregroundColor;

+ (UIColor *)shadowColor;

+ (UIColor *)buttonColorBackgroundOverlay;

+ (UIColor *)pointColor;

+ (UIColor *)pointColorDarken;

+ (UIColor *)pointColorLighten;

+ (UIColor *)bookmarkColor;

+ (UIColor *)vibrancyColorFront;

+ (UIColor *)vibrancyColorBack;

+ (UIColor *)buttonColorBack;

+ (UIColor *)buttonColorForegroundAssistance;

+ (UIColor *)buttonColorFrontSecondary;

+ (UIColor *)buttonColorBackSecondary;

+ (UIColor *)buttonColorBackgroundAssistance;

+ (UIColor *)buttonColorFront;

+ (UIColor *)strokeColorProgressBackground;

+ (NSArray *)colorCollection;

+ (UIColor *)strokeColorProgressFront;

+ (UIColor *)strokeColorPoint;

+ (UIColor *)negativeColor;

+ (UIColor *)positiveColor;

+ (UIColor *)defaultFilterRepresentationColor;

+ (UIColor *)iOSSystemCameraHighlightColor;

+ (UIColor *)blankBackgroundColor;

+ (UIColor *)blankObjectColor;

+ (UIColor *)vibrancyBackgroundLighten;

+ (UIColor *)textColorDarken;

+ (UIColor *)textColorLighten;

#pragma mark Properties of UIView
+ (CGFloat)alphaForDimmingStrong;

+ (CGFloat)alphaForDimming;

+ (CGFloat)alphaForDimmingWeak;

+ (CGFloat)alphaForDimmingMoreWeak;

+ (CGFloat)alphaForDimmingGhostly;

+ (CGFloat)alphaForDimmingGlass;

+ (CGFloat)alphaForDimmingSelection;

+ (CGFloat)alphaForGlassLikeOverlayButtonBackground;

+ (CGFloat)alphaForStrongGlassLikeOverlayButtonBackground;

+ (CGFloat)scaleXYValueForBackward;

+ (UIFont *)defaultFontForHeadLabel;

+ (UIFont *)defaultFontForLabel;

+ (UIFont *)defaultFontForSubLabel;

+ (CGFloat)alphaForDimmingText;

+ (CALayer *)setDropShadowWithDarkBackground:(CALayer *)layer;

+ (CALayer *)setDropShadowBarely:(CALayer *)layer;

@end