//
// Created by BLACKGENE on 15. 8. 27..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <objc/runtime.h>
#import <MessageUI/MessageUI.h>
#import <SafariServices/SafariServices.h>
#import "UIViewController+STStandard.h"
#import "TOWebViewController.h"
#import "NSArray+STUtil.h"
#import "NSObject+STUtil.h"
#import "NSObject+BKAssociatedObjects.h"
#import "MFMailComposeViewController+BlocksKit.h"
#import "MFMessageComposeViewController+BlocksKit.h"
#import "MFMailComposeViewController+URL.h"
#import "MFMessageComposeViewController+URL.h"
#import "NSString+STUtil.h"

@implementation UIViewController (STStandard)

DEFINE_ASSOCIATOIN_KEY(kPresentationStyle)
- (STStandardPresentationStyle)standardPresentationStyle {
    return (STStandardPresentationStyle)[[self bk_associatedValueForKey:kPresentationStyle] unsignedIntegerValue];
}
- (void)setStandardPresentationStyle:(STStandardPresentationStyle)standardPresentationStyle {
    [self bk_associateValue:@(standardPresentationStyle) withKey:kPresentationStyle];
}

DEFINE_ASSOCIATOIN_KEY(kNavigationStyle)
- (STStandardNavigationStyle)standardNavigationStyle {
    return (STStandardNavigationStyle)[[self bk_associatedValueForKey:kNavigationStyle] unsignedIntegerValue];
}
- (void)setStandardNavigationStyle:(STStandardNavigationStyle)standardNavigationStyle {
    [self bk_associateValue:@(standardNavigationStyle) withKey:kNavigationStyle];
}

