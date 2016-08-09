//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCameraControlView.h"
#import "STStandardButton.h"
#import "UIView+STUtil.h"
#import "R.h"
#import "STElieCamera.h"
#import "NSObject+STUtil.h"
#import "STAppInfoView.h"
#import "STAppSetting.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "STPhotoSelector.h"
#import "giff-Swift.h"
#import "STCapturedImageSet+PHAsset.h"
#import "NSArray+STUtil.h"
#import "STPhotoItemSource.h"
#import "STStandardPointableSlider.h"
#import "CALayer+STUtil.h"

#import "STViewFinderPointLayer.h"
#import "SVGKImage.h"
#import "SVGKFastImageView.h"
#import "SVGKFastImageView+STUtil.h"
#import "STPreview.h"
#import "STMainControl.h"
#import "BlocksKit.h"
#import "NSNumber+STUtil.h"

@interface STCameraControlView()
@property(nonatomic, strong) STStandardButton * torchLightButton;
@property(nonatomic, strong) STStandardButton * facingSwitchButton;

@property(nonatomic, strong) STStandardPointableSlider * exposureSlider;
@property(nonatomic, strong) STUIView * cameraControlView;
@end

@implementation STCameraControlView {
    STStandardButton *_appInfoButton;

    STStandardButton *_sourceLibraryButton;

    STUIView * _sourceButtonContainer;

}

CGFloat padding;
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        padding = [STStandardLayout widthBullet];
    }
    return self;
}

- (void)createContent {
    [super createContent];

    [self createOptionControls];
    [self createSourceControls];
    [self createCameraControls];

    [self addSubview:_appInfoButton];
    _appInfoButton.x = padding;
    _appInfoButton.bottom = self.height - padding;

    [self addSubview:_sourceLibraryButton];
    _sourceLibraryButton.right = self.width-padding;
    _sourceLibraryButton.bottom = self.height-padding;
}

- (void)createOptionControls {

}

#pragma mark Camera Control
- (STPreview *)previewView{
    return [STPhotoSelector sharedInstance].previewView;
}

- (void)resetExposure{
    [self.previewView.pointerLayer finishExposure];
    [self.exposureSlider setProgress:.5 animated:YES];
    [STElieCamera sharedInstance].exposureBias = 0;
}

- (void)createCameraControls{
    [[STMainControl sharedInstance] whenNewValueOnceOf:@keypath([STMainControl sharedInstance].mode) id:@"STCameraControlView_STMainControl_mode_changed" changed:^(id value, id _weakSelf) {
        [self resetExposure];
    }];

    //Exposure Control
    self.exposureSlider = [[STStandardPointableSlider alloc] initWithSize:CGSizeMake(self.width/2,STStandardLayout.heightOverlayHorizontal)];
    self.exposureSlider.pointColor = [UIColor whiteColor];
    self.exposureSlider.trackColor = [[UIColor whiteColor] colorWithAlphaComponent:[STStandardUI alphaForDimmingWeak]];
    [self.exposureSlider setProgress:.5 animated:NO];
    [self.exposureSlider.layer setRasterize];
    self.exposureSlider.iconViewOfMinimumSide = [SVGKFastImageView viewWithImageNamed:[R ico_exposure_min] sizeValue:15];
    self.exposureSlider.iconViewOfMaximumSide = [SVGKFastImageView viewWithImageNamed:[R ico_exposure_max] sizeValue:16];
    self.exposureSlider.progressOfPointer = .5;

    self.cameraControlView = [[STUIView alloc] initWithSize:CGSizeMake(self.width, [STStandardButton subSmallSize].height)];
    [self addSubview:self.cameraControlView];
    self.cameraControlView.y = padding;

    [self.cameraControlView addSubview:self.exposureSlider];
    [self.exposureSlider centerToParentVertical];
    self.exposureSlider.layer.position = self.cameraControlView.boundsCenter;

    Weaks
    [self.cameraControlView whenPanAsSlide:nil direction:STSlideAllowedDirectionHorizontal started:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf) {
        Strongs
        [Wself st_clearPerformOnceAfterDelay:@"finish_exposure_layer"];

        [self.previewView.pointerLayer finishFocusing];
        [self.previewView.pointerLayer startExposure];

    } changed:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf, CGFloat distance, CGPoint movedOffset, CGFloat distanceReachRatio, STSlideDirection direction, BOOL confirmed) {
        CGFloat progress = CLAMP(Wself.exposureSlider.progress+(movedOffset.x/self.exposureSlider.boundsWidth), 0, 1);
        if(fabs(distanceReachRatio)<=.06){
            progress = .5;
        }

        [Wself.exposureSlider setProgress:progress animated:NO];

        self.previewView.pointerLayer.exposureIntensityValue = 1-progress;

        CGFloat bias = progress>=.5f ? AGKRemap(progress, .5f, 1, 0, [STElieCamera sharedInstance].maxAdjustingExposureBias) : AGKRemap(progress, 0, .5f, [STElieCamera sharedInstance].minAdjustingExposureBias, 0);

        [STElieCamera sharedInstance].exposureBias = bias;

    } ended:^(UIPanGestureRecognizer *sender, CGPoint locationInSelf, STSlideDirection direction, BOOL confirmed) {
        [STStandardUX revertStateAfterShortDelay:@"finish_exposure_layer" block:^{

            Strongs
            [self.previewView.pointerLayer finishExposure];
        }];
    }];

    //Torch Light
    self.torchLightButton = [STStandardButton subSmallSize];
    [self.cameraControlView addSubview:self.torchLightButton];
