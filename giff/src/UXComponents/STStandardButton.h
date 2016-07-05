//
// Created by BLACKGENE on 2015. 3. 18..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "STCollectableView.h"

@class STStandardButton;
@class M13BadgeView;

typedef void(^STStandardButtonSelectedBlock)(STStandardButton * buttonSelf, NSInteger index, id value);
typedef void(^STStandardButtonSetButtonsBlock)(STStandardButton * buttonSelf, NSArray * imageNames, NSArray * colors);
typedef NS_ENUM(NSInteger, STStandardButtonStyle){
    STStandardButtonStylePBBP,
    //Normal-> Image:PrimaryColor / Background:BackgroundColor
    //Selected-> Image:BackgroundColor / Background:PrimaryColor

    STStandardButtonStylePTTP,
    //Normal-> Image:PrimaryColor / Background:Transparent
    //Selected-> Image:Transparent / Background:PrimaryColor

    STStandardButtonStylePTBP,
    //Normal-> Image:PrimaryColor / Background:Transparent
    //Selected-> Image:BackgroundColor / Background:PrimaryColor

    STStandardButtonStyleTPPB,
    //Normal-> Image:PrimaryColor / Background:BackgroundColor
    //Selected-> Image:Transparent / Background:PrimaryColor

    STStandardButtonStylePTBT,
    //Normal-> Image:PrimaryColor / Background:Transparent
    //Selected-> Image:BackgroundColor / Background:Transparent

    STStandardButtonStyleTBPB,
    //Normal-> Image:Transparent / Background:BackgroundColor
    //Selected-> Image:PrimaryColor / Background:BackgroundColor

    STStandardButtonStyleTBDPB,
    //Normal-> Image:Transparent / Background:BackgroundColor-Dimmed
    //Selected-> Image:PrimaryColor / Background:BackgroundColor

    STStandardButtonStyleTDPB,
    //Normal-> Image:Transparent / Background:WhiteColor-Dimmed
    //Selected-> Image:PrimaryColor / Background:BackgroundColor

    STStandardButtonStyleRawImage,
    //Raw Image, Normal and Selected are same.

    STStandardButtonStyleRawImageWithClipAsCircle,
    //Raw Image, Normal and Selected are same. + Crop as circle mask.

    STStandardButtonStyleSkipImage,
    //Normal-> Background:PrimaryColor
    //Selected-> Background:BackgroundColor

    STStandardButtonStyleSkipImageNormalDimmed,
    //Normal-> Background:PrimaryColor-Dimmed
    //Selected-> Background:BackgroundColor

    STStandardButtonStyleSkipImageSelectedDimmed,
    //Normal-> Background:PrimaryColor
    //Selected-> Background:BackgroundColor-Dimmed

    STStandardButtonStyleSkipImageInvert,
    //Ignore image + fill invert color only
    //Normal-> Background:BackgroundColor
    //Selected-> Background:PrimaryColor

    STStandardButtonStyleSkipImageInvertNormalDimmed,
    //Normal-> Background:BackgroundColor-Dimmed
    //Selected-> Background:PrimaryColor

    STStandardButtonStyleSkipImageInvertSelectedDimmed,
    //Normal-> Background:BackgroundColor
    //Selected-> Background:PrimaryColor-Dimmed

    STStandardButtonStyleDefault = STStandardButtonStylePBBP
};
typedef NS_ENUM(NSInteger, STStandardButtonRenderingMode){
    STStandardButtonRenderingModeDefault,
    STStandardButtonRenderingModeAddIntoUIVisualEffectView
};


@interface STStandardButton : STCollectableView
/*
 * State
 */
@property (nonatomic, assign) BOOL toggleEnabled;
@property (nonatomic, assign) BOOL selectedState;
/*
 * User Events
 */
