//
// Created by BLACKGENE on 4/22/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STCapturedImage.h"
#import "NSString+STUtil.h"
#import "NYXImagesKit.h"
#import "UIImage+STUtil.h"
#import "STCapturedImageProtected.h"
#import "STMotionManager.h"
#import "STQueueManager.h"

NSString * const STCapturedImageFileNameSuffix_Thumbnail = @"_t";
NSString * const STCapturedImageFileNameSuffix_FullScreen = @"_s";
NSString * const STCapturedImageSetDirectory = @"imagesets";

@implementation STCapturedImage {

}

static UIImage *(^ProcessingBlockBeforeSave)(UIImage *);
+ (void)registerProcessingBlockBeforeSave:(UIImage *(^)(UIImage *))block {
    ProcessingBlockBeforeSave = block;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.createdTime = [NSDate timeIntervalSinceReferenceDate];
    }
    return self;
}

- (void)dealloc {
    self.image = nil;
    self.imageData = nil;
    self.imageUrl = nil;
}

#pragma mark Resource
- (BOOL)hasSource {
    return self.image || self.imageData || self.imageUrl;
}

#pragma mark Resource - UIImage
- (UIImage *)UIImage {
    @autoreleasepool {
        if(self.image){
            return self.image;
        }else if(self.imageData){
            return [UIImage imageWithData:self.imageData];
        }else if(self.imageUrl){
            return [UIImage imageWithContentsOfFile:self.imageUrl.path];
        };
        return nil;
    }
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [self init];
    if (self) {
        self.image = image;
    }
    return self;
}

+ (instancetype)imageWithImage:(UIImage *)image {
    return [[self alloc] initWithImage:image];
}

- (void)setImage:(UIImage *)image {
    NSAssert(image.images.count<=1,@"STCaptureResponseImage not allowed animatedImages");
    _image = image;
}

#pragma mark Resource - NSURL
- (NSURL *)NSURL {
    if(self.imageUrl){
        return self.imageUrl;
    }

    NSURL * url = [self.uuid URLForTemp:@"jpg"];
    if(self.image){
        return [UIImageJPEGRepresentation(self.image, 1) writeToURL:url atomically:YES] ? url : nil;
    }else if(self.imageData){
        return [self.imageData writeToURL:url atomically:YES] ? url : nil;
    }
    return nil;
}

- (instancetype)initWithImageUrl:(NSURL *)imageUrl {
    self = [super init];
    if (self) {
        self.imageUrl = imageUrl;
    }

    return self;
}

+ (instancetype)imageWithImageUrl:(NSURL *)imageUrl {
    return [[self alloc] initWithImageUrl:imageUrl];
}

#pragma mark Resource - NSData
- (NSData *)NSData {
    @autoreleasepool {
        if(self.imageData){
            return self.imageData;
        }else if(self.image){
            return UIImageJPEGRepresentation(self.image, 1);
        }else if(self.imageUrl){
            return [NSData dataWithContentsOfURL:self.imageUrl];
        }
        return nil;
    }
}

- (instancetype)initWithImageData:(NSData *)imageData {
    self = [super init];
    if (self) {
        self.imageData = imageData;
    }
    return self;
}

+ (instancetype)imageWithImageData:(NSData *)imageData {
    return [[self alloc] initWithImageData:imageData];
}

#pragma mark File I/O
//TODO: 필터가 있을때는 필터를 굽고 url를 교체

- (NSURL *)save:(UIImage *)sourceImage to:(NSURL *)url{
    NSParameterAssert(sourceImage);
    _pixelSize = [sourceImage sizeWithRasterizationScale];

    NSURL * fileURL = url ?: [self.uuid URLForTemp:@"jpg"];

    //TODO: 성능은 향상되지만 촬영 직후 previewImage를 못 읽어오거나 즉시 저장하지 못하는 리스크가 있음
    dispatch_async([[STQueueManager sharedQueue] writingIO], ^{
        @autoreleasepool {
            [UIImageJPEGRepresentation(ProcessingBlockBeforeSave ? ProcessingBlockBeforeSave(sourceImage) : sourceImage, .8) writeToURL:fileURL atomically:YES];
        }
    });

    return (_imageUrl = fileURL);
}

- (BOOL)createFullScreenImage:(NSString *)path{
    if(self.fullScreenUrl){
        oo(@"[!] WARNING : self.thumbnailUrl already exists, but tried create thumbnail.");
    }

    _fullScreenUrl = [[self _createResizedImage:path suffix:STCapturedImageFileNameSuffix_FullScreen sizeInScreen:[self _screenSizeForResizedImage:1] quality:.7] fileURL];
    return _fullScreenUrl != nil;
}

- (BOOL)createThumbnail:(NSString *)path{
    if(self.thumbnailUrl){
        oo(@"[!] WARNING : self.thumbnailUrl already exists, but tried create thumbnail.");
    }

    _thumbnailUrl = [[self _createResizedImage:path suffix:STCapturedImageFileNameSuffix_Thumbnail sizeInScreen:[self _screenSizeForResizedImage:.5f] quality:.6] fileURL];
    return _thumbnailUrl != nil;
}

- (CGSize)_screenSizeForResizedImage:(CGFloat)scaleRatio{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return CGSizeMakeValue( MIN(screenSize.width,screenSize.height) * (scaleRatio ?: 1));
}

- (NSString *)_createResizedImage:(NSString *)path suffix:(NSString *)suffix sizeInScreen:(CGSize)sizeInScreen quality:(float const)quality{
    NSAssert(self.imageUrl.path,@"self.imageUrl.path is nil");

    @autoreleasepool {
        if(!path){
            path = [self.imageUrl.path stringByAppendingSuffixOfLastPathComponent:suffix];
        }

        CGSize const resizedImageSize = CGSizeByScale(sizeInScreen, TwiceMaxScreenScale());
        UIImage * resizedImage = [[UIImage imageWithContentsOfFile:self.imageUrl.path] scaleToFitSize:resizedImageSize];
        NSAssert(resizedImage,@"image is nil");
        if([UIImageJPEGRepresentation(resizedImage, quality) writeToFile:path atomically:NO]){
            NSAssert([[NSFileManager defaultManager] fileExistsAtPath:path], @"file does not exist");
            return path;
        }
        NSAssert(NO,@"Resized image creation failed");
        return nil;
    }
}

#pragma mark Helpers
- (BOOL)copySourceByImageOfSameLensPosition:(STCapturedImage *)existImage {
    NSAssert(existImage.hasSource, @"existImage has no source for image");
    if(existImage && existImage.hasSource){
        self.lensPosition = existImage.lensPosition;
        self.focusAdjusted = existImage.focusAdjusted;
        self.image = existImage.image;
        self.imageData = existImage.imageData;
        self.imageUrl = existImage.imageUrl;
        _capturedImageOrientation = existImage.capturedImageOrientation;
        _capturedInterfaceOrientation = existImage.capturedInterfaceOrientation;
        _capturedDeviceOrientation = existImage.capturedDeviceOrientation;
        _thumbnailUrl = existImage.thumbnailUrl;
        _fullScreenUrl = existImage.fullScreenUrl;
        _pixelSize = existImage.pixelSize;
        return YES;
    }
    return NO;
}

#pragma mark Orientation
- (void)setOrientationsByCurrent {
    STMotionManager * motionManager = [STMotionManager sharedManager];
    _capturedImageOrientation = motionManager.imageOrientation;
    _capturedInterfaceOrientation = motionManager.interfaceOrientation;
    _capturedDeviceOrientation = motionManager.deviceOrientation;
}
@end