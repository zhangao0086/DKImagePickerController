#import <AssetsLibrary/AssetsLibrary.h>
#import <GPUImage.h>
#import <ImageIO/ImageIO.h>
#import <BlocksKit/NSArray+BlocksKit.h>
#import <CoreMotion/CoreMotion.h>
#import "STGIFFRootViewController.h"
#include "MTGeometry.h"
#import "NSTimer+BlocksKit.h"
#import "STMainControl.h"
#import "NSObject+STThreadUtil.h"
#import "STElieStatusBar.h"
#import "STGIFFAppSetting.h"
#import "UIView+STUtil.h"
#import "NSObject+STUtil.h"
#import "STUserActor.h"
#import "STCaptureRequest.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "STPhotoItemSource.h"
#import "STMotionManager.h"
#import "STTimeOperator.h"
#import "STPermissionManager.h"
#import "STStandardButton.h"
#import "STAnimatableCaptureRequest.h"
#import "STCapturedImageProcessor.h"
#import "STCaptureResponse.h"
#import "STPostFocusCaptureRequest.h"
#import "STUIApplication.h"
#import "STHome.h"
#import "NSString+STUtil.h"
#import "STFilterPresenterBase.h"
#import "STFilterManager.h"
#import "STFilter.h"

@interface STGIFFRootViewController (){
    //Device Control
    BOOL _initialRequestFocusWhenFaceIn;
    BOOL _needsAlwaysRequestFocusWhenFaceIn;

    //Face detection
    NSInteger _faceState;
    NSMutableArray *_faceRects;
    NSInteger _previousDetectedFaceState;
    CGRect _focusFace;
    CGFloat _movedVariable;
    CGRect _previousDetectedFaceAsSingle;
    CGRect _previousDetectedFaceAsGroup;
    STFaceDistance _previousDetectedFaceDistance;
    CGFloat _previousDetectedFaceDistanceRatio;
    BOOL _delayedReadyToStartFaceDetection;

    //Elie Control
    BOOL _needsFaceDetectionLoop;
    BOOL _needsFaceDetectionLoopFromNotNeeded;

    //Capture
    NSDate * _dateFromFaceIn;
    BOOL _lockedCapture;
    NSTimeInterval _lockCaptureInterval;
    NSTimer * _lockCaptureTimer;

    //views
    STUIView * _mainViewWrapper;
    CGRect _cameraFrame;
//    STSettingScreenController *_controlBoardController;
//    STElieCurtain *_curtain;
    STPhotoSelector *_photoSelectionView;
}

@property(nonatomic) CGFloat faceRectMovingIdleValue;
@property (assign, nonatomic) CGAffineTransform cameraOutputToPreviewFrameTransform;
@property (assign, nonatomic) CGAffineTransform portraitRotationTransform;
@property (assign, nonatomic) CGAffineTransform texelToPixelTransform;
@end

static ALAssetsLibrary * assetLibrary;

@implementation STGIFFRootViewController

- (id)init; {
    self = [super init];
    if (self) {
        _needsFaceDetectionLoop = YES;

        if(!assetLibrary){
            assetLibrary = [ALAssetsLibrary new];
        }
    }
    return self;
}

#pragma mark delegations / override

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller; {
    return self;
}

- (void)loadView; {
    [super loadView];

    // init camera
    if([STApp isInSimulator]){
        _cameraFrame = CGRectMakeWithSize_AGK(CGSizeMake(self.view.boundsWidth, self.view.boundsWidth*[STElieCamera outputVerticalRatioDefault]));
    }else{
        _cameraFrame = [[STElieCamera sharedInstance] outputRect:self.view.st_originClearedBounds];
    }

    /*
        init geo
     */
    const CGPoint previewCenter = CGRectCenterPoint(_cameraFrame);

    // init Composition
    CGRect centerR = CGRectZero;
    centerR.size.height = centerR.size.width = _cameraFrame.size.width/7;
    centerR.origin.x = previewCenter.x- centerR.size.width/2;
    centerR.origin.y = previewCenter.y- centerR.size.height/2;

    CGRect sideR = CGRectZero;
    sideR.size.width = _cameraFrame.size.width/1.1f;
    sideR.size.height = _cameraFrame.size.height/1.1f;
    sideR.origin.x = previewCenter.x- sideR.size.width/2;
    sideR.origin.y = previewCenter.y- sideR.size.height/2;

    // init photo selection instance
    _photoSelectionView = [STPhotoSelector initSharedInstanceWithFrame:self.view.bounds];
    _photoSelectionView.collectionView.backgroundView = nil;
    _photoSelectionView.collectionView.backgroundColor = [UIColor clearColor];
    _photoSelectionView.backgroundColor = [STGIFFApp launchScreenBackgroundColor];

    // init elie control
    STUIView * optionControl = [[STUIView alloc] initWithSize:CGSizeMake(self.view.width, (self.view.height-_cameraFrame.size.height)/3)];
    optionControl.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:.2];
    optionControl.y = _cameraFrame.size.height;

    STUIView * sourceControl = [[STUIView alloc] initWithSize:CGSizeMake(self.view.width, (self.view.height-_cameraFrame.size.height)/3)];
    sourceControl.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:.2];
    sourceControl.y = _cameraFrame.size.height*2;

    STMainControl * control = [STMainControl initSharedInstanceWithFrame:CGRectMake(0, 0, self.view.width, (self.view.height-_cameraFrame.size.height)/3)];
    control.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.2];
    control.bottom = self.view.height;

    // init status bar
    [STElieStatusBar sharedInstance].y = 0;// needsCameraFrameHeight;

    /*
        init presenter hirechy
      */
    _mainViewWrapper = [[STUIView alloc] initWithFrame:self.view.bounds];
    [_mainViewWrapper addSubview:_photoSelectionView];
    [_mainViewWrapper addSubview:sourceControl];
    [_mainViewWrapper addSubview:optionControl];
    [_mainViewWrapper addSubview:control];


    [self.view addSubview:_mainViewWrapper];
//    [self.view addSubview:_curtain];

    // init face geometry
    [self calculateTransformations];
    _faceRects = [[NSMutableArray alloc] init];

    BlockOnce(^{
        [self cameraPreviewWillInitialize];
    });
    if([STApp isInSimulator]){
        control.backgroundColor = [UIColor redColor];

        [STElieStatusBar sharedInstance].backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:.4];

        UIView * dummyBackgroundView = [[UIView alloc] initWithSize:_cameraFrame.size];
        dummyBackgroundView.backgroundColor = [UIColor blueColor];
        [_photoSelectionView addSubview:dummyBackgroundView];

        [[STMainControl sharedInstance] enterLivePreview];

        [[[STMainControl sharedInstance].subControl leftButton] expand];
    }
}

