//
// Created by BLACKGENE on 2015. 2. 24..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STExporterSaveToLibrary.h"
#import "STPhotoSelector.h"
#import "STExporter+Handle.h"
#import "STMainControl.h"
#import "STThumbnailGridViewCell.h"
#import "UIView+STUtil.h"
#import "STStandardButton.h"

@implementation STExporterSaveToLibrary {
    STPhotoSource _orientedSource;
}

- (BOOL)export; {
    [self dispatchStartProcessing];
    
    STPhotoViewType type = [STPhotoSelector sharedInstance].type;
    _orientedSource = [STPhotoSelector sharedInstance].source;

    if(type==STPhotoViewTypeEdit){
        [[STPhotoSelector sharedInstance] doExitEditAndApply:^(STPhotoItem *item) {
            [self dispatchFinshed: item ? STExportResultSucceed : STExportResultFailed];
        }];
        return YES;
    }
    else if(type==STPhotoViewTypeEditAfterCapture){
        [[STPhotoSelector sharedInstance] doExportAndExitEditAfterCapture:^(STPhotoItem *item) {
            [self dispatchFinshed: item ? STExportResultSucceed : STExportResultFailed];
        }];
        return YES;
    }
    else {
        Weaks
        if([[STPhotoSelector sharedInstance] currentFocusedPhotoItems].count>0){
            [[STPhotoSelector sharedInstance] exportItemsToAssetLibrary:[[STPhotoSelector sharedInstance] currentFocusedPhotoItems] blockForAllFinished:^(NSArray *array) {
                [[STPhotoSelector sharedInstance] deselectAllCurrentSelected];
                [[STMainControl sharedInstance] home];

                [Wself dispatchFinshed:array.count ? STExportResultSucceed : STExportResultFailed];
            }];

            for(STPhotoItem * photoItem in [[STPhotoSelector sharedInstance] currentFocusedPhotoItems]){
                [[[STPhotoSelector sharedInstance].collectionView cellForPhotoItem:photoItem]
                        transitionZeroScaleTo:[[[STMainControl sharedInstance] subControl] rightButton]
                                 presentImage:photoItem.previewImage
                                   completion:nil];
            }
            return YES;
        }
    }

    return NO;
}

- (BOOL)shouldNeedViewWhenExport {
    return NO;
}

- (void)dispatchFinshed:(STExportResult)result {
    [super dispatchFinshed:result];

    //if changed source Room -> AssetLibrary when completed.
    if (STPhotoSourceRoom == _orientedSource && [STPhotoSelector sharedInstance].source == STPhotoSourceAssetLibrary) {
        [[STPhotoSelector sharedInstance] loadFromCurrentSource];
        //FIXME: do not all reload. put 1 item
    }
}


@end