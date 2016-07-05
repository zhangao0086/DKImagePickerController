//
// Created by BLACKGENE on 15. 8. 27..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@import MessageUI;
@import SafariServices;

typedef NS_ENUM(NSUInteger, STStandardPresentationStyle){
    STStandardPresentationStyleFullScreen,
    STStandardPresentationStylePopover,
    STStandardPresentationStylePopoverArrow
};

typedef NS_ENUM(NSUInteger, STStandardNavigationStyle){
    STStandardNavigationStyleToolbarOnly,
    STStandardNavigationStyleNavigationBarOnly,
    STStandardNavigationStyleToolbarAndNavigationBar,
    STStandardNavigationStyleContentOnly,
    STStandardNavigationStyleNone,
};

@class TOWebViewController;

@interface UIViewController (STStandard) <UIPopoverPresentationControllerDelegate>
@property(nonatomic, assign) STStandardPresentationStyle standardPresentationStyle;
@property(nonatomic, assign) STStandardNavigationStyle standardNavigationStyle;

- (TOWebViewController *)presentWebViewController:(NSString *)url
                                              relatedView:(UIView *__weak)relatedView
                                               completion:(void (^)(void))completion;

#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnavailableInDeploymentTarget"
- (SFSafariViewController *)presentSafariWebViewController:(NSString *)url relatedView:(UIView *__weak)relatedView completion:(void (^)(void))completion;
#pragma clang diagnostic pop

- (MFMailComposeViewController *)presentMailViewController:(UIView *__weak)relatedView
                                         presentCompletion:(void (^)(void))presentCompletion
                                           finishedSending:(void (^)(MFMailComposeViewController *__weak, MFMailComposeResult))finishedSending;

- (MFMailComposeViewController *)presentMailViewController:(UIView *__weak)relatedView url:(NSString *)url presentCompletion:(void (^)(void))presentCompletion finishedSending:(void (^)(MFMailComposeViewController *__weak, MFMailComposeResult))finishedSending;

- (MFMessageComposeViewController *)presentMessageViewController:(UIView *__weak)relatedView url:(NSString *)url presentCompletion:(void (^)(void))presentCompletion finishedSending:(void (^)(MFMessageComposeViewController *__weak, MessageComposeResult))finishedSending;

- (MFMessageComposeViewController *)presentMessageViewController:(UIView *__weak)relatedView message:(NSString *)message image:(NSArray *)images presentCompletion:(void (^)(void))presentCompletion finishedSending:(void (^)(MFMessageComposeViewController *__weak, MessageComposeResult))finishedSending;

- (UIViewController *)presentPopoverController:(UIViewController *)targetController presentationStyle:(STStandardPresentationStyle)presentationStyle navigationStyle:(STStandardNavigationStyle)navigationStyle relatedView:(UIView *__weak)relatedView completion:(void (^)(void))completion;

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller;
@end