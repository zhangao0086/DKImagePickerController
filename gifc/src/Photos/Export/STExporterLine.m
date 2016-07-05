//
// Created by BLACKGENE on 2015. 2. 19..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STExporterLine.h"
#import "STPhotoItem.h"
#import "STExporter+IO.h"
#import "STExporter+Handle.h"


@implementation STExporterLine

+ (NSSet *)primarySupportedLocaleCodes; {
    return [NSSet setWithObjects:@"JP", @"ja", nil];
}

+ (NSString *)scheme {
    return @"line";
}

+ (NSString *)appURLString{
    return @"line://msg/image";
}

- (BOOL)prepare; {
    self.shouldSucceesWhenEnterBackground = YES;
//    return [Line isLineInstalled];
    return [self.class canOpenApp];
}

- (BOOL)export; {
    [self dispatchStartProcessing];

    UIPasteboard *pasteboard = self.class.pasteboard;
    [pasteboard setData:[self exportData:self.photoItems.first] forPasteboardType:@"public.jpeg"];

    [self dispatchStopProcessing];

    return [[UIApplication sharedApplication] openURL:[[self.class appURL] URLByAppendingPathComponent:pasteboard.name]];
}

- (NSURL *)fallbackAppStoreURL; {
    return [NSURL URLWithString:@"http://itunes.apple.com/jp/app/line/id443904275?mt=8"];
}

- (NSString *)fallbackAppStoreId; {
    return @"443904275";
}

- (BOOL)shouldFallback; {
    return ![self.class canOpenApp];
}

+ (UIPasteboard *)pasteboard {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        return [UIPasteboard generalPasteboard];
    } else {
        return [UIPasteboard pasteboardWithName:@"jp.naver.linecamera.pasteboard" create:YES];
    }
}
@end