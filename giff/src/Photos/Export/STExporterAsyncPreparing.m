//
// Created by BLACKGENE on 2015. 2. 16..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STExporterAsyncPreparing.h"
#import "NSObject+STThreadUtil.h"

@interface STExporterAsyncPreparing ()
@property(nonatomic) BOOL prepareFinished;
@property(nonatomic) BOOL exportRequested;
@end

@implementation STExporterAsyncPreparing {

}

- (void)finishAsyncPrepare {
    Weaks
    [self st_runAsMainQueueWithoutDeadlocking:^{
        if (Wself.exportRequested) {
            Wself.exportRequested = NO;
            [Wself exportFromAsyncPrepare];
        }
        Wself.prepareFinished = YES;
    }];
}

- (void)exportFromAsyncPrepare {

}

- (BOOL)export; {
    self.exportRequested = YES;
    if(self.prepareFinished) {
        self.exportRequested = NO;
        [self exportFromAsyncPrepare];
    }
    return YES;
}

- (void)finish; {
    self.exportRequested = NO;
    self.prepareFinished = NO;

    [super finish];
}


@end