- (void)cameraPreviewWillInitialize{
    /*
     * after-launch screen off.
     */
    if([STPermissionManager camera].status == STPermissionStatusAuthorized){

        Weaks
        [self setCameraMode:STCameraModeManual];

        [[STElieStatusBar sharedInstance] hideLogo];
        [[STPhotoSelector sharedInstance].previewView st_coverBlur:NO styleDark:YES completion:nil];

        [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueueOnlyOnce:self forName:STNotificationFilterPresenterItemRenderFinish usingBlock:^(NSNotification *note, id observer) {
            [self cameraPreviewDidInitialized];
        }];

    }else{
        [self setCameraMode:STCameraModeManualExitAndPause];
    };
}

- (void)cameraPreviewDidInitialized{
    [[STPhotoSelector sharedInstance].previewView st_coverRemove:YES promiseIfAnimationFinished:YES duration:.8 finished:^{
        [[STElieStatusBar sharedInstance] logo:YES];
    }];

    [UIView animateWithDuration:.6 animations:^{
        _photoSelectionView.backgroundColor = [STStandardUI backgroundColor];
    }];

    //load photos
    STGIFFAppSetting.get.photoSource = STPhotoSourceCapturedImageStorage;
    [[STPhotoSelector sharedInstance] initialLoadFromCurrentSource];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //start
    //https://fabric.io/jessi/ios/apps/com.stells.eliew/issues/56dfb8ebffcdc04250ab4c07
    BlockOnce(^{
        [self startElie];
    });

    [[STElieCamera sharedInstance] resumeCameraCapture];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[STElieCamera sharedInstance] pauseCameraCapture];
    [super viewWillDisappear:animated];
}

#pragma mark startElie
- (void)startElie{
    [STElieStatusBar sharedInstance].visible = YES;

    //set contents by update or first run
//    if([[STGIFFAppSetting get] isFirstLaunchSinceLastBuild] && [STSettingScreenControllableItem hasAddedUntouchedItems]){
//        [[STMainControl sharedInstance].subControl.leftButton setBadgeText:STStandardButtonsBadgeTextNew];
//        [[STMainControl sharedInstance].subControl setBadgeToLeft:nil mode:STControlDisplayModeMain];
//    }

    //init listeners
    [self initRootListeners];
//
    //start camera
    if(STPermissionManager.camera.isAuthorized){
        Weaks
        //start watching
        [[STCapturedImageProcessor sharedProcessor] startWatching];

        [[NSNotificationCenter defaultCenter] postNotificationName:STNotificationCameraInitialized object:nil];

        [[NSNotificationCenter defaultCenter] postNotificationName:STNotificationFaceDetectionInitialized object:nil];
    }
}

- (void)didReceiveMemoryWarning; {
    [super didReceiveMemoryWarning];

    [[STPhotoSelector sharedInstance] clearWhenMemoryWarinig];
}

- (void)initRootListeners {
    /*
     * Settings
     */
    WeakSelf weakSelf_1 = self;
    [[STGIFFAppSetting.get st_propertyNames] bk_each:^(id obj) {
        [weakSelf_1 _applySettings:obj value:[STGIFFAppSetting.get valueForKeyPath:obj] initializing:YES];
    }];

    WeakSelf weakSelf = self;
    [STGIFFAppSetting.get whenSavedToAll:[@(self.hash) stringValue] withBlock:^(NSString *key, id value) {
        [weakSelf _applySettings:key value:value];
        /*
            * update context if not private value
        */
        if(![STGIFFAppSetting isKeyPathForInternalValue:key]){
            [[STUserActor sharedInstance] updateContext];
        }
    }];

    /*
     * User Action
     */
    Weaks
    [[STUserActor sharedInstance] when:^(NSInteger action, id object) {
        if (action == STUserActionChangeCameraMode) {
            if(object){
                [Wself setCameraMode:(STCameraMode) [object integerValue]];

            }else{
                if(STElieCamera.mode == STCameraModeElie){
                    [Wself setCameraMode:STCameraModeManual];

                }else{
                    [Wself setCameraMode:STCameraModeElie];
                }
            }

        }else if (action == STUserActionManualCapture) {

            [self capture:object];

            [[NSNotificationCenter defaultCenter] st_postNotificationName:STNotificationManualCapture];
        }
        else if (action == STUserActionManualAnimatableCapture) {

            [self captureAnimatable:object];

            [[NSNotificationCenter defaultCenter] st_postNotificationName:STNotificationManualCapture];
        }
        else if (action == STUserActionManualPostFocusCapture) {

            [self capturePostFocus:object];

            [[NSNotificationCenter defaultCenter] st_postNotificationName:STNotificationManualCapture];
        }
        else if (action == STUserActionSetNeedsContext) {

            [Wself _setNeedsUpdateContext];

        }else if (action == STUserActionChangeElieMode) {

            [Wself setElieMode:STGIFFAppSetting.get.elieMode == STElieModeFace ? STElieModeMotion : STElieModeFace];
        }
    }];

    /*
     * Main Control
     */
    [[STMainControl sharedInstance] whenChangedDisplayMode:^(STControlDisplayMode mode, STControlDisplayMode previosMode) {

        [Wself _setNeedsLayoutWhenChangedMainControlDisplayMode:mode previousMode:previosMode];

        [[STUserActor sharedInstance] updateContext];
    }];

    /*
     * Motion
     */
    [[STMotionManager sharedManager] whenValueOf:@keypath([STMotionManager sharedManager].screenDirectionIsNowBackward) id:@"STMotionManager.screenDirectionIsNowBackward" changed:^(id value, id _weakSelf) {
        BOOL screenDirectionIsNowBackward = [value boolValue];
        if(screenDirectionIsNowBackward){
            //TODO: 이걸 꼭 굳이 전체 인터렉션을 막을 필욘없고 오터치가 잘 나는 부분만 해주면 된다ㅋ
            if(![[UIApplication sharedApplication] isIgnoringInteractionEvents]){
                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                oo(@"---------- start ----------------");

                [STStandardUX resetAndRevertStateAfterShortDelay:@"screenDirectionIsNowBackward.changed" block:^{
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                    oo(@"---------- end 1 ----------------");
                }];
            }
        }else{
            if([[UIApplication sharedApplication] isIgnoringInteractionEvents]){
                [STStandardUX clearDelay:@"screenDirectionIsNowBackward.changed"];

                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                oo(@"---------- end 2 ----------------");
            }
        }
    }];


}

#pragma mark Settings
- (void)_applySettings:(NSString *)propertyName value:(id)value {
    [self _applySettings:propertyName value:value initializing:NO];
}

