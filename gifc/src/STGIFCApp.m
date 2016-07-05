#import "NSObject+STPopAnimatableProperty.h"
#import "NSString+STUtil.h"
#import "STElieCamera.h"
#import "NSObject+STUtil.h"
#import "UIImage+STUtil.h"
#import "STApp+Products.h"
#import "STElieStatusBar.h"
#import "iRate.h"
#import "STApp+Logger.h"
#import "STGIFCAppSetting.h"
#import "STFilterItem.h"
#import "STPermissionManager.h"
#import "STGIFCStandardColor.h"
#import "STMainControl.h"
#import "STStandardButton.h"
#import "UIColor+BFPaperColors.h"

@implementation STGIFCApp

+ (Class)defaultAppClass{
    return STGIFCApp.class;
}

#pragma mark Defines
+ (void)registerDefinitions {
    [super registerDefinitions];

    [STStandardUI registerColorScheme:STGIFCStandardColor.new];
    [self registerCommonPopAnimationProperties];
    [self registerInAppProducts];
}

+ (void)registerCommonPopAnimationProperties{
    [UIView addPopAnimationPropertiesAsCGFloat:@[
            //UIView+Positioning
            @"x",
            @"y",
            @"width",
            @"height",
            @"centerX",
            @"centerY",
            @"right",
            @"bottom",
            @"top",
            @"left",
            //UIView+STUtil
            @"scaleXYValue",
            @"originOffsetX",
            @"originOffsetY"
    ]];

    [CALayer addPopAnimationPropertiesAsCGFloat:@[
            @"borderWidth",
            @"scaleXYValue"
    ]];
}

#pragma mark permission
+ (void)checkInitialAppPermissions:(void(^)(void))finished{
    NSParameterAssert(finished);

    //check camera permission
    [[STPermissionManager camera] promptOrStatusIfNeeded:^(STPermissionStatus status) {
        if (status != STPermissionStatusAuthorized) {
            [self logUnique:@"CameraPermissionUserDenied"];
        }

        finished();
    }];
}

#pragma mark Rate
+ (void)registerRatingSettings{
    NSDictionary * ratePeriod = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"STRatePeriod"];
    BOOL hasKeys = [ratePeriod hasKey:@"daysUntilPrompt"] && [ratePeriod hasKey:@"usesUntilPrompt"];
    NSAssert(hasKeys, ([NSString stringWithFormat:@"Check STRatePeriod in plist - %@", ratePeriod]));
    if(ratePeriod && hasKeys){
        [iRate sharedInstance].daysUntilPrompt = [ratePeriod[@"daysUntilPrompt"] floatValue];
        [iRate sharedInstance].usesUntilPrompt = (NSUInteger) [ratePeriod[@"usesUntilPrompt"] integerValue];
        NSParameterAssert([[@([iRate sharedInstance].daysUntilPrompt) stringValue] isEqualToString:ratePeriod[@"daysUntilPrompt"]]);
        NSParameterAssert([[@([iRate sharedInstance].usesUntilPrompt) stringValue] isEqualToString:ratePeriod[@"usesUntilPrompt"]]);
    }
}

#pragma mark In-App Purchase
+ (void)registerInAppProducts {

#if ST_IAP
    [STProductItem registerMetadataUrlForProductContents:[NSString stringWithFormat:@"https://raw.githubusercontent.com/livefocus/livefocus-content/master/%@/products/metadata.json", [[NSBundle mainBundle] bundleIdentifier]]];
#endif

#if DEBUG
    [self disposeAllTransactions];
#endif

    [self loadProducts:@[
            STEWProduct_filter_basic
#if STGIFCProduct_save
            , STGIFCProduct_save
#endif
    ]];

//    [STProductItem registerLocalMetadataUrlForProductContents:@{
//            STEWProduct_room : @{ @"images": [@"intro_room.gif" bundleFileAbsolutePath] },
//            STEWProduct_selfietake : @{ @"images": [@"intro_tilt.jpg" bundleFileAbsolutePath] },
//            STEWProduct_veil : @{ @"images": [@"intro_veil.gif" bundleFileAbsolutePath] }
//    }];

#ifdef STEWProduct_filter_basic
    [STFilterItem registerProductIdByType:@{
            @(STFilterTypeITunesProduct) : STEWProduct_filter_basic
    }];
#endif
}

+ (void)restoreAllProductIfNeeded:(void (^)(NSArray *transactions))successBlock failure:(void (^)(NSError *error))failureBlock {
    [super restoreAllProductIfNeeded:^(NSArray *transactions) {
        !successBlock?:successBlock(transactions);
        [STGIFCApp logUnique:@"RestoreAllSucceed"];
    } failure:^(NSError *error) {
        !failureBlock?:failureBlock(error);
        [STGIFCApp logUnique:@"RestoreAllFailed"];
    }];
}

