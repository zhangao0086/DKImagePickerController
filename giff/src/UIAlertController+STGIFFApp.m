//
// Created by BLACKGENE on 15. 4. 13..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <UIAlertController+Blocks/UIAlertController+Blocks.h>
#import "UIAlertController+STGIFFApp.h"
#import "NSObject+STUtil.h"


@implementation UIAlertController (STGIFFApp)

+ (UIAlertController *)alertToDeleteSelectedPhotos:(void (^)(UIAlertController *__weak alertController))confirmDeleteBlock
                                            cancel:(void(^)(UIAlertController * __weak alertController))cancelBlock{

    return [UIAlertController showAlertInViewController:[self st_rootUVC]
                                       withTitle:NSLocalizedString(@"Delete_Photo", @"")
                                         message:nil
                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                          destructiveButtonTitle:NSLocalizedString(@"Delete", @"")
                               otherButtonTitles:nil
                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {

                                            if (buttonIndex == controller.cancelButtonIndex) {
                                                !cancelBlock?:cancelBlock(controller);

                                            } else if (buttonIndex == controller.destructiveButtonIndex) {

                                                !confirmDeleteBlock ?: confirmDeleteBlock(controller);

                                            } else if (buttonIndex >= controller.firstOtherButtonIndex) {
                                                NSLog(@"Other Button Index %ld", (long) buttonIndex - controller.firstOtherButtonIndex);
                                            }
                                        }];
}

+ (UIAlertController *)alertToDeleteAllInRoom:(void (^)(UIAlertController *__weak alertController))confirmDeleteBlock
                                            cancel:(void(^)(UIAlertController * __weak alertController))cancelBlock{

    return [UIAlertController showAlertInViewController:[self st_rootUVC]
                                              withTitle:NSLocalizedString(@"Delete_Photo_Room", @"")
                                                message:nil
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                 destructiveButtonTitle:NSLocalizedString(@"Yes", @"")
                                      otherButtonTitles:nil
                                               tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {

                                                   if (buttonIndex == controller.cancelButtonIndex) {
                                                       !cancelBlock?:cancelBlock(controller);

                                                   } else if (buttonIndex == controller.destructiveButtonIndex) {

                                                       !confirmDeleteBlock ?: confirmDeleteBlock(controller);

                                                   } else if (buttonIndex >= controller.firstOtherButtonIndex) {
                                                       NSLog(@"Other Button Index %ld", (long) buttonIndex - controller.firstOtherButtonIndex);
                                                   }
                                               }];
}

+ (UIAlertController *)alertToAuthorizeViaSettings:(NSString *)messageWhy
                                           confirm:(void (^)(UIAlertController *__weak alertController))confirmDeleteBlock
                                            cancel:(void(^)(UIAlertController * __weak alertController))cancelBlock{

    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"alert.settings.tail", @""), messageWhy];

    return [UIAlertController showAlertInViewController:[self st_rootUVC]
                                              withTitle:nil
                                                message:message
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:@[NSLocalizedString(@"OK", @"")]
                                               tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {

                                                   if (buttonIndex == controller.cancelButtonIndex) {
                                                       !cancelBlock?:cancelBlock(controller);

                                                   } else if (buttonIndex == controller.firstOtherButtonIndex) {
                                                       !confirmDeleteBlock ?: confirmDeleteBlock(controller);
                                                   }
                                               }];
}

+ (UIAlertController *)alertToNotifyError:(NSString *)message
                                  confirm:(void (^)(UIAlertController *__weak alertController))confirmDeleteBlock{

    return [UIAlertController showAlertInViewController:[self st_rootUVC]
                                              withTitle:nil
                                                message:message
                                      cancelButtonTitle:nil
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:@[NSLocalizedString(@"OK", @"")]
                                               tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {
                                                   if (buttonIndex == controller.firstOtherButtonIndex) {
                                                       !confirmDeleteBlock ?: confirmDeleteBlock(controller);
                                                   }
                                               }];
}

+ (UIAlertController *)alertToAsk:(NSString *)messageQuestion
                                           confirm:(void (^)(UIAlertController *__weak alertController))confirmDeleteBlock
                                            cancel:(void(^)(UIAlertController * __weak alertController))cancelBlock{

    return [UIAlertController showAlertInViewController:[self st_rootUVC]
                                              withTitle:nil
                                                message:messageQuestion
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:@[NSLocalizedString(@"Yes", @"")]
                                               tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {

                                                   if (buttonIndex == controller.cancelButtonIndex) {
                                                       !cancelBlock?:cancelBlock(controller);

                                                   } else if (buttonIndex == controller.firstOtherButtonIndex) {
                                                       !confirmDeleteBlock ?: confirmDeleteBlock(controller);
                                                   }
                                               }];
}

@end
