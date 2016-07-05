//
// Created by BLACKGENE on 2015. 8. 26..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <UIColor+BFPaperColors/UIColor+BFPaperColors.h>
#import "STAppInfoView.h"
#import "STStandardButton.h"
#import "STUIContentAlignmentView.h"
#import "NSArray+STUtil.h"
#import "SCGridView.h"
#import "TTTAttributedLabel.h"
#import "UIView+STUtil.h"
#import "UIViewController+STStandard.h"
#import "STMainControl.h"
#import "NSString+STUtil.h"
#import "UIViewController+URL.h"
#import "STExporterFacebook.h"
#import "STExporterTwitter.h"
#import "STExporterInstagram.h"
#import "NSURL+STUtil.h"
#import "R.h"

#import "STPhotoSelector.h"
#import "STPermissionManager.h"
#import "NSObject+STUtil.h"
#import "STGIFCAppSetting.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "STApp+Logger.h"
#import "UIImage+STUtil.h"
#import "UIView+Shake.h"
#import "STElieStatusBar.h"
#import "SVGKFastImageView.h"
#import "SVGKFastImageView+STUtil.h"
#import "STUIApplication.h"

@interface STAppInfoItemParam : NSObject
typedef NS_ENUM(NSInteger, STAppInfoItem) {
    STAppInfoItem_Undefined,
    STAppInfoItem_CS,
    STAppInfoItem_CS_Tell,
    STAppInfoItem_CS_Feedback,
    STAppInfoItem_CS_LinkAppStore,
    STAppInfoItem_CS_Note,

    STAppInfoItem_Site,
    STAppInfoItem_Site_Facebook,
    STAppInfoItem_Site_Twitter,
    STAppInfoItem_Site_Instagram,
    STAppInfoItem_Site_Vimeo,
    STAppInfoItem_Site_Homepage,

    STAppInfoItem_Permission,
    STAppInfoItem_Permission_Camera,
    STAppInfoItem_Permission_Photos,
    STAppInfoItem_Permission_Location,

    STAppInfoItem_System,
    STAppInfoItem_System_ClearPhotos,
    STAppInfoItem_System_RestoreAll,
    STAppInfoItem_System_BuyAll,

    STAppInfoItem_Notices_LinkPrivacy,
    STAppInfoItem_Notices_LinkTermsOfUse,
    STAppInfoItem_Notices_Attribution,

    STAppInfoItem__count
};

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) BOOL toggle;
@property (nonatomic, assign) BOOL small;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL disabled;
@property (nonatomic, readwrite) NSString *imageName;
@property (nonatomic, assign) BOOL presentJustImage;
@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) NSString *subtitle;
@property (nonatomic, readwrite) NSString *url;
@property (nonatomic, readwrite) NSString *fallbackUrl;
@property (nonatomic, readwrite) NSString *content;
@property (nonatomic, readwrite) UIColor *foregroundolor;
@property (nonatomic, readwrite) UIColor *backgroundColor;
@property (nonatomic, readwrite) id badgeContent;
@property (nonatomic, readwrite) UIColor *badgeColor;
@property (copy) void (^blockForTapped)(UIView * __weak targetView, STAppInfoItemParam * __weak paramSelf);
@property (copy) void (^blockForCreated)(UIView * __weak targetView, STAppInfoItemParam * __weak paramSelf);
@end
@implementation STAppInfoItemParam
@end

/*
 * App Info Main View
 */
@interface STAppInfoView ()
@property (nullable, nonatomic, readwrite) UIActivityViewController * shareController;
@end

@implementation STAppInfoView {

}

- (void)dealloc {
    oo(@"STAppInfoView - dealloc");
    [self st_removeAllSubviews];

    _bottomView = nil;
    _gridView.cells = nil;
    _gridView = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.showsVerticalScrollIndicator = NO;
        self.clipsToBounds = NO;

        Weaks
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Wself updatePermissions];
            });
        }];

        if([STGIFCApp canTryRestoreAll]){
            [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueueOnlyOnce:self forName:STNotificationAppProductRestoreAllSucceed usingBlock:^(NSNotification *note, id observer) {
                [Wself updateAppInfoToContentView:STAppInfoItem_System_RestoreAll];
            }];
        }
    }
    return self;
}