+ (BOOL)checkOrBuyProductIfNeeded:(NSString *)productId success:(void (^)(SKPaymentTransaction *transaction))successBlock failure:(void (^)(SKPaymentTransaction *transaction, NSError *error))failureBlock existence:(void (^)(void))alreadyPurchasedBlock {
    BOOL purchased = [super checkOrBuyProductIfNeeded:productId success:^(SKPaymentTransaction *transaction) {
        [STStandardUX endInAppPurchaseTransactions];
        [[STElieStatusBar sharedInstance] success];
        !successBlock ?: successBlock(transaction);

        [STGIFCApp logPurchaseSuccess:transaction];
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        [STStandardUX endInAppPurchaseTransactions];
        [[STElieStatusBar sharedInstance] fail];
        !failureBlock ?: failureBlock(transaction, error);

        [STGIFCApp logPurchaseFail:transaction];
    } existence:^{
        !alreadyPurchasedBlock?:alreadyPurchasedBlock();

        [STGIFCApp logPurchasingProductExisted:productId];
    } buyerUID:[STGIFCAppSetting get]._guid];

    if(!purchased){
        [STStandardUX beginInAppPurchaseTransactions];
        [[STElieStatusBar sharedInstance] startProgress:nil];

        [STGIFCApp logTryPurchasing:productId];
    }

    return purchased;
}

#pragma mark Environment
+ (STApplicationMode)applicationMode {
    NSSet * args = [NSSet setWithArray:[[NSProcessInfo processInfo] arguments]];
    if ([args containsObject:@"-com_stells_test_mainview"]) {
        return STApplicationModeTestView;

    }else if ([args containsObject:@"-com_stells_test_cam"]) {
        return STApplicationModeTestCamera;
    }
    return STApplicationModeDefault;
}

#pragma mark Business
+ (NSString *)appstoreId{
    return @"1050917948";
}

+ (NSString *)paidLiveFocusAppstoreId{
    return @"1050917948";
}

+ (NSString *)siteUrl {
    return @"http://postfoc.us/";
}

+ (NSString *)elieSiteUrl {
    return @"https://elie.camera/m";
}

+ (NSString *)localizedSiteUrl {
    if([self.languageCode isEqualToString:self.baseLanguageCode]){
        return [self siteUrl];
    }else{
        return [self.siteUrl st_add:self.languageCode];
    }
}

+ (NSString *)marketingTitle{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"STAppMarketingTitle"]?:self.displayName;
}

+ (NSString *)marketingSubTitle{
    return [[[self marketingTitle] split:@"Live Focus - "] lastObject];
}

#pragma mark UserInfo
+ (NSString *)privacyInfoUrl {
    return [[self siteUrl] st_add:@"privacy"];
}

+ (NSString *)termsInfoUrl {
    return [[self siteUrl] st_add:@"terms"];
}

+ (NSString *)attributionInfoUrl {
    return [[self siteUrl] st_add:@"acknowledgements"];
}

+ (NSString *)releaseNoteUrl{
    return [[self siteUrl] st_add:[NSString stringWithFormat:@"notes/%@%@", [self identification], @"#wn"]];
}

+ (NSString *)releaseNoteAPIUrlToCheckVersion{
    return [NSString stringWithFormat:@"https://api.github.com/repos/livefocus/livefocus.github.io/contents/notes/%@",[self identification]];
}

#pragma mark SNSInfo
+ (NSString *)urlToForwardSNSService:(NSString *)serviceName {
    //1 day cache
    return [[self siteUrl] stringByAppendingFormat:@"%@?day=%@",serviceName, [@(floor(([[[NSDate alloc] init] timeIntervalSince1970]/(60*60*24)))) stringValue]];
}

+ (NSString *)primaryHashtag {
    return @"LiveFocus";
}

+ (NSArray *)secondaryHashtags {
    return @[@"postfocus"];
}


#pragma mark CommonLogics
//return : not yet initialized?
+ (BOOL)afterCameraInitialized:(NSString *)identifier perform:(void(^)(void))block{
    NSParameterAssert(identifier);
    NSParameterAssert(block);

    if(STElieCamera.mode == STCameraModeNotInitialized){
        [STElieCamera whenNewValueOnceOf:@keypath(STElieCamera.mode) id:identifier timeout:0 promise:0 changed:^(id value, id _weakSelf) {
            if([value integerValue] != STCameraModeNotInitialized){
                block();
            }
        }];
        return YES;
    }
    return NO;
}


#pragma mark Appearance
+ (UIColor *)launchScreenBackgroundColor{
    return UIColorFromRGB(0x696367);
}

+ (UIImage *)livePhotosBadgeImage {
    return [UIImage imageBundledCache:self.livePhotosBadgeImageName];
}

+ (NSString *)livePhotosBadgeImageName {
    return @"BadgeIcoLivePhoto";
}

#pragma mark PostFocus
+ (BOOL)postFocusAvailable{
    return !([STElieCamera sharedInstance].isPositionFront
            || STGIFCAppSetting.get.postFocusMode == STPostFocusModeNone);
}

+ (BOOL)tryProductSavePostFocus:(void(^)(BOOL purchased))block interactionButton:(STStandardButton *)button{
    NSParameterAssert(block);

#if DEBUG
    return YES;
#endif

#if STGIFCProduct_save
    NSString * productId = STGIFCProduct_save;
    if([STGIFCApp isPurchasedProduct:productId]){
        return YES;
    }

    Weaks
    [STProductCatalogView openWith:button ?: [[[STMainControl sharedInstance] homeView] containerButton]
                         productId:productId
                        iconImages:nil
                          willOpen:^(STProductCatalogView *view, STProductItem * item) {

                          }
                           didOpen:nil
                             tried:^{

                             } purchased:^(NSString *_success_productId) {

            } failed:^(NSString *_failed_productId) {

            } willClose:^(BOOL afterPurchased) {

            } didClose:block];

    return NO;
#else
    return YES;
#endif
}

#pragma mark Product - Warter Mark
@end
