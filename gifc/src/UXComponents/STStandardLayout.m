//
// Created by BLACKGENE on 2015. 3. 18..
// Copyright (c) 2015 stells. All rights reserved.
//

@implementation STStandardLayout {

}

//main
+ (CGFloat)widthMain {
    switch ([STApp screenFamily]){
        case STScreenFamily35:
            return 42;
        case STScreenFamily55:
            return 84;
        default:
            return 78;
    }
}

+ (CGFloat)widthMainMid {
    return 70;
}

+ (CGFloat)widthMainSmall {
    switch ([STApp screenFamily]){
        case STScreenFamily35:
            return 30;
        case STScreenFamily55:
        case STScreenFamily47:
            return 62;
        default:
            return 56;
    }
}


//sub
+ (CGFloat)widthSub {
    switch ([STApp screenFamily]){
        case STScreenFamily35:
            return 30;
        case STScreenFamily55:
            return 54;
        default:
            return 50;
    }
}

+ (CGFloat)widthSubSmall {
    switch ([STApp screenFamily]){
        case STScreenFamily35:
            return 28;
        default:
            return 42;
    }
}

+ (CGFloat)widthSubAssistanceBig {
    switch ([STApp screenFamily]){
        case STScreenFamily35:
            return 24;
        case STScreenFamily55:
        case STScreenFamily47:
            return 34;
        default:
            return 30;
    }

}

+ (CGFloat)widthSubAssistance {
    switch ([STApp screenFamily]){
        case STScreenFamily35:
            return 12;
        case STScreenFamily55:
            return 32;
        case STScreenFamily47:
            return 29;
        default:
            return 23;
    }
}

//bullet
+ (CGFloat)widthBullet {
    switch ([STApp screenFamily]){
        case STScreenFamily55:
        case STScreenFamily47:
            return 11;
        default:
            return 10;
    }
}

+ (CGFloat)widthBulletMiddle {
    return 12;
}

+ (CGFloat)widthBulletBig {
    return 16;
}

//display
+ (CGFloat)widthOverlayMidLongHorizontal {
    return 140;
}

+ (CGFloat)widthOverlayHorizontal {
    return 90;
}

+ (CGFloat)widthFullScreenHorizontal {
    return [UIScreen mainScreen].bounds.size.width-[self.class paddingForAutofitDistanceDefault]*2;
}

+ (CGFloat)heightOverlayHorizontal {
    return 20;
}

+ (CGFloat)heightOverlayHorizontalThin {
    return 10;
}

//HUD
+ (CGFloat)widthFocusPointLayer {
    return 70;
}

+ (CGFloat)widthAFCompleteRectLayer {
    return 10;
}

#pragma mark CollectionView
+ (CGSize)sizeBlankIcon{
    return CGSizeMakeValue(36);
}

+ (CGSize)sizeEditIcon{
    return CGSizeMakeValue(32);
}

#pragma mark Size of button/square
+ (CGSize)sizeMain {
    return CGSizeMakeValue(self.widthMain);
}

+ (CGSize)sizeMainSmall {
    return CGSizeMakeValue(self.widthMainSmall);
}

+ (CGSize)sizeSub {
    return CGSizeMakeValue(self.widthSub);
}

+ (CGSize)sizeSubSmall {
    return CGSizeMakeValue(self.widthSubSmall);
}

+ (CGSize)sizeSubAssistanceBig {
    return CGSizeMakeValue([self widthSubAssistanceBig]);
}

+ (CGSize)sizeSubAssistance {
    return CGSizeMakeValue([self widthSubAssistance]);
}

+ (CGSize)sizeBullet {
    return CGSizeMakeValue(self.widthBullet);
}

+ (CGSize)sizeBulletBig {
    return CGSizeMakeValue(self.widthBulletBig);
}

+ (CGSize)sizeOverlayHorizontal {
    return CGSizeMake([self widthOverlayHorizontal], [self heightOverlayHorizontal]);
}

