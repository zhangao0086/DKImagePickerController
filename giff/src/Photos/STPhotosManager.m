//
// Created by BLACKGENE on 8/3/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Photos/Photos.h>
#import "STPhotosManager.h"

#import "STPhotoItem.h"
#import "STCapturedImage.h"
#import "STCapturedImageSet.h"
#import "STPhotoItemSource.h"
#import "BGUtilities.h"
#import "STQueueManager.h"
#import "NYXImagesKit.h"
#import "PHAsset+STUtil.h"

@implementation STPhotosManager {

}

+ (STPhotosManager *)sharedManager {
    static STPhotosManager *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (STPhotoItem *)generatePhotoItem:(STPhotoItemSource *)photoSource{
    STPhotoItem *item = nil;

    switch(photoSource.type){
        case STPhotoSourceTypeCapturedImageSet:
        {
            item = [STPhotoItem itemWithCapturedImageSet:photoSource.imageSet];
            item.metadataFromCamera = photoSource.metaData;

            for(STCapturedImage * image in item.sourceForCapturedImageSet.images){
                [image createThumbnail:nil];
                [image createFullScreenImage:nil];
            }
        }
            break;
        case STPhotoSourceTypeAsset:
        {
            item = [STPhotoItem itemWithAsset:photoSource.asset];
        }
            break;
        case STPhotoSourceTypeImage:{
            item = [STPhotoItem new];
            UIImage *defaultImage = photoSource.image;

            NSURL *originalUrl = [[STPhotosManager sharedManager] makeTempImageSaveUrl:kSTImageFilePrefix_TempToEdit_OrigianlImage];
            NSURL *fullscreenUrl = [[STPhotosManager sharedManager] makeTempImageSaveUrl:kSTImageFilePrefix_TempToEdit_Fullscreen];

            //original
            CGSize optimizedSizeToFit = [STApp memorySafetyRasterSize:[self previewImageSizeByType:STPhotoViewTypeDetail originalSize:defaultImage.size]];
            [[STPhotosManager sharedManager] saveImageToUrl:[defaultImage scaleToFitSize:optimizedSizeToFit] fileUrl:fullscreenUrl quality:.8 background:NO];

            //preview
            NSURL *previewUrl = [[STPhotosManager sharedManager] makeTempImageSaveUrl:kSTImageFilePrefix_TempToEdit_PreviewImage];
            CGSize optimizedSizeToFitForPreview = [STGIFFApp memorySafetyRasterSize:[self previewImageSizeByType:STPhotoViewTypeGridHigh originalSize:defaultImage.size]];
            UIImage *previewImage = [defaultImage scaleToFitSize:optimizedSizeToFitForPreview];
            [item initializePreviewImage:previewImage];

            [[STPhotosManager sharedManager] saveImageToUrl:previewImage fileUrl:previewUrl quality:.7];
            [[STPhotosManager sharedManager] saveImageToUrl:defaultImage fileUrl:originalUrl quality:1.0];

            item.sourceForFullResolutionFromURL = originalUrl;
            item.sourceForFullScreenFromURL = fullscreenUrl;
            item.sourceForPreviewFromURL = previewUrl;
            item.metadataFromCamera = photoSource.metaData;
        }
            break;
    }

    //common
    item.orientationOriginated = photoSource.orientation;
    item.origin = photoSource.origin;

    [photoSource dispose];
    return item;
}

- (NSArray<STPhotoItem *> *)fetchPhotos:(PHFetchOptions *)option{
    NSMutableArray *_photos = [NSMutableArray array];
    [[PHAsset fetchAssetsWithOptions:option] enumerateObjectsUsingBlock:^(PHAsset * phAsset, NSUInteger idx, BOOL *stop) {
        STPhotoItem * photoItem = [STPhotoItem itemWithAsset:phAsset];
        photoItem.index = idx;
        photoItem.uuid = phAsset.localIdentifierClearingPathSeparator;
        [_photos addObject:photoItem];
    }];
    return _photos;
}

- (NSArray<STPhotoItem *> *)fetchRecentPhotosByLimit:(NSUInteger)numberOfLimit{
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    allPhotosOptions.fetchLimit = numberOfLimit;
    return [self fetchPhotos:allPhotosOptions];
}

- (CGSize)previewImageSizeByType:(STPhotoViewType)type ratio:(CGFloat)ratio{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat sizeWidth = 0;
    if(type == STPhotoViewTypeGrid){
        sizeWidth = screenSize.width / 3.3f;
    }
    else if(type == STPhotoViewTypeGridHigh){
        sizeWidth = screenSize.width / 1.5f;
    }
    else if(type == STPhotoViewTypeMinimum){
        sizeWidth = screenSize.width / kSTBuffPhotosGridCol / 1.9f;
    }else{
        sizeWidth = screenSize.width;
    }
    return CGSizeMake(sizeWidth, sizeWidth * ratio);
}

- (CGSize)previewImageSizeByType:(STPhotoViewType)type originalSize:(CGSize)size{
    return [self previewImageSizeByType:type ratio:(size.width/size.height)];
}

- (void)saveImageToUrl:(UIImage *)image fileUrl:(NSURL *)url quality:(CGFloat)quality {
    [self saveImageToUrl:image fileUrl:url quality:quality background:YES];
}

- (void)saveImageToUrl:(UIImage *)image fileUrl:(NSURL *)url quality:(CGFloat)quality background:(BOOL)background{
    if(background){
        dispatch_async([STQueueManager sharedQueue].writingIO, ^{
            [[NSFileManager defaultManager] createFileAtPath:[url path] contents:UIImageJPEGRepresentation(image, quality ? quality : 1.f) attributes:nil];
        });
    }else{
        [[NSFileManager defaultManager] createFileAtPath:[url path] contents:UIImageJPEGRepresentation(image, quality ? quality : 1.f) attributes:nil];
    }
}

- (void)deleteImageToUrl:(NSURL *)url{
    if([[NSFileManager defaultManager] fileExistsAtPath:[url path]] && [[NSFileManager defaultManager] isDeletableFileAtPath:[url path]]){
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    }
}

- (NSURL *)makeTempImageSaveUrl:(NSString *)prefixName {
    return [[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:prefixName]] URLByAppendingPathExtension:@"jpg"];
}