- (void)_applySettings:(NSString *)keypath value:(id)value initializing:(BOOL)initializing {
    STGIFFAppSetting * p = STGIFFAppSetting.get;

    if([keypath isEqualToString:@keypath(p.elieMode)]){
        [self setElieMode:(STElieMode) p.elieMode];
    }
    else if([keypath isEqualToString:@keypath(p.flashLightMode)]){

        [[STElieCamera sharedInstance] setFlashMode:(AVCaptureFlashMode) p.flashLightMode];
    }
    else if([keypath isEqualToString:@keypath(p.enabledISOAutoBoost)]){

        p.enabledISOAutoBoost ? [[STElieCamera sharedInstance] activateLLBoostMode] : [[STElieCamera sharedInstance] deactivateLLBoostMode];
    }
    else if([keypath isEqualToString:@keypath(p.performanceMode)]){

        [self changePerformance:(EliePerformanceMode) p.performanceMode];

    }else if([keypath isEqualToString:@keypath(p.enabledBacklightCare)]){

        [STElieCamera sharedInstance].enabledBacklightCare = p.enabledBacklightCare;
        [[STElieCamera sharedInstance] resetFocusExposure];

    }else if(!initializing && [keypath isEqualToString:@keypath(p.geotagEnabled)]){
        if([value boolValue]){
            [p aquireGeotagDataIfAllowed];
        }else{
            [p clearGeotagDataIfAllowed];
        }
    }
}

#pragma mark Context
- (void)_setNeedsUpdateContext {
    /*
     * [WARNING] DO NOT USE private key of AppSetting.
     */

    /*
     * Not execute if camera mode is STCameraModeNotInitialized
     */
    if(STElieCamera.mode == STCameraModeNotInitialized){
        return;
    }

    /*
     * face detection
     */
    BOOL needsFaceDetectionLoop = [self context_needsFaceDetection];
    _needsFaceDetectionLoopFromNotNeeded = needsFaceDetectionLoop && !_needsFaceDetectionLoop;
    _needsFaceDetectionLoop = needsFaceDetectionLoop;

    /*
     * detection screen backward.
     */
    [[STMotionManager sharedManager] updateInitialScreenDirectionToCurrent];
    _needsFaceDetectionLoop ? [[STMotionManager sharedManager] startScreenDirectionUpdates] : [[STMotionManager sharedManager] stopScreenDirectionUpdates];

    /*
     * orientation
     */
    [UIView setGlobalAutoOrientationEnabled:NO];

    /*
     * home preview
     */
    [[STMainControl sharedInstance] setPreviewVisibility:_needsFaceDetectionLoop?1:0];

    /*
     * status bar
     */
    [self setNeedsStatusBar];
}

- (BOOL)context_needsFaceDetection {
    //Env
    switch(STElieCamera.mode){
        case STCameraModeNotInitialized:
        case STCameraModeEliePause:
        case STCameraModeManualExitAndPause:
        case STCameraModeManual:
        case STCameraModeManualQuick:
            return NO;
        default: break;
    }

    if(STGIFFAppSetting.get.elieMode != STElieModeFace){
        return NO;
    }
    if([[STElieCamera sharedInstance] isPositionFront] && STElieCamera.mode != STCameraModeManualWithElie){
        return NO;
    }
    if([STElieCamera sharedInstance].changingFacingCamera){
        return  NO;
    }

    //View
//    if(self.presentedViewController){
//        return NO;
//    }

    switch([STMainControl sharedInstance].mode){
        case STControlDisplayModeExport :
        case STControlDisplayModeEdit :
        case STControlDisplayModeMain :
        case STControlDisplayModeEditAfterCapture:
        case STControlDisplayModeReviewAfterAnimatableCapture:
        case STControlDisplayModeEditTool:
        case STControlDisplayModeHomeFilterSelectable:
            return NO;

        default: break;
    }

    return YES;
}


- (BOOL)context_needsUpdateViewsOrientation {
    BOOL needs = YES;
    switch ([STMainControl sharedInstance].mode){
        case STControlDisplayModeMain:
        case STControlDisplayModeEditAfterCapture:
        case STControlDisplayModeReviewAfterAnimatableCapture:
        case STControlDisplayModeEdit:
        case STControlDisplayModeEditTool:
        case STControlDisplayModeExport:
            needs = NO;
            break;
        default:
            break;
    }
    return needs;
}

//pragma mark MainLayout
//FIXME: main control 변화 흐름은 한곳에서 관리
- (void)_setNeedsLayoutWhenChangedMainControlDisplayMode:(STControlDisplayMode)mode previousMode:(STControlDisplayMode)previosMode{
    //main
//    if (previosMode == STControlDisplayModeHome && mode == STControlDisplayModeMain) {
//        [_controlBoardController willEnter];
//        [[STMainControl sharedInstance] showCoverWith:_controlBoardController.view completion:^{
//            [STStandardUX startParallaxToViews:@[@[_controlBoardController.gridViewInCurrentPage]]];
//            [_controlBoardController didEntered];
//        }];
//
//    } else if (previosMode == STControlDisplayModeMain && mode == STControlDisplayModeHome) {
//        [_controlBoardController willExit];
//        [[STMainControl sharedInstance] hideCoverWith:_controlBoardController.view completion:^{
//            [_controlBoardController didExited];
//            [self applySettingsAfterControlExitIfNeeded];
//        }];
//        [STStandardUX stopParallaxToViews:@[_controlBoardController.gridViewInCurrentPage]];
//    }

    //slide up
    if(mode==STControlDisplayModeHomeFilterSelectable){
        [[STPhotoSelector sharedInstance] doSlideUp:YES];

    }else if (previosMode == STControlDisplayModeHomeFilterSelectable) {
        [[STPhotoSelector sharedInstance] doSlideUp:NO];
    }

    //shadow
    if(mode == STControlDisplayModeHome
            || (mode == STControlDisplayModeExport && previosMode == STControlDisplayModeHome)
            || (mode == STControlDisplayModeExport && previosMode == STControlDisplayModeExport)
            ){

        [[STMainControl sharedInstance] st_shadow].animatableVisible = YES;
        [[STElieStatusBar sharedInstance] st_shadow].animatableVisible = YES;
    }else{
        [[STMainControl sharedInstance] st_shadow].animatableVisible = NO;
        [[STElieStatusBar sharedInstance] st_shadow].animatableVisible = NO;
    }

    //torchlight
    if(mode!=STControlDisplayModeLivePreview){
        [STElieCamera sharedInstance].torchLight = 0;
    }

    //facingcamera
    if(mode!=STControlDisplayModeLivePreview){
        [[STElieCamera sharedInstance] changeFacingCamera:NO completion:nil];
    }
}

#pragma mark STCameraMode view handling
- (void)setCameraMode:(STCameraMode)mode{
    NSAssert(STCameraModeNotInitialized < mode, @"wrong STCameraMode");
    if(STElieCamera.mode == mode){
        return;
    }

#pragma mark Product - Save
    if(STCameraModeManualExitAndPause==mode){
        if(![STGIFFApp tryProductSavePostFocus:^(BOOL purchased) {
            if(purchased){
                [self setCameraMode:STCameraModeManualExitAndPause];
            }

        } interactionButton:nil]){
            return;
        }
    }

    [[STElieCamera sharedInstance] resetFocusExposure];

    STGIFFAppSetting.get.mode = mode;

    switch (mode){
        case STCameraModeManual:{
            [[STPhotoSelector sharedInstance] doEnterLivePreview];

        }
            break;

        case STCameraModeManualExitAndPause:
        case STCameraModeElie:{
            [[STPhotoSelector sharedInstance] doExitLivePreview];

            [[STElieCamera sharedInstance] changeFacingCamera:NO completion:^(BOOL changed){
                [[STUserActor sharedInstance] updateContext];
                [[STElieCamera sharedInstance] resetFocusExposure];
            }];
        }
            break;

        default: break;
    }

    STElieCamera.mode = mode;

    [[STUserActor sharedInstance] updateContext];
}

