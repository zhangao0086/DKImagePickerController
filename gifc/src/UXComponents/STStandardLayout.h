//
// Created by BLACKGENE on 2015. 3. 18..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface STStandardLayout : NSObject
+ (CGFloat)widthMain;

+ (CGFloat)widthMainMid;

+ (CGFloat)widthMainSmall;

+ (CGFloat)widthBullet;

+ (CGFloat)widthBulletMiddle;

+ (CGFloat)widthBulletBig;

+ (CGFloat)widthOverlayMidLongHorizontal;

+ (CGFloat)widthOverlayHorizontal;

+ (CGFloat)heightOverlayHorizontal;

+ (CGFloat)heightOverlayHorizontalThin;

+ (CGFloat)widthFocusPointLayer;

+ (CGFloat)widthAFCompleteRectLayer;

+ (CGSize)sizeBlankIcon;

+ (CGSize)sizeEditIcon;

+ (CGSize)sizeMain;

+ (CGSize)sizeMainSmall;

+ (CGFloat)widthSub;

+ (CGFloat)widthSubSmall;

+ (CGFloat)widthSubAssistanceBig;

+ (CGFloat)widthSubAssistance;

+ (CGFloat)widthExportCollectableItem;

+ (CGSize)sizeSub;

+ (CGSize)sizeSubSmall;

+ (CGSize)sizeSubAssistanceBig;

+ (CGSize)sizeSubAssistance;

+ (CGSize)sizeBullet;

+ (CGSize)sizeBulletBig;

+ (CGSize)sizeOverlayHorizontal;

+ (CGSize)sizeOverlayThinHorizontal;

+ (CGSize)sizeOverlayMidLongHorizontal;

+ (CGSize)sizeOverlayMidLongHorizontalThin;

+ (CGSize)sizeOverlayFullScreenHorizontal;

+ (CGSize)sizeBadge;

+ (CGRect)rectMain;

+ (CGRect)rectMainSmall;

+ (CGRect)rectSub;

+ (CGRect)rectSubSmall;

+ (CGRect)rectSubAssistance;

+ (CGRect)rectBullet;

+ (CGRect)rectBulletBig;

+ (CGFloat)defaultRectSizeRatio4by3;

+ (CGFloat)paddingForAutofitDistanceDefault;

+ (CGFloat)insetRatioForAutoAdjustIconImagesPadding;

+ (CGFloat)gapForButtonBottomToTitleLabel;

+ (CGFloat)gapForTitleLabelToSubtitleLabel;

+ (CGFloat)paddingForAutofitDistanceExportCollectables;

+ (CGFloat)circularStrokeWidthDefault;

+ (CGFloat)circularStrokeWidthBold;

+ (CGFloat)widthCellIcon;

+ (CGFloat)minimumHeightOfBottomControlArea;

+ (CGRect)bottomControlAreaFrame;

+ (CGRect)bottomControlAreaFrame:(CGSize)boundSize;

+ (CGFloat)settingScreenGridRowSpacing;
@end