//
// Created by BLACKGENE on 15. 9. 17..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIApplication (STUtil)
- (BOOL)openSettings:(NSString *)messageWhy confirmAndWillOpen:(void (^)(void))confirmAndWillOpen cancel:(void (^)(void))cancel;

- (BOOL)openSettings:(NSString *)messageWhy cancel:(void (^)(void))cancel;

- (BOOL)openSettings:(NSString *)messageWhy;

- (BOOL)openSettings;
@end