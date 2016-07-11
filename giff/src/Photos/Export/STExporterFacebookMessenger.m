//
// Created by BLACKGENE on 2015. 2. 13..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "STExporterFacebookMessenger.h"
#import "FBSDKMessageDialog.h"
#import "FBSDKSharePhotoContent.h"
#import "FBSDKSharePhoto.h"
#import "NSArray+STUtil.h"
#import "STExporter+IO.h"
#import "STExporter+URL.h"
#import "STExporter+Handle.h"
#import "STExporter+IOGIF.h"
#import "STPhotoItem+STExporterIO.h"
#import "STExporter+ConfigGIF.h"
#import "FBSDKMessengerShareOptions.h"
#import "FBSDKMessengerSharer.h"

static FBSDKMessageDialog *_sharedDialog;

@implementation STExporterFacebookMessenger {

}

+ (FBSDKMessageDialog *)sharedDialog{
    @synchronized (self) {
        if(!_sharedDialog){
            _sharedDialog = [[FBSDKMessageDialog alloc] init];
        }
        return _sharedDialog;
    }
}

+ (BOOL)canOpenApp {
    static BOOL _canOpenApp;
    if(_canOpenApp){
        return YES;
    }
    _canOpenApp = [self sharedDialog].canShow;
    return _canOpenApp;
}

+ (BOOL)setup; {
//    static NSString *const FBPLISTAppIDKey = @"FacebookAppID";
//    static NSString *const FBPLISTAppVersionKey = @"FacebookAppVersion";
//    static NSString *const FBPLISTClientTokenKey = @"FacebookClientToken";
//    static NSString *const FBPLISTDisplayNameKey = @"FacebookDisplayName";
//    static NSString *const FBPLISTDomainPartKey = @"FacebookDomainPart";
//    static NSString *const FBPLISTLoggingBehaviorKey = @"FacebookLoggingBehavior";
//    static NSString *const FBPLISTResourceBundleNameKey = @"FacebookBundleName";
//    NSString *const FBPLISTUrlSchemeSuffixKey = @"FacebookUrlSchemeSuffix";
    return [super setup];
}

- (BOOL)prepare; {
    _shouldFallback = ![self.class canOpenApp];

    if(self.isRequiredFullResolution){
        _allowedFullResolution = YES;//[self checkDataTotalMegaBytes:self.photoItems] < FBM_MAX_SAFETY_MEGA_BYTES;
    }

    self.shouldSucceesWhenEnterBackground = YES;

    return !_shouldFallback;
}

- (BOOL)export; {
    [self dispatchStartProcessing];

    if(self.shouldExportGIF && self.photoItemsCanExportGIF.count){
        NSAssert(self.photoItemsCanExportGIF.count==1, @"STExporterFacebookMessenger supports only 1 gif");

        [self exportGIF:[self.photoItemsCanExportGIF firstObject] completion:^(NSURL *gifURL) {
            [self dispatchStopProcessing];

//            FBSDKMessengerShareOptions * options = [[FBSDKMessengerShareOptions alloc] init];
            [FBSDKMessengerSharer shareAnimatedGIF:[NSData dataWithContentsOfURL:gifURL] withOptions:nil];
        }];

    }else{
        Weaks
        [self exportAllImages:^(NSArray *images) {
            Strongs
            [Wself dispatchStopProcessing];

            FBSDKSharePhotoContent * photoContent = [[FBSDKSharePhotoContent alloc] init];
            photoContent.photos = [images mapWithIndex:^id(id object, NSInteger index) {
                return [FBSDKSharePhoto photoWithImage:object userGenerated:YES];
            }];

            [Wself.class sharedDialog].shareContent = photoContent;
            [Wself.class sharedDialog].delegate = Sself;
            [[Wself.class sharedDialog] show];
        }];
    }
    return YES;
}

- (void)finish; {
    @synchronized (self) {
        _sharedDialog.shareContent = nil;
        _sharedDialog.delegate = nil;
        _sharedDialog = nil;
        [super finish];
    }
}

- (NSString *)fallbackAppStoreId; {
    return @"454638411";
}

- (BOOL)handleOpenURL:(UIApplication *)application url:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation; {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                   openURL:url
                                         sourceApplication:sourceApplication
                                                annotation:annotation];
}

- (void)sharer:(id <FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results; {
    [self dispatchFinshed:STExportResultSucceed];
}

- (void)sharer:(id <FBSDKSharing>)sharer didFailWithError:(NSError *)error; {
    [self dispatchFinshed:STExportResultFailed];
}

- (void)sharerDidCancel:(id <FBSDKSharing>)sharer; {
    [self dispatchFinshed:STExportResultCanceled];
}


@end