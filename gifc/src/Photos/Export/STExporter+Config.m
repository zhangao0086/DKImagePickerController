//
// Created by BLACKGENE on 2015. 2. 12..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STExporter+Config.h"
#import "STExporterFacebook.h"
#import "STExporterInstagram.h"
#import "STExporterFacebookMessenger.h"
#import "STExporterWhatsApp.h"
#import "STExporterWeChat.h"
#import "STExporterTwitter.h"
#import "STExporterOpenIn.h"
#import "STExporterShare.h"
#import "STExporterLine.h"
#import "STExporterSaveToLibrary.h"
#import "STPhotoSelector.h"
#import "STExporterKik.h"
#import "NSString+STUtil.h"
#import "R.h"
#import "STExporterTumblr.h"
#import "STCapturedImageSet.h"
#import "UIColor+BFPaperColors.h"
#import "STExporterSaveToPhotos.h"

@implementation STExporter (Config)

// share kit matrix : https://github.com/ShareKit/ShareKit/blob/master/Documentation/sharer_itemProperty_support_matrix.xlsx
// http://handleopenurl.com/
// http://dev.wechatapp.com/document/sdk-en/ios/protocol_w_x_api_delegate-p.html
// http://wiki.open.qq.com/index.php?title=IOS_API调用说明&oldid=44404

#pragma mark Icon

- (NSString *)iconImageName {
    return [self.class iconImageName:self.type];
}

- (NSString *)logoImageName {
    return [self.class logoImageName:self.type];
}


+ (NSString *)iconImageName:(STExportType)type; {
    STPhotoViewType mode = [STPhotoSelector sharedInstance].type;
    STPhotoSource source = [STPhotoSelector sharedInstance].source;

    switch (type){
        case STExportTypeSaveToLibrary:{
            return STPhotoSourceRoom==source ? R.export.transfer : R.export.save;
        }
        case STExportTypeSaveToPhotos: return R.export.ios_photos;
        case STExportTypeWhatsApp:return R.export.whatsapp;
        case STExportTypeFacebookMessenger:return R.export.fbm;
        case STExportTypeWeChat:return R.export.wechat;
        case STExportTypeLine:return R.export.line;
        case STExportTypeKik:return R.export.kik;
        case STExportTypeInstagram:return R.export.instagram;
        case STExportTypeFacebook:return R.export.facebook;
        case STExportTypeTumblr:return R.export.tumblr;
        case STExportTypeTwitter:return R.export.twitter;
        case STExportTypeOpenIn:return R.export.openin;
        case STExportTypeShare:return R.export.share;
        default:
            NSAssert(NO, @"Not defined export type");
            return nil;
    }
}

+ (NSString *)logoImageName:(STExportType)type; {
    switch (type){
        case STExportTypeTumblr:return R.export.tumblr_logo;
        default:
            return nil;
    }
}

- (UIColor *)iconImageBackgroundColor{
    return [self.class iconImageBackgroundColor:self.type];
}

+ (UIColor *)iconImageBackgroundColor:(STExportType)type; {
    switch (type){
        case STExportTypeWhatsApp:return UIColorFromRGB(0x41F26D);
        case STExportTypeFacebookMessenger:return [UIColor whiteColor];
        case STExportTypeWeChat:return UIColorFromRGB(0x5EA90A);
        case STExportTypeLine:return UIColorFromRGB(0x54EA1F);
        case STExportTypeKik:return UIColorFromRGB(0x80C000);
        case STExportTypeInstagram:return [UIColor blackColor];
        case STExportTypeFacebook:return UIColorFromRGB(0x3A589C);
        case STExportTypeTumblr: return UIColorFromRGB(0x35465E);
        case STExportTypeTwitter:return UIColorFromRGB(0x21A9E3);
        case STExportTypeSaveToLibrary:
        case STExportTypeSaveToPhotos:
        case STExportTypeOpenIn:
        case STExportTypeShare:
            return [STStandardUI blankBackgroundColor];
        default:
            NSAssert(NO, @"Not defined export type");
            return nil;
    }
}