@property (nonatomic, assign) BOOL denyDeselectWhenAlreadySelected;
@property (nonatomic, assign) BOOL denySelect;
@property (nonatomic, assign) BOOL expressDenied;
@property (nonatomic, assign) BOOL forceBubblingTapGesturesWhenSelected;
@property (nonatomic, assign) BOOL forceBubblingLongTapGesturesWhenSelected;
@property (nonatomic, assign) BOOL lockCurrentIndexAfterSelected;
@property (nonatomic, assign) BOOL allowSelectedStateFromTouchingOutside;
@property (copy) void (^blockForButtonDown)(STStandardButton *buttonSelf);
@property (copy) void (^blockForButtonUp)(STStandardButton *buttonSelf);
@property (nonatomic, readonly) UILongPressGestureRecognizer *gestureRecognizerForSelection;
/*
 * Views
 */
@property (nonatomic, assign) STStandardButtonRenderingMode renderingMode;
@property (nonatomic, readonly) NSArray *maskColors;
@property (nonatomic, readonly) NSArray *backgroundColors;
@property (nonatomic, readwrite, nullable) UIView * backgroundView;
@property (nonatomic, readwrite, nullable) UIColor *backgroundViewAsColoredImage; //assign very slow, render fast, FPS fast
@property (nonatomic, readwrite, nullable) UIColor *backgroundViewAsOwnBackgroundColorWithShapeMask; //assign fast, render very fast, FPS slow
@property (nonatomic, assign) BOOL animateBackgroundViewWhenStateChange;
@property (nonatomic, assign) BOOL backgroundViewAutoClear;
@property (nonatomic, readonly) STSelectableView *currentButtonView;
@property (nonatomic, readonly) NSArray *buttonViews;
@property (nonatomic, readonly) BOOL covered;
/*
 * Icon Image
 */
@property (nonatomic, readonly) STStandardButtonStyle style;
@property (nonatomic, assign) BOOL autoAdjustVectorIconImagePaddingIfNeeded;
@property (nonatomic, assign) CGFloat preferredIconImagePadding;
@property (nonatomic, assign) CGFloat preferredIconImageRotationDegree;
@property (nonatomic, readonly) NSArray *iconSourceImageNames;
@property (nonatomic, readonly) NSString *currentIconImageName;
@property (nonatomic, readonly) UIImage *currentIconImageNormal;
@property (nonatomic, readonly) UIImage *currentIconImageSelected;
/*
 * Badge
 */
@property (nonatomic, assign) BOOL badgeVisible;
@property (nonatomic, readwrite) NSString * badgeText;
@property (nonatomic, readwrite) UIImage * badgeImage;
@property (nonatomic, assign) BOOL badgeSmallPoint;
@property (nonatomic, readwrite) UIColor * badgeColor;
/*
 * Title Label
 */
@property (nonatomic, readwrite) NSString *titleText;
@property (nonatomic, readwrite) NSAttributedString *titleTextAsAttributedString;
@property (nonatomic, assign) CGFloat titleLabelWidth;
@property (nonatomic, assign) BOOL titleLabelWidthAutoFitToSuperview;
@property (nonatomic, assign) BOOL titleLabelAutoSetNumberOfLines;
@property (nonatomic, assign) CGFloat titleLabelPositionedGapFromButton;

@property (nonatomic, assign) BOOL subtitleLabelSyncWhenSelected;
@property (nonatomic, assign) BOOL subtitleVisibility;
@property (nonatomic, readwrite) NSString *subtitleText;
@property (nonatomic, readwrite) NSAttributedString *subtitleTextAsAttributedString;
@property (nonatomic, readwrite, nullable) NSArray *subtitleTexts;
@property (nonatomic, readonly) NSString *currentSelectedSubtitleText;
/*
 * Shadow
 */
@property (nonatomic, assign) BOOL shadowEnabled;
@property (nonatomic, assign) CGFloat shadowAlpha;
@property (nonatomic, assign) CGFloat shadowOffset;
/*
 * Spin Progress
 */
@property (nonatomic, readonly) BOOL spinProgressStarted;
@property (nonatomic, assign) BOOL keepSpinProgressViewAfterStop;
/*
 * Pie Progress
 */
