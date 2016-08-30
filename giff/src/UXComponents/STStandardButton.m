//
// Created by BLACKGENE on 2015. 3. 18..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <SVGKit/SVGKImage.h>
#import <Colours/Colours.h>
#import <BlocksKit/NSArray+BlocksKit.h>
#import <NYXImagesKit/UIImage+Rotating.h>
#import "STStandardButton.h"
#import "UIImage+STUtil.h"
#import "CALayer+STUtil.h"
#import "UIView+STUtil.h"
#import "CAShapeLayer+STUtil.h"
#import "NSString+STUtil.h"
#import "NSObject+STUtil.h"
#import "NSArray+STUtil.h"
#import "M13BadgeView.h"
#import "SVGKImage+STUtil.h"
#import "UIColor+STUtil.h"
#import "UIColor+BFPaperColors.h"
#import "TTTAttributedLabel.h"
#import "MMMaterialDesignSpinner.h"
#import "UIImageView+WebCache.h"
#import "NSNumber+STUtil.h"
#import "M13ProgressViewPie.h"

@implementation STStandardButton {
    void (^_whenToggled)(STStandardButton * button, BOOL selected);

    UIView * _coveredBoundView;
    UIView * _coveredTargetView;

    UIView * _badgeView;
    UIImageView * _badgeIconView;

    TTTAttributedLabel *_titleLabel;
    TTTAttributedLabel *_subTitleLabel;

    UIImageView * _shadowView;

    UIImageView * _tempCoverImageView;

    MMMaterialDesignSpinner * _spinnerView;

    M13ProgressViewPie * _pieProgressView;
}

#pragma mark UIView's
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoAdjustVectorIconImagePaddingIfNeeded = YES;

        _titleLabelPositionedGapFromButton = [STStandardLayout gapForButtonBottomToTitleLabel];
        _titleLabelAutoSetNumberOfLines = YES;

        _subtitleVisibility = YES;
        _subtitleLabelSyncWhenSelected = YES;

        _expressDenied = YES;

        _pieProgressAnimationEnabled = YES;
        _pieProgressTintColor = [STStandardUI pointColorLighten];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame buttons:(NSArray *)imageNames maskColors:(NSArray *)colors;{
    self = [self initWithFrame:frame];
    if (self) {
        [self setButtons:imageNames colors:colors];
    }
    return self;
}

- (void)dealloc {
    _whenToggled = nil;

    [self removeBadgeView];

    [self clearViews];
    oo([@"dealloc STStandardButton" st_add:self.identifier]);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutLabelIfNeeded];
}

#pragma mark STCollectableView's
- (void)setViews:(NSArray *)presentableObjects; {
    [self _performOnUncoverIfNeeded:^{
        [super setViews:presentableObjects];
    }];
}

- (void)clearViews; {
    if(_buttonViews){
        //remote urㅣ
        for(STSelectableView * view in _buttonViews){
            for(id indexobj in [@(view.count) st_intArray]){
                id object = [view presentableObjectAtIndex:(NSUInteger) [indexobj integerValue]];
                if([object isKindOfClass:UIImageView.class]){
                    [((UIImageView *) object) sd_cancelCurrentImageLoad];
                }
            }
        }

        [self clearUserSelectionInteraction];
        _buttonViews = nil;
    }

    if(self.backgroundViewAutoClear){
        self.backgroundView = nil;
    }

    [super clearViews];
}

- (void)setCurrentIndex:(NSUInteger)currentIndex; {
    super.currentIndex = currentIndex;
    [self updateIndexSelectedState];
}

#pragma mark Update by Selected state
- (void)updateIndexSelectedState {
    if(self.lastSelectedIndex!=self.currentIndex && self.buttonViews.count>1){
        //select button
        [self.buttonViews[self.lastSelectedIndex] setCurrentIndex:0];

        if(self.contentDidCreated){
            //backgroundview
//            _backgroundView.visible = self.currentIndex==0;

            //subtitle
            [self setNeedsSubtitleText];
        }
    }
}

#pragma mark Impl.
+ (instancetype)buttonWithSize:(CGSize)size {
    return [[self alloc] initWithSize:size];
}

+ (instancetype)mainSize {
    return [[self alloc] initWithFrame:[STStandardLayout rectMain]];
}

+ (instancetype)mainSmallSize {
    return [[self alloc] initWithFrame:[STStandardLayout rectMainSmall]];
}

+ (instancetype)subSize {
    return [[self alloc] initWithFrame:[STStandardLayout rectSub]];
}

+ (instancetype)subSmallSize {
    return [[self alloc] initWithFrame:[STStandardLayout rectSubSmall]];
}

+ (instancetype)subAssistanceBigSize {
    return [[self alloc] initWithSize:[STStandardLayout sizeSubAssistanceBig]];
}

+ (instancetype)subAssistanceSize {
    return [[self alloc] initWithFrame:[STStandardLayout rectSubAssistance]];
}

#pragma mark setButtons Core
+ (STStandardButtonStyle)defaultButtonStyle{
    return STStandardButtonStyleDefault;
}

- (instancetype)setButtonsAsDefault:(NSArray *)imageNames{
    return [self setButtons:imageNames colors:nil];
}

- (instancetype)setButtons:(NSArray *)imageNames style:(STStandardButtonStyle)style;{
    return [self setButtons:imageNames colors:nil style:style];
}

- (instancetype)setButtons:(NSArray *)imageNames colors:(NSArray *)colors {
    return [self setButtons:imageNames colors:colors bgColors:nil];
}

- (instancetype)setButtons:(NSArray *)imageNames colors:(NSArray *)colors bgColors:(NSArray *)bgColors{
    return [self setButtons:imageNames colors:colors bgColors:bgColors style:self.class.defaultButtonStyle blockForCreateBackgroundView:nil];
}

- (instancetype)setButtons:(NSArray *)imageNames colors:(NSArray *)colors bgColors:(NSArray *)bgColors style:(STStandardButtonStyle)style{
    return [self setButtons:imageNames colors:colors bgColors:bgColors style:style blockForCreateBackgroundView:nil];
}

- (instancetype)setButtons:(NSArray *)imageNames colors:(NSArray *)colors style:(STStandardButtonStyle)style; {
    return [self setButtons:imageNames colors:colors bgColors:[colors ? colors : @[@(0)] map:^id(id object) { return [self.class defaultBackgroundImageColor]; }] style:style blockForCreateBackgroundView:nil];
}

- (instancetype)setButtons:(NSArray *)imageNames colors:(NSArray *)colors blockForCreateBackgroundView:(UIView *(^)(void))block; {
    return [self setButtons:imageNames colors:colors bgColors:[colors ? colors : @[@(0)] map:^id(id object) { return [self.class defaultBackgroundImageColor]; }] style:self.class.defaultButtonStyle blockForCreateBackgroundView:block];
}

- (instancetype)setButtons:(NSArray *)imageNames colors:(NSArray *)colors style:(STStandardButtonStyle)style blockForCreateBackgroundView:(UIView *(^)(void))block; {
    return [self setButtons:imageNames colors:colors bgColors:[colors ? colors : @[@(0)] map:^id(id object) { return [self.class defaultBackgroundImageColor]; }] style:style blockForCreateBackgroundView:block];
}

- (instancetype)setButtons:(NSArray *)imageNames
                      colors:(NSArray *)colors
                    bgColors:(NSArray *)bgColors
                       style:(STStandardButtonStyle)style
