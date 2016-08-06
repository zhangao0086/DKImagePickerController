//
// Created by BLACKGENE on 8/3/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Photos/Photos.h>
#import "STCapturedImageSet+PHAsset.h"
#import "PHAsset+STUtil.h"
#import "STCapturedImage.h"
#import "NSGIF.h"
#import "NSURL+STUtil.h"
#import "NSString+STUtil.h"


@implementation STCapturedImageSet (PHAsset)

static CGSize defaultAspectFillRatio;
+ (void)setDefaultAspectFillRatioForAssets:(CGSize)aspectRatio {
    defaultAspectFillRatio = aspectRatio;
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

    NSFrameExtractingRequest * request = [NSFrameExtractingRequest new];
    request.framesPerSecond = 4;

    if(asset.isVideo){
        [asset exportFileByResourceType:PHAssetResourceTypeVideo completion:^(NSURL *tempFileURL) {
            request.sourceVideoFile = tempFileURL;
            request.aspectRatioToCrop = defaultAspectFillRatio;
            [NSGIF extract:request completion:^(NSArray *array) {
                block([STCapturedImageSet setWithImageURLs:array]);
            }];
        }];
        return YES;
    }

    if(asset.mediaType==PHAssetMediaTypeImage){
        if(asset.isLivePhoto){
            [asset exportLivePhotoVideoFile:^(NSURL *tempFileURL) {
                request.sourceVideoFile = tempFileURL;
                request.aspectRatioToCrop = defaultAspectFillRatio;
                [NSGIF extract:request completion:^(NSArray *array) {
                    block([STCapturedImageSet setWithImageURLs:array]);
                }];
            }];

        }else{
            CGRect const rectRegionToCrop = CGRectCropRegionAspectFill([asset pixelSize], defaultAspectFillRatio);
            BOOL croppingRequired = !CGSizeEqualToSize(asset.pixelSize, rectRegionToCrop.size);

            [asset exportFileByResourceType:PHAssetResourceTypePhoto completion:^(NSURL *tempFileURL) {
                if(croppingRequired){
                    UIImage * image = [UIImage imageWithContentsOfFile:tempFileURL.path];

                    CGImageRef croppedImage = CGImageCreateWithImageInRect([image CGImage], rectRegionToCrop);
                    UIImage * resultImage = [UIImage imageWithCGImage:croppedImage scale:image.scale orientation:image.imageOrientation];
                    CGImageRelease(croppedImage);

                    NSData * imageData = nil;
                    if([@"image/png" isEqualToString:[[tempFileURL path] mimeTypeFromPathExtension]]){
                        imageData = UIImagePNGRepresentation(resultImage);
                    }else{
                        imageData = UIImageJPEGRepresentation(resultImage, 1);
                    }

                    if([imageData writeToURL:tempFileURL atomically:YES]){
                        !block?:block([STCapturedImageSet setWithImages:@[[STCapturedImage imageWithImageUrl:tempFileURL]]]);
                    }else{
                        !block?:block(nil);
                    }
                }else{
                    !block?:block([STCapturedImageSet setWithImages:@[[STCapturedImage imageWithImageUrl:tempFileURL]]]);
                }
            }];
        }

        return YES;
    }

    !block?:block(nil);
    return NO;
}


@end