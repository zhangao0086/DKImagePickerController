//
//  main.m
//
//  Created by BLACKGENE on 2014. 12. 20..
//  Copyright (c) 2014 STELLS. All rights reserved.
//

#import "AppDelegate.h"
#import "STUIApplication.h"

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
        return UIApplicationMain(argc, argv, NSStringFromClass([STUIApplication class]), NSStringFromClass([AppDelegate class]));
    }
}

