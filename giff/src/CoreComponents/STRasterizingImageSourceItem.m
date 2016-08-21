//
// Created by BLACKGENE on 8/21/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STRasterizingImageSourceItem.h"
#import "SVGKImage.h"
#import "NSString+STUtil.h"
#import "SVGKImage+STUtil.h"
#import "UIImage+STUtil.h"
#import "NSObject+STUtil.h"
#import "CALayer+STUtil.h"
#import "NSArray+STUtil.h"


@implementation STRasterizingImageSourceItem {

}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.image = image;
    }

    return self;
}

- (instancetype)initWithLayer:(CALayer *)layer {
    self = [super init];
    if (self) {
        self.layer = layer;
    }

    return self;
}

- (instancetype)initWithUrl:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
    }

    return self;
}

- (instancetype)initWithBundleFileName:(NSString *)bundleName {
    self = [super init];
    if (self) {
        self.bundleFileName = bundleName;
    }

    return self;
}

+ (instancetype)itemWithBundleFileName:(NSString *)bundleName {
    return [[self alloc] initWithBundleFileName:bundleName];
}


+ (instancetype)itemWithUrl:(NSURL *)url {
    return [[self alloc] initWithUrl:url];
}


+ (instancetype)itemWithLayer:(CALayer *)layer {
    return [[self alloc] initWithLayer:layer];
}


+ (instancetype)itemWithImage:(UIImage *)image {
    return [[self alloc] initWithImage:image];
}


- (UIImage *)rasterize:(CGSize)imageSize{
    NSParameterAssert(self.image || self.url || self.bundleFileName || self.layer);
    NSAssert([[self.st_propertyNames mapWithIndex:^id(id object, NSInteger index) {
        return [self valueForKey:object];
    }] containsNull]==3,@"Must provide 1 property.");

    if(self.image){
#if DEBUG
        if(!CGSizeEqualToSize(self.layer.size, imageSize)){
            oo(@"[!]WARN: Size of image is not matched with given image size.");
        }
#endif
        return self.image;
    }
    

    /*
     * CALayer
     */
    if(self.layer){
#if DEBUG
        if(!CGSizeEqualToSize(self.layer.size, imageSize)){
            oo(@"[!]WARN: Given CALayer's size must be same as given imageSize");
        }
#endif
        return [self.layer UIImage:self.layerShouldOpaque];
    }

    /*
     * url, bundleName
     */
    NSString * lastPathComponent = nil;
    if(self.url) {
        NSAssert([self.url isFileURL], @"Given url is not file url.");
        NSAssert([[NSFileManager defaultManager] fileExistsAtPath:self.url.path isDirectory:NO], @"Given url does not exists.");
        lastPathComponent = [self.url lastPathComponent];
    }

    if(self.bundleFileName){
        lastPathComponent = self.bundleFileName;
    }

    if(lastPathComponent){
        NSString * mimeTypeForPatternImage = [lastPathComponent mimeTypeFromPathExtension];

        //TODO: unify all obj types that origanated from various file type. (remove all if statements)
        if([@"image/svg+xml" isEqualToString:mimeTypeForPatternImage]){
            if(self.url) {
                return [[SVGKImage imageURLNoCache:self.url widthSizeWidth:imageSize.width] UIImage];
            }else if(self.bundleFileName){
                return [[SVGKImage imageNamedNoCache:self.bundleFileName widthSizeWidth:imageSize.width] UIImage];
            }else{
                NSAssert(NO, @"Given property does not support yet.");
            }

        }else if([@"image/png" isEqualToString:mimeTypeForPatternImage]
                || [@"image/jpeg" isEqualToString:mimeTypeForPatternImage]){

            if(self.url) {
                return [UIImage imageWithURL:self.url];
            }else if(self.bundleFileName){
                return [UIImage imageBundled:self.bundleFileName];
            }else{
                NSAssert(NO, @"Given property does not support yet.");
            }

        }else{
            NSAssert(NO, ([mimeTypeForPatternImage st_add:@" is not supported file format"]));
        }
    }

    NSAssert(NO, @"result image is empty.");
    return nil;
}

@end