#pragma mark Exporter
+ (instancetype)exporterBlank {
    return [[STExporter alloc] initWithType:STExportType_blank];
}

+ (instancetype)exporterWithType:(STExportType)type; {
    return [(STExporter *) [[self exporterClassWithType:type] alloc] initWithType:type];
}

+ (Class)exporterClassWithType:(STExportType)type; {
    switch (type){
        case STExportTypeOpenIn:
            return STExporterOpenIn.class;

        case STExportTypeShare:
            return STExporterShare.class;

        case STExportTypeInstagram:
            return STExporterInstagram.class;

        case STExportTypeTumblr:
            return STExporterTumblr.class;

        case STExportTypeFacebook:
            return STExporterFacebook.class;

        case STExportTypeFacebookMessenger:
            return STExporterFacebookMessenger.class;

        case STExportTypeWhatsApp:
            return STExporterWhatsApp.class;

        case STExportTypeWeChat:
            return STExporterWeChat.class;

        case STExportTypeTwitter:
            return STExporterTwitter.class;

        case STExportTypeLine:
            return STExporterLine.class;

        case STExportTypeKik:
            return STExporterKik.class;

        case STExportTypeSaveToLibrary:
            return STExporterSaveToLibrary.class;

        case STExportTypeSaveToPhotos:
            return STExporterSaveToPhotos.class;

        default:
            return NSNull.class;
    }
}

+ (BOOL)isAllowedByCurrentApplicationState:(STExportType)type{
    STPhotoSource source = [STPhotoSelector sharedInstance].source;
    STPhotoViewType view = [STPhotoSelector sharedInstance].type;

    BOOL alreadyStoredAsCapturedImage = ((STPhotoItem *)[STPhotoSelector sharedInstance].currentFocusedPhotoItems.firstObject).sourceForCapturedImageSet.saved;

    switch (type){
        case STExportTypeSaveToLibrary:
            switch (view){
                case STPhotoViewTypeEdit:
                case STPhotoViewTypeEditAfterCapture:
                    return !alreadyStoredAsCapturedImage;
                default:
                    return source==STPhotoSourceRoom;
            }
        default:
            return source==STPhotoSourceRoom
                    || source==STPhotoSourceAssetLibrary
                    || source==STPhotoSourceCapturedImageStorage;
    }
}

+ (BOOL)isAllowedFullResolution:(STExportType)type{
    switch (type){
        case STExportTypeWeChat:
            return NO;

        default:
            return YES;
    }
}

+ (BOOL)isShouldWaitUsersInteraction:(STExportType)type{
    NSAssert(type==STExportType_blank || type < STExportType_count, [@"Wrong export type : " st_add:[@(type) stringValue]]);
    switch (type){
        case STExportTypeSaveToLibrary:
        case STExportTypeSaveToPhotos:
            return NO;
        default:
            return YES;
    }
}

+ (NSUInteger)allowedCount:(STExportType)type; {
    switch (type){
        case STExportTypeSaveToLibrary:
        case STExportTypeSaveToPhotos:
        case STExportTypeShare:
            return MAX_ALLOWED_EXPORT_COUNT;

        case STExportTypeFacebook:
        case STExportTypeTumblr:
            return 10;

        case STExportTypeFacebookMessenger:
            return 6;

        case STExportTypeInstagram:
        case STExportTypeWhatsApp:
        case STExportTypeWeChat:
        case STExportTypeOpenIn:
        case STExportTypeTwitter:
        case STExportTypeLine:
        default:
            return 1;
    }
}

+ (NSString *)localizedPromotionMessageWhenSent; {
    return NSLocalizedFormatString(@"Sent from %@", STGIFCApp.displayName);
}

+ (NSString *)localizedSocialTaggedMessageWhenSent; {
    return NSLocalizedFormatString(@"Sent from %@", STGIFCApp.displayName);
}

@end
