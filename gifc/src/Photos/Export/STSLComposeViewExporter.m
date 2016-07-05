//
// Created by BLACKGENE on 2015. 2. 12..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "NSArray+BlocksKit.h"
#import "STSLComposeViewExporter.h"
#import "NSObject+STUtil.h"
#import "STExporter+IO.h"
#import "STQueueManager.h"
#import "STExporter+Handle.h"
#import "NSString+STUtil.h"

@interface STSLComposeViewExporter ()
@property(atomic, readwrite, nullable) SLComposeViewController *controller;
@end

@implementation STSLComposeViewExporter

static NSDictionary * AvailableSLServiceTypes;

+ (void)precheckSLServiceAvailables {
    @synchronized (self.class) {
        Weaks
        dispatch_async([STQueueManager sharedQueue].starting, ^{
            [Wself _precheckSLServiceAvaliables:nil];
        });
    }
}

+ (void)_precheckSLServiceAvaliables:(NSString *)targetServiceType {
    NSArray * targetServices = targetServiceType ? @[targetServiceType] : @[SLServiceTypeTwitter, SLServiceTypeFacebook, SLServiceTypeSinaWeibo, SLServiceTypeTencentWeibo];
    NSMutableDictionary * _availableSLServiceTypes = [NSMutableDictionary dictionary];
    [targetServices each:^(NSString * serviceType) {
        if([SLComposeViewController isAvailableForServiceType:serviceType]){
            _availableSLServiceTypes[serviceType] = @"available";
        }
    }];
    AvailableSLServiceTypes = _availableSLServiceTypes;
}

- (BOOL)prepare; {
    if([AvailableSLServiceTypes hasKey:self.SLServiceType]){
        return YES;
    }else{
        [self.class _precheckSLServiceAvaliables:self.SLServiceType];
        return [AvailableSLServiceTypes hasKey:self.SLServiceType];
    }
}

- (BOOL)export {

    Weaks
    self.controller = [SLComposeViewController composeViewControllerForServiceType:self.SLServiceType];

    NSString * initialtext = [[self.hashtags bk_map:^id(NSString * hashtag) {
        return [@"#" st_add:hashtag];
    }] join:@" "];

    [self.controller setInitialText:initialtext];
    self.controller.completionHandler = ^(SLComposeViewControllerResult result) {
        //FIXME:  "plugin com.facebook.Facebook.ShareExtension invalidated" when canceling
        [Wself st_performOnceAfterDelay:.1 block:^{
            [Wself dispatchFinshed:result==SLComposeViewControllerResultDone ? STExportResultSucceed : STExportResultCanceled];
        }];
    };

    [self dispatchStartProcessing];

    [self exportAllImages:^(NSArray *images) {
        for (UIImage * image in images){
            [[Wself controller] addImage:image];
        }
        [[Wself st_rootUVC] presentViewController:[Wself controller] animated:YES completion:nil];
        [Wself dispatchStopProcessing];
    }];
    return YES;
}

- (void)finish; {
    [self.controller dismissViewControllerAnimated:NO completion:nil];
    [self.controller removeAllImages];
    [self.controller removeFromParentViewController];
    self.controller = nil;

    [super finish];
}

@end