#pragma mark WebView
- (TOWebViewController *)presentWebViewController:(NSString *)url
                                              relatedView:(UIView *__weak)relatedView
                                               completion:(void (^)(void))completion {
    NSParameterAssert(url);

    if(self.standardNavigationStyle != STStandardNavigationStyleToolbarAndNavigationBar){
        self.standardNavigationStyle = STStandardNavigationStyleToolbarAndNavigationBar;
        oo(@"[!]Warning : self.standardNavigationStyle only allowed 'STStandardNavigationStyleToolbarAndNavigationBar' which has using in iOS 8.4 or earlier.")
    }

    TOWebViewController *wvc = [[TOWebViewController alloc] initWithURLString:url];
    wvc.showPageTitles = self.standardNavigationStyle ==STStandardNavigationStyleNavigationBarOnly || self.standardNavigationStyle ==STStandardNavigationStyleToolbarAndNavigationBar;
    wvc.showDoneButton = wvc.showPageTitles;
    wvc.showActionButton = YES;
    wvc.hideWebViewBoundaries = YES;
    wvc.automaticallyAdjustsScrollViewInsets = YES;

    UIViewController * __weak presentedController = [self presentPopoverController:wvc
                                                                 presentationStyle:self.standardPresentationStyle
                                                                   navigationStyle:self.standardNavigationStyle
                                                                       relatedView:relatedView completion:^{
                
            }];

    [wvc whenNewValueOnceOf:@keypath(wvc.webView) changed:^(id value, id _weakSelf) {
        [[wvc.webView subviews] eachWithIndexMatchClass:UIScrollView.class block:^(UIScrollView *v, NSUInteger i) {
            v.showsVerticalScrollIndicator = NO;
            v.showsHorizontalScrollIndicator = NO;
        }];
        presentedController.preferredContentSize = wvc.webView.size;
        !completion?:completion();
    }];
    return wvc;
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnavailableInDeploymentTarget"
- (SFSafariViewController *)presentSafariWebViewController:(NSString *)url
                                              relatedView:(UIView *__weak)relatedView
                                               completion:(void (^)(void))completion {
    NSParameterAssert(url);
    self.standardNavigationStyle = STStandardNavigationStyleContentOnly;

    SFSafariViewController *wvc = [[SFSafariViewController alloc] initWithURL:[[NSURL alloc] initWithString:url]];
    wvc.automaticallyAdjustsScrollViewInsets = YES;
    wvc.preferredContentSize = self.parentViewController.view.bounds.size;

    UIViewController * __weak presentedController = [self presentPopoverController:wvc
                                                                 presentationStyle:self.standardPresentationStyle
                                                                   navigationStyle:self.standardNavigationStyle
                                                                       relatedView:relatedView completion:completion];
    return wvc;
}
#pragma clang diagnostic pop

#pragma mark Mail
- (MFMailComposeViewController *)presentMailViewController:(UIView *__weak)relatedView
                                         presentCompletion:(void (^)(void))presentCompletion
                                           finishedSending:(void (^)(MFMailComposeViewController *__weak, MFMailComposeResult))finishedSending {

    if([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController * mailComposeViewController = [[MFMailComposeViewController alloc] init];
        [mailComposeViewController bk_setCompletionBlock:^(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *error) {
            if(error){
                finishedSending(nil, MFMailComposeResultFailed);
            }else{
                finishedSending(controller, result);
            }
        }];
        UIViewController * __weak presentedController = [self presentPopoverController:mailComposeViewController
                                                                     presentationStyle:self.standardPresentationStyle
                                                                       navigationStyle:STStandardNavigationStyleNone
                                                                           relatedView:relatedView completion:presentCompletion];

        return mailComposeViewController;
    }

    //TODO : fallback to mail app via 'UIApplication openURL'
    finishedSending(nil, MFMailComposeResultFailed);
    return nil;
}

- (MFMailComposeViewController *)presentMailViewController:(UIView *__weak)relatedView
                                                       url:(NSString *)url
                                         presentCompletion:(void (^)(void))presentCompletion
                                           finishedSending:(void (^)(MFMailComposeViewController *__weak, MFMailComposeResult))finishedSending {

    MFMailComposeViewController * mailComposeViewController = [self presentMailViewController:relatedView presentCompletion:presentCompletion finishedSending:finishedSending];
    [mailComposeViewController setFromUrl:[NSURL URLWithString:url]];
    return mailComposeViewController;
}

#pragma mark Message
- (MFMessageComposeViewController *)presentMessageViewController:(UIView *__weak)relatedView
                                                             url:(NSString *)url
                                               presentCompletion:(void (^)(void))presentCompletion
                                                 finishedSending:(void (^)(MFMessageComposeViewController *__weak, MessageComposeResult))finishedSending {

    if([MFMessageComposeViewController canSendText]){
        MFMessageComposeViewController *msgComposeViewController = [[MFMessageComposeViewController alloc] init];
        if(url){
            [msgComposeViewController setFromUrl:[url URL]];
        }
        [msgComposeViewController bk_setCompletionBlock:^(MFMessageComposeViewController *controller, MessageComposeResult result) {
            finishedSending(controller, result);
        }];

        UIViewController * __weak presentedController = [self presentPopoverController:msgComposeViewController
                                                                     presentationStyle:self.standardPresentationStyle
                                                                       navigationStyle:STStandardNavigationStyleNone
                                                                           relatedView:relatedView completion:presentCompletion];

        return msgComposeViewController;
    }

    finishedSending(nil, MessageComposeResultFailed);
    return nil;
}


- (MFMessageComposeViewController *)presentMessageViewController:(UIView *__weak)relatedView
                                                         message:(NSString *)message
                                                           image:(NSArray *)images
                                         presentCompletion:(void (^)(void))presentCompletion
                                           finishedSending:(void (^)(MFMessageComposeViewController *__weak, MessageComposeResult))finishedSending {

    MFMessageComposeViewController *msgComposeViewController = [self presentMessageViewController:relatedView url:nil presentCompletion:presentCompletion finishedSending:finishedSending];
    msgComposeViewController.body = message;
    for (UIImage * image in images){
        [msgComposeViewController addAttachmentData:UIImagePNGRepresentation(image) typeIdentifier:@"public.data" filename:[NSString stringWithFormat:@"image%d.png", [images indexOfObject:image]]];
    }
    return msgComposeViewController;
}

#pragma mark Core
- (UIViewController *)presentPopoverController:(UIViewController *)targetController
                             presentationStyle:(STStandardPresentationStyle)presentationStyle
                               navigationStyle:(STStandardNavigationStyle)navigationStyle
                                   relatedView:(UIView *__weak)relatedView
                                    completion:(void (^)(void))completion {


    //configure navigation style
    UIViewController *presentController = nil;
    void (^didPresentedViewController)(void) = nil;
    relatedView?:(relatedView = self.view);

    BOOL wrapNavigationController = navigationStyle != STStandardNavigationStyleContentOnly || navigationStyle != STStandardNavigationStyleNone;
    if(wrapNavigationController){
        UINavigationController * _presentController = nil;
        if([targetController isKindOfClass:UINavigationController.class]){
            _presentController = (UINavigationController *) targetController;
        }else{
            _presentController = [[UINavigationController alloc] initWithRootViewController:targetController];
        }

        didPresentedViewController = ^{
            _presentController.navigationBarHidden = !(navigationStyle==STStandardNavigationStyleNavigationBarOnly || navigationStyle==STStandardNavigationStyleToolbarAndNavigationBar);
            [_presentController setToolbarHidden:!(navigationStyle==STStandardNavigationStyleToolbarOnly || navigationStyle==STStandardNavigationStyleToolbarAndNavigationBar) animated:YES];
        };
        presentController = _presentController;

    }else{
        presentController = targetController;
    }

    //configure popover style
    if(presentationStyle == STStandardPresentationStylePopoverArrow || presentationStyle == STStandardPresentationStylePopover){
        presentController.modalPresentationStyle = UIModalPresentationPopover;

        UIPopoverPresentationController *popover_wvc = presentController.popoverPresentationController;
        popover_wvc.sourceView = relatedView;
        popover_wvc.sourceRect = relatedView.bounds;
        popover_wvc.permittedArrowDirections = presentationStyle == STStandardPresentationStylePopoverArrow ? UIPopoverArrowDirectionAny : 0;
        popover_wvc.delegate = self;
        popover_wvc.passthroughViews = nil;
    }

    [self presentViewController:presentController animated:YES completion:^{
        !didPresentedViewController?:didPresentedViewController();
        !completion?:completion();
    }];

    return presentController;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}
@end
