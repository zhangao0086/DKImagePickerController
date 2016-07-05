//
// Created by BLACKGENE on 2016. 4. 14..
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STGIFCAppSetting.h"
#import <BlocksKit/NSArray+BlocksKit.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import "NSNumber+STUtil.h"
#import "STExporter.h"
#import "STCaptureRequest.h"

@implementation STGIFCAppSetting

STAppSettingCorePropertiesImplementation

//common
@dynamic mode;  //STCameraMode
@dynamic elieMode;  //STElieMode
@dynamic photoSource;   //STPhotoSource
//basic camera
@dynamic flashLightMode;    //AVCaptureFlashMode
@dynamic enabledISOAutoBoost;   //YES or NO
@dynamic enabledBacklightCare;  //YES or NO
@dynamic captureSessionPreset; // AVCaptureSessionPresetPhoto;
@dynamic afterManualCaptureAction;
@dynamic captureOutputSizePreset;
//post focus
@dynamic postFocusMode;
//special func
@dynamic curtainType; //Elie Curtain type
@dynamic performanceMode;  //EliePerformanceMode
//motion
@dynamic motionSensitive;   //ElieMotionDetectingSensitivity
//export
@dynamic exportedType; //STExportTypeSavedPhotos
@dynamic exportQuality;
//room mode
@dynamic _lastCapturedIndexInRoom; //-1
@dynamic roomSizePhase; //16
@dynamic securityModeEnabled;
@dynamic _photosOrigins;
//base effects
@dynamic tiltShiftEnabled;
@dynamic autoEnhanceEnabled;
@dynamic autoEnhanceEnabledInEdit;
//usability
@dynamic userPreferedHanderType;
@dynamic userPreferedFilterId;
//appinfo
@dynamic _lastReleaseNoteSHA;
@dynamic _touchedReleaseNoteSHA;
//gifc
@dynamic torchLightMode;
@dynamic animatableCaptureDuration;
@dynamic reversePlaying;
//tutorial
@dynamic _confirmedTutorialFilterSlide;
@dynamic _confirmedTutorialPointedFocalPoint;

#pragma mark Initialize

- (void)willFirstLaunch {
    [super willFirstLaunch];
}

- (void)didMigratedKeyRemoved:(NSString *)key; {
    [super didMigratedKeyRemoved:key];
}

#pragma mark In-App Properties for Products - Elie White

#if ELIE_W
- (NSDictionary *)productsKeyValueConfiguration {
    static NSDictionary * _products;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _products = @{
                STEWProduct_veil : @{
                        @keypath(self.curtainType) : @(ElieCurtainTypeBubble)
                }
                , STEWProduct_privacy : @{
                        @keypath(self.securityModeEnabled) : @(NO)
                }
                , STEWProduct_room : @{
                        @keypath(self.roomSizePhase) : @{STAppProductsKeyValueConfigurationDefaultValueKey: @(STElieRoomSizePhase0), STAppProductsKeyValueConfigurationActivationBoolValueKey : @YES}
                }
                , STEWProduct_selfietake : @{
                        @keypath(self.tiltShiftEnabled) : @(NO),
                        @keypath(self.enabledBacklightCare) : @(NO)
                }
        };

        //Assertion for overrdie setter
        for(NSDictionary * defaultValuesForKeypath in _products.allValues){
            for(NSString * k in [defaultValuesForKeypath allKeys]){
                NSAssert([self.class isPropertySetterOverridden:k], ([NSString stringWithFormat:@"%@ must have overridden property setters for a following keypath : %@",NSStringFromClass(self.class), k]));
            }
        }
    });

    return _products;
}

- (void)setTiltShiftEnabled:(BOOL)tiltShiftEnabled {
    [self setValueForProduct:@(tiltShiftEnabled) forKeyPath: @keypath(self.tiltShiftEnabled)];
}

- (void)setEnabledBacklightCare:(BOOL)enabledBacklightCare {
    [self setValueForProduct:@(enabledBacklightCare) forKeyPath:@keypath(self.enabledBacklightCare)];
}

- (void)setCurtainType:(NSInteger)curtainType {
    [self setValueForProduct:@(curtainType) forKeyPath:@keypath(self.curtainType)];
}

- (void)setSecurityModeEnabled:(BOOL)securityModeEnabled {
    [self setValueForProduct:@(securityModeEnabled) forKeyPath:@keypath(self.securityModeEnabled)];
}

- (void)setRoomSizePhase:(NSInteger)phase {
    [self setValueForProduct:@(phase) forKeyPath:@keypath(self.roomSizePhase)];
}

#endif

