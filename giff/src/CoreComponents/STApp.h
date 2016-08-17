//
// Created by BLACKGENE on 2015. 12. 2..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceUtil.h"

/*
    Usability
 */
typedef NS_ENUM(NSInteger, STUserPreferedHanderType) {
    STUserPreferedHanderTypeRight,
    STUserPreferedHanderTypeLeft,
    STUserPreferedHanderTypeUnspecified,
    STUserPreferedHanderType_count
};

/*
    Capablity
 */
typedef NS_ENUM(NSInteger, STDeviceModelFamily) {
    STDeviceModelFamilyNotHandled,

    STDeviceModelFamilyCurrentIPodTouch,

    STDeviceModelFamilyPreviousIPad,
    STDeviceModelFamilyCurrentIPad,
    STDeviceModelFamilyIPadPro,

    STDeviceModelFamilyIPhone5,
    STDeviceModelFamilyIPhone6,
    STDeviceModelFamilyIPhone6s,
    STDeviceModelFamilyIPhoneSE,

    STDeviceModelFamilyUpComming
};

//http://iosres.com/
typedef NS_ENUM(NSInteger, STScreenFamily){
    STScreenFamilyNotHandled,
    STScreenFamily35,
    STScreenFamily4,
    STScreenFamily47,
    STScreenFamily55,
    //ipad
    STScreenFamily768x1024,
    //ipad pro
    STScreenFamily1024x1366
};

extern NSString *const STAppIdentificationURLQueryKey;

@interface STApp : NSObject

+ (Class)defaultAppClass;

+ (void)registerDefinitions;

+ (NSString *)identification;

+ (NSString *)displayName;

+ (NSString *)appVersion;

+ (NSInteger)appVersionsDistanceWithCurrent:(NSString *)target;

+ (NSInteger)appVersionsDistance:(NSString *)oldVersion new:(NSString *)version;

+ (NSString *)buildVersion;

+ (NSString *)defaultURLScheme;

+ (BOOL)isInSimulator;

+ (BOOL)isDebugMode;

+ (CGFloat)screenScale;

+ (BOOL)isCurrentScreenScaleMemorySafe;

+ (CGSize)memorySafetyRasterSize:(CGSize)pixelSize;

+ (UIImage *)appIconImage;

+ (NSString *)appstoreId;

+ (NSString *)siteUrl;

+ (NSString *)localizedSiteUrl;

+ (NSString *)baseLanguageCode;

+ (NSString *)baseLanguageCodeExcludingRegion;

+ (NSString *)languageCode;

+ (NSString *)languageCodeExcludingRegion;

+ (NSArray *)localeCodes;

+ (NSString *)gidDelimeter;

+ (NSString *)createNewGid;

+ (Hardware)hardware;

+ (STDeviceModelFamily)deviceModelFamily;

+ (STScreenFamily)screenFamily;

+ (BOOL)isCurrentDeviceInLowRenderingPerformanceFamily;

+ (BOOL)isLivePhotoCompatible;

+ (BOOL)isForceTouchCompatible;

+ (NSOperatingSystemVersion)osVersion;

@end