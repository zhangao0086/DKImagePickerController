//
// Created by BLACKGENE on 15. 4. 13..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIAlertController (STGIFFApp)
+ (UIAlertController *)alertToDeleteSelectedPhotos:(void (^)(UIAlertController *__weak alertController))confirmDeleteBlock cancel:(void (^)(UIAlertController *__weak alertController))cancelBlock;

+ (UIAlertController *)alertToDeleteAllInRoom:(void (^)(UIAlertController *__weak alertController))confirmDeleteBlock cancel:(void (^)(UIAlertController *__weak alertController))cancelBlock;

+ (UIAlertController *)alertToAuthorizeViaSettings:(NSString *)messageWhy confirm:(void (^)(UIAlertController *__weak alertController))confirmDeleteBlock cancel:(void (^)(UIAlertController *__weak alertController))cancelBlock;

+ (UIAlertController *)alertToNotifyError:(NSString *)message confirm:(void (^)(UIAlertController *__weak alertController))confirmDeleteBlock;

+ (UIAlertController *)alertToAsk:(NSString *)messageQuestion confirm:(void (^)(UIAlertController *__weak alertController))confirmDeleteBlock cancel:(void (^)(UIAlertController *__weak alertController))cancelBlock;
@end