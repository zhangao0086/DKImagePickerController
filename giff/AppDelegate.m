//
//  AppDelegate.m
//  elie
//
//  Created by Lee on 2014. 7. 10..
//  Copyright (c) 2014년 Eliecam. All rights reserved.
//


#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "AppDelegate.h"
#import "STGIFFRootViewController.h"
#import "SDWebImageManager.h"
#import "STGIFFAppSetting.h"
#import "STFilterManager.h"
#import "STExportManager.h"
#import "STReachabilityManager.h"
#import "STMotionManager.h"
#import "STPermissionManager.h"
#import "STUIApplication.h"
#import "STUIApplication+QuickAction.h"
#import "STUIApplication+SpotlightSearch.h"
#import "PINMemoryCache.h"
#import "STCapturedImageProcessor.h"
#import "FCFileManager.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnavailableInDeploymentTarget"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions; {
    [STGIFFApp registerDefinitions];
    [STGIFFAppSetting get];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // pre-configure
    if(![STGIFFApp isDebugMode]){
        [Fabric with:@[Crashlytics.class, Answers.class]];
        [[Crashlytics sharedInstance] setUserIdentifier:[STGIFFAppSetting get]._guid];
    }

    if(![STGIFFApp isInSimulator]){
        [NSClassFromString(@"SFDynamicCodeInjection") performSelector:@selector(disable)];
    }

    //initialize preloading
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    [[STExportManager sharedManager] setup];
    [[STFilterManager sharedManager] loadFilterInfoWithCompletion:nil];

    //initialize permissions
    [STPermissionManager camera];
    [STPermissionManager photos];

    //initialize utility
    [STStandardUX setupNotificationMessageStyle];
    [STGIFFAppSetting.get aquireGeotagDataIfAllowed];
    [[STReachabilityManager sharedInstance] activate];
    [[STMotionManager sharedManager] startOrientationUpdates];

    //check permission and start app
    Weaks
    [STGIFFApp checkInitialAppPermissions:^{
        [Wself startApp];
    }];

    //spotlight search
    [[STUIApplication sharedApplication] indexDefaultSearchableItemsIfPossible];

    //touch launch time
    [STGIFFAppSetting.get touchForLastLaunchTime];

#if DEBUG
//    [[STUIApplication sharedApplication] launchFromNeededShortcutItemType:@"STShortcutItemTypeEditLastPhoto" completionHandler:nil];
#endif

    return YES;
}

- (void)startApp {
    //start camera

    [[STElieCamera initSharedInstanceWithSessionPreset:AVCaptureSessionPresetPhoto
                                              position:AVCaptureDevicePositionBack
                                  preferredOutputRatio:1] startCameraCapture];

    [[STElieCamera sharedInstance] startCameraCapture];

    //initialize window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    [self.window setRootViewController:[[STGIFFRootViewController alloc] init]];
    self.window.backgroundColor = [STStandardUI backgroundColor];
    [self.window setOpaque:YES];

    //initialize rating
    [STGIFFApp registerRatingSettings];
}

#pragma mark iOS9
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL succeeded))completionHandler {

    //from shortcut items
    [[STUIApplication sharedApplication] launchFromNeededShortcutItemIfPossible:shortcutItem completionHandler:completionHandler];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *__nullable restorableObjects))restorationHandler {

    //from searchable items
    [[STUIApplication sharedApplication] launchFromNeededSearchableItemByUserActivityIfPossible:userActivity];

    return NO;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application; {
    ((STUIApplication *)application).hasBeenReceivedMemoryWarning = YES;

    [[SDImageCache sharedImageCache] clearMemory];
    [[PINMemoryCache sharedCache] removeAllObjects];
//    [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder; {
    [STGIFFAppSetting.get synchronize];
    
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation; {
    BOOL handled = NO;

    handled |= [[STExportManager sharedManager] handle:application openURL:url sourceApplication:sourceApplication annotation:annotation];

    return handled;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[STPhotoSelector sharedInstance] startObservingPhotoLibraryChange];
}

- (void)applicationDidEnterBackground:(UIApplication *)application{

    if(![STCapturedImageProcessor sharedProcessor].processing){
        [[STCapturedImageProcessor sharedProcessor] clean];
    }
//    [[STLocalAuthManager sharedManager] expire];
    [STGIFFAppSetting.get clearGeotagDataIfAllowed];
    //TODO: 일단 한번 안지워보는걸로 함.
//    [STSetting.get clearLocalAuthStateIfSecurityModeConfigured];
//    [STElieAppSetting.get touchForLastLaunchTime];
    [STGIFFAppSetting.get synchronize];
    [[STReachabilityManager sharedInstance] deactivate];
    [[STMotionManager sharedManager] stopOrientationUpdates:NO];

//    [FCFileManager removeFilesInDirectoryAtPath:NSTemporaryDirectory()];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [STGIFFAppSetting.get aquireGeotagDataIfAllowed];
    [[STReachabilityManager sharedInstance] activate];
    [[STPhotoSelector sharedInstance] reloadFromCurrentSourceIfReserved];
    [[STMotionManager sharedManager] startOrientationUpdates];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];

    //TODO FIXME: didBecomeActive를 홈버튼클릭 해서 온 건지 내 앱내에서 uiviewcontroller를 통해 온건지 식별하는게 가장 완벽
    [[STPhotoSelector sharedInstance] stopObservingPhotoLibraryChange];
    [[STPhotoSelector sharedInstance] reloadFromCurrentSourceIfReserved];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[STCapturedImageProcessor sharedProcessor] clean];
    [STGIFFAppSetting.get clearGeotagDataIfAllowed];
    [STGIFFAppSetting.get synchronize];

    [FCFileManager removeFilesInDirectoryAtPath:NSTemporaryDirectory()];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

#pragma clang diagnostic pop