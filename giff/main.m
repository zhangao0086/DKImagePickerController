//
//  main.m
//
//  Created by BLACKGENE on 2014. 12. 20..
//  Copyright (c) 2014 STELLS. All rights reserved.
//

#import "STUIApplication.h"
#if GIFFE
#import "AppDelegateEB.h"
#else
#import "AppDelegate.h"
#endif

#if DEBUG
void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"Exception: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}
#endif

int main(int argc, char * argv[]) {
    @autoreleasepool {
#if DEBUG
        NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
#endif

#if GIFFE
        return UIApplicationMain(argc, argv, NSStringFromClass([STUIApplication class]), NSStringFromClass([AppDelegateEB class]));
#else
        return UIApplicationMain(argc, argv, NSStringFromClass([STUIApplication class]), NSStringFromClass([AppDelegate class]));
#endif
    }
}

