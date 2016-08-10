//
// Created by BLACKGENE on 8/10/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "AppDelegateEB.h"
#import "EBRootViewController.h"


@implementation AppDelegateEB {

}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //initialize window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    [self.window setRootViewController:[[EBRootViewController alloc] init]];
    self.window.backgroundColor = [STStandardUI backgroundColor];
    [self.window setOpaque:YES];

    return YES;
}

@end