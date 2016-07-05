//
// Created by BLACKGENE on 2016. 3. 13..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Photos/Photos.h>
#import "STExporterTumblr.h"
#import "TMAPIClient.h"
#import "STExporter+URL.h"
#import "STExportView.h"
#import "STExporter+Handle.h"
#import "STExporter+IO.h"
#import "NSArray+BlocksKit.h"
#import "NSString+STUtil.h"
#import "UIImage+STUtil.h"
#import "NSObject+STUtil.h"
#import "R.h"
#import "UIAlertController+STGIFCApp.h"
#import "STPhotoItem.h"
#import "STPhotoItem+ExporterIO.h"
#import "NSURL+STUtil.h"
#import "STExporter+View.h"
#import "JXHTTPOperation+Convenience.h"
#import "NSObject+STThreadUtil.h"
#import "STPhotoItem+STExporterIOGIF.h"

/*
 * info
 *
 * https://www.tumblr.com/oauth/apps
 * https://www.tumblr.com/docs/en/api/v2
 *
 * https://github.com/VidMob/TMTumblrSDK
 */

NSString * const TumblrUserDefaultsBlogNameKey = @"TumblrUserDefaultsBlogNameKey";
NSString * const TumblrUserDefaultsOAuthTokenKey = @"TumblrUserDefaultsOAuthTokenKey";
NSString * const TumblrUserDefaultsOAuthTokenSecrentKey = @"TumblrUserDefaultsOAuthTokenSecrentKey";

@implementation STExporterTumblr {
    NSString * _selectedTargetBlogName;
    JXHTTPOperation * _uploadOperation;
}

+ (NSString *)scheme {
    return @"tumblr";
}

+ (NSString *)webURLString {
    return @"https://tumblr.com";
}

- (NSString *)fallbackAppStoreId; {
    return @"305343404";
}

+ (BOOL)setup {
    NSAssert([STApp defaultURLScheme],@"STExporterTumblr - Not found default bundle URLScheme.");

    [TMAPIClient sharedInstance].OAuthConsumerKey = @"GFlK02ANXZMfPq5OBRkYqPwNOG0kgdOoTxl4bxWreD5Y7CnOqg";
    [TMAPIClient sharedInstance].OAuthConsumerSecret = @"DpGli3EnkZjgLhYVusAUr79gPWApOt727HVLEpXvHbsqCNFIl4";
    [TMAPIClient sharedInstance].OAuthToken = [[NSUserDefaults standardUserDefaults] objectForKey:TumblrUserDefaultsOAuthTokenKey];
    [TMAPIClient sharedInstance].OAuthTokenSecret = [[NSUserDefaults standardUserDefaults] objectForKey:TumblrUserDefaultsOAuthTokenSecrentKey];
//    [TMAPIClient sharedInstance].OAuthToken = @"hITjeS69rmAeUNmPC7KrjXex5oMXt81gZ1cumT60dAAPXnsKoE";
//    [TMAPIClient sharedInstance].OAuthTokenSecret = @"rqVlsxAnnbmkwL1l8XbUohVVns8FL3cr3tV37wAeW24ubRKwLT";

    return [super setup];
}

#pragma mark Auth
- (STExporterAuthorizationType)authorizationType {
    return STExporterAuthorizationTypeOAuth;
}

- (BOOL)isTumblrAPIClientAuthorized {
    return !isEmpty([TMAPIClient sharedInstance].OAuthToken) && !isEmpty([TMAPIClient sharedInstance].OAuthTokenSecret);
}