- (void)setContents {
    //performed : 0.122135s

    if(!_gridView){
        /*
         * initial
         */

        _gridView = [[SCGridView alloc] initWithSize:[STPhotoSelector sharedInstance].previewView.size];
        [self addSubview:_gridView];
        self.contentSize = _gridView.boundsSize;

        [self createGridCellContentViews];

        /*
         * Bottom
         */
        _bottomView = [[STUIContentAlignmentView alloc] initWithSize:[STMainControl sharedInstance].size];
        _bottomView.bottom = self.height;
        [self addSubview:_bottomView];
        [_bottomView centerToParentHorizontal];

        /*
         * close button
         */
        _closeButton = [[STStandardButton alloc] initWithSizeWidth:[STStandardLayout widthMainSmall]];
        [_closeButton setButtons:@[R.go_back] colors:nil style:STStandardButtonStylePTTP];
        _closeButton.x = [[[STMainControl sharedInstance] subControl] leftButton].x;
        [_bottomView addSubview:_closeButton];
        [_closeButton centerToParentVertical];

        /*
         * elie
         */
        SVGKFastImageView * elieLogo = [SVGKFastImageView viewWithImageNamedNoCache:[R logo_elie] sizeWidth:[STStandardLayout widthMainSmall]];
        elieLogo.right = [[[STMainControl sharedInstance] subControl] rightButton].right;
        elieLogo.userInteractionEnabled = YES;
        [elieLogo whenTapped:^{
            [self st_rootUVC].standardPresentationStyle = STStandardPresentationStyleFullScreen;
            [[self st_rootUVC] openURL:[STGIFCApp elieSiteUrl] fallbackUrl:nil relatedView:nil];
        }];
        [_bottomView addSubview:elieLogo];
        [elieLogo centerToParentVertical];

        //set title view
        STStandardButton *titleIconView = [STStandardButton mainSmallSize];
        titleIconView.autoAdjustVectorIconImagePaddingIfNeeded = NO;
        [titleIconView setButtons:@[[R icon]] style:STStandardButtonStyleRawImage];
        titleIconView.titleLabelPositionedGapFromButton = -6;
        
#if DEBUG
        titleIconView.subtitleText =[NSString stringWithFormat:@"%@ %@", [STGIFCApp appVersion],[STGIFCApp buildVersion]];
#else
        titleIconView.subtitleText =[NSString stringWithFormat:@"%@", [STGIFCApp appVersion]];
#endif
        titleIconView.titleText = @"";
        _bottomView.contentView = titleIconView;

        
        if ([STApp isInSimulator]){
            _bottomView.backgroundColor = [UIColor redColor];
        }

    }else{
        /*
         * globally update
         */
        [self updateContent];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for(UIView* subview in [self.subviews reverseObjectEnumerator]){
        if(![subview isHidden] && subview.userInteractionEnabled){
            CGPoint p = [subview convertPoint:point fromView:self];
            if([subview pointInside:p withEvent:event]){
                return YES;
            }
        }
    }
    return [super pointInside:point withEvent:event];
}

- (void)updateContent{
    [self updateAppInfoToContentView:STAppInfoItem_System_ClearPhotos];
}

- (void)removeContents {

}

- (NSArray *)createGridCellContentViews {
    NSMutableArray * cells = [NSMutableArray array];

    //Terms of Use
    [cells addObject:[self makeLabel:STAppInfoItem_Notices_LinkTermsOfUse]];
    [cells addObject:[self makeLabel:STAppInfoItem_Notices_LinkPrivacy]];
//    [cells addObject:[self makeLabel:STAppInfoItem_Notices_Attribution]];

    //Permission
//    [cells addObject:[self makeButton:STAppInfoItem_Permission_Camera]];
//    [cells addObject:[self makeButton:STAppInfoItem_Permission_Location]];
//    [cells addObject:[self makeButton:STAppInfoItem_Permission_Photos]];

    //Control App
    [cells addObject:[self makeButton:STAppInfoItem_System_RestoreAll]];

    [cells addObject:[self makeButton:STAppInfoItem_System_ClearPhotos]];
//    [cells addObject:[self makeButton:STAppInfoItem_System_BuyAll]];

    //Social
    STUIView *socialRowCell = [[STUIView alloc] init];
    //TODO: locale 코드롤(언어코드말고 보고 가름
    [socialRowCell addSubview:[self makeButton:STAppInfoItem_Site_Facebook]];
    [socialRowCell addSubview:[self makeButton:STAppInfoItem_Site_Twitter]];
    [socialRowCell addSubview:[self makeButton:STAppInfoItem_Site_Instagram]];
//    [socialRowCell addSubview:[self makeButton:STAppInfoItem_Site_Vimeo]];
    [socialRowCell addSubview:[self makeButton:STAppInfoItem_Site_Homepage]];
    if(STScreenFamily47 > [STApp screenFamily]){
        [socialRowCell st_gridSubviewsAsCenter:20 rowHeight:[socialRowCell st_maxSubviewHeight] * 1.5f column:socialRowCell.subviews.count];
    }else{
        [socialRowCell st_gridSubviewsAsCenter:25 rowHeight:[socialRowCell st_maxSubviewHeight] * 1.5f column:socialRowCell.subviews.count];
    };
    [cells addObject:socialRowCell];

    //Contact
    STUIView *contactRowCell = [[STUIView alloc] init];
    [contactRowCell addSubview:[self makeButton:STAppInfoItem_CS_Tell]];
    [contactRowCell addSubview:[self makeButton:STAppInfoItem_CS_LinkAppStore]];
    [contactRowCell addSubview:[self makeButton:STAppInfoItem_CS_Feedback]];
    [contactRowCell addSubview:[self makeButton:STAppInfoItem_CS_Note]];

    if(STScreenFamily47 > [STApp screenFamily]){
        [contactRowCell st_gridSubviewsAsCenter:25 rowHeight:[socialRowCell st_maxSubviewHeight] * 1.5f column:contactRowCell.subviews.count];
    }else{
        [contactRowCell st_gridSubviewsAsCenter:35 rowHeight:[socialRowCell st_maxSubviewHeight] * 1.5f column:contactRowCell.subviews.count];
    };

    [cells addObject:contactRowCell];

    /*
     * Layout Cells
     */
    _gridView.schema = @[@(2), @(1),@(1), @(1), @(1)];
    _gridView.blockForOutsetRowHeight = ^CGFloat(CGFloat rowHeight, NSUInteger indexOfRow) {
        if(indexOfRow==0){
            return -rowHeight/1.5f;
        }
        else if(indexOfRow==1){
            return rowHeight/3;
        }
        else if(indexOfRow==2){
            return rowHeight/8;
        }
        else if(indexOfRow==3){
            return rowHeight/4;
        }
        else if(indexOfRow==4){
            return -rowHeight/2;
        }
        return 0;
    };

    if(STScreenFamily47 > [STApp screenFamily]){
        _gridView.colSpacing = -60;
    }else{
        _gridView.colSpacing = -80;
    };

    _gridView.cells = [cells mapWithIndex:^id(UIView *contentView, NSInteger index) {
        STUIContentAlignmentView *_cellView = [[STUIContentAlignmentView alloc] init];
        _cellView.touchInsidePolicy = STUIViewTouchInsidePolicyContentInside;
        _cellView.contentView = contentView;
//        _cellView.backgroundColor = [[UIColor randomFlatColor] colorWithAlphaComponent:.2];

        /*
         * STAppInfoItem_Notices
         */
        if(NSLocationInRange(index, NSMakeRange(0,2))){
            _cellView.contentViewVerticalAlignment = UIControlContentVerticalAlignmentTop;
            _cellView.contentViewInsets = UIEdgeInsetsMake(0,0,-8,0);
        }

        return _cellView;
    }];

    return cells;
}

- (STAppInfoItemParam *)appInfoItemParam:(STAppInfoItem)item {
    Weaks

    STAppInfoItemParam *p = [[STAppInfoItemParam alloc] init];
    p.tag = item;

    switch(item){
        case STAppInfoItem_Notices_LinkPrivacy:
            p.title = NSLocalizedString(@"Privacy", @"");
            p.url = [STGIFCApp privacyInfoUrl];
            p.small = YES;
            break;
        case STAppInfoItem_Notices_LinkTermsOfUse:
            p.title = NSLocalizedString(@"main.appinfo.termsofuse", @"");
            p.url = [STGIFCApp termsInfoUrl];
            p.small = YES;
            break;
        case STAppInfoItem_Notices_Attribution:
            p.title = NSLocalizedString(@"main.appinfo.acknowledgements", @"");
            p.url = [STGIFCApp attributionInfoUrl];
            p.small = YES;
            break;

        case STAppInfoItem_CS:
            break;
        case STAppInfoItem_CS_Feedback:
            p.imageName = [R set_info_contact_feedback];
            p.title = NSLocalizedString(@"main.appinfo.feedback", @"");
            p.url = [[NSString stringWithFormat:@"mailto:ask@postfoc.us?subject=%@ %@,&body=\n\n\n%@\n%@"
                    , NSLocalizedString(@"Hello", nil)
                    , [STGIFCApp displayName]
                    , NSLocalizedString(@"main.appinfo.feedback.noti",nil)
                    , [NSString stringWithFormat:@"%@|%d|%d|%d"
                            , STGIFCAppSetting.get._guid
                            , STGIFCAppSetting.get.postFocusMode
                            , [STGIFCAppSetting get].afterManualCaptureAction
                            , [STGIFCAppSetting get].captureOutputSizePreset
                    ]
            ] escapeForQuery];

            break;
        case STAppInfoItem_CS_Note:
            p.imageName = [R set_info_contact_note];
            p.title = NSLocalizedString(@"main.appinfo.note", @"");
            p.url = [STGIFCApp releaseNoteUrl];
            p.blockForCreated = ^(UIView *targetView, STAppInfoItemParam *paramSelf) {
                if([targetView isKindOfClass:STStandardButton.class]){
                    STStandardButton * targetButton = ((STStandardButton *)targetView);
                    if([[STGIFCAppSetting get] isFirstLaunchSinceLastBuild]){
                        targetButton.badgeText = STStandardButtonsBadgeTextNew;
                    }else{
                        [[STGIFCAppSetting get] checkNewReleaseNoteIfPossible:^(BOOL updated) {
                            if (updated) {
                                targetButton.badgeText = STStandardButtonsBadgeTextNew;
                            }
                        }];
                    }
                }
            };
            p.blockForTapped = ^(UIView *targetView, STAppInfoItemParam *paramSelf) {
                STStandardButton * targetButton = ((STStandardButton *)targetView);
                if(targetButton.badgeText){
                    targetButton.badgeText = nil;
                    [[STGIFCAppSetting get] touchNewReleaseNoteIfNeeded];
                }
            };
            break;
        case STAppInfoItem_CS_LinkAppStore:
            p.imageName = [R set_info_contact_rateus];
            p.title = NSLocalizedString(@"main.appinfo.rate", @"");
            p.url = [NSURL URLForAppstoreApp:[STGIFCApp appstoreId]].absoluteString;
            break;
        case STAppInfoItem_CS_Tell:{
            p.imageName = [R set_info_contact_spread];
            p.title = NSLocalizedString(@"main.appinfo.tell", @"");
            p.blockForTapped = ^(UIView *targetView, STAppInfoItemParam *paramSelf) {
                Wself.shareController = [[UIActivityViewController alloc] initWithActivityItems:@[
                        [NSString stringWithFormat:@"%@ %@", [STGIFCApp marketingTitle], [STGIFCApp siteUrl]],
                        [NSURL URLForAppstoreWeb:[STGIFCApp appstoreId]],
                        [UIImage imageBundled:@"marketingAppIcon.png"]
                ] applicationActivities:nil];

                Wself.shareController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
                    Strongs
                    Sself.shareController = nil;
                };
                [[Wself st_rootUVC] presentViewController:Wself.shareController animated:YES completion:nil];
            };
//            p.url = [[NSString stringWithFormat:@"sms:?body=Elie\n%@&attachments=%@", [NSURL URLForAppstoreWeb:[STGIFCApp appstoreId]], [STGIFCApp iconPathOrCreateToPublish]] escapeForQuery];
        }
            break;
        case STAppInfoItem_Site:
            break;
        case STAppInfoItem_Site_Facebook:
            p.imageName = R.export.facebook;
            p.small = YES;
            p.presentJustImage = YES;
            p.url = [STExporterFacebook appURLStringWithUserName:@"1728892824066204"];
            p.fallbackUrl = [STGIFCApp urlToForwardSNSService:@"facebook"];
            break;
        case STAppInfoItem_Site_Twitter:
            p.imageName = R.export.twitter;
            p.small = YES;
            p.presentJustImage = YES;
            p.url = [STExporterTwitter appURLStringWithUserName:@"lfcamera"];
            p.fallbackUrl = [STExporterTwitter webURLStringWithUserName:@"lfcamera"];
            break;
        case STAppInfoItem_Site_Instagram:
            p.imageName = R.export.instagram;
            p.small = YES;
            p.presentJustImage = YES;
            p.url = [STExporterInstagram appURLStringWithUserName:@"lfcamera"];
            p.fallbackUrl = [STExporterInstagram webURLStringWithUserName:@"lfcamera"];
            break;
//        case STAppInfoItem_Site_Vimeo:
//            p.imageName = R.export.vimeo;
//            p.small = YES;
//            p.presentJustImage = YES;
//            p.url = @"https://vimeo.com/user46402004";
//            break;
        case STAppInfoItem_Site_Homepage:
            p.imageName = [R set_info_contact_site];
            p.small = YES;
            p.presentJustImage = YES;
//            p.title = NSLocalizedString(@"main.appinfo.about", @"");
            p.url = [STGIFCApp localizedSiteUrl];
            break;

        case STAppInfoItem_Permission:
            break;

        case STAppInfoItem_Permission_Camera:{
            p.imageName = [R ico_camera];
            p.title = NSLocalizedString(@"main.appinfo.permission.camera", @"");
            [self setupPermissionsToParam:[STPermissionManager camera] param:p];
        }
            break;
        case STAppInfoItem_Permission_Photos:
            p.imageName = [R go_roll];
            p.title = NSLocalizedString(@"main.appinfo.permission.photos", @"");
            [self setupPermissionsToParam:[STPermissionManager photos] param:p];

            break;
        case STAppInfoItem_Permission_Location:
            p.imageName = [R set_info_perm_loc];
            p.title = NSLocalizedString(@"main.appinfo.permission.location", @"");
            [self setupPermissionsToParam:[STPermissionManager location] param:p];
            break;

        case STAppInfoItem_System:break;
        case STAppInfoItem_System_ClearPhotos:{
            p.imageName = [R go_remove];
            p.title = NSLocalizedString(@"main.appinfo.deletephotos", @"");
            p.disabled = !(p.selected = [[STPhotoSelector sharedInstance] allAvailablePhotoItems].count > 0);
            p.toggle = YES;
            p.blockForTapped = p.disabled ? nil : ^(UIView * __weak targetView, STAppInfoItemParam * __weak paramSelf) {
                STStandardButton * button = (STStandardButton *) [self appInfoContentView:STAppInfoItem_System_ClearPhotos];

                //clear elie room
                button.userInteractionEnabled = NO;
                button.selectedState = YES;

                [[STPhotoSelector sharedInstance] deleteAllPhotos:^(BOOL succeed) {
                    if(succeed){
                        p.blockForTapped = nil;
                        p.selected = NO;
                        p.disabled = YES;
                        [Wself updateAppInfoToContentView:button param:p];
                    }else{
                        p.selected = YES;
                        button.selectedState = YES;
                    }
                    button.userInteractionEnabled = YES;
                }];
            };
        }
            break;
        case STAppInfoItem_System_RestoreAll:{
            p.imageName = [R set_info_setting_restore_all];
            p.title = NSLocalizedString(@"main.appinfo.restoreall", @"");
            p.selected = [STGIFCApp canTryRestoreAll];
            p.disabled = !p.selected;
            p.toggle = YES;
            p.blockForTapped = p.disabled ? nil : ^(UIView * __weak targetView, STAppInfoItemParam * __weak paramSelf) {
                STStandardButton * button = (STStandardButton *) [self appInfoContentView:STAppInfoItem_System_RestoreAll];
                button.userInteractionEnabled = NO;
                [button startSpinProgress:[UIColor whiteColor]];
                [STGIFCApp restoreAllProductIfNeeded:^(NSArray *transactions) {
                    if (transactions.count) {
                        p.blockForTapped = nil;
                        p.selected = NO;
                        p.disabled = YES;
                    }
                    button.userInteractionEnabled = YES;
                    [button stopSpinProgress];
                } failure:^(NSError *error) {
                    p.selected = YES;
                    button.selectedState = YES;
                    [button stopSpinProgress];
                    button.userInteractionEnabled = YES;
                }];

                [STGIFCApp logUnique:@"RestoreAll"];
            };
        }
            break;
        case STAppInfoItem_System_BuyAll:{
            p.imageName = [R set_info_setting_buy_all];
            p.title = NSLocalizedString(@"main.appinfo.buyall", @"");
//            p.subtitle = NSLocalizedString(@"main.appinfo.buyall.save50", @"");
//            p.url = [NSURL URLForAppstoreApp:[STGIFCApp paidElieAppstoreId]].absoluteString;
            p.blockForTapped = ^(UIView *targetView, STAppInfoItemParam *paramSelf) {
                [STGIFCApp logUnique:@"BuyAll"];
            };
        }
            break;
        default:
            p = nil;
            break;
        case STAppInfoItem_Undefined:break;
        case STAppInfoItem__count:break;
    }
    return p;
};

