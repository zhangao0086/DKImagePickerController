//
// Created by BLACKGENE on 2015. 2. 14..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STExporterWeChat.h"
#import "STPhotoItem.h"
#import "STExporter+IO.h"
#import "STExporter+URL.h"
#import "STExporter+Config.h"
#import "STExporter+Handle.h"

static BOOL _canOpenApp;
@implementation STExporterWeChat {
    SendMessageToWXReq * _req;
}

- (NSString *)serviceName; {
    return @"WeChat";
}

+ (BOOL)canOpenApp {
    if(_canOpenApp){
        return YES;
    }
    return (_canOpenApp = [WXApi isWXAppInstalled]);
}

+ (BOOL)setup; {
    return [WXApi registerApp:@"wx063ab48ce4a0152b"];
}

+ (NSSet *)primarySupportedLocaleCodes; {
    return [NSSet setWithObjects:@"CN", @"zh-Hans", @"zh-Hant", @"zh-HK", nil];
}

- (BOOL)prepare; {
    _shouldFallback = ![self.class canOpenApp];
    self.shouldSucceesWhenEnterBackground = YES;

    return !self.shouldFallback;
}

- (BOOL)export {
    STPhotoItem *photoItem = self.photoItems.first;

    [self dispatchStartProcessing];

    Weaks
    [self exportDatas:@[self.photoItems.first] completion:^(NSArray *datas) {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = @"";
        message.description = STExporter.localizedPromotionMessageWhenSent;
        [message setThumbImage:[photoItem previewImage]];

        WXImageObject *ext = [WXImageObject object];
        ext.imageData = [datas firstObject];
        message.mediaObject = ext;

        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = WXSceneSession;

        Strongs
        Sself->_req = req;

        BOOL sended = [WXApi sendReq:Sself->_req];
        if(sended){
            [Sself dispatchFinshed:STExportResultSucceed];
        }else{
            [Sself dispatchFinshed:STExportResultFailed];
        }

        [Sself dispatchStopProcessing];

    }];
    return YES;
}

- (NSURL *)fallbackAppStoreURL; {
    return [NSURL URLWithString:[WXApi getWXAppInstallUrl]];
}

- (BOOL)handleOpenURL:(UIApplication *)application url:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation; {
    return [WXApi handleOpenURL:url delegate:nil];
}

- (void)finish; {
    _req = nil;
    [super finish];
}

@end