- (void)setTumblrAPIClientOAuthKeysToUserDefaults:(BOOL)clear {
    if(clear){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:TumblrUserDefaultsOAuthTokenKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:TumblrUserDefaultsOAuthTokenSecrentKey];
        [TMAPIClient sharedInstance].OAuthToken = nil;
        [TMAPIClient sharedInstance].OAuthTokenSecret = nil;
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:[TMAPIClient sharedInstance].OAuthToken forKey:TumblrUserDefaultsOAuthTokenKey];
        [[NSUserDefaults standardUserDefaults] setObject:[TMAPIClient sharedInstance].OAuthTokenSecret forKey:TumblrUserDefaultsOAuthTokenSecrentKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)authorize:(NSDictionary *)inputData result:(void (^)(BOOL succeed, id data))block {
    [super authorize:inputData result:block];

    Weaks
    if(self.authorizationType==STExporterAuthorizationTypeInputAccountPassword){

        NSAssert(inputData && inputData[STExporterAuthorizationInputDataAccountKey] && inputData[STExporterAuthorizationInputDataPasswordKey], @"STExporterAuthorizationTypeInputAccountPassword needs account and its passwords.");

        [[TMAPIClient sharedInstance] xAuth:inputData[STExporterAuthorizationInputDataAccountKey] password:inputData[STExporterAuthorizationInputDataPasswordKey] callback:^(NSError *error) {
            BOOL authorized = !error && [Wself isTumblrAPIClientAuthorized];
            [Wself setTumblrAPIClientOAuthKeysToUserDefaults:NO];
            _shouldNeedAuthorize = !authorized;

            !block?:block(authorized, nil);
        }];

    }else if(self.authorizationType==STExporterAuthorizationTypeOAuth){

        [[TMAPIClient sharedInstance] authenticate:[STApp defaultURLScheme] fromViewController:[self st_rootUVC] callback:^(NSError *error) {
            BOOL authorized = !error && [Wself isTumblrAPIClientAuthorized];
            [Wself setTumblrAPIClientOAuthKeysToUserDefaults:NO];
            _shouldNeedAuthorize = !authorized;

            !block?:block(authorized, nil);
        }];
    }
}

- (BOOL)prepare {
    _shouldNeedAuthorize = ![self isTumblrAPIClientAuthorized];
    return YES;
}

- (BOOL)export {
    if(self.shouldNeedAuthorize){
        [self authorize:nil result:^(BOOL succeed, id data) {
            if(succeed){
                [self fetchUserInfoAndOpenExporterView];
            }else{
                [self openExporterViaAppLink];
            }
        }];
    }else{
        [self fetchUserInfoAndOpenExporterView];
    }
    return YES;
}

#pragma mark ExporterView
- (void)fetchUserInfoAndOpenExporterView{
    Weaks
    [self dispatchStartProcessing];
    [[TMAPIClient sharedInstance] userInfo:^(id userInfoData, NSError *_error) {
        [Wself dispatchStopProcessing];

        //check status
        BOOL apiAvailableButUnauthorized = _error.code==401;
        BOOL needsBuiltInExporterView = !_error || apiAvailableButUnauthorized;
        BOOL validUserInfo = !isEmpty(userInfoData)
                //check data
                && [userInfoData isKindOfClass:NSDictionary.class]
                //check valid user
                && userInfoData[@"user"][@"name"];

        _shouldNeedAuthorize = apiAvailableButUnauthorized || !validUserInfo;

        //open
        if(needsBuiltInExporterView){
            [Wself openBuiltInExporterView:userInfoData];
        }else{
            [Wself openExporterViaAppLink];
        }
    }];
}

#pragma mark ExporterView - AppLink
- (void)openExporterViaAppLink{
    [self setShouldSucceesWhenEnterBackground:YES];

    //api is unavailable -> pass app or fallback.
    _shouldFallback = ![self.class canOpenApp];
    if(_shouldFallback){
        [self fallback];

    }else{
        [self dispatchStartProcessing];
        [self exportFiles:self.photoItems completion:^(NSArray *imageURLs) {
            [self dispatchStopProcessing];
            [UIPasteboard generalPasteboard].images = [imageURLs bk_map:^id(NSURL *url) {
                return [UIImage imageWithURL:url];
            }];
            [[UIApplication sharedApplication] openURL:[[NSString stringWithFormat:@"tumblr://x-callback-url/photo?caption=&tags=%@", [STGIFCApp primaryHashtag]] URL]];
        }];
    }
}