blockForCreateBackgroundView:(UIView *(^)(void))block; {

    Weaks
    [self _performOnUncoverIfNeeded:^{
        [Wself _setButtons:imageNames colors:colors bgColors:bgColors style:style blockForCreateBackgroundView:block];
    }];
    return self;
}

- (void)_setButtons:(NSArray *)imageNames
             colors:(NSArray *)colors
           bgColors:(NSArray *)bgColors
              style:(STStandardButtonStyle)style
        blockForCreateBackgroundView:(UIView *(^)(void))block; {

    _iconSourceImageNames = imageNames;
    _maskColors = colors;
    _backgroundColors = bgColors;
    _style = style;

    NSArray * buttons = [imageNames ? imageNames : colors mapWithIndex:^id(id object, NSInteger index) {
        NSString * imageName = [imageNames st_objectOrNilAtIndex:index];

        UIColor * color = [colors st_objectOrNilAtIndex:index] ?: [self.class defaultForegroundImageColor];

        UIColor * bgColor = [bgColors st_objectOrNilAtIndex:index] ?: [self.class defaultBackgroundImageColor];

        CGSize size = self.fitIconImageSizeToCenterSquare ?
                CGSizeMakeValue(CGSizeMinSide(self.size)) : self.size;


        CGFloat inset = self.preferredIconImagePadding!=0 ?
                self.preferredIconImagePadding
                : ([imageName isEqualToFileExtension:@"svg"] && self.autoAdjustVectorIconImagePaddingIfNeeded ?
                        CGSizeMinSide(size)*STStandardLayout.insetRatioForAutoAdjustIconImagesPadding
                        : 0);

        /*
         * create resources
         */
        //TODO: wrap the content of "imageName (NSURL.absoluteString)" to STRasterizingImageSourceItem
        //TODO: absoluteString from URL -> relative path support
        NSArray * iconPresentableObjects = nil;
        if([imageName isGeneralURL]){
            //from url
            iconPresentableObjects = [self createButtonIconViewsFromURL:imageName
                                                                   size:size
                                                                  style:style];

        }else{
            //from bundle name
            //TODO: this should perform as serial async while create multiple icon images
            iconPresentableObjects = [self.class createButtonIcons:size
                                                             inset:inset
                                                         imageName:imageName
                                                       objectColor:color
                                                   backgroundColor:bgColor
                                                             style:style
                                                              mode:self.renderingMode
                                                          useCache:YES
                                                          rotation:self.preferredIconImageRotationDegree];
        }

        NSAssert(iconPresentableObjects, @"iconPresentableObjects is nil");
        STSelectableView *button = [[STSelectableView alloc] initWithFrame:self.bounds views:iconPresentableObjects];
        button.tagName = [@"STStandardButton_" st_add:imageName];
        return button;
    }];

    [self setViews:buttons];
    _buttonViews = buttons;
    [self setUserSelectionInteraction];
    !block?:[self setBackgroundView:block()];
    [self setNeedsShadowDisplay];
}

#pragma mark IconImage
//- (void)setPreferredIconImagePadding:(CGFloat)preferredIconImagePadding {
//    if(preferredIconImagePadding!=0){
//        NSAssert(self.count==0, @"setPreferredIconImagePadding must set before setButtons.");
//    }
//    _preferredIconImagePadding = preferredIconImagePadding;
//}
//
//- (void)setAutoAdjustVectorIconImagePaddingIfNeeded:(BOOL)autoAdjustVectorIconImagePaddingIfNeeded {
//    if(autoAdjustVectorIconImagePaddingIfNeeded){
//        NSAssert(self.count==0, @"setAutoAdjustVectorIconImagePaddingIfNeeded must set before setButtons.");
//    }
//    _autoAdjustVectorIconImagePaddingIfNeeded = autoAdjustVectorIconImagePaddingIfNeeded;
//}

+ (UIColor *)defaultBackgroundImageColor{
    return [[STStandardUI buttonColorBack] colorWithAlphaComponent:[STStandardUI alphaForDimmingStrong]];
}

+ (UIColor *)defaultForegroundImageColor{
    return [STStandardUI buttonColorFront];
}

#pragma mark create button image from URL
- (NSArray *)createButtonIconViewsFromURL:(NSString *)url
                                     size:(CGSize)size
                                    style:(STStandardButtonStyle)style{
    NSParameterAssert(!CGSizeEqualToSize(CGSizeZero,size));
#if DEBUG
    //warning
    if(![url matchedSchemeToURL:[NSSet setWithArray:@[@"https", @"http",@"file",@"assets-library"]]]){
        NSString * msg = [NSString stringWithFormat:@"[!]WARNING: %@ is not general remote url to fetch images", url];
        oo(msg);
    }
    if(self.autoAdjustVectorIconImagePaddingIfNeeded){
        NSLog(@"%@",@"[!]WARNING: self.autoAdjustVectorIconImagePaddingIfNeeded not allowed when type of image is URL");
    }
#endif

    UIImageView * iconImageViewByURL = [[UIImageView alloc] initWithSize:size];
    STStandardButtonStyle styleToAppy = self.style;
    switch(styleToAppy){
        case STStandardButtonStyleRawImageWithClipAsCenteredCircle:
        case STStandardButtonStyleRawImageWithClipAsCenteredRoundRect:{
            WeakAssign(iconImageViewByURL)
            //inset from self.preferredIconImagePadding
            CGRect destinationImageViewFrame = CGRectInset(CGRectMakeSize(size),self.preferredIconImagePadding,self.preferredIconImagePadding);
            [iconImageViewByURL sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                dispatch_queue_t processingqueue = dispatch_queue_create("com.stells.standardbutton.createroundmask", DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(processingqueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
                dispatch_async(processingqueue, ^{
                    CGFloat originalImageScale = image.scale;
                    //reset scale for processing image
                    UIImage * resultImage = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationUp];
                    //centered crop
                    BOOL needToCrop = resultImage.size.width != resultImage.size.height;
                    resultImage = needToCrop ? [resultImage imageByCroppingAspectFillRatio:CGSizeMakeValue(1)] : image;
                    //clip
                    switch(styleToAppy){
                        case STStandardButtonStyleRawImageWithClipAsCenteredCircle:
                            resultImage = [resultImage clipAsCenteredCircle];
                            break;
                        case STStandardButtonStyleRawImageWithClipAsCenteredRoundRect:
                            resultImage = [resultImage clipAsRoundedRect:resultImage.size cornerRadius:resultImage.size.width/6];
                            break;
                        default:
                            NSAssert(NO, @"Doesn't support for currently given STStandardButtonStyle");
                            break;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(weak_iconImageViewByURL){
                            weak_iconImageViewByURL.contentMode = UIViewContentModeScaleAspectFill;
                            //restore original scale
                            weak_iconImageViewByURL.image = [UIImage imageWithCGImage:resultImage.CGImage scale:originalImageScale orientation:UIImageOrientationUp];
                            weak_iconImageViewByURL.frame = destinationImageViewFrame;
                        }
                    });
                });
            }];
        }
            break;
        default:
            [iconImageViewByURL sd_setImageWithURL:[NSURL URLWithString:url]];
            break;
    }
    return @[iconImageViewByURL];
}

