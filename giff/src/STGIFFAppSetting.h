//
// Created by BLACKGENE on 2016. 4. 14..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STGIFFAppSetting.h"
#import "STAppSetting.h"
#import "STPhotoItem.h"


@interface STGIFFAppSetting : STAppSetting

STAppSettingCorePropertiesInterface

//common
@property (nonatomic, assign) NSInteger mode;
@property (nonatomic, assign) NSInteger elieMode;
@property (nonatomic, assign) NSInteger photoSource;
//basic camera
@property (nonatomic, assign) NSInteger flashLightMode;
@property (nonatomic, assign) BOOL enabledISOAutoBoost;
@property (nonatomic, assign) BOOL enabledBacklightCare;
@property (nonatomic, assign) NSString * captureSessionPreset;
@property (nonatomic, assign) NSInteger afterManualCaptureAction;
@property (nonatomic, assign) NSInteger captureOutputSizePreset;
//post focus
@property (nonatomic, assign) NSInteger postFocusMode;
//elie
@property (nonatomic, assign) NSInteger performanceMode;
//elie-face
@property (nonatomic, assign) NSInteger curtainType;
//elie-motion
@property (nonatomic, assign) NSInteger motionSensitive;
//elie-room
@property (nonatomic, assign) NSInteger roomSizePhase;
@property (nonatomic, assign) NSInteger _lastCapturedIndexInRoom;
@property (nonatomic, assign) BOOL securityModeEnabled;
@property (nonatomic, assign) NSDictionary * _photosOrigins;
//export
@property (nonatomic, assign) NSInteger exportedType;
@property (nonatomic, assign) NSInteger exportQuality;
//base effects
@property (nonatomic, assign) BOOL tiltShiftEnabled;
@property (nonatomic, assign) BOOL autoEnhanceEnabled;
@property (nonatomic, assign) BOOL autoEnhanceEnabledInEdit;
//usability
@property (nonatomic, assign) NSInteger userPreferedHanderType;
@property (nonatomic, assign) NSString * userPreferedFilterId;
//appinfo
@property (nonatomic, assign) NSString * _lastReleaseNoteSHA;
@property (nonatomic, assign) BOOL _touchedReleaseNoteSHA;
//giff
@property (nonatomic, assign) NSInteger torchLightMode;
@property (nonatomic, assign) NSTimeInterval animatableCaptureDuration;
@property (nonatomic, assign) NSTimeInterval reversePlaying;
//tutorial
@property (nonatomic, assign) BOOL _confirmedTutorialFilterSlide;
@property (nonatomic, assign) BOOL _confirmedTutorialPointedFocalPoint;

+ (NSArray *)valuesFlashLightMode;

- (NSUInteger)indexOfFlashLightMode;

- (NSString *)labelForPostFocusMode:(STPostFocusMode)mode;

- (NSInteger)currentRoomSize;

+ (NSInteger)roomSize:(STElieRoomSizePhase)phase;

+ (NSArray *)roomSizes;

- (void)savePhotosOrigin:(NSURL *)savedUrl origin:(STPhotoItemOrigin)origin;

- (STPhotoItemOrigin)photosOrigin:(NSURL *)savedUrl;

- (NSArray *)photoUrlsByOrigin:(STPhotoItemOrigin)origin;

- (void)clearPhotosOrigins;

- (BOOL)checkNewReleaseNoteIfPossible:(void (^)(BOOL updated))completion;

- (void)touchNewReleaseNoteIfNeeded;

+ (NSArray *)valuesExportType;

@end