#pragma mark ExporterView - BuiltIn
- (NSURL *)avatarURL:(NSString *)blogName size:(NSUInteger)size{
    return [[NSString stringWithFormat:@"https://api.tumblr.com/v2/blog/%@.tumblr.com/avatar/%d", blogName, size] URL];
}

- (void)openBuiltInExporterView:(NSDictionary *)userInfoDict {
    Weaks
    //check blog data
    NSArray * blogDictArr = userInfoDict[@"user"][@"blogs"];
    if(!blogDictArr){
        [self dispatchFinshed:STExportResultImpossible];
        return;
    }

    //check max count
    NSUInteger maxBlogCount = [STApp screenFamily]<STScreenFamily47 ? 8 : 9;
    if(blogDictArr.count>maxBlogCount){
        blogDictArr = [blogDictArr subarrayWithRange:NSMakeRange(0,maxBlogCount)];
    }


    NSDictionary * primaryBlogDict = [blogDictArr firstObject];
    NSString * defaultBlogName = [[NSUserDefaults standardUserDefaults] objectForKey:TumblrUserDefaultsBlogNameKey];
    _selectedTargetBlogName = defaultBlogName?:primaryBlogDict[@"name"];
    if(!_selectedTargetBlogName){
        [self dispatchFinshed:STExportResultImpossible];
        return;
    }

    __block NSUInteger selectedIndex = 0;
    NSArray * optionsItems = [blogDictArr bk_map:^id(NSDictionary * obj) {
        STExporterViewSelectionOptionItem * optionItem = [STExporterViewSelectionOptionItem new];
        optionItem.label = obj[@"name"];
        optionItem.thumbnailAsURL = [self avatarURL:optionItem.label size:128];
        oo(optionItem.thumbnailAsURL);
        if([optionItem.label isEqualToString:_selectedTargetBlogName]){
            selectedIndex = [blogDictArr indexOfObject:obj];
        }
        return optionItem;
    }];

    [self whenValueOf:@keypath(self.selectedOptionItem) changed:^(STExporterViewSelectionOptionItem *item, id _weakSelf) {
        _selectedTargetBlogName = item.label;
        [[NSUserDefaults standardUserDefaults] setObject:item.label forKey:TumblrUserDefaultsBlogNameKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];

    STExporterViewOption * option = self.viewOption;
    option.exportOptionItems = optionsItems;
    option.selectedExportOptionIndex = selectedIndex;
    //already exported
    BOOL alreadyExported = [self.photoItems bk_select:^BOOL(STPhotoItem * obj) {
        return obj.isExportedTempFileGIF;
    }].count > 0;

    [self openExporterView:option tryExport:^{
        if(alreadyExported){
            [self exportAllFiles:^(NSArray *imageURLs) {
                [self uploadPhotos];
            }];
        }else{
            [self uploadPhotos];
        }
    }];
}

- (BOOL)shouldNeedViewWhenExport {
    return NO;
}

- (STExporterViewOption *)viewOption {
    Weaks
    STExporterViewOption * option = [super viewOption];
    option.exportOptionItems =
    option.cancelIconImageNames = @[[R set_logout]];
    option.cancelHandler = ^(NSUInteger i) {
        [UIAlertController alertToAsk:NSLocalizedString(@"exporter_logout_message", @"") confirm:^(UIAlertController *alertController) {
            [STExportView close:YES];
            [Wself setTumblrAPIClientOAuthKeysToUserDefaults:YES];
        } cancel:nil];
    };
    return option;
}

- (void)uploadPhotos{
    Weaks
    //extract urls
    NSArray * totalTargetExportURLs = [[self.photoItems bk_select:^BOOL(STPhotoItem * _item) {
        NSAssert(_item.exportedTempFileURL, @"STPhotoItems.exportedTempFileURL is missing");
        return _item.exportedTempFileURL != nil;

    }] bk_map:^id(STPhotoItem * _item) {
        return _item.exportedTempFileURL;
    }];

    NSString *caption = @"";//@"Shared via <a href=\"http://elie.camera\">Elie</a>";

    NSAssert(!_uploadOperation,@"_uploadOperation is pending. only single upload operation allowed");
    if(_uploadOperation){
        [_uploadOperation cancel];
    }
    _uploadOperation = [[TMAPIClient sharedInstance] photoRequest:_selectedTargetBlogName
                                                                     filePathArray:[totalTargetExportURLs bk_map:^id(NSURL *obj) {
                                                                         return [obj path];
                                                                     }]
                                                                  contentTypeArray:[totalTargetExportURLs bk_map:^id(NSURL *obj) {
                                                                      return [obj primaryMimeType];
                                                                  }]
                                                                     fileNameArray:[totalTargetExportURLs bk_map:^id(NSURL *obj) {
                                                                         return [obj lastPathComponent];
                                                                     }]
                                                                        parameters:@{@"caption" : caption, @"tags" : [STGIFCApp primaryHashtag]}];


    [_uploadOperation st_addKeypathListener:@keypath(_uploadOperation.uploadProgress) id:@"tumblr_upload_op" newValueBlock:^(id value, id _weakSelf) {
        [Wself st_runAsMainQueueAsyncWithoutDeadlocking:^{
            [STExportView setProgress:[value floatValue]];
            if([value floatValue]==1){
                [STExportView startSpinProgressOfOkButton];
            }
        }];
    }];

    [[TMAPIClient sharedInstance] sendRequest:_uploadOperation callback:^(id response, NSError *error) {
        Strongs

        if (error)
            NSLog(@"Error posting to Tumblr");
        else
            NSLog(@"Posted to Tumblr");

        _uploadOperation = nil;

         [STExportView close:!error];
    }];
}

- (void)finish {
    [_uploadOperation st_removeAllKeypathListeners];
    [_uploadOperation cancel];
    _uploadOperation = nil;
    [super finish];
}

- (BOOL)handleOpenURL:(UIApplication *)application url:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation; {
    oo(url);
    return [[TMAPIClient sharedInstance] handleOpenURL:url];
}

/*
 * Avartar
 *
 * size : 16, 24, 30, 40, 48, 64, 96, 128, 512
 *
 */

/* userInfo
 * {
    user =     {
        blogs =         (
                        {
                admin = 1;
                ask = 0;
                "ask_anon" = 0;
                "ask_page_title" = "Ask me anything";
                "can_send_fan_mail" = 1;
                "can_subscribe" = 0;
                description = "";
                drafts = 0;
                facebook = N;
                "facebook_opengraph_enabled" = N;
                followed = 0;
                followers = 0;
                "is_blocked_from_primary" = 0;
                "is_nsfw" = 0;
                likes = 0;
                messages = 0;
                name = elieapp;
                posts = 16;
                primary = 1;
                queue = 0;
                "share_likes" = 1;
                subscribed = 0;
                title = "Elie - Your Selfie Assistant";
                tweet = N;
                "twitter_enabled" = 0;
                "twitter_send" = 0;
                type = public;
                updated = 1457973497;
                url = "https://elieapp.tumblr.com/";
            },
                        {
                admin = 1;
                ask = 0;
                "ask_anon" = 0;
                "ask_page_title" = "Ask me anything";
                "can_send_fan_mail" = 0;
                "can_subscribe" = 0;
                description = "";
                drafts = 0;
                facebook = N;
                "facebook_opengraph_enabled" = N;
                followed = 0;
                followers = 0;
                "is_blocked_from_primary" = 0;
                "is_nsfw" = 0;
                messages = 0;
                name = elietest1;
                posts = 0;
                primary = 0;
                queue = 0;
                "share_likes" = 0;
                subscribed = 0;
                title = elietest1;
                tweet = N;
                "twitter_enabled" = 0;
                "twitter_send" = 0;
                type = public;
                updated = 0;
                url = "http://elietest1.tumblr.com/";
            }
        );
        "default_post_format" = html;
        following = 1;
        likes = 0;
        name = elieapp;
    };
}
 */

@end