- (NSURL *)makeImagesSaveUrl:(NSString *)prefixName index:(NSInteger)index {
    return [self makeImagesSaveUrl:[self saveTargetDir] prefix:prefixName index:index];
}

- (NSURL *)makeImagesSaveUrl:(NSString *)dirPath prefix:(NSString *)prefix index:(NSInteger)index {
    NSString *fileName = [prefix stringByAppendingFormat:@"%d", index];
    return [[NSURL fileURLWithPath:[dirPath stringByAppendingPathComponent:fileName]] URLByAppendingPathExtension:@"jpg"];
}

- (NSURL *)makeSavedImageUrlFromOtherPreifx:(NSURL *)url prefix:(NSString *)prefix prefixConvertTo:(NSString *)prefixConvertTo {
    return [self makeImagesSaveUrl:prefixConvertTo index:[self indexFromSaveUrl:url prefix:prefix]];
}

- (NSInteger)indexFromSaveUrl:(NSURL *)url prefix:(NSString *)prefix {
    NSString *filename = [[url URLByDeletingPathExtension] lastPathComponent];

    if(![filename matchesRegex:[prefix stringByAppendingString:@"[0-9]{1,}$"]]){
        NSLog(@"* WARN : filename must be match with prefix");
        return 0;
    }

    return [[[filename split:prefix] lastObject] integerValue];
}

- (NSString *)saveTargetDir{
    NSString *dir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    if(!dir){
        dir = NSTemporaryDirectory();
    }
    return dir;
}

- (NSArray *)savedPreviewImageFileURLsInRoom {
    NSURL *fileDir = [NSURL fileURLWithPath:[self saveTargetDir] isDirectory:YES];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:fileDir
                                                      includingPropertiesForKeys:@[]
                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                           error:nil];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'jpg' AND lastPathComponent CONTAINS %@", kSTImageFilePrefix_PreviewImage];
    return [contents filteredArrayUsingPredicate:predicate];
}
@end