- (void)setElieMode:(STElieMode)mode{
    if(mode == STElieModeMotion){
        Weaks
        [[STElieCamera sharedInstance] startMotionDetection:.8 withGyro:YES detectionBlock:^(CGPoint motionCentroid, CGFloat motionIntensity, CMTime frameTime, CMGyroData * gyroData) {
            if(motionIntensity==0.0){
                return;
            }

            CMRotationRate r = gyroData.rotationRate;
            double deviceMoving = fabs(r.x)+fabs(r.y)+fabs(r.z);

            if(deviceMoving==0 || deviceMoving > .3){
                return;
            }

            if(motionIntensity < 0.1){
                return;
            }

            [Wself st_runAsMainQueueAsyncWithSelf:^(id selfObject) {
                NSLog(@"MOTION ! -- %f %f",motionIntensity, deviceMoving);
//                [selfObject captureAsElie];
            }];
        }];

    }else{

        [[STElieCamera sharedInstance] stopMotionDetection];
    }

    STGIFFAppSetting.get.elieMode = mode;

    [[STUserActor sharedInstance] updateContext];
}

#pragma mark status bar control
- (void)setNeedsStatusBar{
    STControlDisplayMode mode = [STMainControl sharedInstance].mode;
    BOOL show = NO;
//    show |= _needsFaceDetectionLoop;

    show |= mode==STControlDisplayModeLivePreview;
    show |= mode==STControlDisplayModeEditAfterCapture;
    show |= mode==STControlDisplayModeExport;

//    show &= [STElieCamera mode] != STCameraModeManualQuick;

    if(show){
        [[STElieStatusBar sharedInstance] show];

        BOOL inVisibleBackground = NO;
        inVisibleBackground |= STControlDisplayModeLivePreview == mode;
        inVisibleBackground |= STControlDisplayModeMain == mode;

        [STElieStatusBar sharedInstance].visibleBackground = !inVisibleBackground;

    }else{
        [[STElieStatusBar sharedInstance] hide];
    }
}

#pragma mark Performance + Preset
- (void)changePerformance:(EliePerformanceMode)mode{
//    BOOL duplicatedChange = [STElieCamera mode] != STCameraModeNotInitialized && mode == [[STSetting.get read:@keypath([STSetting get].performanceMode)] integerValue];
    NSString * preset = AVCaptureSessionPresetPhoto;

    switch (mode){
        case EliePerformanceModeSingle:
            _needsAlwaysRequestFocusWhenFaceIn = YES;
            _lockCaptureInterval = NSTimeIntervalSince1970;
            _faceRectMovingIdleValue = 5;
            preset = AVCaptureSessionPresetPhoto;
            break;

        case EliePerformanceModeQualityThanSpeed:
            _needsAlwaysRequestFocusWhenFaceIn = YES;
            _lockCaptureInterval = 2.5;
            _faceRectMovingIdleValue = 3;
            preset = AVCaptureSessionPresetPhoto;
            break;

        case EliePerformanceModeBalanced :
            _needsAlwaysRequestFocusWhenFaceIn = YES;
            _lockCaptureInterval = 1.4;
            _faceRectMovingIdleValue = 5;
            preset = AVCaptureSessionPresetPhoto;
            break;

        case EliePerformanceModeSpeedThanQuality:
            _needsAlwaysRequestFocusWhenFaceIn = NO;
            _lockCaptureInterval = 1;
            _faceRectMovingIdleValue = 3;
            preset = AVCaptureSessionPreset640x480;
            break;

        case EliePerformanceModeBestSpeed:
            _needsAlwaysRequestFocusWhenFaceIn = NO;
            //_lockCaptureInterval = .001; 까지 테스트됨
            _lockCaptureInterval = .5;
            _faceRectMovingIdleValue = 1;
            preset = AVCaptureSessionPreset640x480;
            break;
        default:
            break;
    }

    STGIFFAppSetting.get.captureSessionPreset = preset;
}

- (void)applyCaptureSessionPresetFromSetting {
    NSString * preset = [STGIFFAppSetting.get.captureSessionPreset copy];
    if([[STElieCamera sharedInstance].captureSessionPreset isEqualToString:preset]){
        return;
    }
    runAsynchronouslyOnVideoProcessingQueue(^{
        [STElieCamera sharedInstance].captureSessionPreset = preset;
    });
}

#pragma mark Capture
- (void)captureAsElie
{
    if(_lockedCapture){
        return;
    }
    _lockedCapture = YES;

    //haptic
//    [_haptic stopAction];
//    [_haptic lockActionAndUnlockAfterTime:kSTHapticRestartInterval];

    //capture interval
    if(_lockCaptureInterval != NSTimeIntervalSince1970){
        Weaks
        [_lockCaptureTimer invalidate];
        _lockCaptureTimer = [NSTimer bk_scheduledTimerWithTimeInterval:_lockCaptureInterval block:^(NSTimer *timer) {
            Strongs
            Sself->_lockedCapture = NO;
            NSLog(@"[ Capture Unlocked ] %.20f", _lockCaptureInterval);
        } repeats:NO];
    }

    /*
     * request capture
     */
    STCaptureRequest *request = [STCaptureRequest request];
    if(_faceRects.count){
        request.faceRect = [[_faceRects last] CGRectValue];
        request.faceRectBounds = _cameraFrame;
    }
    request.needsFilter = [[STFilterManager sharedManager] acquire:[[STMainControl sharedInstance] homeSelectedFilterItem]];
    request.origin = STPhotoItemOriginElie;

    //now
    NSLog(@"! ! ! SHOT ! ! ! %f", [[NSDate date] timeIntervalSinceDate:_dateFromFaceIn]);
    _dateFromFaceIn = [NSDate date];

    [self capture:request];
}

#pragma mark Capture
- (void)captureByNeededRequest:(STCaptureRequest *)request {
    if([request isKindOfClass:STPostFocusCaptureRequest.class]){
        [self capturePostFocus:(STPostFocusCaptureRequest *) request];

    }else if([request isKindOfClass:STAnimatableCaptureRequest.class]){
        [self captureAnimatable:(STAnimatableCaptureRequest *) request];

    }else {
        [self capture:request];
    }
}