- (UIView *)appInfoContentView:(STAppInfoItem)item{
    for(STUIContentAlignmentView * view in _gridView.cells){
        UIView * _v = [view viewWithTagFromAllSubviews:item];
        if(_v){
            return _v;
        }
    }
    return nil;
}

#pragma mark Update ContentView

- (void)updateAppInfoToContentView:(STAppInfoItem)item{
    [self updateAppInfoToContentView:[self appInfoContentView:item] param:[self appInfoItemParam:item]];
}

- (void)updateAppInfoParamToContentView:(STAppInfoItem)item param:(STAppInfoItemParam *)param{
    [self updateAppInfoToContentView:[self appInfoContentView:item] param:param];
}

- (void)updateAppInfoToContentView:(UIView *)contentView param:(STAppInfoItemParam *)param{
    if([contentView isKindOfClass:STStandardButton.class]){
        [self setButtonFrom:(STStandardButton *) contentView param:param];

    }else if([contentView isKindOfClass:TTTAttributedLabel.class]){
        [self setLabelFrom:(TTTAttributedLabel *) contentView param:param];
    }
}

#pragma mark Creation - Button
- (STStandardButton *)makeButton:(STAppInfoItem)which {
    return [self makeButtonFrom:[self appInfoItemParam:which]];
}

