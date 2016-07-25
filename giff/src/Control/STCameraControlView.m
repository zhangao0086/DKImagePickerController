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
#import "STMainControl.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "STUserActor.h"
#import "STPhotoSelector.h"


@implementation STCameraControlView {
    STStandardButton *_appInfoButton;

    STStandardButton *_sourceLibraryButton;

    STUIView * _sourceButtonContainer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor brownColor];
    }

    return self;
}

- (void)createContent {
    [super createContent];

    [self createOptionControls];
    [self createSourceControls];

    CGFloat padding = [STStandardLayout widthBullet];

    [self addSubview:_appInfoButton];
    _appInfoButton.x = padding;
    _appInfoButton.bottom = self.height - padding;

    [self addSubview:_sourceLibraryButton];
    _sourceLibraryButton.right = self.width-padding;
    _sourceLibraryButton.bottom = self.height-padding;
}

- (void)createOptionControls {

}

- (void)createSourceControls {
    [self addSubview:_sourceButtonContainer];

    //left button
    _appInfoButton = [STStandardButton subSmallSize];
    _appInfoButton.preferredIconImagePadding = _appInfoButton.height/4;
    [_appInfoButton setButtons:@[[R set_info_indicator_bullet]] colors:nil style:STStandardButtonStylePTTP];
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

        if(STElieCamera.mode==STCameraModeManualExitAndPause){
            [[STMainControl sharedInstance] backToHome];
        }else {

            if ([STMainControl sharedInstance].mode == STControlDisplayModeLivePreview) {

                UIImageView *coveredView = [_sourceLibraryButton coverAndUncoverBegin:self.st_rootUVC.view presentingTarget:[STPhotoSelector sharedInstance]];
                [[STUserActor sharedInstance] act:STUserActionChangeCameraMode object:@(STCameraModeManualExitAndPause)];
                [_sourceLibraryButton coverAndUncoverEnd:self.st_rootUVC.view presentingTarget:[STPhotoSelector sharedInstance] beforeCoverView:coveredView comletion:nil];

            } else {
                [[STPhotoSelector sharedInstance] doDirectlyEnterHome];

                [[STUserActor sharedInstance] act:STUserActionChangeCameraMode object:@(STCameraModeManualExitAndPause)];
            }
        }
    }];

    [[NSNotificationCenter get] st_addObserverWithMainQueue:self forName:STNotificationPhotosDidLocalSaved usingBlock:^(NSNotification *note, id observer) {
        _sourceLibraryButton.badgeSmallPoint = YES;
    }];
}


@end