- (void)capture:(STCaptureRequest *)request {
    if([STGIFFApp isInSimulator]){
        NSMutableDictionary * metadata = [NSMutableDictionary dictionaryWithDictionary:[STElieCamera sharedInstance].currentCaptureMetadata];
        metadata[(NSString *)kCGImagePropertyOrientation] = @(0);

//        [[STPhotoSelector sharedInstance] doAfterCaptured:[STPhotoItemSource sourceWithImage:[UIImage imageNamed:@"LaunchScreenIcon"]]];

        if([request responseHandler]){
            [request responseHandler](nil);
            request.responseHandler = nil;
        }
        return;
    }

    /*
     * make capture
     */
    if(!request){
        request = [STCaptureRequest requestWithNeedsFilter:
                [[STFilterManager sharedManager] acquire:[STPhotoSelector sharedInstance].previewState.currentFocusedFilterItem]
        ];
    }

    //setup priority
    switch (STElieCamera.mode){
        case STCameraModeElie:{
            switch ((EliePerformanceMode) [[STGIFFAppSetting.get read:@keypath([STGIFFAppSetting get].performanceMode)] integerValue]){
                case EliePerformanceModeSingle:
                    request.afterCaptureProcessingPriority = AfterCaptureProcessingPriorityFirst;
                    break;
                case EliePerformanceModeQualityThanSpeed:
                case EliePerformanceModeBalanced:
                case EliePerformanceModeSpeedThanQuality:
                case EliePerformanceModeBestSpeed:
                    request.afterCaptureProcessingPriority = AfterCaptureProcessingPriorityDefault;
                    break;
                default:
                    break;
            }
        }
            break;
        case STCameraModeManualWithElie:
        case STCameraModeManual:{
            switch ((STAfterManualCaptureAction) [[STGIFFAppSetting.get read:@keypath([STGIFFAppSetting get].afterManualCaptureAction)] integerValue]){
                case STAfterManualCaptureActionEnterEdit:
                    request.afterCaptureProcessingPriority = AfterCaptureProcessingPriorityFirst;
                    break;
                case STAfterManualCaptureActionSaveToLocalAndContinue:
                case STAfterManualCaptureActionSaveToRemoveDirectlyAndContinue:
                    request.afterCaptureProcessingPriority = AfterCaptureProcessingPriorityDefault;
                    break;
                default:
                    break;
            }
        }
            break;
        case STCameraModeManualQuick:
            request.afterCaptureProcessingPriority = AfterCaptureProcessingPriorityFirst;
            break;
        case STCameraModeEliePause:
        case STCameraModeNotInitialized:
            break;

    }

    //result block
    [[STUIApplication sharedApplication] beginIgnoringInteractionEvents];

    __block STCaptureResponseHandler childBlock = [request.responseHandler copy];
    request.responseHandler = ^(STCaptureResponse *response) {
        [[NSNotificationCenter defaultCenter] st_postNotificationName:STNotificationManualCaptureFinished];

        [[STUIApplication sharedApplication] endIgnoringInteractionEvents];

        if (response) {
            [[STPhotoSelector sharedInstance] doAfterCaptured:[STPhotoItemSource sourceWithResponse:response]];
        }

        if(childBlock){
            childBlock(response);
            childBlock = nil;
        }

        [[STElieStatusBar sharedInstance] stopProgress];
    };

    //assign current origin if needed
    if(request.origin == STPhotoItemOriginUndefined){
        request.origin = [STPhotoItem originFromCameraMode:STElieCamera.mode];
    }

    //assign settings
    if(STAppSetting.get.geotagEnabled && STAppSetting.get.geotagData){
        request.geoTagMedataData = STAppSetting.get.geotagData;
    }
    request.privacyRestriction = STGIFFAppSetting.get.securityModeEnabled;
    request.tiltShiftEnabled = STGIFFAppSetting.get.tiltShiftEnabled;
    request.autoEnhanceEnabled = STGIFFAppSetting.get.autoEnhanceEnabled;

    //capture
    [[STElieStatusBar sharedInstance] startProgress:nil];
    [[STElieCamera sharedInstance] capture:request];
}

- (void)captureAnimatable:(STAnimatableCaptureRequest *)request {
    if(!request){
        request = [STAnimatableCaptureRequest requestWithNeedsFilter:[[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.f, 0.125f, 1.f, .75f)]];
    }

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

#if DEBUG
    NSDate * startDate = [NSDate date];
#endif
//    STUserActionManualAnimatableCapture
    request.origin = STPhotoItemOriginAnimatable;
    request.captureOutputSizePreset = CaptureOutputSizePresetSmall;
    request.autoReverseFrames = YES;
//    request.needsLoadAnimatableImagesToMemory = YES;
    request.responseHandler = ^(STCaptureResponse *result) {
        [[NSNotificationCenter defaultCenter] st_postNotificationName:STNotificationManualCaptureFinished];
#if DEBUG
        NSLog(@"TIME : %.20fs", [[NSDate date] timeIntervalSinceDate:startDate]);
#endif
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

        if(result){
            [[STPhotoSelector sharedInstance] doAfterCaptured:[STPhotoItemSource sourceWithResponse:result]];

//            UIImage * animatedImage = result.image;
//            UIImageView * view = [[UIImageView alloc] initWithSize:CGSizeByScale(animatedImage.size, .5)];
//            view.image = animatedImage;
//            view.tagName = @"imageview";
//            [[self.view viewWithTagName:view.tagName] clearAllOwnedImagesIfNeededAndRemoveFromSuperview:NO];
//            [self.view addSubview:view];
//            [view centerToParent];

//            NSURL * fileurl = [@"tempgif.gif" URLForTemp];
//
//            [UIImageAnimatedGIFRepresentation(animatedImage) writeToURL:fileurl atomically:YES];

//            avController = [[UIActivityViewController alloc] initWithActivityItems:@[fileurl] applicationActivities:nil];
//            avController.excludedActivityTypes = @[
////                UIActivityTypeSaveToCameraRoll,
//                    UIActivityTypePostToTwitter,
//                    UIActivityTypeAddToReadingList
//            ];
//            avController.completionWithItemsHandler = (UIActivityViewControllerCompletionWithItemsHandler) ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
//
//            };
//            [self presentViewController:avController animated:YES completion:nil];

        }

    };
    [[STElieCamera sharedInstance] captureAnimatable:request];
}