- (STStandardButton *)makeButtonFrom:(STAppInfoItemParam *)param {
    STStandardButton * button = param.small ? [STStandardButton subAssistanceBigSize] : [STStandardButton subSmallSize];
    button.tag = param.tag;
    [self setButtonFrom:button param:param];
    !param.blockForCreated?:param.blockForCreated(button, param);

    return button;
}

- (void)setButtonFrom:(STStandardButton *)button param:(STAppInfoItemParam *)param{
    //selection
    button.toggleEnabled = param.toggle;
    button.denyDeselectWhenAlreadySelected = !param.toggle && param.selected;
    button.denySelect = param.disabled;
    //label
    button.titleText = param.title;
    button.subtitleText = param.subtitle;
    //style default
    STStandardButtonStyle style = STStandardButtonStylePTTP;
    //style weight priority 3 - toggle
    if(param.toggle){
        style = STStandardButtonStylePTBT;
    }
    //style weight priority 2 - color
    if(param.foregroundolor && param.backgroundColor){
        style = STStandardButtonStyleDefault;
    }
    //style weight priority 1 - use image
    if(param.presentJustImage){
        button.autoAdjustVectorIconImagePaddingIfNeeded = NO;
        style = STStandardButtonStyleRawImage;
    }
    if(param.toggle){
        [button setButtons:@[param.imageName]
                    colors:@[param.foregroundolor?:[UIColor paperColorGray300]]
                  bgColors:@[param.backgroundColor?: [STStandardUI pointColor]]
                     style: style];
    }else{
        [button setButtons:@[param.imageName]
                    colors:param.foregroundolor?@[param.foregroundolor]:nil
                  bgColors:param.backgroundColor?@[param.backgroundColor]:nil
                     style:style];
    }
    //selection
    button.selectedState = param.selected;
    button.titleLabelWidthAutoFitToSuperview = YES;
//    button.titleLabelPositionedGapFromButton = style==STStandardButtonStylePTTP ? 0 : [STStandardLayout sizeBulletBig].height;
    //badge
    if(param.badgeContent){
        if([param.badgeContent isKindOfClass:UIImage.class]){
            button.badgeImage = param.badgeContent;
        } else if([param.badgeContent isKindOfClass:NSString.class]){
            button.badgeText = param.badgeContent;
        }
        button.badgeColor = param.badgeColor;
    }
    //selected block
    Weaks
    [button whenSelected:^(STSelectableView * selectedView, NSInteger index) {
        [Wself open:param relatedView:selectedView];

        [STGIFCApp logEvent:@"AppInfoItem" key:[@(param.tag) stringValue]];
    }];

    //re assign subtitle?
    button.subtitleText = param.subtitle;

    //disable - alpha
    button.currentButtonView.alpha = param.disabled ? [STStandardUI alphaForDimming] : 1;
}

