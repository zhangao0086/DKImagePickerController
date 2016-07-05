//
// Created by BLACKGENE on 2015. 10. 9..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <BlocksKit/NSDictionary+BlocksKit.h>
#import "STUIApplication.h"
#import "STUIApplication+SpotlightSearch.h"
#import "NSString+STUtil.h"
#import "NSArray+BlocksKit.h"
#import "STSettingScreenControllableItem.h"
#import "SVGKImage.h"
#import "SVGKImage+STUtil.h"
#import "STGIFFAppSetting.h"
#import "STUIApplication+QuickAction.h"
#import "STQueueManager.h"
#import "NSArray+STUtil.h"
#import "R.h"
#import "UIImage+STUtil.h"
#import "STApp+Logger.h"

NSString * const STSearchableContextDefault = @"STSearchableContextDefault";
NSString * const STSearchableContextControllable = @"STSearchableContextControllable";

NSString * const SEP = @".";
//default localizable keyword items
NSString * const STSearchableItemDomainDefaultLocalizableKeyword = @"stells_giff_domain_DefaultLocalizableKeyword";
NSString * const STSearchableItemDefaultLocalizableKeywordIdentifier = @"stells_giff_id_DefaultLocalizableKeyword";
NSString * const STSearchableItemDefaultLocalizableKeywordPrefix = @"sp_keyword_";
NSUInteger const STSearchableItemDefaultLocalizableKeywordLastIndexNumber = 10;

//quick action items
NSString * const STSearchableItemDomainQuickActions = @"stells_giff_domain_QuickActions";
NSString * const STSearchableItemIdentifierPrefixQuickActions = @"stells_giff_id_QuickActions";

//controllable items
NSString * const STSearchableItemDomainControllable = @"stells_giff_domain_Controllable";
NSString * const STSearchableItemIdentifierPrefixControllable = @"stells_giff_id_Controllable";

//presets
NSString * const STSearchableItemDomainPreset = @"stells_giff_domain_Preset";
NSString * const STSearchableItemIdentifierPrefixPreset = @"stells_giff_id_Preset";

#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnavailableInDeploymentTarget"

@implementation STUIApplication (SpotlightSearch)

- (BOOL)launchFromNeededSearchableItemByUserActivityIfPossible:(NSUserActivity *)userActivity{
    if([STGIFFApp osVersion].majorVersion<9){
        return NO;
    }

    BOOL isFromSearchableItem = [userActivity.activityType isEqualToString:CSSearchableItemActionType] && [userActivity.userInfo hasKey:CSSearchableItemActivityIdentifier];
    if(!isFromSearchableItem){
        return NO;
    }

    @try {
        NSString * id = userActivity.userInfo[CSSearchableItemActivityIdentifier];
        NSArray * id_scheme = [id split:SEP];
        NSString * prefix = [id_scheme st_objectOrNilAtIndex:0];

        /*if([STSearchableItemIdentifierPrefixControllable isEqualToString:prefix] && id_scheme.count==5){
            NSString * titlelabel = [id_scheme st_objectOrNilAtIndex:1];
            NSString * keypath = [id_scheme st_objectOrNilAtIndex:2];
            NSString * functionName = [id_scheme st_objectOrNilAtIndex:3];
            NSString * type = [id_scheme st_objectOrNilAtIndex:4];

            [self launchFromNeededShortcutItemType:STShortcutItemTypeModeMain completionHandler:nil];

            [[STSettingScreenController sharedController] requestSelectControllable:keypath type:[type integerValue]];

        }
        else if([STSearchableItemIdentifierPrefixPreset isEqualToString:prefix] && id_scheme.count==2){
            NSString * preset = [id_scheme st_objectOrNilAtIndex:1];

            [self launchFromNeededShortcutItemType:STShortcutItemTypeModeMain completionHandler:nil];

            [[STMainControl sharedInstance] requestAssignPreset:(STSettingPreset) [preset integerValue]];

        }
        else */if([STSearchableItemIdentifierPrefixQuickActions isEqualToString:prefix] && id_scheme.count==2){
            NSString * type = [id_scheme st_objectOrNilAtIndex:1];

            [self launchFromNeededShortcutItemType:type completionHandler:nil];
        }

        [STGIFFApp logEvent:@"LaunchFromSpotlightSearchForPrefix" key:prefix];

        return YES;

    }@finally {}

    return NO;
}

- (BOOL)isPossibleIndexing{
    return [STGIFFApp osVersion].majorVersion>=9 && [CSSearchableIndex isIndexingAvailable];
}

- (BOOL)isPossibleIndexingOnlyNewVersion{
    return [self isPossibleIndexing] && [STGIFFAppSetting.get isFirstLaunchSinceLastBuild];
}

- (BOOL)isPossibleIndexingNewVersionOrSinceLastLaunchAt6Hours{
    return [self isPossibleIndexing] && ([STGIFFAppSetting.get isFirstLaunchSinceLastBuild] || [STGIFFAppSetting.get isPassedHoursSinceLastLaunched:6]);
}

