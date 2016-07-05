//
// Created by BLACKGENE on 2014. 12. 18..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <ChameleonFramework/UIColor+Chameleon.h>
#import "CALayer+STUtil.h"
#import "UIColor+BFPaperColors.h"
#import "NSArray+STUtil.h"
#import "UIColor+STUtil.h"


@implementation STStandardUI {

}

#pragma Pallete - Lib
// https://github.com/bennyguitar/Colours

#pragma Pallete - References
//http://tintui.com/ios.html
//https://color.adobe.com/ko/explore/newest/?time=all
//https://www.materialpalette.com
//http://www.materialui.co/colors
//https://github.com/sachin1092/awesome-material

#pragma mark Color

#define DEFINED_COLOR_OR(KeyName) [colorScheme respondsToSelector:@selector(KeyName)] && colorScheme.KeyName ? colorScheme.KeyName :

static id<STStandardColor> colorScheme;
+ (void)registerColorScheme:(id <STStandardColor>)scheme {
    colorScheme = scheme;
}

+ (UIColor *)colorAtCollectionByIndex:(NSUInteger)index or:(UIColor *)defaultColot{
    return [UIColor colorIf:[[self colorCollection] st_objectOrNilAtIndex:index] or:defaultColot];
}

+ (NSArray *)colorCollection{
    return DEFINED_COLOR_OR(colorCollection) @[
            [self pointColor],
            UIColorFromRGB(0x8BC34A),
            UIColorFromRGB(0xFF9800),
            UIColorFromRGB(0x227FBB),
            [self negativeColor],
            [self bookmarkColor]
    ];
}

+ (UIColor *)backgroundColor {
    return DEFINED_COLOR_OR(backgroundColor) [UIColor paperColorGray900];
}

+ (UIColor *)foregroundColor; {
    return DEFINED_COLOR_OR(foregroundColor) [UIColor paperColorGray300];
}

+ (UIColor *)shadowColor {
    return DEFINED_COLOR_OR(shadowColor) nil;
}

+ (UIColor *)pointColor{
    return DEFINED_COLOR_OR(pointColor) UIColorFromRGB(0xB073D8);
}

+ (UIColor *)pointColorDarken{
    return DEFINED_COLOR_OR(pointColorDarken) UIColorFromRGB(0x784997);
}

+ (UIColor *)pointColorLighten{
    return DEFINED_COLOR_OR(pointColorLighten) UIColorFromRGB(0xcd80ff);
}

+ (UIColor *)buttonColorFront; {
    return DEFINED_COLOR_OR(buttonColorFront) [UIColor paperColorGray200];
}

+ (UIColor *)buttonColorBack; {
    return DEFINED_COLOR_OR(buttonColorBack) UIColorFromRGB(0x2f2f2f);
}

+ (UIColor *)buttonColorBackgroundAssistance; {
    return DEFINED_COLOR_OR(buttonColorBackgroundAssistance) UIColorFromRGB(0x353535);
}

+ (UIColor *)buttonColorForegroundAssistance; {
    return DEFINED_COLOR_OR(buttonColorForegroundAssistance) [self pointColor];
}

+ (UIColor *)buttonColorFrontSecondary; {
    return DEFINED_COLOR_OR(buttonColorFrontSecondary) UIColorFromRGB(0x353535);
}

+ (UIColor *)buttonColorBackSecondary; {
    return DEFINED_COLOR_OR(buttonColorBackSecondary) [UIColor paperColorGray300];
}

+ (UIColor *)buttonColorBackgroundOverlay {
    return DEFINED_COLOR_OR(buttonColorBackgroundOverlay) [UIColor whiteColor];
}

+ (UIColor *)bookmarkColor{
    return DEFINED_COLOR_OR(bookmarkColor) UIColorFromRGB(0xFFCD00);
}

+ (UIColor *)vibrancyColorFront {
    return DEFINED_COLOR_OR(vibrancyColorFront) [UIColor whiteColor];
}

+ (UIColor *)vibrancyColorBack {
    return DEFINED_COLOR_OR(vibrancyColorBack) [UIColor blackColor];
}

+ (UIColor *)strokeColorPoint {
    return DEFINED_COLOR_OR(strokeColorPoint) [UIColor paperColorGray700];
}