- (void)capturePostFocus:(STPostFocusCaptureRequest *)request {
    if(!request){
        request = [STPostFocusCaptureRequest requestWithNeedsFilter:
                [[STFilterManager sharedManager] acquire:[STPhotoSelector sharedInstance].previewState.currentFocusedFilterItem]
        ];

    }

#pragma mark Product
#if STGIFFProduct_save
    [STCapturedImage registerProcessingBlockBeforeSave: [STGIFFApp isPurchasedProduct:STGIFFProduct_save] ? nil : ^UIImage *(UIImage *sourceImage) {
        if(![STGIFFApp isPurchasedProduct:STGIFFProduct_save]) {
            @autoreleasepool {
                NSString * cacheKey = @"STGIFFProduct_save_waterMarkImage";

                if([STApp isDebugMode] || [STGIFFAppSetting.get isFirstLaunchSinceLastBuild]){
                    [self st_uncacheImage:cacheKey];
                }

                UIImage * waterMarkImage = [self st_cachedImage:cacheKey useDisk:YES init:^UIImage * {
                    return [SVGKImage imageNamedNoCache:[R icon_fit] widthSizeWidth:[STStandardLayout widthMainMid]].UIImage;
                }];
                NSParameterAssert(waterMarkImage);

                CGPoint point = CGPointMake(
                        sourceImage.size.width-waterMarkImage.size.width-waterMarkImage.size.width/1.5f,
                        sourceImage.size.height-waterMarkImage.size.height-waterMarkImage.size.height/1.5f
                );
//                    (null) > performed : 0.024048s at ckTime: NSObject+BNRTimeBlock.m:29 1
//                    (null) > performed : 0.005825s at ckTime: NSObject+BNRTimeBlock.m:29 1
//                    (null) > performed : 0.006760s at ckTime: NSObject+BNRTimeBlock.m:29 1
//                    (null) > performed : 0.004857s at ckTime: NSObject+BNRTimeBlock.m:29 1
//                    (null) > performed : 0.005055s at ckTime: NSObject+BNRTimeBlock.m:29 1
//                    (null) > performed : 0.007983s at ckTime: NSObject+BNRTimeBlock.m:29 1
//                    (null) > performed : 0.006910s at ckTime: NSObject+BNRTimeBlock.m:29 1
//                    (null) > performed : 0.007474s at ckTime: NSObject+BNRTimeBlock.m:29 1
//                    (null) > performed : 0.006892s at ckTime: NSObject+BNRTimeBlock.m:29 1
//                    (null) > performed : 0.008940s at ckTime: NSObject+BNRTimeBlock.m:29 1
//                    (null) > performed : 0.005748s at ckTime: NSObject+BNRTimeBlock.m:29 1
//                    (null) > performed : 0.006757s at ckTime: NSObject+BNRTimeBlock.m:29 1
//                    (null) > performed : 0.008821s at ckTime: NSObject+BNRTimeBlock.m:29 1
//                    (null) > performed : 0.006749s at ckTime: NSObject+BNRTimeBlock.m:29 1
//                    (null) > performed : 0.007762s at ckTime:

                return [sourceImage drawOver:waterMarkImage atPosition:point alpha:[STStandardUI alphaForDimmingWeak]];
            }
        }
        return sourceImage;
    }];
#endif

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [[STElieStatusBar sharedInstance] message:NSLocalizedString(@"Please maintain the position",nil) showLogoAfterDelay:NO];

    request.origin = STPhotoItemOriginPostFocus;
    request.progressHandler = ^(double progress, NSUInteger offset, NSUInteger length, BOOL *stop) {
        [[[STMainControl sharedInstance] homeView] setLogoProgress:(CGFloat) progress];
        [[STMainControl sharedInstance] homeView].containerButton.visible = NO;
    };

    //image size
    request.captureOutputSizePreset = (CaptureOutputSizePreset) STGIFFAppSetting.get.captureOutputSizePreset;

#if DEBUG
    NSDate * startDate = [NSDate date];
#endif
    request.responseHandler = ^(STCaptureResponse *result) {
#if DEBUG
        NSLog(@"TIME : %.20fs", [[NSDate date] timeIntervalSinceDate:startDate]);
#endif
        [[NSNotificationCenter defaultCenter] st_postNotificationName:STNotificationManualCaptureFinished];

        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

        [[[STMainControl sharedInstance] homeView] setLogoProgress:0];
        [[STMainControl sharedInstance] homeView].containerButton.visible = YES;

        if(result){
//            STGIFFAppSetting.get.afterManualCaptureAction = STAfterManualCaptureActionEnterEdit;

            [[STPhotoSelector sharedInstance] doAfterCaptured:[STPhotoItemSource sourceWithResponse:result]];
        }
    };

    //focal point
    switch((STPostFocusMode)[STGIFFAppSetting get].postFocusMode){
        case STPostFocusModeVertical3Points:{
            request.outputSizeForFocusPoints = [[STElieCamera sharedInstance] outputScreenSize];
            request.focusPointsOfInterestSet = @[
                    [NSValue valueWithCGPoint:CGPointMake(.5f,.5f)]
                    //top - bottom
                    , [NSValue valueWithCGPoint:CGPointMake(.5f,0.18125f)]
                    , [NSValue valueWithCGPoint:CGPointMake(.5f,0.81875f)]
            ];
        }
            break;
        case STPostFocusMode5Points:{
            request.outputSizeForFocusPoints = [[STElieCamera sharedInstance] outputScreenSize];
            request.focusPointsOfInterestSet = @[
                    [NSValue valueWithCGPoint:CGPointMake(.5f,.5f)]
                    //left - right
                    , [NSValue valueWithCGPoint:CGPointMake(.12,.5f)]
                    , [NSValue valueWithCGPoint:CGPointMake(.88f,.5f)]
                    //top - bottom
                    , [NSValue valueWithCGPoint:CGPointMake(.5f,.15f)]
                    , [NSValue valueWithCGPoint:CGPointMake(.5f,.85f)]
            ];
        }
            break;
        case STPostFocusModeFullRange:{
            request.frameCount = 10;
        }
            break;
        default:
            NSAssert(NO, @"Not supported post focus mode.");
            break;
    }

#if DEBUG
    if(request.focusPointsOfInterestSet.count){
        NSString * bulletViewTagNameToTest = @"bulletViewTagNameToTest";
        [request.focusPointsOfInterestSet each:^(id object) {
            NSString * tagName = [bulletViewTagNameToTest st_add:NSStringFromCGPoint([object CGPointValue])];
            UIView * uiView;
            if(!(uiView = [[STPhotoSelector sharedInstance].previewView viewWithTagName:tagName])){
                uiView = [[UIView alloc] initWithSizeWidth:5];
                uiView.userInteractionEnabled = NO;
                uiView.backgroundColor = [UIColor redColor];
                uiView.tagName = tagName;
                [[STPhotoSelector sharedInstance].previewView addSubview:uiView];
            }
            [[STPhotoSelector sharedInstance].previewView bringSubviewToFront:uiView];
            uiView.center = CGPointMake([STPhotoSelector sharedInstance].previewView.width*[object CGPointValue].x,
                    [STPhotoSelector sharedInstance].previewView.height*[object CGPointValue].y
            );
        }];
    }
#endif

    [[STElieCamera sharedInstance] capturePostFocusing:request];
}

#pragma mark Elie-Face
- (void)setFaceDetection:(BOOL)running{
    if(running){
        [[STElieCamera sharedInstance] startFaceDetection:self];
    }else{
        [[STElieCamera sharedInstance] stopFaceDetection];
    }
}