#pragma mark defaults
- (void)setDefaultToChangable:(NSString *)key; {
    // XXXX : changable
    // _XXXX : NOT changable, use in application.

    //application
    if([key isEqual:@keypath(self.mode)]) (self.mode = STCameraModeElie);

    else if([key isEqual:@keypath(self.elieMode)]) (self.elieMode = STElieModeFace);

    else if([key isEqual:@keypath(self.photoSource)]) (self.photoSource = STPhotoSourceAssetLibrary);
        //capture
    else if([key isEqual:@keypath(self.captureSessionPreset)]) (self.captureSessionPreset = AVCaptureSessionPresetPhoto);
        //export
    else if([key isEqual:@keypath(self.exportedType)]) (self.exportedType = STExportTypeSaveToLibrary);
    else if([key isEqual:@keypath(self.exportQuality)]) (self.exportQuality = STExportQualityAuto);
        //room
    else if([key isEqual:@keypath(self._lastCapturedIndexInRoom)]) (self._lastCapturedIndexInRoom = NSNotFound);
    else if([key isEqual:@keypath(self.roomSizePhase)]) (self.roomSizePhase = STElieRoomSizePhase0);

        //user preset
    else if([key isEqual:@keypath(self.flashLightMode)]) (self.flashLightMode = AVCaptureFlashModeOff);
    else if([key isEqual:@keypath(self.enabledISOAutoBoost)]) (self.enabledISOAutoBoost = YES);
    else if([key isEqual:@keypath(self.enabledBacklightCare)]) (self.enabledBacklightCare = NO);
    else if([key isEqual:@keypath(self.afterManualCaptureAction)]) (self.afterManualCaptureAction = STAfterManualCaptureActionEnterEdit);
    else if([key isEqual:@keypath(self.captureOutputSizePreset)]) (self.captureOutputSizePreset = [[STCaptureRequest supportedPresets] containsObject:@(CaptureOutputSizePresetMedium)] ? CaptureOutputSizePresetMedium : CaptureOutputSizePresetSmall);

    else if([key isEqual:@keypath(self.motionSensitive)]) (self.motionSensitive = ElieMotionDetectingSensitivityNormal);
    else if([key isEqual:@keypath(self.curtainType)]) (self.curtainType = ElieCurtainTypeBubble);
    else if([key isEqual:@keypath(self.securityModeEnabled)]) (self.securityModeEnabled = NO);
    else if([key isEqual:@keypath(self.geotagEnabled)]) (self.geotagEnabled = NO);
        //post focus
    else if([key isEqual:@keypath(self.postFocusMode)]) (self.postFocusMode = STPostFocusModeFullRange);
        //base effects
    else if([key isEqual:@keypath(self.tiltShiftEnabled)]) (self.tiltShiftEnabled = NO);
    else if([key isEqual:@keypath(self.autoEnhanceEnabled)]) (self.autoEnhanceEnabled = NO);
    else if([key isEqual:@keypath(self.autoEnhanceEnabledInEdit)]) (self.autoEnhanceEnabledInEdit = NO);
        //usablilty
    else if([key isEqual:@keypath(self.userPreferedHanderType)]) (self.userPreferedHanderType = STUserPreferedHanderTypeUnspecified);
    else if([key isEqual:@keypath(self.userPreferedFilterId)]) (self.userPreferedFilterId = nil);
}

- (void)validate {
    if(self.mode == STCameraModeNotInitialized || (self.mode != STCameraModeElie && self.mode != STCameraModeManual)){
        [self setDefaultToChangable:@keypath(self.mode)];
    }


}

- (void)setPolicy {
    [super setPolicy];

    //TODO: 추후 메뉴얼 즉시 진입을 안정화 시키고 이 코드를 삭제함.
    self.mode = STCameraModeElie;

    if([@"1.1" isEqualToString:[STApp appVersion]]){
        self.afterManualCaptureAction = STAfterManualCaptureActionEnterEdit;
    }

}

- (void)setPolicyLaunchFirst {

}

- (void)setPolicyLaunchSinceLastBuildNotFirst:(NSString *)previousBuildVersion {

}

- (void)setSubscribe{

}

#pragma mark values

+ (NSArray *)valuesExportType; {
    static NSArray *_values;
    if(!_values){
        return _values = [@(STExportType_count) st_intArray];
    }
    return _values;
}

+ (NSArray *)valuesFlashLightMode {
    static NSArray *_values;
    if(!_values){
        return _values = @[
                @(AVCaptureFlashModeAuto),
                @(AVCaptureFlashModeOn),
                @(AVCaptureFlashModeOff)];
    }
    return _values;
}

- (NSUInteger)indexOfFlashLightMode{
    return [[self.class valuesFlashLightMode] indexOfObject:@(self.flashLightMode)];
}

- (void)setFlashLightModeByIndex:(NSUInteger)index{
    self.flashLightMode = [[[self.class valuesFlashLightMode] objectAtIndex:index] integerValue];
}


- (NSString *)labelForPostFocusMode:(STPostFocusMode)mode{
    switch(mode){
        case STPostFocusMode5Points:
            return @"5 Focal Points";
        case STPostFocusModeVertical3Points:
            return @"Vertical Focal Points";
        case STPostFocusModeFullRange:
            return @"Full Range";
        default:
            return nil;
    }
}

