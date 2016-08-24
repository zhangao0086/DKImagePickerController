//
// Created by BLACKGENE on 8/21/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"

//TODO: add cache based on resource's exact identification.
@interface STRasterizingImageSourceItem : STItem
@property (nonatomic, readwrite) UIImage * image;

@property (nonatomic, readwrite) CALayer * layer;
@property (nonatomic, assign) BOOL layerShouldOpaque;

@property (nonatomic, readwrite) NSURL * url;
@property (nonatomic, readwrite) NSString * bundleFileName;

//an image that used as a mask image must be filled out black and white color on both sides, background and foreground.
- (UIImage *)rasterize:(CGSize)imageSize;

- (instancetype)initWithImage:(UIImage *)image;

+ (instancetype)itemWithImage:(UIImage *)image;

- (instancetype)initWithLayer:(CALayer *)layer;

+ (instancetype)itemWithLayer:(CALayer *)layer;

- (instancetype)initWithUrl:(NSURL *)url;

+ (instancetype)itemWithUrl:(NSURL *)url;

- (instancetype)initWithBundleFileName:(NSString *)bundleName;

+ (instancetype)itemWithBundleFileName:(NSString *)bundleName;

@end