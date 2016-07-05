//
// Created by BLACKGENE on 2015. 2. 13..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STExporterWhatsApp.h"
#import "STPhotoItem.h"
#import "NSObject+STUtil.h"
#import "STExporter+IO.h"
#import "STExporter+URL.h"
#import "STExporter+Config.h"
#import "STExporter+Handle.h"

@interface STExporterWhatsApp()
@property (atomic, strong) UIDocumentInteractionController *docController;
@property BOOL didSend;
@end

@implementation STExporterWhatsApp

+ (NSString *)scheme {
    return @"whatsapp";
}

+ (NSString *)appURLString{
    return @"whatsapp://send";
}

- (BOOL)prepare; {

    _shouldFallback = ![self.class canOpenApp];

    [self finishAsyncPrepare];

    return !_shouldFallback;
}

- (void)exportFromAsyncPrepare; {
    STPhotoItem * photo = self.photoItems.first;
    NSString * text = STExporter.localizedPromotionMessageWhenSent;

    Weaks
    [self dispatchStartProcessing];

    [self exportFiles:@[photo] completion:^(NSArray *imageURLs) {
        Strongs
        Sself.docController = [UIDocumentInteractionController interactionControllerWithURL:[imageURLs firstObject]];
        Sself.docController.UTI = @"net.whatsapp.image";
        Sself.docController.annotation = @{@"text" : text};
        Sself.docController.delegate = Sself;

        [Sself.docController presentOpenInMenuFromRect:[Sself st_rootUVC].view.bounds inView:[Sself st_rootUVC].view animated:YES];

        [Sself dispatchStopProcessing];
    }];
}

- (void)finish; {
    [self.docController dismissMenuAnimated:NO];
    self.docController.delegate = nil;
    self.docController = nil;
    [super finish];
}

- (NSURL *)fallbackAppStoreURL; {
    return [[NSURL alloc] initWithString:@"http://itunes.apple.com/app/whatsapp-messenger/id310633997"];
}

- (NSString *)fallbackAppStoreId; {
    return @"310633997";
}

- (NSString *)preferedExtensionOfTempFile {
    return @"wai";
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller{
    [self dispatchFinshed:self.didSend?STExportResultSucceed:STExportResultCanceled];
}

- (void) documentInteractionController: (UIDocumentInteractionController *) controller willBeginSendingToApplication: (NSString *) application{
    self.didSend = YES;
}

@end
