//
// Created by BLACKGENE on 2014. 11. 1..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"

@class STPhotoItem;
@class STExporterViewOption;

extern NSString * const STExporterAuthorizationInputDataAccountKey;
extern NSString * const STExporterAuthorizationInputDataPasswordKey;

typedef NS_ENUM(NSInteger, STExporterAuthorizationType) {
    STExporterAuthorizationTypeUndefined,
    STExporterAuthorizationTypeAppLink,
    STExporterAuthorizationTypeOAuth,
    STExporterAuthorizationTypeInputAccountPassword
};
typedef NS_ENUM(NSInteger, STExportType) {
    //partner
            STExportTypeTumblr,
    //messenger
            STExportTypeWhatsApp,
    STExportTypeFacebookMessenger,
    STExportTypeLine,
    STExportTypeKik,
    //sns
            STExportTypeInstagram,
    STExportTypeFacebook,
    STExportTypeTwitter,
    //system
            STExportTypeOpenIn,
    STExportTypeShare,
    STExportTypeSaveToLibrary,
    STExportTypeSaveToPhotos,
    STExportType_count,
    STExportType_blank,
    STExportTypeWeChat
};

typedef NS_ENUM(NSInteger, STExportQuality) {
    STExportQualityOptimized,
    STExportQualityOriginal,
    STExportQualityAuto
};

typedef NS_ENUM(NSInteger, STExportResult) {
    STExportResultImpossible,
    STExportResultFailed,
    STExportResultFailedAndTriedFallback,
    STExportResultCanceled,
    STExportResultSucceed
};


@interface STExporter : STItem{
@protected
    BOOL _shouldNeedAuthorize;
    BOOL _allowedFullResolution;
    BOOL _shouldFallback;
    BOOL _shouldWaitUsersInteraction;
}
//readonly
@property (nonatomic, readonly) STExportType type;
@property (nullable, nonatomic, readonly) NSString * serviceName;
@property (nonatomic, readonly) NSUInteger allowedCount;
@property (nonatomic, readonly) BOOL allowedFullResolution;
@property (nonatomic, readonly) BOOL shouldFallback;
@property (nonatomic, readonly) BOOL shouldWaitUsersInteraction;
//Authorization
@property (nonatomic, readonly) BOOL shouldNeedAuthorize;
@property (nonatomic, readonly) STExporterAuthorizationType authorizationType;
//writable
@property (nonatomic, assign) BOOL shouldSucceesWhenEnterBackground;
@property (nonatomic, readwrite, nullable) NSArray * photoItems;
@property (nonatomic, assign) BOOL processing;
//social marketing
@property (nullable, nonatomic, readwrite) NSArray * hashtags;
//view
@property (nonatomic, readonly) BOOL shouldNeedViewWhenExport;
@property (nonatomic, readonly) STExporterViewOption * viewOption;

+ (BOOL)setup;

+ (nullable NSSet *)primarySupportedLocaleCodes;

- (instancetype)initWithType:(STExportType)type;

- (BOOL)prepare;

- (void)authorize:(NSDictionary *)inputData result:(void (^)(BOOL succeed, id data))block;

- (BOOL)export;

- (void)finish;

- (void)fallback;

- (void)whenFinished:(void(^)(STExporter * __weak exporter, STExportResult result))block;

- (void)dispatchFinshed:(STExportResult)result;
@end