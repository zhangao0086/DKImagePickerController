//
// Created by BLACKGENE on 2015. 2. 12..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "NSArray+BlocksKit.h"
#import "STExporterInstagram.h"
#import "STPhotoItem.h"
#import "NSString+STUtil.h"
#import "NSObject+STUtil.h"
#import "NSObject+STThreadUtil.h"
#import "STExporter+IO.h"
#import "STExporter+Config.h"
#import "NSURLComponents+STUtil.h"
#import "STExporter+Handle.h"

@interface STExporterInstagram ()
@property (atomic, strong) UIDocumentInteractionController *docController;
@property BOOL didSend;
@end

#define MAX_RESOLUTION_IPHONE_3GS 1536.0f
#define MAX_RESOLUTION_IPHONE_4 1936.0f

/*
 * https://instagram.com/developer/iphone-hooks/?hl=en
 *
app	The Instagram app
camera	The camera (or photo library on non-camera devices)
media?id=MEDIA_ID	Media with this ID
user?username=USERNAME	User with this username
location?id=LOCATION_ID	Location feed for this location ID
tag?name=TAG	Tag feed for this tag

 https://www.instagram.com/explore/tags/eliecam/
 */
@implementation STExporterInstagram {
    BOOL _presentAlone;
};

+ (NSString *)scheme {
    return @"instagram";
}

+ (NSString *)appURLString{
    return @"instagram://app";
}

+ (NSString *)appURLStringWithHashtagName:(NSString *)hashtag {
    return [[[[self scheme] URLSchemeComponent] st_host:@"tag"] st_query:@{@"name":hashtag}].string;
}

+ (NSString *)appURLStringWithUserName:(NSString *)userName {
    return [[[[self scheme] URLSchemeComponent] st_host:@"user"] st_query:@{@"username": userName}].string;
}

+ (NSString *)webURLStringWithUserName:(NSString *)userName {
    return [[self webURL] URLByAppendingPathComponent:userName].absoluteString;
}

+ (NSString *)webURLStringWithHashtagName:(NSString *)hashtag {
    return [@"http://www.instagram.com/explore/tags/" st_add:hashtag];
}

+ (NSString *)webURLString{
    return @"http://instagram.com/";
}

- (BOOL)prepare; {
    _shouldFallback = ![self.class canOpenApp];
    _presentAlone = YES;

//    if(tmpImg.size.width != tmpImg.size.height && [SHKCONFIG(instagramLetterBoxImages) boolValue]){
//        float size = tmpImg.size.width > tmpImg.size.height ? tmpImg.size.width : tmpImg.size.height;
//        CGFloat maxPhotoSize = [self maxPhotoSize];
//        if(size > maxPhotoSize) size = maxPhotoSize;
//        tmpImg = [self imageByScalingImage:tmpImg proportionallyToSize:CGSizeMake(size,size)];
//    }
//
//    NSData* imgData = [self generateImageData:tmpImg];

    [self finishAsyncPrepare];

    return !_shouldFallback;
}

- (NSString *)fallbackAppStoreId; {
    return @"389801252";
}

- (void)exportFromAsyncPrepare; {
    [self dispatchStartProcessing];

    NSString * title = STExporter.localizedPromotionMessageWhenSent;
    NSArray * tags = self.hashtags;
    STPhotoItem * photo = self.photoItems.first;
    Weaks
    [self exportFiles:@[photo] completion:^(NSArray *imageURLs) {
        @autoreleasepool {
            Strongs
            Sself.docController = [UIDocumentInteractionController interactionControllerWithURL:[imageURLs firstObject]];

            if (Sself->_presentAlone) {
                Sself.docController.UTI = @"com.instagram.exclusivegram";
            } else {
                Sself.docController.UTI = @"com.instagram.photo";
            }

            NSString *captionString = [NSString stringWithFormat:@"%@%@%@", title,
                                                                 [title length] && [tags count] ? @" " : @"",
                                                                 [[tags bk_map:^id(id obj) {
                                                                     return [@"#" st_add:obj];
                                                                 }] join:@" "]];

            Sself.docController.annotation = @{@"InstagramCaption" : captionString};
            Sself.docController.delegate = Wself;

            WeakObject(Sself) WWself = Sself;
            [Sself st_runAsMainQueueAsync:^{
                [WWself dispatchStopProcessing];
                [WWself.docController presentOpenInMenuFromRect:[WWself st_rootUVC].view.bounds inView:[WWself st_rootUVC].view animated:YES];
            }];
        }
    }];
}

- (void)finish; {
    [self.docController dismissMenuAnimated:NO];
    self.docController.delegate = nil;
    self.docController = nil;
    [super finish];
}

- (NSString *)preferedExtensionOfTempFile {
    return _presentAlone ? @"igo" : @"ig";
}

- (CGFloat)_maxPhotoSize {
    CGFloat scale = [[UIScreen mainScreen] scale];
    if (scale == 1.0f) {
        return MAX_RESOLUTION_IPHONE_3GS;
    } else {
        return MAX_RESOLUTION_IPHONE_4;
    }
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller{
    [self dispatchFinshed: self.didSend ? STExportResultSucceed : STExportResultCanceled];
}

- (void) documentInteractionController: (UIDocumentInteractionController *) controller willBeginSendingToApplication: (NSString *) application{
    self.didSend = YES;
}

@end
