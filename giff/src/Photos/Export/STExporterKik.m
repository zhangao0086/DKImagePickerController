//
// Created by BLACKGENE on 2015. 2. 25..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STExporterKik.h"
#import "KikMessage.h"
#import "KikClient.h"
#import "STExporter+IO.h"
#import "STExporter+URL.h"
#import "STExporter+Handle.h"


@implementation STExporterKik

+ (NSSet *)primarySupportedLocaleCodes; {
    return [NSSet setWithObjects:@"CA", @"en-CA", @"fr-CA", nil];
}

+ (NSString *)scheme {
    return @"kik-share";
}

+ (NSString *)appURLString{
    return @"kik-share://kik.com/send/";
}

- (NSString *)fallbackAppStoreId; {
    return @"357218860";
}

- (BOOL)prepare; {
    _shouldFallback = ![self.class canOpenApp];
    self.shouldSucceesWhenEnterBackground = YES;

    [self finishAsyncPrepare];

    return !self.shouldFallback;
}

//- (BOOL)shouldNeedViewWhenExport {
//    return YES;
//}

- (void)exportFromAsyncPrepare; {
    [self dispatchStartProcessing];

    [self exportAllFiles:^(NSArray *imageURLs) {
        NSString * urlString = [[imageURLs firstObject] absoluteString];
        KikMessage *message = [KikMessage photoMessageWithImageURL:urlString previewURL:nil];
//        [message.URLs addObjectsFromArray:imageURLs];
        [message addFallbackURL:@"itms-apps://itunes.apple.com/ca/app/kik/id357218860?mt=8" forPlatform:KikMessagePlatformiPhone];

        [[KikClient sharedInstance] sendKikMessage:message];
        [[KikClient sharedInstance] backToKik];
        [self dispatchStopProcessing];
    }];

//    [self exportAllImages:^(NSArray *images) {
//        KikMessage *message = [KikMessage photoMessageWithImage:[images firstObject]];
//        [message addFallbackURL:@"itms-apps://itunes.apple.com/ca/app/kik/id357218860?mt=8" forPlatform:KikMessagePlatformiPhone];
//
//        [[KikClient sharedInstance] sendKikMessage:message];
//        [[KikClient sharedInstance] backToKik];
//        [self dispatchStopProcessing];
//    }];
}

@end