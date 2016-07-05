//
// Created by BLACKGENE on 15. 4. 17..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STExporter+Handle.h"
#import "NSNotificationCenter+STFXNotificationsShortHand.h"
#import "NSObject+STUtil.h"


@implementation STExporter (Handle)

- (void)registDispatchSuccessWhenEnterBackground {
    [self unregistDispatchSuccessWhenEnterBackground];

    @weakify(self)
    [[NSNotificationCenter defaultCenter] st_addObserverWithMainQueue:self forName:UIApplicationDidEnterBackgroundNotification usingBlock:^(NSNotification *note, id observer) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        [self dispatchFinshed:STExportResultSucceed];
    }];
}

- (void)unregistDispatchSuccessWhenEnterBackground {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)dispatchStartProcessing {
    NSAssert([NSThread isMainThread], @"must dispatch in main thread.");

    if(!self.processing){
        [self st_clearPerformOnceAfterDelay:@"delayedStopProcessing"];
        [self changeProcessingStatus:YES];
    }
}

- (void)dispatchStopProcessing {
    NSAssert([NSThread isMainThread], @"must dispatch in main thread.");

    if(self.processing){
        Weaks
        [self st_performOnceAfterDelay:@"delayedStopProcessing" interval:.3 block:^{
            if(Wself){
                [Wself changeProcessingStatus:NO];
            }
        }];
    }
}

- (void)changeProcessingStatus:(BOOL)processing {
    [self willChangeValueForKey:@keypath(self.processing)];
    self.processing = processing;
    [self didChangeValueForKey:@keypath(self.processing)];
}
@end