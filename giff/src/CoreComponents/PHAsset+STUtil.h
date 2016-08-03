//
// Created by BLACKGENE on 2016. 3. 28..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface PHAsset (STUtil)
- (UIImage *)fullResolutionImage;

- (NSData *)fullResolutionData;

- (UIImage *)fullScreenImage;

- (BOOL)isLivePhoto;

- (BOOL)isVideo;

- (BOOL)exportLivePhotoVideoFile:(void (^)(NSURL *tempFileURL))block;

- (void)exportFileByResourceType:(PHAssetResourceType)type completion:(void (^)(NSURL *tempFileURL))block;

- (void)exportFileByResourceType:(PHAssetResourceType)type to:(NSURL *)fileURL completion:(void (^)(NSURL *tempFileURL))block;

- (void)exportFileByResourceType:(PHAssetResourceType)type to:(NSURL *)fileURL forceReload:(BOOL)reload completion:(void (^)(NSURL *tempFileURL))block;
@end