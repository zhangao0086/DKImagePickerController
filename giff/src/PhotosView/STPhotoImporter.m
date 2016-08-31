//
// Created by BLACKGENE on 8/29/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STPhotoImporter.h"
#import "STCapturedImageSet.h"
#import "STCapturedImageSet+PHAsset.h"
#import "NSArray+STUtil.h"
#import "STPhotoSelector.h"
#import "STPhotoItemSource.h"
#import "STPhotoItemSource.h"
#import "NSObject+STUtil.h"
#if GIFFE
#import "giffe-Swift.h"
#else
#import "giff-Swift.h"
#import "UIView+STUtil.h"

#endif

@implementation STPhotoImporter {

}
+ (STPhotoImporter *)sharedImporter {
    static STPhotoImporter *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (void)startImporting:(void(^)(NSArray<STPhotoItemSource *> *importedPhotoItemSource))block{
    NSParameterAssert(block);

    DKImagePickerController * pickerController = [[DKImagePickerController alloc] init];

    DKImagePickerControllerSTPhotoImporterDelegate * imagePickerDelegator = DKImagePickerControllerSTPhotoImporterDelegate.new;
    imagePickerDelegator.checkedNumberColor = [STStandardUI buttonColorForegroundAssistance];
    imagePickerDelegator.checkedImageTintColor = [STStandardUI pointColor];
    imagePickerDelegator.collectionViewBackgroundColor = [STStandardUI backgroundColor];

    pickerController.UIDelegate = imagePickerDelegator;
    pickerController.maxSelectableCount = 2;
    pickerController.allowCirculatingSelection = YES;
    pickerController.assetType = DKImagePickerControllerAssetTypeAllAssets;
    pickerController.showsCancelButton = YES;
    pickerController.showsEmptyAlbums = YES;
    pickerController.allowMultipleTypes = YES;
    pickerController.defaultSelectedAssets = @[];
    pickerController.sourceType = DKImagePickerControllerSourceTypePhoto;

    [pickerController setDidSelectAssets:^(NSArray * __nonnull assets) {
        [STCapturedImageSet setDefaultAspectFillRatioForAssets:CGSizeMake(1, 1)];
        [STCapturedImageSet setMaxFrameDurationIfAssetHadAnimatableContents:[STGIFFApp defaultMaxDurationForAnimatableContent]];
        NSArray<PHAsset *> * importedAssets = [assets mapWithIndex:^id(DKAsset * dkAsset, NSInteger index) {
            return dkAsset.originalAsset;
        }];
        [STCapturedImageSet createFromAssets:importedAssets completion:^(NSArray *imageSets) {

            !block?:block([imageSets mapWithIndex:^id(STCapturedImageSet * imageSet, NSInteger index) {
                return [STPhotoItemSource sourceWithImageSet:imageSet];
            }]);
        }];
        NSLog(@"didSelectAssets");
    }];

    [[self st_rootUVC] presentViewController:pickerController animated:YES completion:nil];


}
@end