@property (nonatomic, assign) CGFloat pieProgress;
@property (nonatomic, assign) BOOL pieProgressAnimationEnabled;
@property (nonatomic, readwrite, nullable) UIColor * pieProgressTintColor;
@property (nonatomic, assign) BOOL synchronizePieProgressWithSelectedState;
@property (nonatomic, assign) BOOL resetPieProgressAfterReached;

- (id)initWithFrame:(CGRect)frame buttons:(NSArray *)imageNames maskColors:(NSArray *)colors;

+ (instancetype)buttonWithSize:(CGSize)size;

+ (instancetype)mainSize;

+ (instancetype)mainSmallSize;

+ (instancetype)subSize;

+ (instancetype)subAssistanceBigSize;

+ (instancetype)subAssistanceSize;

+ (instancetype)subSmallSize;

+ (UIColor *)defaultBackgroundImageColor;

+ (UIColor *)defaultForegroundImageColor;

+ (STStandardButtonStyle)defaultButtonStyle;

+ (NSArray *)createButtonIcons:(CGSize)size inset:(CGFloat)inset imageName:(NSString *)imageName objectColor:(UIColor *)color backgroundColor:(UIColor *)backgroundColor style:(STStandardButtonStyle)style mode:(STStandardButtonRenderingMode)renderingMode useCache:(BOOL)useCache rotation:(CGFloat)degree;

- (instancetype)setButtonsAsDefault:(NSArray *)imageNames;

- (instancetype)setButtons:(NSArray *)imageNames style:(STStandardButtonStyle)style;

- (instancetype)setButtons:(NSArray *)imageNames colors:(NSArray *)colors;

- (instancetype)setButtons:(NSArray *)imageNames colors:(NSArray *)colors bgColors:(NSArray *)bgColors;

- (instancetype)setButtons:(NSArray *)imageNames colors:(NSArray *)colors style:(STStandardButtonStyle)style;

- (instancetype)setButtons:(NSArray *)imageNames colors:(NSArray *)colors blockForCreateBackgroundView:(UIView *(^)(void))block;

- (instancetype)setButtons:(NSArray *)imageNames colors:(NSArray *)colors style:(STStandardButtonStyle)style blockForCreateBackgroundView:(UIView *(^)(void))block;

- (instancetype)setButtons:(NSArray *)imageNames colors:(NSArray *)colors bgColors:(NSArray *)bgColors style:(STStandardButtonStyle)style;

- (instancetype)setButtons:(NSArray *)imageNames colors:(NSArray *)colors bgColors:(NSArray *)bgColors style:(STStandardButtonStyle)style blockForCreateBackgroundView:(UIView *(^)(void))block;

- (void)whenToggled:(void (^)(STStandardButton *selectedView, BOOL selected))block;

- (void)dispatchToggled;

/*
 * Cover Effect
 */
- (CGFloat)coverAnimationDefaultDuration;

- (void)coverWithBlur:(UIView *)coveringTargetView presentingTarget:(UIView *)view comletion:(void (^)(STStandardButton *button, BOOL covered))block;

- (void)coverWithBlur:(UIView *)coveringTargetView presentingTarget:(UIView *)view blurStyle:(UIBlurEffectStyle)blurStyle comletion:(void (^)(STStandardButton *button, BOOL covered))block;

- (void)uncoverWithBlur:(BOOL)animation comletion:(void (^)(STStandardButton *button, BOOL covered))block;

- (UIImageView *)coverAndUncoverBegin:(UIView *)coveringTargetView presentingTarget:(UIView *)view;

- (void)coverAndUncoverEnd:(UIView *)coveringTargetView presentingTarget:(UIView *)view beforeCoverView:(UIImageView *)before_coverView comletion:(void (^)(STStandardButton *button, BOOL covered))block;

/*
 * Activating Display
 */
- (void)startAlert;

- (void)startAlert:(NSUInteger)repeatCount;

- (void)stopAlert;

/*
 * Progress Display
 */
- (void)startSpinProgress;

- (void)startSpinProgress:(UIColor *)tintColor;

- (void)stopSpinProgress;
@end