//
// Created by BLACKGENE on 15. 10. 4..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STPermission.h"

@class STPermission;

typedef void(^STPermissionsStatusPromptResult)(STPermissionStatus status);

@protocol STPermissionsStatus <NSObject>
- (BOOL)isAuthorized;
- (STPermissionStatus)status;
- (STPermissionStatus)update;
- (STPermission *)permission;
- (STPermission *)permissionWithUpdate;
- (void)prompt:(STPermissionsStatusPromptResult)block;
- (void)promptOrStatusIfNeeded:(STPermissionsStatusPromptResult)block;
- (void)alertNeeded;
- (void)alertNeeded:(void(^)(BOOL confirm))block;
@end

@interface STPermissionManager : NSObject
+ (id <STPermissionsStatus>)photos;

+ (id <STPermissionsStatus>)location;

+ (id <STPermissionsStatus>)camera;
@end