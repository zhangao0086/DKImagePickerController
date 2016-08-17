//
// Created by BLACKGENE on 8/3/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Photos/Photos.h>
#import "STCapturedImageSet+PHAsset.h"
#import "PHAsset+STUtil.h"
#import "STCapturedImage.h"
#import "NSGIF.h"
#import "STCapturedImageSetProtected.h"


@implementation STCapturedImageSet (PHAsset)

static CGSize defaultAspectFillRatio;
+ (void)setDefaultAspectFillRatioForAssets:(CGSize)aspectRatio {
    defaultAspectFillRatio = aspectRatio;
}

static NSTimeInterval maxFrameDurationIfAssetHadAnimatableContents;
+ (void)setMaxFrameDurationIfAssetHadAnimatableContents:(NSTimeInterval)count {
    maxFrameDurationIfAssetHadAnimatableContents = count;
}

+ (void)createFromAssets:(NSArray<PHAsset *> *)assets completion:(void(^)(NSArray<STCapturedImageSet *>* imageSets))block{
    NSParameterAssert(assets.count);
    NSParameterAssert(block);

    NSMutableArray<STCapturedImageSet *> * imageSets = [NSMutableArray<STCapturedImageSet *> array];
    NSUInteger totalCount = assets.count;
    for(PHAsset * asset in assets){
        if([self createFromAsset:asset completion:^(STCapturedImageSet *imageSet) {
            [imageSets addObject:imageSet];

            if(imageSets.count==totalCount){
                block(imageSets);
            }
        }]){
            totalCount--;
            continue;
        }
    }
    
    if(totalCount==0){
        block(nil);
    }
}


+ (BOOL)createFromAsset:(PHAsset *)asset completion:(void(^)(STCapturedImageSet * imageSet))block{
    NSParameterAssert(block);

    if(asset.isVideo){
        [asset exportFileByResourceType:PHAssetResourceTypeVideo completion:^(NSURL *tempFileURL) {
            [self createFromVideo:tempFileURL completion:block];
        }];
        return YES;
    }

    if(asset.mediaType==PHAssetMediaTypeImage){
        if(asset.isLivePhoto){
            [asset exportLivePhotoVideoFile:^(NSURL *tempFileURL) {
                [self createFromVideo:tempFileURL completion:block];
            }];

        }else{
            [asset exportPhotoFileCropIfNeeded:CGRectCropRegionAspectFill([asset pixelSize], defaultAspectFillRatio) completion:^(NSURL *tempFileURL) {
                !block ?: block([STCapturedImageSet setWithImages:@[[STCapturedImage imageWithImageUrl:tempFileURL]]]);
            }];
        }

        return YES;
    }

    !block?:block(nil);
    return NO;
}

+ (void)createFromVideo:(NSURL *)url completion:(void(^)(STCapturedImageSet * imageSet))block{
    NSFrameExtractingRequest * request = [NSFrameExtractingRequest new];
    request.framesPerSecond = 6;
    request.maxDuration = maxFrameDurationIfAssetHadAnimatableContents;
    request.sourceVideoFile = url;
    request.aspectRatioToCrop = defaultAspectFillRatio;

    [NSGIF extract:request completion:^(NSArray *array) {
        STCapturedImageSet * imageSet = [STCapturedImageSet setWithImageURLs:array];
        imageSet.type = STCapturedImageSetTypeAnimatable;
        block(imageSet);
    }];
}

@end