#pragma mark Room
- (NSInteger)currentRoomSize {
    return [self.class roomSize:(STElieRoomSizePhase) [[self read:@keypath(self.roomSizePhase)] integerValue]];
}

+ (NSInteger)roomSize:(STElieRoomSizePhase)phase{
    switch (phase){
        case STElieRoomSizePhase0: return 16;
        case STElieRoomSizePhase1: return 32;
        case STElieRoomSizePhase2: return 64;
        case STElieRoomSizePhase3: return 128;
        case STElieRoomSizePhase_count:
            NSParameterAssert(NO);
            break;
    }
    return [self roomSize: STElieRoomSizePhase0];
}

+ (NSArray *)roomSizes{
    static NSArray * _roomSizes;
    BlockOnce(^{
        _roomSizes = [[@(STElieRoomSizePhase_count) st_intArray] bk_map:^id(id obj) {
            return @([self roomSize:(STElieRoomSizePhase) [obj integerValue]]);
        }];
    });
    return _roomSizes;
}

#pragma mark PhotoItemOrigin
- (NSString *)keyPhotosOrigin:(NSURL *)savedUrl {
    return [savedUrl absoluteString];
}

- (void)savePhotosOrigin:(NSURL *)savedUrl origin:(STPhotoItemOrigin)origin{
    NSParameterAssert(savedUrl);
    if(savedUrl){
        NSString * key = [self keyPhotosOrigin:savedUrl];
        NSAssert(key, @"key is cannot be nil");
        if(key){
            NSMutableDictionary * origins = self._photosOrigins ? [self._photosOrigins mutableCopy] : [NSMutableDictionary dictionary];
            origins[key] = @(origin);
            self._photosOrigins = origins;
        }
    }
}

- (STPhotoItemOrigin)photosOrigin:(NSURL *)savedUrl {
    NSString * key = [self keyPhotosOrigin:savedUrl];
    NSDictionary * dictionary = [self read:@keypath(self._photosOrigins)];
    return dictionary && [dictionary hasKey:key] ? (STPhotoItemOrigin)[dictionary[key] integerValue] : STPhotoItemOriginUndefined;
}

- (NSArray *)photoUrlsByOrigin:(STPhotoItemOrigin)origin{
    NSDictionary * dictionary = [self read:@keypath(self._photosOrigins)];
    return [dictionary allKeysForObject:@(origin)];
}

- (void)clearPhotosOrigins{
    self._photosOrigins = nil;
}

#pragma mark Web Resources
//TODO : 추후 파일이나 폴더의 깃허브 컨텐츠를 확인할 수 있는 공통 컴퍼넌트로 분리
static BOOL newReleaseNoteAvailableFetched;
- (BOOL)checkNewReleaseNoteIfPossible:(void(^)(BOOL updated))completion{
    NSParameterAssert(completion);

    //already fetched
    if(newReleaseNoteAvailableFetched){
        !completion?:completion(!self._touchedReleaseNoteSHA);
        return NO;
    }

    //recheck by each 6 hours
    if(![self isPassedHoursSinceLastLaunched:6]){
        !completion?:completion(!self._touchedReleaseNoteSHA);
        return NO;
    }

    Weaks
    [[AFHTTPSessionManager manager] GET:[STGIFCApp releaseNoteAPIUrlToCheckVersion]
                                      parameters:nil progress:nil
                                         success:^(NSURLSessionDataTask *operation, id responseObject) {

                                             if([responseObject isKindOfClass:[NSArray class]]) {
                                                 NSArray *files = responseObject;
                                                 NSDictionary * info = nil;
                                                 for(NSDictionary *_info in files){
                                                     @try {
                                                         NSString * lname = [[[[_info valueForKey:@"name"] split:@"."] firstObject] lowercaseString];
                                                         //primary current language
                                                         if([lname containsString:[STApp languageCodeExcludingRegion]]){
                                                             info = _info;
                                                             break;
                                                         }
                                                             //secondary current language
                                                         else if([lname containsString:[STApp baseLanguageCodeExcludingRegion]]){
                                                             info = _info;
                                                         }

                                                     } @finally{}
                                                 }

                                                 NSString * sha = [info valueForKey:@"sha"];
                                                 if(sha && ![sha isEqualToString:Wself._lastReleaseNoteSHA]){
                                                     Wself._lastReleaseNoteSHA = sha;
                                                     Wself._touchedReleaseNoteSHA = NO;
                                                     [Wself synchronize];
                                                 }

                                                 newReleaseNoteAvailableFetched = YES;
                                             }

                                             !completion?:completion(!Wself._touchedReleaseNoteSHA);
                                         }
                                         failure:^(NSURLSessionDataTask *operation, NSError *error) {

                                             !completion?:completion(NO);
                                         }];

    return YES;
}

- (void)touchNewReleaseNoteIfNeeded {
    self._touchedReleaseNoteSHA = YES;
    [self synchronize];
}
@end
