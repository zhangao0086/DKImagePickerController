//
// Created by BLACKGENE on 2015. 12. 2..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "NSString+STUtil.h"
#import "NSArray+STUtil.h"
#import "NSNumber+STUtil.h"
#import "STApp.h"

@implementation STApp

static Class _defaultAppClass;
+ (Class)defaultAppClass{
    return _defaultAppClass?:STApp.class;
}

+ (void)registerDefinitions {
    _defaultAppClass = self.class;
}

NSString *const STAppIdentificationURLQueryKey = @"appid";
+ (NSString *)identification {
    static NSString * _id;
    BlockOnce(^{
        _id = [[NSBundle mainBundle] infoDictionary][(__bridge_transfer NSString *) kCFBundleIdentifierKey];
    });
    return _id;
}

+ (NSString *)displayName {
    static NSString * _displayName;
    BlockOnce(^{
        _displayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    });
    return _displayName;
}

+ (NSString *)appVersion{
    static NSString * _appVersion;
    BlockOnce(^{
        _appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    });
    return _appVersion;
}

+ (NSInteger)appVersionsDistanceWithCurrent:(NSString *)target{
    return [self appVersionsDistance:target new:[self appVersion]];
}

+ (NSInteger)appVersionsDistance:(NSString *)old new:(NSString *)new{
    /*
    pseudo (based on semantic versioning)

    v="1.1.14".split('.')
    o="1.2".split('.')
    vl=len(o)-len(v)
    at=None
    if vl<0:
        at=o
    elif vl>0:
        at=v
    for i in range(abs(vl)):
        at.append('0')

    d=0
    for i in range(max(len(v),len(o))):
        on = int(v[i])
        nn = int(o[i])
        if abs(d)>0:
            #old->new
            if d>0:
                d += nn
            #new->old
            else:
                d -= on
        else:
            d += nn - on

 */
    if(!old){
        return 0;
    }
    NSParameterAssert(new);

    //caching
    NSString * cacheKey = NSStringWithFormat(@"%@_%@",old,new);
    static NSMutableDictionary * _appVersionsDistanceCachingDict;
    BlockOnce(^{
        _appVersionsDistanceCachingDict = [NSMutableDictionary dictionary];
    });
    if(_appVersionsDistanceCachingDict[cacheKey]){
        return [_appVersionsDistanceCachingDict[cacheKey] integerValue];
    }

    //calc
    NSMutableArray * olds = [[old split:@"."] mutableCopy];
    NSMutableArray * news = [[new split:@"."] mutableCopy];
#if DEBUG
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", @"."];
    NSAssert(([predicate evaluateWithObject:old]), @"version splitter '.' must contain in old");
    NSAssert(([predicate evaluateWithObject:new]), @"version splitter '.' must contain in new");
    for(NSString *e in [olds arrayByAddingObjectsFromArray:news])
        NSAssert([e st_isNumeric],@"Containing strings must be numeric type.");
#endif
    NSInteger dl = news.count-olds.count;
    for(id i in [@(abs(dl)) st_intArray]){
        if (dl<0) [news addObject:@"0"];
        else if (dl>0) [olds addObject:@"0"];
    }

    NSInteger distance=0;
    for(id i in [@(MAX(olds.count, news.count)) st_intArray]){
        NSInteger oldv = [olds[[i unsignedIntegerValue]] integerValue];
        NSInteger newv = [news[[i unsignedIntegerValue]] integerValue];
        if(abs(distance)>0){
            distance>0 ? (distance += oldv) : (distance -= newv);
        }else{
            distance += oldv - newv;
        }
    }

    _appVersionsDistanceCachingDict[cacheKey] = @(distance);
    return distance;
}

+ (NSString *)buildVersion {
    static NSString *_buildVersion;
    BlockOnce(^{
        _buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    });
    return _buildVersion;
}