- (void)detectorWillOuputFaceMetadata:(NSArray *)faceMetadataObjects; {

    if(_needsFaceDetectionLoop){
        [self updateFaceMetadataTrackingViewWithObjects:faceMetadataObjects];
    }else{
        [[NSRunLoop currentRunLoop] cancelPerformSelector:@selector(updateFaceMetadataTrackingViewWithObjects:) target:self argument:faceMetadataObjects];
        [self updateFaceMetadataTrackingViewWithObjects:nil];
    }
}

#pragma mark FaceDetection
#define FACEDETECTION_RESTART_ID @"face_detection_restart"
#define FACEDETECTION_RESTART_DELAY 1.4

- (void)updateFaceMetadataTrackingViewWithObjects:(NSArray *)objects
{
    if (!objects || !objects.count) {

        if(_faceState != STFaceStateNotDetected){
            NSLog(@"NO face.");

            [STTimeOperator st_clearPerformOnceAfterDelay:FACEDETECTION_RESTART_ID];
            _delayedReadyToStartFaceDetection = NO;

            _needsFaceDetectionLoopFromNotNeeded = NO;

            if(_previousDetectedFaceDistance==STFaceDistanceFar){
                [STElieStatusBar sharedInstance].faceDistance = _previousDetectedFaceDistance = STFaceDistanceFarWithDisappeared;
            }else{
                [STElieStatusBar sharedInstance].faceDistance = STFaceDistanceNotDetected;
            }
            _previousDetectedFaceDistanceRatio = 0;

            _focusFace = CGRectNull;

            [_faceRects removeAllObjects];

            _dateFromFaceIn = nil;

            _initialRequestFocusWhenFaceIn = NO;

            [_lockCaptureTimer invalidate];
            _lockCaptureTimer = nil;

            _lockedCapture = NO;

//            [_haptic finishAction];

            [[STElieCamera sharedInstance] resetFocusExposure];

            _previousDetectedFaceState = _faceState;
        }

        _faceState = STFaceStateNotDetected;
        return;
    }

    /*
     * delayed call from after non-detection loop that was paused.
     */
    if(_needsFaceDetectionLoopFromNotNeeded && _faceState == STFaceStateNotDetected && !_delayedReadyToStartFaceDetection){
        if(![STTimeOperator st_isPerforming:FACEDETECTION_RESTART_ID]){
            [STTimeOperator st_performOnceAfterDelay:FACEDETECTION_RESTART_ID interval:FACEDETECTION_RESTART_DELAY block:^{
                _delayedReadyToStartFaceDetection = YES;
            }];
        }
        return;
    }

    /*
     * instantly pausing if now Ready to done.
     */
    if(_faceState==STFaceStateReady){
        return;
    }

    /*
        set faces
     */
    if(_faceRects.count){
        [_faceRects removeAllObjects];
    }

    WeakSelf weakSelf = self;
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        AVMetadataFaceObject * metadataObject = obj;

        //TODO: 카메라를 돌렸을때 셀프캠모드에서 roll이 잘못들어옴.
        // roll : back카메라일경우 0.0,  font는 180.0 / 90도 단위로만 들어옴

        CGRect face = metadataObject.bounds;

        // Flip the Y coordinate to compensate for coordinate difference
        face.origin.y = (CGFloat) (1.0 - face.origin.y - face.size.height);

        // Transform to go from texels, which are relative to the image size to pixel values
        face = CGRectApplyAffineTransform(face, weakSelf.portraitRotationTransform);
        face = CGRectApplyAffineTransform(face, weakSelf.texelToPixelTransform);
        face = CGRectApplyAffineTransform(face, weakSelf.cameraOutputToPreviewFrameTransform);

        [_faceRects addObject:[NSValue valueWithCGRect:face]];
    }];


    /*
        focusing & capture.
     */
    CGPoint focusPoint;
    CGFloat faceDistanceRatio = 0;
    CGRect visualRect = CGRectNull;
    BOOL motionIsIdled;

    if(_faceRects.count>0){

        if(_faceState == STFaceStateNotDetected){
            _dateFromFaceIn = [NSDate date];
            _initialRequestFocusWhenFaceIn = YES;
            _faceState = STFaceStateDetected;
        }

        //
        // Single Face
        //
        if(_faceRects.count == 1){

            CGRect face =  [[_faceRects firstObject] CGRectValue];
            _focusFace = face;
            focusPoint = CGRectCenterPoint(_focusFace);
            visualRect = face;
            faceDistanceRatio = _focusFace.size.width/_cameraFrame.size.width;

            // motion
            _movedVariable = CGPointDistance(face.origin, _previousDetectedFaceAsSingle.origin)*(face.size.width/_photoSelectionView.width);
            _previousDetectedFaceAsSingle = face;

            motionIsIdled = _movedVariable < _faceRectMovingIdleValue;//&& [[STElieCamera sharedInstance] isMotionIdled];
        }
        //
        // Group Faces
        //
        else{
            /*
                add Union rect If multiple
             */
            CGRect unionFace = CGRectNull;
            CGRect biggestFace = CGRectNull;
            for(NSValue * rr in _faceRects){
                CGRect r = [rr CGRectValue];

                //union
                if(!CGRectIsNull(unionFace)){
                    unionFace = CGRectUnion(unionFace, r);
                }else{
                    unionFace = r;
                }

                //size
                if(CGRectIsNull(biggestFace)){
                    biggestFace = r;
                }else{
                    biggestFace = ST_DIF_RSIZE(biggestFace, r) ? biggestFace : r;
                }
            }
            [_faceRects addObject:[NSValue valueWithCGRect:unionFace]];

            visualRect = unionFace;
            _focusFace = biggestFace;
            focusPoint = CGRectCenterPoint(_focusFace);
            faceDistanceRatio = _focusFace.size.width/_cameraFrame.size.width;

            // motion
            _movedVariable = CGPointDistance(unionFace.origin, _previousDetectedFaceAsGroup.origin)*(unionFace.size.width/_photoSelectionView.width);
            _previousDetectedFaceAsGroup = unionFace;

            // rect
            motionIsIdled = _movedVariable < _faceRectMovingIdleValue;// && [camera isMotionIdled];
        }

        /*
            Change Face State , Capture
         */
        if(_lockCaptureInterval==NSTimeIntervalSince1970 && _lockedCapture){
            _faceState = STFaceStateDetectedButIgnored;

        }
        else if(!motionIsIdled){
            _faceState = STFaceStateInBoundMotion;

        }
        else if(_lockedCapture){
            _faceState = STFaceStateInBoundMotionIdled;

        }
        else if(!_lockedCapture){

            if([STElieCamera sharedInstance].isPositionBack){
                if(_needsAlwaysRequestFocusWhenFaceIn || _initialRequestFocusWhenFaceIn){

                    _faceState = STFaceStateReady;

                    Weaks
                    void(^requestFocus)(void) = ^{
                        Strongs
                        BOOL succeedFocus = [[STElieCamera sharedInstance] requestSingleFocus:Sself->_cameraFrame pointInRect:focusPoint syncWithExposure:NO completion:^{
                            if (Sself->_faceState == STFaceStateReady) {
                                Sself->_faceState = STFaceStateDone;

                                Sself->_initialRequestFocusWhenFaceIn = NO;

                                NSLog(@"SHOT --1 ");
                                [Sself captureAsElie];

                                [[STElieCamera sharedInstance] unlockRequestFocus];
                                [[STElieCamera sharedInstance] unlockRequestExposure];
                            }
                        }];
                        if (succeedFocus) {
                            [[STElieCamera sharedInstance] lockRequestFocus];
                        }
                    };

                    //backlight care - on : exposure.continuous NO -> focus.continuous NO / syncWithExposure NO
                    //backlight care - off : exposure.continuous YES -> focus.continuous NO / syncWithExposure NO
                    if([[[STGIFFAppSetting get] read:@keypath([STGIFFAppSetting get].enabledBacklightCare)] boolValue]){
                        if([[STElieCamera sharedInstance] requestExposureToFace:_cameraFrame faceFrame:_focusFace facePoint:focusPoint continuous:NO completion:requestFocus]){
                            [[STElieCamera sharedInstance] lockRequestExposure];
                        };

                    }else{
                        requestFocus();
                    }

                }else{

                    if([STElieCamera sharedInstance].focusAdjusted){
                        _faceState = STFaceStateReady;

                        [[STElieCamera sharedInstance] lockRequestFocus];
                        [self captureAsElie];
                        NSLog(@"SHOT --2 ");
                        [[STElieCamera sharedInstance] unlockRequestFocus];

                        Weaks
                        [self st_runAsTimerQueue:^{
                            Strongs
                            Sself->_faceState = STFaceStateDone;
                        }];
                    }
                }

            }else{
                //front camera
                _faceState = STFaceStateReady;

                [[STElieCamera sharedInstance] lockRequestFocus];
                NSLog(@"SHOT --3 ");
                [self captureAsElie];
                [[STElieCamera sharedInstance] unlockRequestFocus];

                Weaks
                [self st_runAsTimerQueue:^{
                    Strongs
                    Sself->_faceState = STFaceStateDone;
                }];
            }
        }
    }

    /*
      set Elie View Center
    */