//    self.torchLightButton.preferredIconImagePadding = self.torchLightButton.height/4;
    [self.class torchLightSwitcher:self.torchLightButton setButtonsBlock:^(__weak STStandardButton *Self, NSArray *imageNames, NSArray *colors) {
        [Self setButtons:imageNames style:STStandardButtonStylePTTP];
    }];
    self.torchLightButton.x = padding;
    [self.torchLightButton centerToParentVertical];

    //Facing changer
    self.facingSwitchButton = [STStandardButton subSmallSize];
    [[self cameraControlView] addSubview:self.facingSwitchButton];
    self.facingSwitchButton.allowSelectedStateFromTouchingOutside = YES;
//    self.facingSwitchButton.preferredIconImagePadding = self.facingSwitchButton.height/4;
    [self.facingSwitchButton setButtons:@[[R set_manual_rear],[R set_manual_front]] style:STStandardButtonStylePTTP];
    self.facingSwitchButton.valuesMap = @[@(0), @(1)];
    self.facingSwitchButton.currentMappedValue = [STElieCamera sharedInstance].isPositionFront ? @(0) : @(1);
    [self.facingSwitchButton whenSelectedWithMappedValue:^(STSelectableView *button, NSInteger index, id value) {
        //if STCameraModeManualWithElie is On
        if(self.facingSwitchButton.selectedState){
            self.facingSwitchButton.selectedState = NO;
            [self.facingSwitchButton dispatchToggled];
        }

        [[STPhotoSelector sharedInstance] doBlurPreviewBegin];
        [[STElieCamera sharedInstance] changeFacingCamera:[value integerValue]==0 completion:^(BOOL changed){
            [[STPhotoSelector sharedInstance] doBlurPreviewEnd];
        }];
    }];
    self.facingSwitchButton.right = self.width-padding;
    [self.facingSwitchButton centerToParentVertical];
}