#pragma mark create button image from bundlename
+ (UIImage *)loadIconImage:(NSString *)imageName size:(CGSize)size rotation:(CGFloat)degree{
    if(!imageName){
        return nil;
    }

    @autoreleasepool {
        if([imageName isEqualToFileExtension:@"svg"]){
            //SVG
            UIImage * image = [SVGKImage imageNamedNoCache:imageName widthSizeWidth:size.width].UIImage;
            if(degree){
                image = [image rotateInDegrees:degree];
            }
            return image;
        }else{
            //Others
            return [UIImage imageBundled:imageName];
        }
    }
}

+ (NSArray *)createButtonIcons:(CGSize)size
                         inset:(CGFloat)inset
                     imageName:(NSString *)imageName
                   objectColor:(UIColor *)color
               backgroundColor:(UIColor *)backgroundColor
                         style:(STStandardButtonStyle)style
                          mode:(STStandardButtonRenderingMode)renderingMode
                      useCache:(BOOL)useCache
                      rotation:(CGFloat)degree{

    NSAssert(imageName || color, @"imageName or color should be available at least one.");

    NSString * cacheKey = NSStringWithFormat(@"%@%@%@s%dw%fh%fis%fr%drt%f"
            , imageName?:@"skipimage"
            , color ? color.hexString : @"#0"
            , backgroundColor ? backgroundColor.hexString : @"#0"
            , style
            , size.width
            , size.height
            , inset
            , renderingMode
            , degree
    );

    BOOL useRawImage = style== STStandardButtonStyleRawImage
            || style == STStandardButtonStyleRawImageWithClipAsCenteredCircle
            || style == STStandardButtonStyleRawImageWithClipAsCenteredRoundRect;

    BOOL skipRenderingImageDefault = style==STStandardButtonStyleSkipImage
            || style==STStandardButtonStyleSkipImageNormalDimmed
            || style==STStandardButtonStyleSkipImageSelectedDimmed;

    BOOL skipRenderingImageInvert = style==STStandardButtonStyleSkipImageInvert
            || style==STStandardButtonStyleSkipImageInvertNormalDimmed
            || style==STStandardButtonStyleSkipImageInvertSelectedDimmed;

    BOOL skipRenderingImage = skipRenderingImageDefault || skipRenderingImageInvert;

    BOOL transparentNormal = style== STStandardButtonStylePTBT
            || style== STStandardButtonStylePTBP
            || style== STStandardButtonStylePTTP;

    BOOL transparentSelectedWithBackgroundColor = style== STStandardButtonStylePTBT;
    BOOL transparentSelected = !transparentSelectedWithBackgroundColor && (style== STStandardButtonStyleTPPB || style== STStandardButtonStylePTTP);
    if(transparentSelected || transparentSelectedWithBackgroundColor){
        NSAssert(transparentSelected != transparentSelectedWithBackgroundColor, @"CAN NOT both YES transparentSelected, transparentSelectedWithBackgroundColor");
    }

    Weaks
    NSArray * (^__create_block)(void) = ^NSArray * {
        CGRect containerRect = CGRectMakeWithSize_AGK(size);
        CGRect imageRect = inset!=0 ? CGRectInset(containerRect,inset,inset) : containerRect;
        UIImage * image = [Wself loadIconImage:imageName size:imageRect.size rotation:degree];
        UIImage * imageNormal = nil;
        UIImage * imageSelected = nil;

        /*
         * return pure image if style none
         */
        if(image && useRawImage) {
            switch(style){
                case STStandardButtonStyleRawImageWithClipAsCenteredCircle:
                    imageNormal = [image clipAsCenteredCircle];
                    break;
                case STStandardButtonStyleRawImageWithClipAsCenteredRoundRect:
                    imageNormal = [image clipAsRoundedRect:image.size cornerRadius:image.size.width/6];
                    break;
                default:
                    imageNormal = image;
                    break;
            }
        }else{
            /*
            * start normal,selected images
            */
            UIGraphicsBeginImageContextWithOptions(containerRect.size, NO, [UIScreen mainScreen].scale);
            CGContextRef context = UIGraphicsGetCurrentContext();

            /*
             * render image
             */
            if(!skipRenderingImage){

                switch (style){
                    case STStandardButtonStyleTBPB:
                    case STStandardButtonStyleTBDPB:
                    case STStandardButtonStyleTDPB:{
                        /*
                         * normal
                         */
                        [image drawInRect:imageRect];

                        UIColor * _fillColor = nil;
                        switch (style) {
                            case STStandardButtonStyleTBDPB:
                                //backgroundcolor + dim
                                _fillColor = [[UIColor colorIf:backgroundColor or:[UIColor whiteColor]] colorWithAlphaComponent:[STStandardUI alphaForDimmingGhostly]];
                                break;

                            case STStandardButtonStyleTDPB:
                                //whitecolor + dim
                                _fillColor = [[UIColor whiteColor] colorWithAlphaComponent:[STStandardUI alphaForDimmingGhostly]];
                                break;

                            default:
                                //backgroundcolor
                                _fillColor = [UIColor colorIf:backgroundColor or:[UIColor whiteColor]];
                                break;
                        }
                        CGContextSetFillColorWithColor(context, [_fillColor CGColor]);
                        CGContextSetBlendMode(context, kCGBlendModeSourceOut);
                        CGContextFillEllipseInRect(context, containerRect);
                        imageNormal = UIGraphicsGetImageFromCurrentImageContext();

                        /*
                         * selected
                         */
                        CGContextClearRect(context, containerRect);
                        [image drawInRect:imageRect];

                        CGContextSetFillColorWithColor(context, (color ? color : [UIColor blackColor]).CGColor);
                        CGContextSetBlendMode(context, kCGBlendModeSourceIn);
                        CGContextFillRect(context, containerRect);

                        if(!(backgroundColor && [UIColor isColorClear:backgroundColor])){
                            CGContextSetFillColorWithColor(context, [(backgroundColor ? backgroundColor : [UIColor whiteColor]) CGColor]);
                            CGContextSetBlendMode(context, kCGBlendModeDestinationAtop);
                            CGContextFillEllipseInRect(context, containerRect);
                        }

                        imageSelected = UIGraphicsGetImageFromCurrentImageContext();

                        break;
                    }
                    default:{
                        /*
                        * normal
                        */
                        [image drawInRect:imageRect];

                        CGContextSetFillColorWithColor(context, [(color ? color : [UIColor blackColor]) CGColor]);
                        CGContextSetBlendMode(context, kCGBlendModeSourceIn);
                        CGContextFillRect(context, containerRect);

                        //clearColor
                        if(!transparentNormal && !(backgroundColor && [UIColor isColorClear:backgroundColor])){
                            if(backgroundColor){
                                CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
                            }else{
                                CGContextSetFillColorWithColor(context, (color ? [color negative] : [UIColor whiteColor]).CGColor);
                            }
                            CGContextSetBlendMode(context, kCGBlendModeDestinationAtop);
                            CGContextFillEllipseInRect(context, containerRect);
                        }

                        imageNormal = UIGraphicsGetImageFromCurrentImageContext();

                        /*
                         * selected
                         */
                        CGContextClearRect(context, containerRect);

                        [image drawInRect:imageRect];

                        if(transparentSelectedWithBackgroundColor){
                            if(backgroundColor){
                                CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
                            }else{
                                CGContextSetFillColorWithColor(context, (color ? [color negative] : [UIColor whiteColor]).CGColor);
                            }
                            CGContextFillRect(context, containerRect);

                        }else{
                            //clearColor

                            if(!(backgroundColor && [UIColor isColorClear:backgroundColor])){
                                if(backgroundColor){
                                    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
                                }else{
                                    CGContextSetFillColorWithColor(context, (color ? [color negative] : [UIColor whiteColor]).CGColor);
                                }
                                CGContextSetBlendMode(context, kCGBlendModeSourceIn);
                                CGContextFillRect(context, containerRect);
                            }

                            CGContextSetFillColorWithColor(context, [(color ? color : [UIColor blackColor]) CGColor]);
                            if(transparentSelected){
                                CGContextSetBlendMode(context, kCGBlendModeSourceOut);
                            }else{
                                CGContextSetBlendMode(context, kCGBlendModeDestinationAtop);
                            }
                            CGContextFillEllipseInRect(context, containerRect);
                        }

                        imageSelected = UIGraphicsGetImageFromCurrentImageContext();
                    }
                }

            }else{
                /*
                 * render only color
                 */
                NSParameterAssert(skipRenderingImageDefault || skipRenderingImageInvert);

                UIColor * normalColor = [UIColor colorIf:skipRenderingImageDefault ? color : backgroundColor or:[UIColor whiteColor]];
                UIColor * selectedColor = [UIColor colorIf:skipRenderingImageDefault ? backgroundColor : color or:[UIColor blackColor]];

                if(style==STStandardButtonStyleSkipImageNormalDimmed || style==STStandardButtonStyleSkipImageInvertNormalDimmed){
                    normalColor = [normalColor colorWithAlphaComponent:[STStandardUI alphaForDimmingGhostly]];

                }else if(style==STStandardButtonStyleSkipImageSelectedDimmed || style==STStandardButtonStyleSkipImageInvertSelectedDimmed){
                    selectedColor = [selectedColor colorWithAlphaComponent:[STStandardUI alphaForDimmingGhostly]];
                }

                CGContextSetFillColorWithColor(context, normalColor.CGColor);
                CGContextFillEllipseInRect(context, containerRect);
                imageNormal = UIGraphicsGetImageFromCurrentImageContext();

                CGContextClearRect(context, containerRect);

                CGContextSetFillColorWithColor(context, selectedColor.CGColor);
                CGContextFillEllipseInRect(context, containerRect);
                imageSelected = UIGraphicsGetImageFromCurrentImageContext();
            }

            UIGraphicsEndImageContext();
        }

        /*
         * set rendering mode
         */
        switch(renderingMode){
            case STStandardButtonRenderingModeAddIntoUIVisualEffectView:
                imageNormal = [imageNormal imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                imageSelected = [imageSelected imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                break;
            default:
                break;
        }

        /*
         * return
         */
        NSAssert(imageNormal,@"an image of normal state must not be nil");
        return imageNormal && imageSelected ? @[imageNormal, imageSelected] : @[imageNormal];
    };

    return useCache ? [self st_cachedObject:cacheKey init:__create_block] : __create_block();
}

- (NSString *)currentIconImageName{
    return [[self iconSourceImageNames] st_objectOrNilAtIndex:self.currentIndex];
}

- (UIImage *)currentIconImageNormal {
    return [[self currentButtonView] presentableObjectAtIndex:0];
}

- (UIImage *)currentIconImageSelected {
    return [[self currentButtonView] presentableObjectAtIndex:1];
}

#pragma mark Background
- (UIImage *)createBackgroundImage:(UIColor *)color{
    CGRect rect = CGRectMake(0, 0, self.boundsWidth, self.boundsHeight);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillEllipseInRect(context, rect);

    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)setBackgroundView:(UIView *)view{
    if(![_backgroundView isEqual:view]){
        [_backgroundView clearAllOwnedImagesIfNeededAndRemoveFromSuperview:YES];

        if(view){
            if(!CGRectEqualToRect(view.frame, self.bounds)){
                view.frame = self.bounds;
            }
            view.userInteractionEnabled = NO;
            [self insertSubview:view belowSubview:_contentView];
        }
    }
    _backgroundView = view;

#if DEBUG
    switch(self.style){
        case STStandardButtonStylePTTP:
        case STStandardButtonStylePTBP:
        case STStandardButtonStylePTBT:
            break;
        default:
            oo(@"[!]WARNING : backgroundView will not appear while use current style. Use STStandardButtonStylePTTP, STStandardButtonStylePTBP, STStandardButtonStylePTBT instead.");
            break;
    }
#endif
}

- (void)setBackgroundViewAsColoredImage:(UIColor *)backgroundViewAsColoredImage {
    if(backgroundViewAsColoredImage){
        if(![_backgroundViewAsColoredImage isEqual:backgroundViewAsColoredImage]){
            self.backgroundView = nil;

            NSString * cacheKey = [NSString stringWithFormat:@"backgroundViewAsColor@STStandardButton%f%@",self.width, backgroundViewAsColoredImage.hexString];
            CGFloat width = self.width;
            UIImageView *coloredCircleView = [[UIImageView alloc] initWithImage:[self st_cachedImage:cacheKey init:^UIImage * {
                return [[CAShapeLayer circle:width color:backgroundViewAsColoredImage] UIImage];
            }]];
            self.backgroundView = coloredCircleView;
            [coloredCircleView centerToParent];
        }

    }else{
        self.backgroundView = nil;
    }
    _backgroundViewAsColoredImage = backgroundViewAsColoredImage;
}

- (void)setBackgroundViewAsOwnBackgroundColorWithShapeMask:(UIColor *)backgroundViewAsOwnBackgroundColorWithShapeMask {
    _backgroundViewAsOwnBackgroundColorWithShapeMask = backgroundViewAsOwnBackgroundColorWithShapeMask;

    if(!self.backgroundView && backgroundViewAsOwnBackgroundColorWithShapeMask){
        UIView * backgroundView = [[UIView alloc] initWithSizeWidth:self.width];
        backgroundView.layer.mask = [CAShapeLayer circle:backgroundView.width];
        self.backgroundView = backgroundView;
    }

    if(backgroundViewAsOwnBackgroundColorWithShapeMask){
        Weaks
        if(self.animateBackgroundViewWhenStateChange){
            [UIView animateWithDuration:.6 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                Wself.backgroundView.backgroundColor = backgroundViewAsOwnBackgroundColorWithShapeMask;
            } completion:nil];
        }else{
            self.backgroundView.backgroundColor = backgroundViewAsOwnBackgroundColorWithShapeMask;
        }
    }else{
        self.backgroundView = nil;
    }
}

#pragma mark Shadow
- (void)setShadowEnabled:(BOOL)shadowEnabled {
    if(_shadowEnabled == shadowEnabled){
        return;
    }

    if(!_shadowEnabled && shadowEnabled){
        _shadowOffset?:(_shadowOffset = 1);
        _shadowAlpha?:(_shadowAlpha = .3f);
    }
    _shadowEnabled = shadowEnabled;
    [self setNeedsShadowDisplay];
}

- (void)setShadowOffset:(CGFloat)shadowOffset {
    _shadowOffset = shadowOffset;
    [self setNeedsShadowDisplay];
}

- (void)setShadowAlpha:(CGFloat)shadowAlpha {
    _shadowAlpha = shadowAlpha;
    [self setNeedsShadowDisplay];
}

- (void)setNeedsShadowDisplay {
    if(self.shadowEnabled/* && self.count*/){
        CGFloat shadowOffset = _shadowOffset;
        CGFloat shadowAlpha = _shadowAlpha;

        UIImage * shadowImage = [self shadowImage:shadowOffset];
        if(!_shadowView){
            _shadowView = [[UIImageView alloc] initWithImage:shadowImage];
        }else{
            _shadowView.image = shadowImage;
        }

        _shadowView.contentMode = UIViewContentModeCenter;

        if(_backgroundView){
            [self insertSubview:_shadowView belowSubview:_backgroundView];
        }else{
            [self insertSubview:_shadowView belowSubview:_contentView];
        }

        _shadowView.alpha = shadowAlpha;
        _shadowView.y = self.bounds.origin.y + shadowOffset;

    }else{
        [_shadowView removeFromSuperview];
        _shadowView.image = nil;
//        _shadowView = nil;
    }
}

- (UIImage *)shadowImage:(CGFloat)shadowOffset{
    Weaks
    NSString * cacheKey = [NSString stringWithFormat:@"STStandardButton.shadow%f_%f",self.width, shadowOffset];
    return [self st_cachedImage:cacheKey init:^UIImage * {
        Strongs
        NSAssert(Sself->_contentView.width >= Sself.width, @"Self.width must be bigger than _contentView for make ShadowImage");

        CALayer *layer = [CAShapeLayer circle:Sself.width];
        layer.positionY = layer.boundsHeightHalf;
        layer.positionX = layer.boundsWidthHalf;
        layer.mask = [CAShapeLayer circleInvertFilled:CGRectInset(Sself.bounds, 0, -shadowOffset) diameter:Sself.width color:[UIColor blackColor]];
        layer.mask.positionY = -shadowOffset*2;
        return layer.UIImage;
    }];
}

#pragma mark Interaction

- (void)setAllowSelectedStateFromTouchingOutside:(BOOL)allowSelectedStateFromTouchingOutside {
    _allowSelectedStateFromTouchingOutside = allowSelectedStateFromTouchingOutside;
    [self setUserSelectionInteraction];
}

- (void)setDenySelect:(BOOL)denySelect {
    _denySelect = denySelect;
    [self setUserSelectionInteraction];
}

- (void)setUserSelectionInteraction {
    __block BOOL selectedAndDeniedSelect;
    Weaks
    for(STSelectableView * button in _buttonViews){
        button.allowSelectAsTap = NO;
        [button whenLongTapAsTapDownUp:_denySelect ? nil : ^(UILongPressGestureRecognizer *sender, CGPoint location) {
            Strongs
            if(Sself.forceBubblingLongTapGesturesWhenSelected){
                [Sself st_dispatchGestureHandlerToAll:sender];
            }

            if(!Sself->_toggleEnabled && button.count>1){
                button.currentIndex = 1;
            }

            selectedAndDeniedSelect = Sself.selectedState && Sself.denyDeselectWhenAlreadySelected;

            //after events
            if(Sself.blockForButtonDown){
                Sself.blockForButtonDown(Wself);
            }

        } changed:_allowSelectedStateFromTouchingOutside || _denySelect ? nil : ^(UILongPressGestureRecognizer *sender, CGPoint location) {
            Strongs
            BOOL touchInside = CGPointLengthBetween_AGK(Sself.st_halfXY, [sender locationInView:Sself]) <= Sself.width;
            if(!Sself.toggleEnabled && button.count>1){
                button.currentIndex = touchInside ? 1 : 0;
            }

        } ended:^(UILongPressGestureRecognizer *sender, CGPoint location) {
            Strongs
            BOOL touchInside = Sself->_allowSelectedStateFromTouchingOutside ?
                    YES : CGPointLengthBetween_AGK(Sself.st_halfXY, [sender locationInView:Sself]) <= Sself.width;

            //when deny select
            if(Sself->_denySelect && touchInside){
                if(Sself.expressDenied){
                    [STStandardUX expressDenied:Sself];
                }
                return;
            }

            //when touch inside
            if(touchInside){
                //when toggle enabled
                if(Sself->_toggleEnabled){
                    if(selectedAndDeniedSelect){
                        if(Sself.expressDenied){
                            [STStandardUX expressDenied:Wself];
                        }
                    }else{
                        [button next];

                        [Wself dispatchToggled];
                        [Wself dispatchSelected];
                    }
                }else{
                    //when toggle disabled
                    if(selectedAndDeniedSelect){
                        if(Wself.expressDenied){
                            [STStandardUX expressDenied:Wself];
                        }
                    }else{
                        [button next];

                        if(Wself.count>1){
                            if(!Wself.lockCurrentIndexAfterSelected){
                                [Wself next];
                            }
                            [Wself dispatchSelected];

                        }else{
                            [Wself dispatchSelected];
                        }
                    }
                }

                //after events
                if(Sself.forceBubblingTapGesturesWhenSelected){
                    [Sself st_dispatchTapGestureHandlerToViews:[Sself st_allSuperviewsContainSelf] from:sender];
                }

                if(Sself.forceBubblingLongTapGesturesWhenSelected){
                    [Sself st_dispatchGestureHandlerToAll:sender];
                }
            }

            if(Sself.blockForButtonUp){
                Sself.blockForButtonUp(Wself);
            }

        }].delaysTouchesBegan = NO;
    }
}

- (void)clearUserSelectionInteraction{
    for(UIView * button in _buttonViews){
        [button whenLongTapped:nil];
    }
}

- (UILongPressGestureRecognizer *)gestureRecognizerForSelection {
    return [self.currentButtonView.gestureRecognizers bk_match:^BOOL(id obj) {
        return [obj isKindOfClass:UILongPressGestureRecognizer.class];
    }];
}

#pragma mark Toggle
- (void)whenToggled:(void (^)(STStandardButton *button, BOOL selected))block; {
    _whenToggled = block;
    self.toggleEnabled = block!=nil;
}

- (void)setToggleEnabled:(BOOL)toggleEnabled; {
    _toggleEnabled = toggleEnabled;
    [self setUserSelectionInteraction];

    if(!toggleEnabled){
        self.selectedState = NO;
    }
}

- (void)dispatchToggled{
    !_whenToggled?:_whenToggled(self, self.selectedState);
}

#pragma mark State
- (STSelectableView *)currentButtonView {
    if(_buttonViews){
        return _buttonViews[self.currentIndex];
    }
    return nil;
}

- (void)setSelectedState:(BOOL)selectedState; {
    if(self.currentButtonView.count>1){
        self.currentButtonView.currentIndex = selectedState ? 1 : 0;
    }
    [self layoutLabelIfNeeded];
}

- (BOOL)selectedState; {
    return self.currentButtonView.currentIndex==1;
}

#pragma mark Badge
- (void)setBadgeSmallPoint:(BOOL)badgeSmallPoint {
    _badgeSmallPoint = badgeSmallPoint;
    [self setBadgeView:_badgeSmallPoint asSmall:YES];
    if(_badgeSmallPoint){
        self.badgeVisible = YES;
    }
}

- (void)setBadgeVisible:(BOOL)badgeVisible; {
    _badgeView.visible = badgeVisible;
}

- (BOOL)badgeVisible; {
    return _badgeView.visible;
}

- (void)setBadgeView:(BOOL)show asSmall:(BOOL)small{
    if(show){
        [_badgeView pop_removeAllAnimations];

        //create badge view
        if(!_badgeView){
            if(small){
                CGFloat minimumWidth = self.width/4;
                UIView * miniBadgeView = [[UIView alloc] initWithSizeWidth:minimumWidth];
                miniBadgeView.layer.cornerRadius = minimumWidth/2;
                miniBadgeView.backgroundColor = [UIColor redColor];
                _badgeView = miniBadgeView;

            }else{
                M13BadgeView *view = [[M13BadgeView alloc] initWithSize:[STStandardLayout sizeBadge]];
                view.animateChanges = NO;
                view.horizontalAlignment = M13BadgeViewHorizontalAlignmentRight;
                _badgeView = view;
            }
            [self addSubview:_badgeView];
        }

        //update view
        if(self._badgeViewAsM13BadgeView){
            self._badgeViewAsM13BadgeView.alignmentShift = CGSizeMake(-self._badgeViewAsM13BadgeView.width/5, self._badgeViewAsM13BadgeView.height/5);;
        }else{
            _badgeView.center = CGPointMake(_contentView.width-_badgeView.width,_badgeView.height);
        }
        [_badgeView.superview bringSubviewToFront:_badgeView];

    }else{
        Weaks
        [NSObject animate:^{
            _badgeView.spring.scaleXYValue = 0;
        } completion:^(BOOL finished) {
            [Wself removeBadgeView];
        }];
    }
}

- (void)removeBadgeView {
    [_badgeIconView clearAllOwnedImagesIfNeeded:NO];
    [_badgeIconView removeFromSuperview];
    _badgeIconView = nil;

    self._badgeViewAsM13BadgeView.text = nil;
    [_badgeView removeFromSuperview];
    _badgeView = nil;
}

- (void)setBadgeText:(NSString *)label; {
    [self setBadgeView:0 < label.length asSmall:NO];
    self._badgeViewAsM13BadgeView.text = label;
}

- (M13BadgeView *)_badgeViewAsM13BadgeView{
    return [_badgeView isKindOfClass:M13BadgeView.class] ? (M13BadgeView *)_badgeView : nil;
}

- (NSString *)badgeText{
    return self._badgeViewAsM13BadgeView ? self._badgeViewAsM13BadgeView.text : nil;
}

- (void)setBadgeImage:(UIImage *)badgeImage {
    BOOL show = badgeImage != nil;
    [self setBadgeView:show asSmall:NO];

    if(show){
        _badgeIconView = [[UIImageView alloc] initWithSize:CGSizeByScale(_badgeView.size, 0.8)];
        _badgeIconView.image = badgeImage;

        [_badgeView addSubview:_badgeIconView];
        [_badgeIconView centerToParent];
    }
}

- (UIImage *)badgeImage {
    return _badgeIconView.image;
}

- (void)setBadgeColor:(UIColor *)badgeColor {
    if(self._badgeViewAsM13BadgeView){
        self._badgeViewAsM13BadgeView.badgeBackgroundColor = badgeColor;
    }else{
        _badgeView.backgroundColor = badgeColor;
    }
    _badgeColor = badgeColor;
}

#pragma mark Title Label
- (void)layoutLabelIfNeeded {
    if(self.superview){
        if(self.titleLabelWidthAutoFitToSuperview){
            self.titleLabelWidth = self.superview.width;
        }

        //title label
        if(_titleLabel){
            [_titleLabel sizeToFit];
            [_titleLabel centerToParent];
            _titleLabelWidth = _titleLabel.width;
            _titleLabel.y = _contentView.bottom + _titleLabelPositionedGapFromButton;

            if(_toggleEnabled){
                _titleLabel.alpha = self.selectedState ? 1 : [STStandardUI alphaForDimmingText];
            }else{
                _titleLabel.alpha = 1;
            }
        }

        //subtitle label
        if(_subTitleLabel){
            [_subTitleLabel sizeToFit];
            [_subTitleLabel centerToParent];
            _subTitleLabel.y = _titleLabel.bottom + [STStandardLayout gapForTitleLabelToSubtitleLabel];
        }
    }
}

- (void)setTitleText:(NSString *)titleText {
    if(titleText){
        if(!_titleLabel){
            _titleLabel = [[TTTAttributedLabel alloc] initWithSizeWidth:_titleLabelWidth ? _titleLabelWidth : [self st_subviewsUnionFrame].size.width];
            _titleLabel.font = [STStandardUI defaultFontForLabel];
            _titleLabel.textColor = [STStandardUI textColorLighten];
            _titleLabel.lineBreakMode = NSLineBreakByClipping;
            _titleLabel.userInteractionEnabled = NO;
            _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:_titleLabel];
        }

        if(![_titleLabel.text isEqualToString:titleText]){
            _titleLabel.numberOfLines = self.titleLabelAutoSetNumberOfLines ? [titleText st_numberOfNewLines] : 1;
        }
        _titleLabel.text = titleText;

        [self layoutLabelIfNeeded];

    }else{
        [_titleLabel removeFromSuperview];
        _titleLabel = nil;
    }
    _titleText = titleText;
}

