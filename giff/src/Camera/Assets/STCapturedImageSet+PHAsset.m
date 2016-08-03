//
// Created by BLACKGENE on 8/3/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Photos/Photos.h>
#import "STCapturedImageSet+PHAsset.h"
#import "PHAsset+STUtil.h"
#import "STCapturedImage.h"


@implementation STCapturedImageSet (PHAsset)


+ (BOOL)createFromAsset:(PHAsset *)asset completion:(void(^)(STCapturedImageSet * imageSet))block{
    NSParameterAssert(block);

    if(asset.isVideo){
        [asset exportFileByResourceType:PHAssetResourceTypeVideo completion:^(NSURL *tempFileURL) {

        }];
        return YES;
    }

    if(asset.mediaType==PHAssetMediaTypeImage){
        if(asset.isLivePhoto){
            [asset exportLivePhotoVideoFile:^(NSURL *tempFileURL) {

            }];

        }else{
            [asset exportFileByResourceType:PHAssetResourceTypePhoto completion:^(NSURL *tempFileURL) {
                !block?:block([STCapturedImageSet setWithImages:@[[STCapturedImage imageWithImageUrl:tempFileURL]]]);
            }];
        }

        return YES;
    }

    !block?:block(nil);
    return NO;
}

@end