//
// Created by BLACKGENE on 2015. 7. 3..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STOrientationItem;
@class STCaptureResponse;
@class STCapturedImageSet;
@class PHAsset;

@interface STPhotoItemSource : NSObject

@property (nonatomic, readonly) STPhotoSourceType type;
//source for image
@property (nonatomic, readonly, nullable) UIImage * image;
@property (nonatomic, readonly, nullable) STCapturedImageSet * imageSet;
@property (nonatomic, readonly, nullable) PHAsset * asset;
//attr
@property (nonatomic, readwrite, nullable) STOrientationItem * orientation;
@property (nonatomic, assign) STPhotoItemOrigin origin;
@property (nonatomic, readwrite, nullable) NSDictionary * metaData;

- (void)dispose;

- (instancetype)initWithResponse:(STCaptureResponse *)response;

+ (instancetype)sourceWithResponse:(STCaptureResponse *)response;

- (instancetype)initWithImageSet:(STCapturedImageSet *)imageSet;

+ (instancetype)sourceWithImageSet:(STCapturedImageSet *)imageSet;

- (instancetype)initWithImage:(UIImage *)image metaData:(NSDictionary *)metaData orientation:(STOrientationItem *)orientation;

+ (instancetype)sourceWithImage:(UIImage *)image metaData:(NSDictionary *)metaData orientation:(STOrientationItem *)orientation;

+ (instancetype)sourceWithImage:(UIImage *)image metaData:(NSDictionary *)metaData;

+ (instancetype)sourceWithImage:(UIImage *)image;

- (instancetype)initWithAsset:(PHAsset *)asset;

+ (instancetype)sourceWithAsset:(PHAsset *)asset;


@end