- (void)setTitleTextAsAttributedString:(NSAttributedString *)titleTextAsAttributedString {
    _titleLabel.attributedText = titleTextAsAttributedString;
    [self layoutLabelIfNeeded];
}

- (void)setTitleLabelPositionedGapFromButton:(CGFloat)titleLabelPositionedGapFromButton {
    _titleLabelPositionedGapFromButton = titleLabelPositionedGapFromButton;
    [self layoutLabelIfNeeded];
}

- (NSAttributedString *)titleTextAsAttributedString {
    return _titleLabel.attributedText;
}

- (void)setTitleLabelWidth:(CGFloat)titleLabelWidth {
    if(_titleLabelWidth != titleLabelWidth){
        _titleLabel.width = titleLabelWidth;
        [_titleLabel sizeToFit];
        [_titleLabel centerToParentHorizontal];

        _titleLabelWidthAutoFitToSuperview = NO;
    }
    _titleLabelWidth = titleLabelWidth;
}

#pragma mark Subtitle Label
- (void)setSubtitleText:(NSString *)subtitleText {
    if(subtitleText && self.subtitleVisibility){
        BOOL initial = _subTitleLabel==nil;
        if(!_subTitleLabel){
            _subTitleLabel = [[TTTAttributedLabel alloc] initWithSizeWidth:_titleLabelWidth ? _titleLabelWidth : [self st_subviewsUnionFrame].size.width];
            _subTitleLabel.font = [STStandardUI defaultFontForSubLabel];
            _subTitleLabel.textColor = [STStandardUI textColorLighten];
            _subTitleLabel.alpha = [STStandardUI alphaForDimmingText];
            _subTitleLabel.lineBreakMode = NSLineBreakByClipping;
            _subTitleLabel.numberOfLines = 1;
            _subTitleLabel.userInteractionEnabled = NO;
            _subTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _subTitleLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:_subTitleLabel];
        }

        if(!initial){
            [STStandardUX setAnimationFeelsToFastShortSpring:_titleLabel];
            _titleLabel.easeInEaseOut.scaleY = 0;

            _subTitleLabel.font = _titleLabel.font;
            _subTitleLabel.easeInEaseOut.alpha = 1;

            [STStandardUX resetAndRevertStateAfterShortDelay:[self.identifier st_add:@"labelTransform"] block:^{
                _titleLabel.easeInEaseOut.scaleY = 1;

                _subTitleLabel.easeInEaseOut.alpha = [STStandardUI alphaForDimmingText];
                _subTitleLabel.font = [STStandardUI defaultFontForSubLabel];
                _subTitleLabel.text = subtitleText;
                [self layoutLabelIfNeeded];
            }];
        }

        _subTitleLabel.text = subtitleText;
        [self layoutLabelIfNeeded];

    }else{
        [_subTitleLabel removeFromSuperview];
        _subTitleLabel = nil;
    }
    _subtitleText = subtitleText;
}

