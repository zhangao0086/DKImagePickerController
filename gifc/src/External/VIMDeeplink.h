//
//  VIMDeeplink.h
//  Vimeo
//
//  Created by Alfred Hanssen on 9/10/14.
//  Copyright (c) 2014 Vimeo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VIMDeeplink : NSObject

+ (BOOL)viewVimeoAppInAppStore;

+ (BOOL)isVimeoAppInstalled;

+ (BOOL)openVimeoApp;

+ (BOOL)showVideoWithURI:(NSString *)videoURI;

+ (BOOL)showUserWithURI:(NSString *)userURI;

+ (BOOL)showUpload;

+ (BOOL)showMyProfile;

@end
