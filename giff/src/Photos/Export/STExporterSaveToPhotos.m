//
// Created by BLACKGENE on 6/1/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STExporterSaveToPhotos.h"
#import "STExporter+Handle.h"
#import "NSObject+STUtil.h"
#import "STPhotoSelector.h"
#import "STPhotoItem+STExporterIO.h"

@implementation STExporterSaveToPhotos {

}

- (BOOL)export; {

    if([[STPhotoSelector sharedInstance] currentFocusedPhotoItems].count>0){

        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Save To Camera Roll"
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

        [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self dispatchFinshed:STExportResultCanceled];
        }]];

        [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Save Current Photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self _saveToPhotos:YES];
        }]];

        [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Save All Photos", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self _saveToPhotos:NO];
        }]];

        [[self st_rootUVC] presentViewController:actionSheet animated:YES completion:nil];

        return YES;

    }
    return NO;
}

- (void)_saveToPhotos:(BOOL)exportAsOnlyDefaultImageOfImageSet {
    [self dispatchStartProcessing];

    for(STPhotoItem * photoItem in self.photoItems){
        photoItem.exportAsOnlyDefaultImageOfImageSet = exportAsOnlyDefaultImageOfImageSet;
    }

    [[STPhotoSelector sharedInstance] exportItemsToAssetLibrary:self.photoItems blockForAllFinished:^(NSArray *array) {
        [self dispatchFinshed:array.count ? STExportResultSucceed : STExportResultFailed];
    }];
}

//- (BOOL)shouldNeedViewWhenExport {
//    return NO;
//}
@end