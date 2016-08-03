//
// Created by BLACKGENE on 2016. 4. 4..
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STPhotoItem+UIAccessory.h"
#import "SVGKImage.h"
#import "UIImage+STUtil.h"
#import "R.h"
#import "SVGKImage+STUtil.h"
#import "UIView+STUtil.h"
#import "BlocksKit.h"
#import "STCapturedImageSet+PostFocus.h"

@implementation STPhotoItem (UIAccessory)

#pragma mark Icon

- (UIImage *)iconImage {
    switch(self.origin){
        case STPhotoItemOriginElie:
            return [SVGKImage UIImageNamed:[R ico_cell_origin_elie] withSizeWidth:STStandardLayout.widthCellIcon];
        case STPhotoItemOriginQuickCamera:
            return [SVGKImage UIImageNamed:[R ico_cell_origin_quick] withSizeWidth:STStandardLayout.widthCellIcon];
        case STPhotoItemOriginManualCamera:
            return [SVGKImage UIImageNamed:[R ico_cell_origin_manual] withSizeWidth:STStandardLayout.widthCellIcon];
        case STPhotoItemOriginExportedFromRoom:
            return [SVGKImage UIImageNamed:[R ico_cell_origin_room] withSizeWidth:STStandardLayout.widthCellIcon];
        case STPhotoItemOriginAssetVideo:
            return [SVGKImage UIImageNamed:[R ico_video] withSizeWidth:STStandardLayout.widthCellIcon];
        case STPhotoItemOriginAssetLivePhoto:
            return [UIImage imageBundledCache:@"BadgeIcoLivePhoto"];
        case STPhotoItemOriginGIFExportedVideo:
            return [SVGKImage UIImageNamed:[R ico_animatable] withSizeWidth:STStandardLayout.widthCellIcon];
        case STPhotoItemOriginPostFocus:{
            switch([self.sourceForCapturedImageSet postFocusMode]){
                case STPostFocusMode5Points:
                    return [SVGKImage UIImageNamed:[R ico_cell_origin_postfocus_point] withSizeWidth:STStandardLayout.widthCellIcon];
                case STPostFocusModeVertical3Points:
                    return [SVGKImage UIImageNamed:[R set_postfocus_vertical_3point] withSizeWidth:STStandardLayout.widthCellIcon];
                case STPostFocusModeFullRange:
                    return [SVGKImage UIImageNamed:[R set_postfocus_fullrange] withSizeWidth:STStandardLayout.widthCellIcon];
                default:
                    return nil;
            }
        }
        default:
            return nil;
    }
}

DEFINE_ASSOCIATOIN_KEY(kPresentIconView)

NSString * const TagNameForIconView = @"com.stells.STPhotoItem.TagNameForIconView";
- (UIImageView *)presentIcon:(UIView *)containerView{
    UIImage * iconImage = self.iconImage;
    CGRect imageRect = CGRectMakeValue(STStandardLayout.widthCellIcon);
    BOOL presented = YES;

    UIImageView * iconView = [containerView bk_associatedValueForKey:kPresentIconView];

    if(!iconView && iconImage){
        iconView = [[UIImageView alloc] initWithImage:iconImage];
        iconView.tagName = TagNameForIconView;
        iconView.shadowEnabledForOverlay = YES;

        CGSize iconViewContainerSize = imageRect.size;//CGRectInset(imageRect, -4, -4).size;
        UIImageView * iconViewContainer = [[UIImageView alloc] initWithSize:iconViewContainerSize];
//        iconViewContainer.image = [[CAShapeLayer circle:iconViewContainerSize.width color:[[STStandardUI pointColor] colorWithAlphaComponent:[STStandardUI alphaForDimmingWeak]]] UIImage];
        iconViewContainer.contentMode = UIViewContentModeScaleAspectFit;
        [iconViewContainer addSubview:iconView];
        iconViewContainer.x = iconViewContainer.y = 12;

        [containerView addSubview:iconViewContainer];

    }else{
        if(iconImage){
            iconView.superview.visible = YES;
            iconView.image = iconImage;;
        }else{
            presented = NO;
            [self unpresentIcon:containerView];
        }
    }

    if(presented){
        iconView.size = self.origin==STPhotoItemOriginAssetLivePhoto ? CGRectInset(imageRect, -2, -2).size : imageRect.size;
        [iconView centerToParent];
    }

    NSAssert(!iconView || [iconView.superview viewsWithTagNameFromAllSubviews:TagNameForIconView].count==1, @"iconViewContainer must contains child icon view which tags name is TagNameForIconView");
    [containerView bk_associateValue:iconView withKey:kPresentIconView];
    return (UIImageView *)iconView.superview;
}

- (void)unpresentIcon:(UIView *)containerView {
    UIImageView * iconView = [containerView bk_associatedValueForKey:kPresentIconView];
    NSAssert(!iconView || [containerView isEqual:iconView.superview.superview],@"given containerView must already contains iconView");
    iconView.image = nil;
    iconView.superview.visible = NO;
}

- (void)disposeIcon:(UIView *)containerView{
    UIImageView * iconView = [containerView bk_associatedValueForKey:kPresentIconView];
    NSAssert(!iconView || [containerView isEqual:iconView.superview.superview],@"given containerView must already contains iconView");
    NSAssert(!iconView || [iconView.superview viewsWithTagNameFromAllSubviews:TagNameForIconView].count==1, @"iconViewContainer must contains child icon view which tags name is TagNameForIconView");
    [iconView.superview clearAllOwnedImagesIfNeededAndRemoveFromSuperview:NO];
    [containerView bk_associateValue:nil withKey:kPresentIconView];
}
@end