#pragma mark Creation - Label
- (TTTAttributedLabel *)makeLabel:(STAppInfoItem)which {
    return [self makeLabelFrom:[self appInfoItemParam:which]];
}

- (TTTAttributedLabel *)makeLabelFrom:(STAppInfoItemParam *)param {
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithSize:CGSizeMake(0,15)];
    label.tag = param.tag;
    [self setLabelFrom:label param:param];
    return label;
}

- (void)setLabelFrom:(TTTAttributedLabel *)label param:(STAppInfoItemParam *)param{
    label.font = param.small ? [STStandardUI defaultFontForSubLabel] : [STStandardUI defaultFontForLabel];
    label.textColor = [STStandardUI textColorLighten];
    label.lineBreakMode = NSLineBreakByClipping;
    label.textAlignment = NSTextAlignmentCenter;
    if(![label.text isEqualToString:param.title]){
        label.numberOfLines = [param.title st_numberOfNewLines];
    }
    label.text = param.title;
    label.userInteractionEnabled = param.url || param.blockForTapped || !param.disabled;
    Weaks
    [label whenTap:label.userInteractionEnabled ? ^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [UIView st_setDelayedToggleAlpha:@[label] delay:0 duration:.2 minAlpha:.5 maxAlpha:1];
        [Wself open:param relatedView:sender.view];

    } : nil];
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
}

