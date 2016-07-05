//
// Created by BLACKGENE on 15. 9. 17..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <UIAlertController+Blocks/UIAlertController+Blocks.h>
#import "UIApplication+STUtil.h"
#import "NSObject+STUtil.h"

@implementation UIApplication (STUtil)

- (BOOL)openSettings:(NSString *)messageWhy confirmAndWillOpen:(void(^)(void))confirmAndWillOpen cancel:(void(^)(void))cancel{
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:url];
    if(canOpenURL){
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"alert.settings.tail", @""), messageWhy];

        [UIAlertController showAlertInViewController:[self st_rootUVC]
                                           withTitle:nil
                                             message:message
                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@[NSLocalizedString(@"OK", @"")]
                                            tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {

                                                if (buttonIndex == controller.cancelButtonIndex) {
                                                    !cancel?:cancel();

                                                } else if (buttonIndex == controller.firstOtherButtonIndex) {
                                                    !confirmAndWillOpen?:confirmAndWillOpen();

                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [[UIApplication sharedApplication] openURL:url];
                                                    });
                                                }
                                            }];
    }else{
        !cancel?:cancel();
    }
    return canOpenURL;
}

- (BOOL)openSettings:(NSString *)messageWhy cancel:(void(^)(void))cancel{
    return [self openSettings:messageWhy confirmAndWillOpen:nil cancel:cancel];
}

- (BOOL)openSettings:(NSString *)messageWhy{
    return [self openSettings:messageWhy confirmAndWillOpen:nil cancel:nil];
}

- (BOOL)openSettings{
    return [self openSettings:nil confirmAndWillOpen:nil cancel:nil];
}

@end