//
// Created by BLACKGENE on 2015. 2. 16..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STExporterShare.h"
#import "NSObject+STUtil.h"
#import "STExporter+IO.h"
#import "STExporter+Handle.h"


@interface STExporterShare ()
@property(atomic, strong) UIActivityViewController *avController;
@end

@implementation STExporterShare

- (BOOL)prepare; {
    [self finishAsyncPrepare];
    return YES;
}

- (void)exportFromAsyncPrepare; {
    [self dispatchStartProcessing];

    Weaks
    [self exportFiles:self.photoItems completion:^(NSArray *imageURLs) {
        Wself.avController = [[UIActivityViewController alloc] initWithActivityItems:imageURLs applicationActivities:nil];
        Wself.avController.excludedActivityTypes = @[
//                UIActivityTypeSaveToCameraRoll,
                UIActivityTypePostToTwitter,
                UIActivityTypeAddToReadingList
        ];
        Wself.avController.completionWithItemsHandler = (UIActivityViewControllerCompletionWithItemsHandler) ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            Strongs
            if (activityError) {
                [Sself dispatchFinshed:STExportResultFailed];
            } else {
                [Sself dispatchFinshed:completed ? STExportResultSucceed : STExportResultCanceled];
            }
        };
        [[Wself st_rootUVC] presentViewController:Wself.avController animated:YES completion:nil];

        [Wself dispatchStopProcessing];
    }];
}

//- (BOOL)shouldNeedViewWhenExport {
//    return YES;
//}

@end