+ (NSString *)defaultURLScheme {
    static NSString *_urlScheme;
    BlockOnce(^{
        for(id obj in [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleURLTypes"]){
            if([obj isKindOfClass:NSDictionary.class]){
                if([obj[@"CFBundleURLName"] isEqualToString:[self identification]]){
                    _urlScheme = [obj[@"CFBundleURLSchemes"] firstObject];
                }
            }
        }
    });
    return _urlScheme;
}

+ (BOOL)isInSimulator{
    return TARGET_IPHONE_SIMULATOR;
}

+ (BOOL)isDebugMode{
#if DEBUG
    return YES;
#endif
    return NO;
}

+ (CGFloat)screenScale{
    static CGFloat _scale;
    BlockOnce(^{
        _scale = [[UIScreen mainScreen] scale];
    });
    return _scale;
}

+ (BOOL)isCurrentScreenScaleMemorySafe{
    return self.screenScale<=2;
}

+ (CGSize)memorySafetyRasterSize:(CGSize)pixelSize {
    return CGSizeByScale(pixelSize, TwiceMaxScreenScale());
}

+ (UIImage *)appIconImage{
    return [UIImage imageNamed: [[[[[NSBundle mainBundle] infoDictionary][@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"] objectAtIndex:0]];
}

#pragma mark Business
+ (NSString *)appstoreId{
    return nil;
}

+ (NSString *)siteUrl {
    return nil;
}

+ (NSString *)localizedSiteUrl {
    if([self.languageCode isEqualToString:self.baseLanguageCode]){
        return [self siteUrl];
    }else{
        return [self.siteUrl st_add:self.languageCode];
    }
}

#pragma mark Locale
/*

[language designator]
en
fr
An unspecified region where the language is used.

[language designator]_[region designator]
en_GB
zh_HK
The language used by and regional preference of the user.

[language designator]-[script designator]
az-Arab
zh-Hans
An unspecified region where the script is used.

[language designator]-[script designator]_[region designator]
zh-Hans_HK
The script used by and regional preference of the user.

 */
+ (NSString *)baseLanguageCode {
    return @"en-US";
}

+ (NSString *)baseLanguageCodeExcludingRegion {
    return [self languageCodeExcludingRegion:[self baseLanguageCode]];
}

+ (NSString *)languageCode {
    static NSString *_langCode = nil;
    if(!_langCode){
        if(!(_langCode = [[NSLocale preferredLanguages] st_objectOrNilAtIndex:0])){
            _langCode = [self baseLanguageCode];
        }
    }
    return _langCode;
}

+ (NSString *)languageCodeExcludingRegion {
    return [self languageCodeExcludingRegion:[self languageCode]];
}

+ (NSArray *)localeCodes{
    NSLocale * locale = [NSLocale autoupdatingCurrentLocale];
    //US, en, en_US, en-US
    //https://fabric.io/jessi/ios/apps/com.stells.eliew/issues/56f3c994ffcdc0425019a612
    NSMutableArray * codes = [NSMutableArray array];
    if([locale objectForKey:NSLocaleCountryCode]){
        [codes addObject:[locale objectForKey:NSLocaleCountryCode]];
    }
    if([locale objectForKey:NSLocaleLanguageCode]){
        [codes addObject:[locale objectForKey:NSLocaleLanguageCode]];
    }
    if([locale localeIdentifier]){
        [codes addObject:[locale localeIdentifier]];
    }
    if([self languageCode]){
        [codes addObject:[self languageCode]];
    }
    return codes;
}

+ (NSString *)languageCodeExcludingRegion:(NSString *)languageCode {
    return [[languageCode componentsSeparatedByString:@"-"] firstObject];
}

#pragma mark gid
+ (NSString *)gidDelimeter{
    return @"|";
}

+ (NSString *)createNewGid {
    NSString * uuid = [NSString stringWithFormat:@"%@-%@",[self displayName],[NSUUID UUID].UUIDString];
    NSString * appVersion = [self appVersion];
    NSString * buildVersion = [self buildVersion];
    NSString * device = [DeviceUtil hardwareDescription];
    device = device ? [device st_clearWhitespace] : @"Unknown";
    NSString * iosversion = [UIDevice currentDevice].systemVersion;
    NSString * locales = [self.localeCodes join:@","];
    NSString * time = @(round([[NSDate date] timeIntervalSince1970])).stringValue;
    return [@[uuid, appVersion, buildVersion, device, iosversion,locales,time] join:self.gidDelimeter];
}

#pragma mark Capability
+ (Hardware)hardware{
    static Hardware _hardware;
    BlockOnce(^{
        _hardware = [DeviceUtil hardware];
    });
    return _hardware;
}

+ (STDeviceModelFamily)deviceModelFamily; {
    static STDeviceModelFamily _deviceModelFamily;
    BlockOnce(^{
        _deviceModelFamily = [self _deviceModelFamily];
    });
    return _deviceModelFamily;
}

//https://en.wikipedia.org/wiki/List_of_iOS_devices
+ (STDeviceModelFamily)_deviceModelFamily; {
    Hardware hardware = [self hardware];
    switch(hardware){
            //iphone
        case IPHONE_2G:
        case IPHONE_3G:
        case IPHONE_3GS:
        case IPHONE_4:
        case IPHONE_4_CDMA:
        case IPHONE_4S:
            return STDeviceModelFamilyNotHandled;

        case IPHONE_5:
        case IPHONE_5_CDMA_GSM:
        case IPHONE_5C:
        case IPHONE_5C_CDMA_GSM:
        case IPHONE_5S:
        case IPHONE_5S_CDMA_GSM:
            return STDeviceModelFamilyIPhone5;
        case IPHONE_6:
        case IPHONE_6_PLUS:
            return STDeviceModelFamilyIPhone6;
        case IPHONE_6S:
        case IPHONE_6S_PLUS:
            return STDeviceModelFamilyIPhone6s;
        case IPHONE_SE:
            return STDeviceModelFamilyIPhoneSE;

            //ipod touch
        case IPOD_TOUCH_1G:
        case IPOD_TOUCH_2G:
        case IPOD_TOUCH_3G:
        case IPOD_TOUCH_4G:
        case IPOD_TOUCH_5G:
            return STDeviceModelFamilyNotHandled;
        case IPOD_TOUCH_6G:
            return STDeviceModelFamilyCurrentIPodTouch;

            //ipad
        case IPAD:
            return STDeviceModelFamilyNotHandled;

        case IPAD_2:
        case IPAD_2_WIFI:
        case IPAD_2_CDMA:
        case IPAD_3:
        case IPAD_3G:
        case IPAD_3_WIFI:
        case IPAD_3_WIFI_CDMA:
        case IPAD_4:
        case IPAD_4_WIFI:
        case IPAD_4_GSM_CDMA:

        case IPAD_MINI:
        case IPAD_MINI_WIFI:
        case IPAD_MINI_WIFI_CDMA:
        case IPAD_MINI_RETINA_WIFI:
        case IPAD_MINI_RETINA_WIFI_CDMA:
        case IPAD_MINI_RETINA_WIFI_CELLULAR_CN:

        case IPAD_AIR_WIFI:
        case IPAD_AIR_WIFI_GSM:
        case IPAD_AIR_WIFI_CDMA:
            return STDeviceModelFamilyPreviousIPad;

        case IPAD_MINI_3_WIFI:
        case IPAD_MINI_3_WIFI_CELLULAR:
        case IPAD_MINI_3_WIFI_CELLULAR_CN:
        case IPAD_MINI_4_WIFI:
        case IPAD_MINI_4_WIFI_CELLULAR:

        case IPAD_AIR_2_WIFI:
        case IPAD_AIR_2_WIFI_CELLULAR:
            return STDeviceModelFamilyCurrentIPad;

        case IPAD_PRO_WIFI:
        case IPAD_PRO_WIFI_CELLULAR:
        case IPAD_PRO_97_WIFI:
        case IPAD_PRO_97_WIFI_CELLULAR:
            return STDeviceModelFamilyIPadPro;

        default:
            return STDeviceModelFamilyUpComming;
    }
}

static STScreenFamily _screenFamily;
+ (STScreenFamily)screenFamily; {
    BlockOnce(^{
        _screenFamily = [self _screenFamily];
    });
    return _screenFamily;
}

+ (STScreenFamily)_screenFamily; {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGSize boundSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenVertical = UIDeviceOrientationIsPortrait(orientation) ? boundSize.height : boundSize.width;

    if (screenVertical == 480)
        return STScreenFamily35;
    else if(screenVertical == 568)
        return STScreenFamily4;
    else if(screenVertical == 667)
        return  STScreenFamily47;
    else if(screenVertical == 736)
        return STScreenFamily55;

    else if(screenVertical == 1024)
        return STScreenFamily768x1024;
    else if(screenVertical >= 1366)
        return STScreenFamily1024x1366;

    return STScreenFamilyNotHandled;
}

+ (BOOL)isCurrentDeviceInLowRenderingPerformanceFamily; {
    Hardware hardware = [self hardware];

    BOOL lowPerformanceDevice = NO;

    //check model
    switch(hardware){
        case IPHONE_4:
        case IPHONE_4S:
        case IPHONE_4_CDMA:
        case IPHONE_6_PLUS:
            lowPerformanceDevice |= YES;
        default:
            lowPerformanceDevice |= NO;
    }

    //check from screen scale
    if(self.screenScale<=2 && self.deviceModelFamily == STDeviceModelFamilyNotHandled){
        lowPerformanceDevice |= YES;
    }

    return lowPerformanceDevice;
}

+ (BOOL)isLivePhotoCompatible {
    static BOOL _isLivePhotoCompatible;
    BlockOnce(^{
        NSOperatingSystemVersion v = [self osVersion];
        _isLivePhotoCompatible = STDeviceModelFamilyIPhone6s <= [self deviceModelFamily] && 9 <= v.majorVersion && 1 <= v.minorVersion;
    })
    return _isLivePhotoCompatible;
}

+ (BOOL)isForceTouchCompatible {
    static BOOL _isForceTouchCompatible;
    BlockOnce(^{
        if([self osVersion].majorVersion >= 9){
            _isForceTouchCompatible = [UIScreen mainScreen].traitCollection.forceTouchCapability==UIForceTouchCapabilityAvailable;
        }
    });
    return _isForceTouchCompatible;
}

+ (NSOperatingSystemVersion)osVersion{
    static NSOperatingSystemVersion _osversion;
    BlockOnce(^{
        _osversion = [[NSProcessInfo processInfo] operatingSystemVersion];
    });
    return _osversion;
}

@end