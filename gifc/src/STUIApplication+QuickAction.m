//
// Created by BLACKGENE on 2015. 10. 8..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STUIApplication+QuickAction.h"
#import "STPhotoSelector.h"
#import "STMainControl.h"
#import "NSObject+STUtil.h"
#import "R.h"
#import "STApp+Logger.h"

//max numbers of items : 4
NSString * const STShortcutItemTypeCaptureAsFullRange = @"STShortcutItemTypeCaptureAsFullRange";
NSString * const STShortcutItemTypeEditLastPhoto = @"STShortcutItemTypeEditLastPhoto";
NSString * const STShortcutItemTypeCaptureAsMultiPoint = @"STShortcutItemTypeCaptureAsMultiPoint";
NSString * const STShortcutItemTypeOpenAlbum = @"STShortcutItemTypeOpenAlbum";

@implementation STUIApplication (QuickAction)

+ (NSString *)shortcutItemSVGImageNameByType:(NSString *)type{
    return @{
            STShortcutItemTypeCaptureAsFullRange: [R set_postfocus_fullrange],
            STShortcutItemTypeCaptureAsMultiPoint: [R set_postfocus_point],
            STShortcutItemTypeEditLastPhoto: [R go_edit],
            STShortcutItemTypeOpenAlbum: [R go_roll]
    }[type];
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnavailableInDeploymentTarget"

- (void)launchFromNeededShortcutItemIfPossible:(UIApplicationShortcutItem *)item completionHandler:(void (^)(BOOL succeeded))completionHandler{
    [self launchFromNeededShortcutItemType:item.type completionHandler:completionHandler];
    [STGIFCApp logEvent:@"LaunchFromShortcut" key:item.type];
}

- (void)launchFromNeededShortcutItemType:(NSString *)itemType completionHandler:(void (^)(BOOL succeeded))completionHandler{
    if([STGIFCApp osVersion].majorVersion < 9){
        return;
    }

    BOOL initialized = [STElieCamera mode] != STCameraModeNotInitialized;
    if(initialized){
        Weaks
        [STUIApplication st_performAfterDelay:1.5 block:^{
            [Wself _launchFromNeededShortcutItemType:itemType completionHandler:completionHandler];
        }];

    }else{
        [self _launchFromNeededShortcutItemType:itemType completionHandler:completionHandler];
    }
}

- (void)_launchFromNeededShortcutItemType:(NSString *)itemType completionHandler:(void (^)(BOOL succeeded))completionHandler{
    if([itemType isEqualToString:STShortcutItemTypeCaptureAsFullRange]){
        [[STMainControl sharedInstance] requestQuickPostFocusCaptureIfPossible:STPostFocusModeFullRange];
    }
    else if([itemType isEqualToString:STShortcutItemTypeCaptureAsMultiPoint]){
        [[STMainControl sharedInstance] requestQuickPostFocusCaptureIfPossible:STPostFocusMode5Points];
    }
    else if([itemType isEqualToString:STShortcutItemTypeEditLastPhoto]){
        [[STMainControl sharedInstance] backToHome];
        [[STPhotoSelector sharedInstance] requestEnterEditLastItemIfPossible];
    }
    else if([itemType isEqualToString:STShortcutItemTypeOpenAlbum]){
        [[STMainControl sharedInstance] backToHome];
    }
}

#pragma clang diagnostic pop
@end