//    CGPoint visualRectCenter = CGRectCenterPoint(visualRect);
//    [_curtain setFaceCenter:CGPointMake(visualRectCenter.x / _cameraFrame.size.width, visualRectCenter.y / _cameraFrame.size.height)];
//    if(_previousDetectedFaceState != _faceState){
//        [_curtain displayByFaceState:(STFaceState) _faceState];
//    }

    /*
        FaceDistance
     */
    STFaceDistance faceDistance;
    if(faceDistanceRatio < .15){
        faceDistance = STFaceDistanceFar;

    }else if(faceDistanceRatio < .3){
        faceDistance = STFaceDistanceFarRanged;

    }else if(faceDistanceRatio < .5){
        faceDistance = STFaceDistanceOptimized;

    }else if(faceDistanceRatio < .7){
        faceDistance = STFaceDistanceNear;

    }else {
        faceDistance = STFaceDistanceNearest;
    }

    if(_previousDetectedFaceDistance != [STElieStatusBar sharedInstance].faceDistance){
        [STElieStatusBar sharedInstance].faceDistance = faceDistance;
    }

    /*
        Haptic
    */

//    _haptic.actionFlag = (STHapticAction)[[STGIFFAppSetting.get read:@keypath([STGIFFAppSetting get].hapticAction)] integerValue];
//
//    if(_haptic.actionFlag==STHapticActionNone){
//
//    }else{
//        if(_previousDetectedFaceState != _faceState /*|| _previousDetectedFaceDistance != faceDistance*/){
//
//            switch(_faceState){
//                case STFaceStateDetectedButIgnored:
//                    [_haptic stopAction];
//                    break;
//                case STFaceStateDone:
//                case STFaceStateDetectedButOutbound:
//                    [_haptic startAction:_haptic.minIntensityLevel];
//                    break;
//                case STFaceStateDetected:
//                    [_haptic startAction:1];
//                    break;
//                case STFaceStateTouchBound:
//                    [_haptic startAction:2];
//                    break;
//                case STFaceStateTouchBoundMotionIdled:
//                    [_haptic startAction:3];
//                    break;
//                case STFaceStateInBoundMotion:
//                    [_haptic startAction:4];
//                    break;
//                case STFaceStateInBoundMotionIdled:
//                    [_haptic startAction:5];
//                    break;
//                case STFaceStateReady:
//                    [_haptic startAction:_haptic.maxIntensityLevel];
//                    break;
//                default:
//                    break;
//            }
//        }
//    }
    /*
        set old value
     */
    _previousDetectedFaceDistance = faceDistance;
    _previousDetectedFaceDistanceRatio = faceDistanceRatio;
    _previousDetectedFaceState = _faceState;
}

- (void)calculateTransformations {
    NSInteger outputWidth = [[[STElieCamera sharedInstance].captureSession.outputs[0] videoSettings][@"Width"] integerValue];
    NSInteger outputHeight = [[[STElieCamera sharedInstance].captureSession.outputs[0] videoSettings][@"Height"] integerValue];

    if (UIInterfaceOrientationIsPortrait([STElieCamera sharedInstance].outputImageOrientation)) {
        // swap x & y coordinates
        self.portraitRotationTransform = CGAffineTransformMake(0, 1, 1, 0, 0, 0);

        // swap w & h
        NSInteger temp = outputWidth;
        outputWidth = outputHeight;
        outputHeight = temp;
    }
    else {
        self.portraitRotationTransform = CGAffineTransformIdentity;
    }

    CGFloat viewWidth = _cameraFrame.size.width;
    CGFloat viewHeight = _cameraFrame.size.height;
    CGFloat scale;
    CGAffineTransform frameTransform;

    switch ([STPhotoSelector sharedInstance].previewState.fillMode) {
        case kGPUImageFillModePreserveAspectRatio:
            scale = MIN(viewWidth / outputWidth, viewHeight / outputHeight);
            frameTransform = CGAffineTransformMakeScale(scale, scale);
            frameTransform = CGAffineTransformTranslate(frameTransform, -(outputWidth * scale - viewWidth) / 2, -(outputHeight * scale - viewHeight) / 2);
            break;
        case kGPUImageFillModePreserveAspectRatioAndFill:
            scale = MAX(viewWidth / outputWidth, viewHeight / outputHeight);
            frameTransform = CGAffineTransformMakeScale(scale, scale);
            frameTransform = CGAffineTransformTranslate(frameTransform, -(outputWidth * scale - viewWidth) / 2, -(outputHeight * scale - viewHeight) / 2);
            break;
        case kGPUImageFillModeStretch:
            frameTransform = CGAffineTransformMakeScale(viewWidth / outputWidth, viewHeight / outputHeight);
            break;
    }
    self.cameraOutputToPreviewFrameTransform = frameTransform;
    self.texelToPixelTransform = CGAffineTransformMakeScale(outputWidth, outputHeight);
}
@end


