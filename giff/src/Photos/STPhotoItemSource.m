// Created by BLACKGENE on 2015. 7. 3..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Photos/Photos.h>
#import "STPhotoItemSource.h"
#import "STCaptureResponse.h"
#import "STOrientationItem.h"
#import "STCapturedImageSet.h"
#import "STCaptureRequest.h"
#import "STCapturedImage.h"

@implementation STPhotoItemSource {

    UIImage * _image;
}

- (void)dealloc {
    [self dispose];
}

- (void)dispose{
    _imageSet = nil;
    _image = nil;
    _metaData = nil;
    self.orientation = nil;
}

- (UIImage *)image {
    NSAssert(_image || _imageSet, @"image or imageSet must be available");
    if(!_image && _imageSet){
        return [_imageSet.defaultImage UIImage];
    }
    return _image;
}

- (instancetype)initWithImage:(UIImage *)image metaData:(NSDictionary *)metaData orientation:(STOrientationItem *)orientation {
    self = [super init];
    if (self) {
        NSParameterAssert(image);
        NSAssert(!orientation || image.imageOrientation==orientation.imageOrientation,@"MUST BE SAME with image.imageOrientation, orientation.imageOrientation");

        _type = STPhotoSourceTypeImage;
        _image = image;
        _metaData = metaData;
        self.orientation = orientation;
    }
    return self;
}

- (instancetype)initWithResponse:(STCaptureResponse *)response {
    self = [self initWithImageSet:response.imageSet];
    if (self) {
        NSAssert(response.imageSet,@"STCaptureResponse's imageSet is nil");
        _image = response.imageSet.defaultImage.image;
        _origin = response.request.origin;
        _orientation = response.orientation;
        _metaData = response.metaData;
    }
    return self;
}

+ (instancetype)sourceWithResponse:(STCaptureResponse *)response {
    return [[self alloc] initWithResponse:response];
}

- (instancetype)initWithImageSet:(STCapturedImageSet *)imageSet {
    self = [super init];
    if (self) {
        NSParameterAssert(imageSet);
        NSAssert(imageSet.defaultImage,@"Any image was not found");
        _type = STPhotoSourceTypeCapturedImageSet;
        _imageSet = imageSet;
    }
    return self;
}

- (instancetype)initWithAsset:(PHAsset *)asset {
    self = [super init];
    if (self) {
        _type = STPhotoSourceTypeAsset;
        _asset = asset;
    }

    return self;
}

+ (instancetype)sourceWithAsset:(PHAsset *)asset {
    return [[self alloc] initWithAsset:asset];
}


+ (instancetype)sourceWithImageSet:(STCapturedImageSet *)imageSet {
    return [[self alloc] initWithImageSet:imageSet];
}

+ (instancetype)sourceWithImage:(UIImage *)image metaData:(NSDictionary *)metaData orientation:(STOrientationItem *)orientation {
    return [[self alloc] initWithImage:image metaData:metaData orientation:orientation];
}

+ (instancetype)sourceWithImage:(UIImage *)image metaData:(NSDictionary *)metaData{
    return [[self alloc] initWithImage:image metaData:metaData orientation:nil];
}

+ (instancetype)sourceWithImage:(UIImage *)image {
    return [[self alloc] initWithImage:image metaData:nil orientation:nil];
}

@end