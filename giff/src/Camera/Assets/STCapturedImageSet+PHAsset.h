//
// Created by BLACKGENE on 8/3/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCapturedImageSet.h"

@class PHAsset;

@interface STCapturedImageSet (PHAsset)

+ (void)setDefaultAspectFillRatioForAssets:(CGSize)aspectRatio;

+ (void)setMaxFrameDurationIfAssetHadAnimatableContents:(NSTimeInterval)duration;

+ (void)createFromAssets:(NSArray<PHAsset *> *)assets completion:(void (^)(NSArray<STCapturedImageSet *> *imageSets))block;

+ (BOOL)createFromAsset:(PHAsset *)asset completion:(void (^)(STCapturedImageSet *imageSet))block;

+ (void)createFromVideo:(NSURL *)url completion:(void (^)(STCapturedImageSet *imageSet))block;
@end