#pragma mark Open Param
- (void)open:(STAppInfoItemParam *)param relatedView:(UIView *)relatedView{
    if(param.blockForTapped){
        param.blockForTapped(relatedView, param);
    }
    if(param.url){
        [self openUrl:param relatedView:relatedView];
    }
}

#pragma mark Urls
- (void)openUrl:(STAppInfoItemParam *)param relatedView:(UIView *)relatedView{
    UIViewController * controller = self.parentViewController;

    /*
     * define pop over style
     */
    switch(param.tag) {
        case STAppInfoItem_Notices_LinkPrivacy:
        case STAppInfoItem_Notices_LinkTermsOfUse:
        case STAppInfoItem_Notices_Attribution:
        case STAppInfoItem_Site_Homepage:
        case STAppInfoItem_CS_Feedback:
        case STAppInfoItem_CS_Tell:
        case STAppInfoItem_CS_Note:
        {
            relatedView = nil;
            controller.standardPresentationStyle = STStandardPresentationStyleFullScreen;
        }
            break;
        default:
            controller.standardPresentationStyle = STStandardPresentationStylePopover;
            break;
    }

    /*
     * append param - appid
     */
    NSString * url = [param.url hasPrefix:[STGIFCApp siteUrl]] ?
            [[NSURL URLWithString:param.url] st_query:@{
                    STAppIdentificationURLQueryKey : [STApp identification],
                    @"guid" : [STGIFCAppSetting get]._guid
            }].absoluteString : param.url;

    [controller openURL:url fallbackUrl:param.fallbackUrl relatedView:relatedView];
}

