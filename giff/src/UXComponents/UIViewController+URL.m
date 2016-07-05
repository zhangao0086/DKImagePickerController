//
// Created by BLACKGENE on 15. 9. 2..
// Copyright (c) 2015 stells. All rights reserved.
//

//#import <StoreKit/StoreKit.h>
#import "UIViewController+URL.h"
#import "MFMailComposeViewController+URL.h"
#import "UIViewController+STStandard.h"
#import "NSURL+STUtil.h"

@implementation UIViewController (URL)

//https://developer.apple.com/library/ios/featuredarticles/iPhoneURLScheme_Reference/iPhoneURLScheme_Reference.pdf

- (BOOL)openURL:(NSString *)url fallbackUrl:(NSString *)fallbackUrl relatedView:(UIView *)relatedView{

    NSURL * Url = [NSURL URLWithString:url].standardizedURL;
    NSString * scheme = [Url scheme];

    /*if([SKStoreProductViewController class] && [Url appStoreId]){
        // appstore built-in
        SKStoreProductViewController *storeVC = [[SKStoreProductViewController alloc] init];
        NSDictionary *params = @{ SKStoreProductParameterITunesItemIdentifier : [Url appStoreId] };
        [storeVC loadProductWithParameters:params completionBlock:nil];
        storeVC.modalPresentationStyle = UIModalPresentationPopover;

        [[self st_rootUVC]  presentViewController:storeVC animated:YES completion:nil];
        return YES;

    }else */
    if([@"http" isEqualToString:scheme] || [@"https" isEqualToString:scheme]){
        //web link
        if([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion < 9){
            return (BOOL) [self presentWebViewController:url relatedView:relatedView completion:^{

            }];
        }else{
            return (BOOL) [self presentSafariWebViewController:url relatedView:relatedView completion:^{

            }];
        }

    }else if([Url isMailtoURL]){
        //mail link
        return (BOOL) [self presentMailViewController:relatedView url:url presentCompletion:^{

        } finishedSending:^(MFMailComposeViewController *_controller, MFMailComposeResult result) {

        }];
    }
    else if([Url isSMSURL]){
        //mail link
        return (BOOL) [self presentMessageViewController:relatedView url:url presentCompletion:^{

        } finishedSending:^(MFMessageComposeViewController *controller, MessageComposeResult result) {

        }];
    }
    else{
        //itunes, applink
        if([[UIApplication sharedApplication] canOpenURL:Url]){
            return [[UIApplication sharedApplication] openURL:Url];

        }else if(fallbackUrl){
            return [self openURL:fallbackUrl fallbackUrl:nil relatedView:relatedView];
        }
    }
    return NO;
}

@end