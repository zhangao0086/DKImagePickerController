//
// Created by BLACKGENE on 15. 10. 4..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STPermissionManager.h"
#import "STPhotosPermission.h"
#import "STCoreLocationWhenInUsePermission.h"
#import "STCameraPermission.h"
#import "NSObject+STThreadUtil.h"
#import "UIApplication+STUtil.h"

@interface STPermissionsStatusImpl : NSObject <STPermissionsStatus>
@end
@implementation STPermissionsStatusImpl{
    STPermission * _permissionObj;
}

- (instancetype)initWithClass:(Class)cls {
    self = [super init];
    if (self) {
        _permissionObj = (STPermission *)[[cls alloc] init];
        [self update];
    }
    return self;
}

- (void)dealloc {
    _permissionObj = nil;
}

- (BOOL)isAuthorized {
    return self.permission.status == STPermissionStatusAuthorized;
}

- (STPermissionStatus)status {
    //simply mapping status from 'VWWPermissionStatus'
    return (STPermissionStatus) self.permission.status;
}

- (STPermissionStatus)update {
    [_permissionObj updatePermissionStatus];
    return self.status;
}

- (STPermission *)permission {
    return _permissionObj;
}

- (STPermission *)permissionWithUpdate {
    [self update];
    return self.permission;
}

- (void)prompt:(STPermissionsStatusPromptResult)block {
    Weaks
    [[self permission] presentSystemPromtWithCompletionBlock:^{
        [Wself st_runAsMainQueueAsyncWithoutDeadlockingWithSelf:^(STPermissionsStatusImpl * _self) {
            STPermissionStatus status = [_self update];
            !block?: block(status);
        }];
    }];
}

- (void)promptOrStatusIfNeeded:(STPermissionsStatusPromptResult)block {
    STPermissionStatus status = self.status;
    if(status == STPermissionStatusNotDetermined || status == STPermissionStatusUninitialized){
        [self prompt:block];
    }else{
        block(status);
    }
}

- (void)alertNeeded {
    [self alertNeeded:nil];
}

- (void)alertNeeded:(void (^)(BOOL confirm))block {
    switch(self.status){
        case STPermissionStatusUninitialized:
        case STPermissionStatusNotDetermined:{
            [self prompt:^(STPermissionStatus status) {
                !block?:block(status == STPermissionStatusAuthorized);
            }];
        }
            break;

        case STPermissionStatusAuthorized:{
            [[UIApplication sharedApplication] openSettings:NSLocalizedString(@"alert.permission.authorized",@"") confirmAndWillOpen:^{
                !block?:block(YES);
            } cancel:^{
                !block?:block(NO);
            }];
        }
            break;

        case STPermissionStatusDenied:
        case STPermissionStatusRestricted:{
            [[UIApplication sharedApplication] openSettings:NSLocalizedString(@"alert.permission.denied",@"") confirmAndWillOpen:^{
                !block?:block(YES);
            } cancel:^{
                !block?:block(NO);
            }];
        }
            break;

    }
}
@end

@implementation STPermissionManager {

}

+ (id<STPermissionsStatus>)photos {
    static STPermissionsStatusImpl * permissionOfPhoto;
    BlockOnce(^{
        permissionOfPhoto = [[STPermissionsStatusImpl alloc] initWithClass:STPhotosPermission.class];
    });
    return permissionOfPhoto;
}

+ (id<STPermissionsStatus>)location {
    @synchronized (self) {
        return [[STPermissionsStatusImpl alloc] initWithClass:STCoreLocationWhenInUsePermission.class];
    }
}

+ (id<STPermissionsStatus>)camera {
    static STPermissionsStatusImpl * permissionOfCamera;
    BlockOnce(^{
        permissionOfCamera = [[STPermissionsStatusImpl alloc] initWithClass:STCameraPermission.class];
    });
    return permissionOfCamera;
}
@end
