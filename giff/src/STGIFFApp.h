//
// Created by BLACKGENE on 2014. 9. 14..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

/*
    Notification Singnitures
 */
#import <Foundation/Foundation.h>
#import <DeviceUtil/DeviceUtil.h>
#import "STApp.h"

@class SKPaymentTransaction;
@class STStandardButton;

typedef NS_ENUM(NSInteger, STApplicationMode) {
    STApplicationModeDefault,
    STApplicationModeTestView,
    STApplicationModeTestCamera
};

#define STNotificationPhotosDidLoaded @"camera.elie.photos.changed"
#define STNotificationPhotosDidLoadedAndCellsInserted @"camera.elie.photos.cellsinserted"
#define STNotificationManualCapture @"camera.elie.signal.usermanual.capture"
#define STNotificationManualCaptureFinished @"camera.elie.signal.usermanual.capture.finished"
#define STNotificationCameraInitialized @"camera.elie.init"
#define STNotificationFaceDetectionInitialized @"camera.elie.facedetection"
#define STNotificationFaceDetectionAndHomePreviewInitialized @"camera.elie.homeinit"
#define STNotificationPhotosDidLocalSaved @"camera.elie.saved.succeed"

/*
    File, I/O
 */
#define kSTImageFilePrefix_OrigianlImage @"elie_tmpimg_o_"
#define kSTImageFilePrefix_Fullscreen @"elie_tmpimg_f_"
#define kSTImageFilePrefix_PreviewImage @"elie_tmpimg_p_"

#define kSTImageFilePrefix_TempToEdit_OrigianlImage @"elie_editimg_o"
#define kSTImageFilePrefix_TempToEdit_Fullscreen @"elie_editimg_f"
#define kSTImageFilePrefix_TempToEdit_PreviewImage @"elie_editimg_p"

#define MAX_ALLOWED_EXPORT_COUNT 20

/*
    User Action
 */
typedef NS_ENUM(NSInteger, STUserAction) {
    STUserActionChangeCameraMode,
    STUserActionManualCapture,
    STUserActionManualAnimatableCapture,
    STUserActionManualPostFocusCapture,
    STUserActionSetNeedsContext,
    STUserActionChangeElieMode
};

/*
    Elie Camera
 */
#define kSTHapticRestartInterval 0.3
#define kSTFaceMovingIdleMinValue 1.0

typedef NS_ENUM(NSInteger, STTorchLightMode) {
    STTorchLightModeOff,
    STTorchLightModeWeak,
    STTorchLightModeMax,
    STTorchLightMode_count
};


/*
    PhotosView
 */
#define kSTBuffPhotosGridCol 4


typedef NS_ENUM(NSInteger, STAfterManualCaptureAction) {
    STAfterManualCaptureActionSaveToLocalAndContinue,
    STAfterManualCaptureActionEnterEdit,
    STAfterManualCaptureActionEnterAnimatableReview,
    STAfterManualCaptureActionSaveToRemoveDirectlyAndContinue,
    STAfterManualCaptureAction_count
};

typedef NS_ENUM(NSInteger, STPreviewCollectorEnterTransitionContext) {
    STPreviewCollectorEnterTransitionContextDefault,
    STPreviewCollectorEnterTransitionContextFromCollectionViewItemSelected
};

typedef NS_ENUM(NSInteger, STPreviewCollectorExitTransitionContext) {
    STPreviewCollectorExitTransitionContextDefault,
    STPreviewCollectorExitTransitionContextSaveToLibraryFromEditedPhotoInRoom,
    STPreviewCollectorExitTransitionContextDeletingInExport,
    STPreviewCollectorExitTransitionContextCancelInEdit
};

/*
 * Room
 */

typedef NS_ENUM(NSUInteger, STElieRoomSizePhase) {
    STElieRoomSizePhase0,
    STElieRoomSizePhase1,
    STElieRoomSizePhase2,
    STElieRoomSizePhase3,
    STElieRoomSizePhase_count
};

/*
    Elie
 */

typedef NS_ENUM(NSInteger, STElieMode) {
    STElieModeFace,
    STElieModeMotion,
    STElieMode_count
};

/*
    Elie - face
 */
typedef NS_ENUM(NSInteger, STFaceState) {
    STFaceStateNotDetected,
    STFaceStateDetectedButIgnored,
    STFaceStateDetected,
    STFaceStateDetectedButOutbound,
    STFaceStateTouchBound,
    STFaceStateTouchBoundMotionIdled,
    STFaceStateInBoundMotion,
    STFaceStateInBoundMotionIdled,
    STFaceStateReady,
    STFaceStateDone,
    STFaceState_count
};