- (void)setSubtitleTextAsAttributedString:(NSAttributedString *)subtitleTextAsAttributedString {
    _subtitleTextAsAttributedString = subtitleTextAsAttributedString;
    self.subtitleText = (id) subtitleTextAsAttributedString;

    [self layoutLabelIfNeeded];
}

- (void)setSubtitleLabelSyncWhenSelected:(BOOL)subtitleLabelSyncWhenSelected {
    _subtitleLabelSyncWhenSelected = subtitleLabelSyncWhenSelected;

    if(self.subtitleText && _subtitleLabelSyncWhenSelected){
        [self setNeedsSubtitleText];
    }
}

- (void)setSubtitleVisibility:(BOOL)subtitleVisibility {
    _subTitleLabel.visible = _subtitleVisibility = subtitleVisibility;
}

- (void)setSubtitleTexts:(NSArray *)subtitleTexts {
    NSAssert(self.toggleEnabled ? subtitleTexts.count == 2 : self.count== subtitleTexts.count, ([@"self.toggleEnabled ? namesOfButtons.count == 2 : self.count== namesOfButtons.count " stringByAppendingFormat:@"%d %d",self.count, subtitleTexts.count]));
    _subtitleTexts = subtitleTexts;

    [self setNeedsSubtitleText];
}

