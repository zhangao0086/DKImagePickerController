//
// Created by BLACKGENE on 8/3/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STPhotosManager.h"

#import "STPhotoItem.h"
#import "STCapturedImage.h"
#import "STCapturedImageSet.h"
#import "STPhotoItemSource.h"
#import "BGUtilities.h"
#import "STQueueManager.h"

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

- (STPhotoItem *)createPhotoItem:(STPhotoItemSource *)photoSource{
    STPhotoItem *item = [STPhotoItem new];
    item.orientationOriginated = photoSource.orientation;

    //TODO: 현재는 imageSet전용이지만 추후 전체를 통합
    if(photoSource.imageSet.defaultImage){
        item.sourceForCapturedImageSet = photoSource.imageSet;
        item.metadataFromCamera = photoSource.metaData;

        for(STCapturedImage * image in item.sourceForCapturedImageSet.images){
            [image createThumbnail:nil];
            [image createFullScreenImage:nil];
        }
    }

    [photoSource dispose];
    return item;
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