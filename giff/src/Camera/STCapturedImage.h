//
// Created by BLACKGENE on 4/22/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"
#import "STCapturedResource.h"

@class STCapturedImageSet;

extern NSString * const STCapturedImageFileNameSuffix_Thumbnail;
extern NSString * const STCapturedImageFileNameSuffix_FullScreen;
extern NSString * const STCapturedImageSetDirectory;

@interface STCapturedImage : STCapturedResource
@property (nonatomic, readonly) BOOL hasSource;
//resource
@property (nonatomic, readwrite) UIImage * image;
@property (nonatomic, readwrite) NSURL * imageUrl;
@property (nonatomic, readwrite) NSData * imageData;
//assistant resource
@property (nonatomic, readonly) NSURL * thumbnailUrl;
@property (nonatomic, readonly) NSURL * fullScreenUrl;
//attr
@property (nonatomic, readonly) CGSize pixelSize;
//focus
@property (nonatomic, assign) CGPoint focusPointOfInterestInOutputSize;
@property (nonatomic, assign) float lensPosition;
@property (nonatomic, assign) BOOL focusAdjusted;
//orientation
@property (nonatomic, readonly) UIInterfaceOrientation capturedInterfaceOrientation;
@property (nonatomic, readonly) UIImageOrientation capturedImageOrientation;
@property (nonatomic, readonly) UIDeviceOrientation capturedDeviceOrientation;

+ (void)registerProcessingBlockBeforeSave:(UIImage *(^)(UIImage * savingImage))block;

- (UIImage *)UIImage;

- (instancetype)initWithImage:(UIImage *)image;

+ (instancetype)imageWithImage:(UIImage *)image;

- (NSURL *)NSURL;

- (instancetype)initWithImageUrl:(NSURL *)imageUrl;

+ (instancetype)imageWithImageUrl:(NSURL *)imageUrl;

- (NSData *)NSData;

- (instancetype)initWithImageData:(NSData *)imageData;

+ (instancetype)imageWithImageData:(NSData *)imageData;

- (NSURL *)save:(UIImage *)sourceImage to:(NSURL *)url;

- (BOOL)createFullScreenImage:(NSString *)path;

- (BOOL)createThumbnail:(NSString *)path;

- (BOOL)copySourceByImageOfSameLensPosition:(STCapturedImage *)existImage;

- (void)setOrientationsByCurrent;
@end