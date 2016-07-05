//
// Created by BLACKGENE on 2015. 2. 16..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STExporterOpenIn.h"
#import "STExporter+IO.h"
#import "NSObject+STUtil.h"
#import "STExporter+Handle.h"


@interface STExporterOpenIn ()
@property(atomic, strong) UIDocumentInteractionController *docController;
@property(nonatomic) BOOL didSend;
@end

@implementation STExporterOpenIn {

}

- (BOOL)prepare; {
    self.shouldSucceesWhenEnterBackground = YES;
    [self finishAsyncPrepare];
    return YES;
}

- (void)exportFromAsyncPrepare; {
    [self dispatchStartProcessing];

    Weaks
    [self exportFiles:@[self.photoItems.first] completion:^(NSArray *imageURLs) {
        NSURL * exportTargetURL = [imageURLs firstObject];
        Strongs
        //succeed
        if(exportTargetURL){
            Sself.docController = [[UIDocumentInteractionController alloc] init];
            Sself.docController.delegate = Sself;
            Sself.docController.URL = exportTargetURL;
            [Sself.docController presentOpenInMenuFromRect:[Sself st_rootUVC].view.bounds inView:[Sself st_rootUVC].view animated:YES];

        }else{
            //failed
            [Sself dispatchFinshed:STExportResultFailed];
        }

        [Sself dispatchStopProcessing];
    }];
}

//- (BOOL)shouldNeedViewWhenExport {
//    return YES;
//}

- (void)finish; {
    [self.docController dismissMenuAnimated:NO];
    self.docController.delegate = nil;
    self.docController = nil;
    [super finish];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller; {
    [self dispatchFinshed:self.didSend ? STExportResultSucceed : STExportResultCanceled];
}

- (void) documentInteractionController: (UIDocumentInteractionController *) controller willBeginSendingToApplication: (NSString *) application{
    self.didSend = YES;
}
@end