- (void)createSourceControls {
    [self addSubview:_sourceButtonContainer];

    //left button
    _appInfoButton = [STStandardButton subSmallSize];
    _appInfoButton.preferredIconImagePadding = _appInfoButton.height/4;
    [_appInfoButton setButtons:@[[R set_info_indicator_bullet]] style:STStandardButtonStylePTTP];
    [_appInfoButton whenSelected:^(STSelectableView *selectedView, NSInteger index) {
        [[STElieCamera sharedInstance] pauseCameraCapture];

        _appInfoButton.badgeSmallPoint = NO;

        STUIView * appInfoViewContainer = [[STUIView alloc] initWithSize:[self st_rootUVC].view.size];
        [[self st_rootUVC].view addSubview:appInfoViewContainer];

        STAppInfoView * appInfoView = [[STAppInfoView alloc] initWithSize:appInfoViewContainer.size];
        [appInfoViewContainer addSubview:appInfoView];
        [appInfoView setContents];

        [_appInfoButton coverWithBlur:[self st_rootUVC].view presentingTarget:appInfoViewContainer blurStyle:UIBlurEffectStyleDark comletion:nil];

        [appInfoView.closeButton whenSelected:^(STSelectableView *_selectedView, NSInteger _index) {
            [[STElieCamera sharedInstance] resumeCameraCapture];

            [_appInfoButton uncoverWithBlur:YES comletion:^(STStandardButton *button, BOOL covered) {
                [appInfoViewContainer clearAllOwnedImagesIfNeededAndRemoveFromSuperview:YES];

            }];
        }];
    }];
    _appInfoButton.badgeSmallPoint = STAppSetting.get.isFirstLaunchSinceLastBuild;


    //right button
    _sourceLibraryButton = [STStandardButton subSmallSize];
    _sourceLibraryButton.allowSelectAsTap = YES;
    _sourceLibraryButton.preferredIconImagePadding = _sourceLibraryButton.height/4;
    [_sourceLibraryButton setButtons:@[[R go_roll]] colors:nil style:STStandardButtonStylePTTP];
    [_sourceLibraryButton whenSelected:^(STSelectableView *selectedView, NSInteger index) {
        _sourceLibraryButton.badgeSmallPoint = NO;

        // fix for Fully Cached image - blanked image
//        if([STUIApplication sharedApplication].hasBeenReceivedMemoryWarning){
//            [[[STPhotoSelector sharedInstance] collectionView] representPhotoItemOfAllVisibleCells:YES];
//        }

        DKImagePickerController *pickerController = [DKImagePickerController new];
        pickerController.maxSelectableCount = 1;
        pickerController.assetType = DKImagePickerControllerAssetTypeAllAssets;
        pickerController.showsCancelButton = YES;
        pickerController.showsEmptyAlbums = YES;
        pickerController.allowMultipleTypes = YES;
        pickerController.defaultSelectedAssets = @[];
        pickerController.sourceType = DKImagePickerControllerSourceTypePhoto;

        [pickerController setDidSelectAssets:^(NSArray * __nonnull assets) {
            [STCapturedImageSet setDefaultAspectFillRatioForAssets:CGSizeMake(1, 1)];
            [STCapturedImageSet setMaxFrameDurationIfAssetHadAnimatableContents:[STGIFFApp defaultMaxDurationForAnimatableContent]];
            NSArray<PHAsset *> * importedAssets = [assets mapWithItemsKeyPath:@"originalAsset"];
            [STCapturedImageSet createFromAssets:importedAssets completion:^(NSArray *imageSets) {
                for(STCapturedImageSet * imageSet in imageSets){
                    [[STPhotoSelector sharedInstance] doAfterCaptured:[STPhotoItemSource sourceWithImageSet:imageSet]];
                }

            }];
            NSLog(@"didSelectAssets");
        }];

        [[self st_rootUVC] presentViewController:pickerController animated:YES completion:nil];

//        if(STElieCamera.mode==STCameraModeManualExitAndPause){
//            [[STMainControl sharedInstance] backToHome];
//        }else {
//
//            if ([STMainControl sharedInstance].mode == STControlDisplayModeLivePreview) {
//
//                UIImageView *coveredView = [_sourceLibraryButton coverAndUncoverBegin:self.st_rootUVC.view presentingTarget:[STPhotoSelector sharedInstance]];
//                [[STUserActor sharedInstance] act:STUserActionChangeCameraMode object:@(STCameraModeManualExitAndPause)];
//                [_sourceLibraryButton coverAndUncoverEnd:self.st_rootUVC.view presentingTarget:[STPhotoSelector sharedInstance] beforeCoverView:coveredView comletion:nil];
//
//            } else {
//                [[STPhotoSelector sharedInstance] doDirectlyEnterHome];
//
//                [[STUserActor sharedInstance] act:STUserActionChangeCameraMode object:@(STCameraModeManualExitAndPause)];
//            }
//        }
    }];

    [[NSNotificationCenter get] st_addObserverWithMainQueue:self forName:STNotificationPhotosDidLocalSaved usingBlock:^(NSNotification *note, id observer) {
        _sourceLibraryButton.badgeSmallPoint = YES;
    }];
}

#pragma mark UI creator
+ (STStandardButton *)torchLightSwitcher:(STStandardButton *)button setButtonsBlock:(STStandardButtonSetButtonsBlock)block{
    NSArray * valuesForTorchLight = [@(STTorchLightMode_count) st_intArray];
    block(button, [valuesForTorchLight bk_map:^id(id obj) {
        switch ((STTorchLightMode)[obj integerValue]){
            case STTorchLightModeOff:
                return [R set_torchlight_off];
            case STTorchLightModeWeak:
                return [R set_torchlight_on];
            case STTorchLightModeMax:
                return [R set_torchlight_strong];
            default:
                NSParameterAssert(NO);
                return nil;
        }
    }], nil);

    button.valuesMap = valuesForTorchLight;
    button.currentMappedValue = @(STTorchLightModeOff);
    [button whenSelectedWithMappedValue:^(STSelectableView *_button, NSInteger index, id value) {
        switch ((STTorchLightMode)[value integerValue]){
            case STTorchLightModeOff:
                [STElieCamera sharedInstance].torchLight = 0;
                break;
            case STTorchLightModeWeak:
                [STElieCamera sharedInstance].torchLight = .1;
                break;
            case STTorchLightModeMax:
                [STElieCamera sharedInstance].torchLight = 1;
                break;
            default:
                break;
        }
    }];
    return button;
}
@end