- (NSString *)currentSelectedSubtitleText {
    return [[self subtitleTexts] st_objectOrNilAtIndex:self.toggleEnabled ? (self.selectedState ? 1 : 0) : self.currentIndex];
}

- (void)setNeedsSubtitleText {
    if(self.subtitleLabelSyncWhenSelected){
        NSString * targetText = [self currentSelectedSubtitleText];
        if(![self.subtitleText isEqualToString:targetText]){
            self.subtitleText = targetText;
        }
    }
}

#pragma mark Cover Effect
- (void)_performOnUncoverIfNeeded:(void (^)(void))block{
    if(_covered){
        [self uncoverWithBlur:YES comletion:^(STStandardButton *button, BOOL covered) {
            block();
        }];
    }else{
        block();
    }
}

#define COVER_ANIMATION_DURAION .3
- (CGFloat)coverAnimationDefaultDuration{
    return COVER_ANIMATION_DURAION;
}

- (void)coverWithBlur:(UIView *)coveringTargetView presentingTarget:(UIView *)view comletion:(void (^)(STStandardButton *button, BOOL covered))block;{
    [self coverWithBlur:coveringTargetView presentingTarget:view blurStyle:UIBlurEffectStyleDark comletion:block];
}

// cover with background
- (void)coverWithBlur:(UIView *)coveringTargetView presentingTarget:(UIView *)view blurStyle:(UIBlurEffectStyle)blurStyle comletion:(void (^)(STStandardButton *button, BOOL covered))block;{

    UIImage * snapshot = [view st_takeSnapshot:[view st_originClearedBounds] afterScreenUpdates:NO useTransparent:YES maxTwiceScale:YES];
    if(!_tempCoverImageView && snapshot){
        _tempCoverImageView = [[UIImageView alloc] initWithImage:snapshot];
    }else{
        _tempCoverImageView.image = snapshot;
    }

    [self resetAutoOrientedTransformToDefaultIfNeeded];

    _coveredBoundView = coveringTargetView;
    _coveredTargetView = view;

    view.visible = NO;

    UIVisualEffectView *tempCoverView = [coveringTargetView st_createBlurView:blurStyle];
    tempCoverView.tagName = @"covered_bg_layer";

    [tempCoverView.contentView addSubview:_tempCoverImageView];
    [view.superview insertSubview:tempCoverView aboveSubview:view];

    CAShapeLayer * circleLayer = [CAShapeLayer circle:self.width];
    circleLayer.position = [self convertPoint:_contentView.origin toView:view];
    circleLayer.positionX += [circleLayer boundsWidthHalf];
    circleLayer.positionY += [circleLayer boundsHeightHalf];
    circleLayer.anchorPoint = CGPointHalf;
    tempCoverView.layer.mask = circleLayer;

    Weaks
    WeakAssign(view)
    WeakAssign(tempCoverView)
    WeakAssign(coveringTargetView)
    WeakAssign(circleLayer)
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        dispatch_async(dispatch_get_main_queue(),^{
            [Wself _cover:weak_coveringTargetView animationTarget:weak_circleLayer animation:YES comletion:^(STStandardButton *button, BOOL covered) {
                Strongs
                [CATransaction begin];
                [CATransaction setValue:(id) kCFBooleanTrue forKey:kCATransactionDisableActions];

                weak_view.layer.mask = weak_tempCoverView.layer.mask;
                weak_tempCoverView.layer.mask = nil;

                [[weak_tempCoverView.contentView firstSubview] removeFromSuperview];
                [weak_view insertSubview:weak_tempCoverView atIndex:0];
                weak_view.visible = YES;

                [CATransaction commit];

                [Sself resetAutoOrientedTransformToCurrentIfNeeded];

                !block ?: block(button, covered);
            }];
        });
    });
}