#pragma mark Permissions
- (void)setupPermissionsToParam:(id<STPermissionsStatus>)permission param:(STAppInfoItemParam *)p{
    STAppInfoItem item = (STAppInfoItem) p.tag;
    WeakObject(p) _weakParam = p;

    p.toggle = YES;

    if(permission.status == STPermissionStatusAuthorized){
        p.selected = YES;
        p.blockForTapped = ^(UIView * __weak targetView, STAppInfoItemParam * __weak paramSelf) {
            ((STStandardButton *)targetView).selectedState = YES;
            [permission alertNeeded];
        };

    }else{
        p.selected = NO;
        p.blockForTapped = ^(UIView * __weak targetView, STAppInfoItemParam * __weak paramSelf) {
            ((STStandardButton *)targetView).selectedState = NO;

            if(permission.status == STPermissionStatusDenied || permission.status == STPermissionStatusRestricted){
                [permission alertNeeded];
            }
            else if(permission.status == STPermissionStatusNotDetermined || permission.status == STPermissionStatusUninitialized){
                Weaks
                [permission prompt:^(STPermissionStatus status) {
                    ((STStandardButton *)targetView).selectedState = status == STPermissionStatusAuthorized;
                    [Wself updateAppInfoParamToContentView:(STAppInfoItem) _weakParam.tag param:_weakParam];
                }];
            };
        };
    }
}

- (void)updatePermissions{
    oo(@"updatePermissions");
    [self updateAppInfoToContentView:STAppInfoItem_Permission_Camera];
    [self updateAppInfoToContentView:STAppInfoItem_Permission_Photos];
    [self updateAppInfoToContentView:STAppInfoItem_Permission_Location];

}

- (void)expressWhenPresentIfNeeded:(BOOL)force {
    if(force || [[STGIFCAppSetting get] isFirstLaunchSinceLastBuild]){
        STStandardButton * button = (STStandardButton *) [self appInfoContentView:STAppInfoItem_CS_LinkAppStore];
        [button.currentButtonView shakeWithOptions:SCShakeOptionsDirectionRotate | SCShakeOptionsAutoreverse force:0.4 duration:2 iterationDuration:0.5 completionHandler:nil];
    }

}
@end