typedef NS_ENUM(NSInteger, STFaceDistance) {
    STFaceDistanceNotDetected,
    STFaceDistanceNearest,
    STFaceDistanceNear,
    STFaceDistanceOptimized,
    STFaceDistanceFarRanged,
    STFaceDistanceFar,
    STFaceDistanceFarWithDisappeared,
    STFaceDistance_count
};

/*
    Elie - motion
 */
typedef NS_ENUM(NSInteger, STMotionState) {
    STMotionStateNotDetected,
    STMotionStateDetected,
    STMotionStateReady,
    STMotionStateDone,
    STMotionState_count
};

/*
    Elie - Performance Mode
 */
typedef NS_OPTIONS(NSInteger, EliePerformanceMode) {
    EliePerformanceModeSingle,
    EliePerformanceModeQualityThanSpeed,
    EliePerformanceModeBalanced,
    EliePerformanceModeSpeedThanQuality,
    EliePerformanceModeBestSpeed,
    EliePerformanceMode_count
};

/*
    Elie Motion - Sensitive
 */
typedef NS_OPTIONS(NSInteger, ElieMotionDetectingSensitivity) {
    ElieMotionDetectingSensitivityHigh,
    ElieMotionDetectingSensitivityNormal,
    ElieMotionDetectingSensitivityUnconcerned,
    ElieMotionDetectingSensitivity_count,
};

/*
    Elie Hijab / Curtain
 */
typedef NS_OPTIONS(NSInteger, ElieCurtainType) {
    ElieCurtainTypeBubble,
    ElieCurtainTypeBlack,
    ElieCurtainTypeAuto,
    ElieCurtainType_count
};

/*
 * Elie Animatable
 */
typedef NS_ENUM(NSInteger, STAnimatableCaptureDuration) {
    STAnimatableCaptureDuration1s,
    STAnimatableCaptureDuration2s,
    STAnimatableCaptureDuration3s,
    STAnimatableCaptureDuration5s,
    STAnimatableCaptureDuration10s,
    STAnimatableCaptureDuration_count
};

/*
    Cache
 */
#define kSTTMCacheName @"camera.elie.uiview_cache_name"


/*
    ElieControl
 */

typedef NS_ENUM(NSInteger, STControlDisplayMode) {
    STControlDisplayModeHome,
    STControlDisplayModeHomeSelectable,
    STControlDisplayModeEdit,
    STControlDisplayModeEditAfterCapture,
    STControlDisplayModeReviewAfterAnimatableCapture,
    STControlDisplayModeEditTool,
    STControlDisplayModeLivePreview,
    STControlDisplayModeExport,
    STControlDisplayModeMain,
    STControlDisplayModeMain_initial
};

typedef NS_ENUM(NSInteger, STSubControlVisibleEffect) {
    STSubControlVisibleEffectNone,
    STSubControlVisibleEffectEnterCenter,
    STSubControlVisibleEffectOutside,
    STSubControlVisibleEffectScaling,
    STSubControlVisibleEffectCover
};


/*
 * Products
 */
#define STEWProduct_filter_basic  @"giff_filter_basic"
#if GIFF_W
#define STGIFFProduct_save  @"giff_save"
#endif

@interface STGIFFApp : STApp

+ (void)checkInitialAppPermissions:(void (^)(void))finished;

+ (void)registerRatingSettings;

+ (STApplicationMode)applicationMode;

+ (NSString *)paidLiveFocusAppstoreId;

+ (NSString *)elieSiteUrl;

+ (NSString *)marketingTitle;

+ (NSString *)marketingSubTitle;

+ (NSString *)privacyInfoUrl;

+ (NSString *)termsInfoUrl;

+ (NSString *)attributionInfoUrl;

+ (NSString *)releaseNoteUrl;

+ (NSString *)releaseNoteAPIUrlToCheckVersion;

+ (NSString *)urlToForwardSNSService:(NSString *)serviceName;

+ (NSString *)primaryHashtag;

+ (NSArray *)secondaryHashtags;

+ (BOOL)afterCameraInitialized:(NSString *)identifier perform:(void (^)(void))block;

+ (UIColor *)launchScreenBackgroundColor;

+ (UIImage *)livePhotosBadgeImage;

+ (NSString *)livePhotosBadgeImageName;

+ (BOOL)postFocusAvailable;

+ (BOOL)tryProductSavePostFocus:(void (^)(BOOL purchased))block interactionButton:(STStandardButton *)button;

@end