- (void)_uncoverWithBlurRemove {
    [[_coveredTargetView viewWithTagName:@"covered_bg_layer"] st_removeAllSubviews];
    [[_coveredTargetView viewWithTagName:@"covered_bg_layer"] removeFromSuperview];
    _coveredTargetView.layer.mask = nil;
    _coveredTargetView.visible = NO;
    _coveredTargetView = nil;

    _tempCoverImageView.image = nil;

    _coveredBoundView = nil;

    [self resetAutoOrientedTransformToCurrentIfNeeded];
}

- (void)uncoverWithBlur:(BOOL)animation comletion:(void (^)(STStandardButton *button, BOOL covered))block;{
    _covered = NO;

    _coveredBoundView.visible = YES;

    if(animation){
        @weakify(self)
        void(^completion)(BOOL) = ^(BOOL finished) {
            @strongify(self)
            self.userInteractionEnabled = YES;

            [self _uncoverWithBlurRemove];

            !block?:block(self, _covered);
        };

        if(_coveredBoundView && _coveredTargetView.layer.mask.scaleXYValue!=1){
            self.userInteractionEnabled = NO;
            [NSObject animate:^{
                [[_coveredTargetView.layer.mask easeInEaseOut] setScaleXYValue:1];
            } completion:completion];

        }else{
            completion(YES);
        }

    }else{
        [_coveredTargetView.layer.mask setScaleXYValue:1];

        [self _uncoverWithBlurRemove];

        !block?:block(self, _covered);
    }
}

- (UIImageView *)coverAndUncoverBegin:(UIView *)coveringTargetView presentingTarget:(UIView *)view {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

    [self resetAutoOrientedTransformToDefaultIfNeeded];

    UIImageView *before_coverView = [view st_coverSnapshot:NO useTransparent:NO maxTwiceScale:YES completion:nil];
    before_coverView.origin = view.origin;
    [view insertAboveToSuperview:before_coverView];
    view.visible = NO;

    [CATransaction commit];
    return before_coverView;
}