+ (CGSize)sizeOverlayThinHorizontal {
    return CGSizeMake([self widthOverlayHorizontal], [self heightOverlayHorizontalThin]);
}

+ (CGSize)sizeOverlayMidLongHorizontal {
    return CGSizeMake([self widthOverlayMidLongHorizontal], [self heightOverlayHorizontal]);
}

+ (CGSize)sizeOverlayMidLongHorizontalThin {
    return CGSizeMake([self widthOverlayMidLongHorizontal], [self heightOverlayHorizontalThin]);
}

+ (CGSize)sizeOverlayFullScreenHorizontal {
    return CGSizeMake([self widthFullScreenHorizontal], [self heightOverlayHorizontalThin]);
}

+ (CGSize)sizeBadge{
    return CGSizeMakeValue(24);
}

#pragma mark Rect of button/square
+ (CGRect)rectMain{
    return CGRectMakeWithSize_AGK([self sizeMain]);
}

+ (CGRect)rectMainSmall{
    return CGRectMakeWithSize_AGK([self sizeMainSmall]);
}

+ (CGRect)rectSub{
    return CGRectMakeWithSize_AGK([self sizeSub]);
}

+ (CGRect)rectSubSmall{
    return CGRectMakeWithSize_AGK([self sizeSubSmall]);
}

+ (CGRect)rectSubAssistance{
    return CGRectMakeWithSize_AGK([self sizeSubAssistance]);
}

+ (CGRect)rectBullet{
    return CGRectMakeWithSize_AGK([self sizeBullet]);
}

+ (CGRect)rectBulletBig{
    return CGRectMakeWithSize_AGK([self sizeBulletBig]);
}

+ (CGFloat)defaultRectSizeRatio4by3{
    return 1.331250f;
}

#pragma mark StandardButton's
+ (CGFloat)paddingForAutofitDistanceDefault {
    return 7;
}

+ (CGFloat)insetRatioForAutoAdjustIconImagesPadding {
    return .2f;
}

+ (CGFloat)gapForButtonBottomToTitleLabel {
    return 10;
}

+ (CGFloat)gapForTitleLabelToSubtitleLabel {
    return 2;
}

#pragma mark Export
+ (CGFloat)paddingForAutofitDistanceExportCollectables {
    //TODO: make like mediaquery
    switch ([STApp screenFamily]){
        case STScreenFamily47:
        case STScreenFamily55:
            return 11;
        default:
            return 7;
    }
}

+ (CGFloat)widthExportCollectableItem {
    return 32;
}

#pragma mark UIView / CALayer
+ (CGFloat)circularStrokeWidthDefault {
    return 1.5f;
}

+ (CGFloat)circularStrokeWidthBold {
    return 2;
}

#pragma mark STThumbnailGridView
+ (CGFloat)widthCellIcon {
    return 14;
}

#pragma mark STMainControl
+ (CGFloat)minimumHeightOfBottomControlArea {
    return 142;
}

+ (CGRect)bottomControlAreaFrame{
    return [self bottomControlAreaFrame:[[UIScreen mainScreen] bounds].size];
}

+ (CGRect)bottomControlAreaFrame:(CGSize)boundSize{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat needsCameraFrameHeight = screenSize.width * 1.331250f;
    CGFloat needsHeightOfBottomControlArea = screenSize.height-needsCameraFrameHeight;
    if(needsHeightOfBottomControlArea < STStandardLayout.minimumHeightOfBottomControlArea){
        needsHeightOfBottomControlArea = STStandardLayout.minimumHeightOfBottomControlArea;
    }
    return CGRectMake(0, screenSize.height-needsHeightOfBottomControlArea, screenSize.width, needsHeightOfBottomControlArea);
}

#pragma mark Settings Screen
+ (CGFloat)settingScreenGridRowSpacing {
    switch ([STApp screenFamily]){
        case STScreenFamily55:
            return -80;
        case STScreenFamily47:
            return -100;
        case STScreenFamily4:
            return -20;
        default:
            return 0;
    }
}
@end