+ (UIColor *)strokeColorProgressFront {
    return DEFINED_COLOR_OR(strokeColorProgressFront) [self pointColor];
}

+ (UIColor *)strokeColorProgressBackground {
    return DEFINED_COLOR_OR(strokeColorProgressBackground) [UIColor paperColorGray800];
}

+ (UIColor *)negativeColor; {
    return DEFINED_COLOR_OR(negativeColor) [UIColor flatRedColor];
}

+ (UIColor *)positiveColor; {
    return DEFINED_COLOR_OR(positiveColor) [self pointColor];
}

+ (UIColor *)defaultFilterRepresentationColor{
    return DEFINED_COLOR_OR(defaultFilterRepresentationColor) UIColorFromRGB(0x2E2E2E);
}

+ (UIColor *)iOSSystemCameraHighlightColor{
    return DEFINED_COLOR_OR(iOSSystemCameraHighlightColor) UIColorFromRGB(0xF7C501);
}

+ (UIColor *)blankBackgroundColor {
    return DEFINED_COLOR_OR(blankBackgroundColor) UIColorFromRGB(0x303030);
}

+ (UIColor *)blankObjectColor {
    return DEFINED_COLOR_OR(blankObjectColor) UIColorFromRGB(0x424242);
}

+ (UIColor *)vibrancyBackgroundLighten {
    return DEFINED_COLOR_OR(vibrancyBackgroundLighten) [[UIColor whiteColor] colorWithAlphaComponent:[self.class alphaForDimmingStrong]];
}

#pragma mark View Values
+ (CGFloat)alphaForDimmingStrong {
    return .96;
}

+ (CGFloat)alphaForDimming {
    return .8;
}

+ (CGFloat)alphaForDimmingWeak {
    return .5;
}

+ (CGFloat)alphaForDimmingMoreWeak {
    return .45;
}

+ (CGFloat)alphaForDimmingGhostly {
    return .25;
}

+ (CGFloat)alphaForDimmingGlass {
    return .15;
}

+ (CGFloat)alphaForDimmingSelection {
    return .9;
}

+ (CGFloat)alphaForGlassLikeOverlayButtonBackground {
    return .075;
}

+ (CGFloat)alphaForStrongGlassLikeOverlayButtonBackground {
    return .1;
}

+ (CGFloat)scaleXYValueForBackward {
    return .88;
}

#pragma mark Label/Text
+ (UIColor *)textColorDarken; {
    return DEFINED_COLOR_OR(textColorDarken) [UIColor blackColor];
}

+ (UIColor *)textColorLighten; {
    return DEFINED_COLOR_OR(textColorDarken) [UIColor whiteColor];
}

// http://iosfonts.com/
+ (UIFont *)defaultFontForHeadLabel{
    return [UIFont systemFontOfSize:15];
}

+ (UIFont *)defaultFontForLabel{
    switch ([STApp screenFamily]){
        case STScreenFamily55:
        case STScreenFamily47:
            return [UIFont systemFontOfSize:12];
        default:
            return [UIFont systemFontOfSize:11];
    }
}

+ (UIFont *)defaultFontForSubLabel{
    switch ([STApp screenFamily]){
        case STScreenFamily55:
        case STScreenFamily47:
            return [UIFont systemFontOfSize:10];
        default:
            return [UIFont systemFontOfSize:9];
    }
}

+ (CGFloat)alphaForDimmingText{
    return .55;
}

#pragma mark UIView Effects
+ (CALayer *)setDropShadowWithDarkBackground:(CALayer *)layer{
//    layer.masksToBounds = NO;
//    layer.cornerRadius = 8;
//    layer.shadowOffset = CGSizeMake(1.5, 1.5);
//    layer.shadowRadius = 2;
//    layer.shadowOpacity = 0.4;
//    layer.shadowPath = [[UIBezierPath bezierPathWithOvalInRect:layer.bounds] CGPath];
    return [layer setRasterize];
}

+ (CALayer *)setDropShadowBarely:(CALayer *)layer{
    layer.masksToBounds = NO;
    layer.cornerRadius = 8;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 2.5;
    layer.shadowOpacity = 0.2;
    return layer;
}
@end