- (void)coverAndUncoverEnd:(UIView *)coveringTargetView presentingTarget:(UIView *)view beforeCoverView:(UIImageView *)before_coverView comletion:(void (^)(STStandardButton *button, BOOL covered))block;{
    Weaks
    [self st_performOnceAfterDelay:@"cover_and_uncover_end_presenter_internal_delay" interval:.05 block:^{
        [Wself _coverAndUncoverEnd: coveringTargetView presentingTarget:view beforeCoverView:before_coverView comletion:block];
    }];
}

- (void)_coverAndUncoverEnd:(UIView *)coveringTargetView presentingTarget:(UIView *)view beforeCoverView:(UIImageView *)before_coverView comletion:(void (^)(STStandardButton *button, BOOL covered))block;{
    UIImageView *after_coverView = [view st_coverSnapshot:NO useTransparent:NO maxTwiceScale:YES completion:nil];

    after_coverView.origin = view.origin;
    [before_coverView insertAboveToSuperview:after_coverView];

    after_coverView.layer.mask = [CAShapeLayer circle:_contentView.boundsWidth];
    after_coverView.layer.mask.position = [self convertPoint:self.boundsCenter toView:after_coverView];
    after_coverView.layer.mask.anchorPoint = CGPointMake(.5, .5);

    [self _cover:coveringTargetView animationTarget:after_coverView.layer.mask animation:YES comletion:^(STStandardButton *button, BOOL covered) {
        view.visible = YES;

        before_coverView.image = nil;
        before_coverView.layer.mask = nil;
        [before_coverView removeFromSuperview];

        after_coverView.image = nil;
        after_coverView.layer.mask = nil;
        [after_coverView removeFromSuperview];

        [self resetAutoOrientedTransformToCurrentIfNeeded];

        !block ?: block(button, covered);
    }];
}

- (void)_cover:(UIView *)boundsTarget animationTarget:(id)animationTarget animation:(BOOL)animation comletion:(void (^)(STStandardButton *button, BOOL covered))block;{
    NSParameterAssert(boundsTarget);
    NSAssert([animationTarget isKindOfClass:UIView.class] || [animationTarget isKindOfClass:CALayer.class], @"must type be UIView or CALayer.");

    _covered = YES;

    CGPoint center = [self convertPoint:self.boundsCenter toView:boundsTarget];
    CGFloat maxRadiusFromTargetsCenter = MAXRadiusInBoundsFromPoint(center, boundsTarget.bounds);
    CGFloat maxTargetRadius = MAX([self boundsWidthHalf], [self boundsHeightHalf]);
    CGFloat scaleTo = maxRadiusFromTargetsCenter / maxTargetRadius;

    if(animation){

        [animationTarget pop_stop];
        [animationTarget pop_removeAllAnimations];
        [(NSObject *)[animationTarget easeInEaseOut] setDuration:self.coverAnimationDefaultDuration];

        @weakify(self)
        void(^completion)(BOOL) = ^(BOOL finished) {
            @strongify(self)
            !block?:block(self, self->_covered);
            self.userInteractionEnabled = YES;
        };

        if([animationTarget scaleXYValue]!=scaleTo){
            self.userInteractionEnabled = NO;
            [NSObject animate:^{
                [(id)[animationTarget easeInEaseOut] setScaleXYValue:scaleTo];
            } completion:completion];
        }else{
            completion(YES);
        }

    }else{
        [animationTarget setScaleXYValue:scaleTo];

        !block?:block(self, _covered);
    }
}

#pragma mark Activating Display

- (void)startAlert{
    [self startAlert:NSUIntegerMax];
}

- (void)startAlert:(NSUInteger)repeatCount{
    _contentView.alpha = 0;
    [UIView animateWithDuration:.6 delay:0.1 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        [UIView setAnimationRepeatCount:repeatCount==NSUIntegerMax ? CGFLOAT_MAX : (CGFloat)repeatCount];
        _contentView.alpha = 1;
    } completion:nil];
}

- (void)stopAlert{
    [_contentView.layer removeAllAnimations];
}

#pragma mark Progress Display
- (void)startSpinProgress{
    [self startSpinProgress:nil];
}

- (void)startSpinProgress:(UIColor *)tintColor{
    if(_spinProgressStarted){
        return;
    }
    _spinProgressStarted = YES;

    if(!_spinnerView){
        _spinnerView = [[MMMaterialDesignSpinner alloc] initWithSizeWidth:self.width/2];
        _spinnerView.duration = 1;
        _spinnerView.lineWidth = STStandardLayout.circularStrokeWidthBold;
        _spinnerView.tintColor = tintColor?:([self.maskColors st_objectOrNilAtIndex:self.currentIndex]?:[UIColor whiteColor]);
        _spinnerView.hidesWhenStopped = YES;
        _spinnerView.userInteractionEnabled = NO;
        [self addSubview:_spinnerView];
        [_spinnerView centerToParent];
    }

    _spinnerView.visible = YES;
    [_spinnerView startAnimating];

    [self lockVisibleToHideExcludingSubviews:[NSSet setWithObject:_spinnerView]];

    [self disableUserInteraction];
}

- (void)stopSpinProgress{
    if(!_spinProgressStarted){
        return;
    }
    _spinProgressStarted = NO;

    if(!self.keepSpinProgressViewAfterStop){
        [_spinnerView removeFromSuperview];
        _spinnerView = nil;
    }else{
        [_spinnerView stopAnimating];
    }

    [self unlockVisibleToAllSubviews];

    [self restoreUserInteractionEnabled];
}

#pragma mark SetProgress
- (void)setPieProgress:(CGFloat)pieProgress {
    _pieProgress = pieProgress;

    [self _setPieProgress:self.pieProgressAnimationEnabled];

    //synchronizePieProgressWithSelectedState
    BOOL reached = _pieProgress==1;
    if(self.synchronizePieProgressWithSelectedState){
        if(self.selectedState != reached){
            self.selectedState = reached;
        }
    }

    if(self.resetPieProgressAfterReached && reached){
        _pieProgress = 0;
        [self _setPieProgress:NO];
    }
}

- (void)_setPieProgress:(BOOL)animation{

    if(_pieProgress <= 0){
        [_pieProgressView removeFromSuperview];
        _pieProgressView = nil;

    }else{
        if(!_pieProgressView){
#if DEBUG
            switch (self.style){
                case STStandardButtonStylePTTP:
                case STStandardButtonStylePTBP:
                case STStandardButtonStylePTBT:
                case STStandardButtonStyleTBDPB:
                case STStandardButtonStyleTDPB:
                    break;
                default:{
                    NSString * msg = @"[!]WARNING : PieProgressView may not appear if self.style is not STStandardButtonStylePTTP, STStandardButtonStylePTBP, STStandardButtonStylePTBT, STStandardButtonStyleTBDPB, STStandardButtonStyleTDPB";
                    oo(msg);
                    break;
                }
            }
#endif
            _pieProgressView = [[M13ProgressViewPie alloc] initWithSizeWidth:self.width];
            _pieProgressView.backgroundRingWidth = 0;
            _pieProgressView.alpha = [STStandardUI alphaForDimmingGlass];
            _pieProgressView.primaryColor = self.pieProgressTintColor;
            [self insertSubview:_pieProgressView belowSubview:_contentView];
            [_pieProgressView centerToParent];
        }

        if(![_pieProgressView.primaryColor isEqual:self.pieProgressTintColor]){
            _pieProgressView.primaryColor = self.pieProgressTintColor;
        }

        [_pieProgressView setProgress:_pieProgress animated:animation];
    }
}

@end