#pragma mark default indexing
- (void)indexDefaultSearchableItemsIfPossible {

    Weaks
    if([STGIFFApp afterCameraInitialized:@"STSearchableIndexing.default" perform:^{
        [Wself indexDefaultSearchableItemsIfPossible];
    }]){
        return;
    }

    dispatch_async([STQueueManager sharedQueue].startingBackground, ^{
        NSMutableArray * seachableItems = [@[] mutableCopy];

        /*
         * exposure keywords
         */
        NSMutableArray *localizableKeywords = [NSMutableArray arrayWithCapacity:STSearchableItemDefaultLocalizableKeywordLastIndexNumber +1];
        [@(0) upto:STSearchableItemDefaultLocalizableKeywordLastIndexNumber do:^(NSInteger number) {
            [localizableKeywords addObject:NSLocalizedString([STSearchableItemDefaultLocalizableKeywordPrefix st_add:[@(number) stringValue]], nil)];
        }];

        CSSearchableItemAttributeSet *attributeSet_default = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeImage];
        attributeSet_default.title = [STGIFFApp displayName];
        attributeSet_default.contentDescription = NSLocalizedString(@"sp_description",nil);
        attributeSet_default.keywords = localizableKeywords;

        [seachableItems addObject:[[CSSearchableItem alloc] initWithUniqueIdentifier:STSearchableItemDefaultLocalizableKeywordIdentifier
                                                                    domainIdentifier:STSearchableItemDomainDefaultLocalizableKeyword
                                                                        attributeSet:attributeSet_default]];

        /*
         * QuickActions
         */
        NSArray * shortcutItems = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIApplicationShortcutItems"];
        NSDictionary * infoPlistDict = [[NSBundle mainBundle] localizedInfoDictionary];
        for(NSDictionary * shortcutItem in shortcutItems){
            @autoreleasepool {
                NSString * type = shortcutItem[@"UIApplicationShortcutItemType"];
                CSSearchableItemAttributeSet *attributeSet_quickaction = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeImage];
                attributeSet_quickaction.title = infoPlistDict[shortcutItem[@"UIApplicationShortcutItemTitle"]];
                attributeSet_quickaction.contentDescription = NSLocalizedString(@"Quick_Action",nil);
                attributeSet_quickaction.keywords = @[attributeSet_quickaction.title];
                attributeSet_quickaction.thumbnailData = [STUIApplication searchableIndexThumbnailDataFromImageName:[STUIApplication shortcutItemSVGImageNameByType:type]];

                [seachableItems addObject:[[CSSearchableItem alloc] initWithUniqueIdentifier:[@[STSearchableItemIdentifierPrefixQuickActions, type] join:SEP]
                                                                            domainIdentifier:STSearchableItemDomainQuickActions
                                                                                attributeSet:attributeSet_quickaction]];
            }
        }

        [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:seachableItems completionHandler: ^(NSError * __nullable error) {
            if (!error){
                NSLog(@"Search item indexed - default");

                [STGIFFAppSetting.get touchSearchableContext:STSearchableContextDefault];
            }
        }];
    });
}

#pragma mark setting control
- (void)indexControllableItemsIfPossible:(NSDictionary *)items {
//    if(![self isPossibleIndexingNewVersionOrSinceLastLaunchAt6Hours]){
//        return;
//    }

    Weaks
    WeakObject(items) weakItems = items;

    if([STGIFFApp afterCameraInitialized:@"STSearchableIndexing.controllable" perform:^{
        [Wself indexControllableItemsIfPossible:weakItems];
    }]){
        return;
    }

    dispatch_async([STQueueManager sharedQueue].startingBackground, ^{
        NSMutableArray * searchableItems = [NSMutableArray array];
        /*
        * Control Items
        */
        for (NSString *label in weakItems){
            [searchableItems addObjectsFromArray:[items[label] bk_map:^id(STSettingScreenControllableItem * item) {
                @autoreleasepool {
                    CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *) kUTTypeImage];
                    attributeSet.title = label;
                    attributeSet.contentDescription = item.name;
                    attributeSet.keywords = @[item.name];
                    attributeSet.thumbnailData = [STUIApplication searchableIndexThumbnailDataFromImageName:item.buttonIconName];

                    NSArray * controllableItemScheme = @[
                            STSearchableItemIdentifierPrefixControllable,
                            label,
                            item.keypath,
                            item.name,
                            [@(item.type) stringValue]
                    ];

                    return [[CSSearchableItem alloc] initWithUniqueIdentifier:[controllableItemScheme join:SEP]
                                                             domainIdentifier:STSearchableItemDomainControllable
                                                                 attributeSet:attributeSet];
                }
            }]];
        }

        [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:searchableItems completionHandler: ^(NSError * __nullable error) {
            if (!error){
                NSLog(@"Search item indexed - controllable");
            }
        }];
    });
}

+ (NSData *)searchableIndexThumbnailDataFromImageName:(NSString *)imageName{
    return [self searchableIndexThumbnailDataFromImageName:imageName color:nil];
}

+ (NSData *)searchableIndexThumbnailDataFromImageName:(NSString *)imageName color:(UIColor *)color{
    UIImage * image = [SVGKImage imageNamedNoCache:imageName widthSizeWidth:60].UIImage;
    if(color){
        image = [image maskWithColor:color];
    }
    return UIImagePNGRepresentation(image);
}
#pragma clang diagnostic pop


@end