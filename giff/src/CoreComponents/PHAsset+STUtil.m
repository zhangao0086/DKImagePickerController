//
// Created by BLACKGENE on 2016. 3. 28..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <BlocksKit/NSArray+BlocksKit.h>
#import "PHAsset+STUtil.h"
#import "NSString+STUtil.h"
#import "NSObject+STThreadUtil.h"
#import "PHImageRequestOptions+STUtil.h"
#import "UIImage+STUtil.h"


@implementation PHAsset (STUtil)

- (NSString *)localIdentifierClearingPathSeparator {
    return [[self.localIdentifier componentsSeparatedByString:@"/"] firstObject];
}

- (CGSize)pixelSize {
    return CGSizeMake(self.pixelWidth, self.pixelHeight);
}

- (UIImage *)fullResolutionImage{
    __block UIImage * image = nil;
    [[PHImageManager defaultManager] requestImageForAsset:self
                                               targetSize:PHImageManagerMaximumSize
                                              contentMode:PHImageContentModeDefault
                                                  options:[PHImageRequestOptions fullResolutionOptions:YES]
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
        image = result;
    }];
    return image;
}

- (NSData *)fullResolutionData{
    return [self fullResolutionData:nil];
}

- (NSData *)fullResolutionData:(PHImageRequestOptions *(^)(PHImageRequestOptions * defaultOptions))getOptionBlock{
    PHImageRequestOptions * defaultOption = [PHImageRequestOptions fullResolutionOptions:YES];
    NSMutableData * data = [NSMutableData data];

    [[PHImageManager defaultManager] requestImageDataForAsset:self
                                                      options:getOptionBlock ? getOptionBlock(defaultOption) : defaultOption
                                                resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                                                    [data setData:imageData];
                                                }];
    return data;
}

- (UIImage *)fullScreenImage{
    __block UIImage * image = nil;
    [[PHImageManager defaultManager] requestImageForAsset:self
                                               targetSize:[UIScreen mainScreen].bounds.size
                                              contentMode:PHImageContentModeAspectFit
                                                  options:[PHImageRequestOptions fullScreenOptions:YES]
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                image = result;
                                            }];
    return image;
}

- (BOOL)isLivePhoto{
    return self.mediaSubtypes & PHAssetMediaSubtypePhotoLive;
}

- (BOOL)isVideo{
    return self.mediaType==PHAssetMediaTypeVideo;
}

- (void)exportFileTo:(NSURL *)url completion:(void(^)(NSURL * tempFileURL))block{
    //automatic detect by own mediaType and subtype, resource type
}

- (BOOL)exportLivePhotoVideoFile:(void(^)(NSURL * tempFileURL))block{
    NSAssert(self.isLivePhoto, @"this asset is not a LivePhoto.");
    if(self.isLivePhoto){
        [self exportFileByResourceType:PHAssetResourceTypePairedVideo to:nil completion:block];
        return YES;
    }
    return NO;
}

- (void)exportPhotoFileCropIfNeeded:(CGRect)rectToCrop completion:(void(^)(NSURL * tempFileURL))block{
    BOOL croppingRequired = !CGSizeEqualToSize(self.pixelSize, rectToCrop.size);
    if(croppingRequired){
        [self exportFileByResourceType:PHAssetResourceTypePhoto completion:block];
    }else{
        [self exportFileByResourceType:PHAssetResourceTypePhoto completion:^(NSURL *tempFileURL) {
            UIImage * resultImage = [[UIImage imageWithContentsOfFile:tempFileURL.path] imageByCroppingRect:rectToCrop];

            if([resultImage writeDataToURL:tempFileURL]){
                !block?:block(tempFileURL);
            }else{
                !block?:block(nil);
            }
        }];
    }
}

- (void)exportFileByResourceType:(PHAssetResourceType)type completion:(void(^)(NSURL * tempFileURL))block{
    return [self exportFileByResourceType:type to:nil completion:block];
}

- (void)exportFileByResourceType:(PHAssetResourceType)type to:(NSURL *)fileURL completion:(void(^)(NSURL * tempFileURL))block{
    [self exportFileByResourceType:type to:fileURL forceReload:NO completion:block];
}

- (void)exportFileByResourceType:(PHAssetResourceType)type to:(NSURL *)fileURL forceReload:(BOOL)reload completion:(void(^)(NSURL * tempFileURL))block{
    NSParameterAssert(block);

    NSArray * resources = [PHAssetResource assetResourcesForAsset:self];
    PHAssetResource * targetResource = [resources bk_match:^BOOL(PHAssetResource *r) {
        return r.type == type;
    }];

    NSURL * targetURL = fileURL?:[targetResource.originalFilename URLForTemp:@"PHAsset_STUtil_" extension:nil];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[targetURL path]];
    BOOL existsButForcefullyNeededWrite = reload && exists && [[NSFileManager defaultManager] removeItemAtURL:targetURL error:nil];

    if(!exists || existsButForcefullyNeededWrite){
        Weaks
        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:targetResource toFile:targetURL options:nil completionHandler:^(NSError *error) {
            [Wself st_runAsMainQueueAsyncWithoutDeadlocking:^{
                if(!error){
                    block(targetURL);
                }else{
                    block(nil);
                }
            }];
        }];
    }else{
        block(targetURL);
    }
}

@end