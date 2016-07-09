//
// Created by BLACKGENE on 4/29/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "RLMCapturedImage.h"
#import "STCapturedImage.h"
#import "NSArray+STUtil.h"
#import "NSNumber+STUtil.h"
#import "STCapturedImageSet.h"
#import "NSString+STUtil.h"
#import "STCapturedImageSetProtected.h"
#import "STCapturedImageProtected.h"
#import "STApp+Logger.h"

#pragma mark RLMCapturedResource
@implementation RLMCapturedResource{
}

+ (instancetype)imageWithCapturedResource:(STCapturedResource *)capturedResource{
    return [[self alloc] initWithCapturedResource:capturedResource];
}

- (instancetype)initWithCapturedResource:(STCapturedResource *)capturedResource{
    self = [super init];
    if (self) {
        NSParameterAssert(capturedResource);
        NSParameterAssert(capturedResource.uuid);
        NSParameterAssert(capturedResource.createdTime);
        self.uuid = capturedResource.uuid;
        self.createdTime = capturedResource.createdTime;
        self.extensionData = [NSKeyedArchiver archivedDataWithRootObject:capturedResource.extensionObject];
    }
    return self;
}

- (void)loadResource:(STCapturedResource *)resource{
    NSParameterAssert(self.uuid);
    NSParameterAssert(self.createdTime);
    NSParameterAssert(self.savedTime);
    resource.uuid = self.uuid;
    resource.createdTime = self.createdTime;
    resource.savedTime = self.savedTime;
    resource.extensionObject = [NSKeyedUnarchiver unarchiveObjectWithData:self.extensionData];
}
@end

#pragma mark RLMCapturedImage

@implementation RLMCapturedImage{
    STCapturedImage * __weak _capturedImage;
}

+ (instancetype)imageWithCapturedImage:(STCapturedImage *)capturedImage parentSet:(RLMCapturedImageSet *)imageSet{
    return [[self alloc] initWithCapturedImage:capturedImage parentSet:imageSet];
}

- (instancetype)initWithCapturedImage:(STCapturedImage *)capturedImage parentSet:(RLMCapturedImageSet *)imageSet{
    self = [super initWithCapturedResource:capturedImage];
    if (self) {
        NSParameterAssert(imageSet);
        NSParameterAssert(capturedImage.imageUrl.path);
        NSParameterAssert(!CGSizeEqualToSize(capturedImage.pixelSize, CGSizeZero));
        _capturedImage = capturedImage;

        self.parentSet = imageSet;

        self.pixelSize = NSStringFromCGSize(capturedImage.pixelSize);

        self.lensPosition = capturedImage.lensPosition;
        self.focusAdjusted = capturedImage.focusAdjusted;
        self.focusPointOfInterestInOutputSize = NSStringFromCGPoint(capturedImage.focusPointOfInterestInOutputSize);

        self.capturedImageOrientation = capturedImage.capturedImageOrientation;
        self.capturedInterfaceOrientation = capturedImage.capturedInterfaceOrientation;
        self.capturedDeviceOrientation = capturedImage.capturedDeviceOrientation;
    }
    return self;
}

- (STCapturedImage *)fetchImage{
    NSParameterAssert(self.imagePathForDocument);
    NSParameterAssert(self.savedTime);

    STCapturedImage * image = [STCapturedImage imageWithImageUrl:[[self.imagePathForDocument absolutePathFromDocument] fileURL]];
    [self loadResource:image];

    image.thumbnailUrl = [[[self thumbnailPathForDocument] absolutePathFromDocument] fileURL];
    image.fullScreenUrl = [[[self fullScreenPathForDocument] absolutePathFromDocument] fileURL];

    image.pixelSize = CGSizeFromString(self.pixelSize);
    NSParameterAssert(!CGSizeEqualToSize(CGSizeZero, image.pixelSize));

    image.lensPosition = self.lensPosition;
    image.focusAdjusted = self.focusAdjusted;
    image.focusPointOfInterestInOutputSize = CGPointFromString(self.focusPointOfInterestInOutputSize);

    image.capturedImageOrientation = (UIImageOrientation) self.capturedImageOrientation;
    image.capturedInterfaceOrientation = (UIInterfaceOrientation) self.capturedInterfaceOrientation;
    image.capturedDeviceOrientation = (UIDeviceOrientation) self.capturedDeviceOrientation;
    return image;
}

+ (NSString *)primaryKey {
    return @"uuid";
}

+ (NSArray *)indexedProperties {
    return @[@"uuid"];
}

#pragma mark Files
- (NSString *)createDirectoryInDocument {
    return [self.parentSet createDirectoryInDocument];
}

- (NSString *)writeFile {
    NSString * imageSetRelativePath = nil;
    if((imageSetRelativePath = [self createDirectoryInDocument])){
        NSString * imageFileName = [self.uuid stringByAppendingPathExtension:@"jpg"];
        NSString * destFileAbsolutePath = [[imageSetRelativePath absolutePathFromDocument] stringByAppendingPathComponent:imageFileName];
        NSError *writeFileError = nil;

        NSAssert(_capturedImage.imageUrl,@"capturedImage.imageUrl is nil");
        if([[NSFileManager defaultManager] copyItemAtPath:_capturedImage.imageUrl.path toPath:destFileAbsolutePath error:&writeFileError]){
            NSAssert([[NSFileManager defaultManager] fileExistsAtPath:destFileAbsolutePath], @"file does not exist");

            //save main url
            self.imagePathForDocument = [imageSetRelativePath stringByAppendingPathComponent:imageFileName];

            //save thumbnail
            NSString * const thumbnail_ImagePathForDocument = [self.imagePathForDocument stringByAppendingSuffixOfLastPathComponent:STCapturedImageFileNameSuffix_Thumbnail];
            NSString * const absolute_thumbnail_ImagePathForDocument = [thumbnail_ImagePathForDocument absolutePathFromDocument];
            if(_capturedImage.thumbnailUrl){
                if([[NSFileManager defaultManager] copyItemAtPath:_capturedImage.thumbnailUrl.path toPath:absolute_thumbnail_ImagePathForDocument error:NULL]){
                    self.thumbnailPathForDocument = thumbnail_ImagePathForDocument;
                }
            }else{
                if([_capturedImage createThumbnail:absolute_thumbnail_ImagePathForDocument]){
                    self.thumbnailPathForDocument = thumbnail_ImagePathForDocument;
                }
            }
            NSAssert(self.thumbnailPathForDocument, @"thumbnailPathForDocument does not exists");

            //save full screen image
            NSString * const fullScreen_ImagePathForDocument = [self.imagePathForDocument stringByAppendingSuffixOfLastPathComponent:STCapturedImageFileNameSuffix_FullScreen];
            NSString * const absolute_fullScreen_ImagePathForDocument = [fullScreen_ImagePathForDocument absolutePathFromDocument];
            if(_capturedImage.fullScreenUrl){
                if([[NSFileManager defaultManager] copyItemAtPath:_capturedImage.fullScreenUrl.path toPath:absolute_fullScreen_ImagePathForDocument error:NULL]){
                    self.fullScreenPathForDocument = fullScreen_ImagePathForDocument;
                }
            }else{
                if([_capturedImage createFullScreenImage:absolute_fullScreen_ImagePathForDocument]){
                    self.fullScreenPathForDocument = fullScreen_ImagePathForDocument;
                }
            }
            NSAssert(self.fullScreenPathForDocument, @"fullScreenPathForDocument does not exists");

            //save time
            self.savedTime = [NSDate timeIntervalSinceReferenceDate];

            return self.imagePathForDocument;
        }

        /*
         * Error
         */
        if(![[NSFileManager defaultManager] fileExistsAtPath:_capturedImage.imageUrl.path]){
            [STApp logError:@"RLMCapturedImage.writeFile.copyItemAtPath.sourceImageFileDoesNotExist"];
        }else{
            [STApp logError:[@"RLMCapturedImage.writeFile.copyItemAtPath." st_add:[writeFileError description]]];
        }

        NSAssert(NO, @"writeFile failed before db access");
    }
    return nil;
}

- (BOOL)deleteFile {
    NSError * error;
    NSParameterAssert(self.imagePathForDocument);
    if(self.imagePathForDocument){
        [[NSFileManager defaultManager] removeItemAtPath:[self.imagePathForDocument absolutePathFromDocument] error:&error];
    }
    NSParameterAssert(self.thumbnailPathForDocument);
    if(self.thumbnailPathForDocument){
        [[NSFileManager defaultManager] removeItemAtPath:[self.thumbnailPathForDocument absolutePathFromDocument] error:&error];
    }
    if(self.fullScreenPathForDocument){
        [[NSFileManager defaultManager] removeItemAtPath:[self.fullScreenPathForDocument absolutePathFromDocument] error:&error];
    }
    return error==nil;
}

- (BOOL)isFileExist {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self.imagePathForDocument absolutePathFromDocument]];
}


@end

#pragma mark RLMCapturedImageSet
@implementation RLMCapturedImageSet
- (instancetype)initWithCapturedImageSet:(STCapturedImageSet *)capturedImageSet {
    self = [super initWithCapturedResource:capturedImageSet];
    if (self) {
        NSParameterAssert(capturedImageSet.type!=STCapturedImageSetTypeUnspecified);
        NSParameterAssert(capturedImageSet.images.count);

        self.type = capturedImageSet.type;

        self.indexOfDefaultImage = capturedImageSet.indexOfDefaultImage;

        self.indexOfFocusPointsOfInterestSet = capturedImageSet.indexOfFocusPointsOfInterestSet;
        self.outputSizeForFocusPoints = NSStringFromCGSize(capturedImageSet.outputSizeForFocusPoints);

        //focusPointsOfInterestSet
        RLMArray * focusPointsOfInterestSet = [[RLMArray alloc] initWithObjectClassName:NSStringFromClass(RLMCGPoint.class)];
        [focusPointsOfInterestSet addObjects:[capturedImageSet.focusPointsOfInterestSet mapWithIndex:^id(id object, NSInteger index) {
            return [RLMCGPoint pointWithCGPoint:[object CGPointValue]];
        }]];
        self.focusPointsOfInterestSet = (RLMArray <RLMCGPoint> *) focusPointsOfInterestSet;

        //images
        RLMArray * images = [[RLMArray alloc] initWithObjectClassName:NSStringFromClass(RLMCapturedImage.class)];
        [images addObjects:[capturedImageSet.images mapWithIndex:^id(STCapturedImage * image, NSInteger index) {
            return [RLMCapturedImage imageWithCapturedImage:image parentSet:self];
        }]];
        self.images = (RLMArray <RLMCapturedImage> *) images;

    }
    return self;
}

+ (instancetype)setWithCapturedImageSet:(STCapturedImageSet *)capturedImageSet {
    return [[self alloc] initWithCapturedImageSet:capturedImageSet];
}

- (STCapturedImageSet *)fetchImageSet{
    NSParameterAssert(self.images.count);

    STCapturedImageSet * imageSet = [STCapturedImageSet setWithImages:[[@([self.images count]) st_intArray] mapWithIndex:^id(id object, NSInteger index) {
        RLMCapturedImage * rlm_image = [self.images objectAtIndex:[object unsignedIntegerValue]];
        return [rlm_image fetchImage];
    }]];

    [self loadResource:imageSet];

    imageSet.type = (STCapturedImageSetType) self.type;
    imageSet.indexOfDefaultImage = (NSUInteger) self.indexOfDefaultImage;

    imageSet.indexOfFocusPointsOfInterestSet = (NSUInteger) self.indexOfFocusPointsOfInterestSet;
    imageSet.outputSizeForFocusPoints = CGSizeFromString(self.outputSizeForFocusPoints);

    //focusPointsOfInterestSet
    NSArray<NSValue *> * points = [[@([self.focusPointsOfInterestSet count]) st_intArray] mapWithIndex:^id(id object, NSInteger index) {
        RLMCGPoint * pointValue = [self.focusPointsOfInterestSet objectAtIndex:[object unsignedIntegerValue]];
        return [NSValue valueWithCGPoint:CGPointFromString(pointValue.CGPointString)];
    }];
    imageSet.focusPointsOfInterestSet = points;

    return imageSet;
}

+ (NSString *)primaryKey {
    return @"uuid";
}

+ (NSArray *)indexedProperties {
    return @[@"uuid",@"type"];
}

- (NSString *)createDirectoryInDocument{
    BOOL isDir = YES;
    NSString * imageSetRelativePath = [STCapturedImageSetDirectory stringByAppendingPathComponent:self.uuid];
    NSString * absoluteImageSetPath = [imageSetRelativePath absolutePathFromDocument];

    BOOL dirExists = [[NSFileManager defaultManager] fileExistsAtPath:absoluteImageSetPath isDirectory:&isDir];
    NSError * dirCreateError = nil;
    if(dirExists || [[NSFileManager defaultManager] createDirectoryAtPath:absoluteImageSetPath withIntermediateDirectories:YES attributes:nil error:&dirCreateError]){
        self.imageSetPathForDocument = imageSetRelativePath;
        return imageSetRelativePath;
    }

    [STApp logError:[@"RLMCapturedImage.createDirectoryInDocument." st_add:[dirCreateError description]]];
    return nil;
}

- (NSString *)writeFile {
    for (RLMCapturedImage * image in self.images){
        if(![image writeFile]){
            return nil;
        }
    }
    self.savedTime = [NSDate timeIntervalSinceReferenceDate];
    return self.imageSetPathForDocument;
}

- (BOOL)deleteFile {
    for (RLMCapturedImage * image in self.images){
        if(![image deleteFile]){
            return NO;
        }
    }
    self.savedTime = 0;
    return YES;
}

- (BOOL)isFileExist {
    BOOL dir = YES;
    return [[NSFileManager defaultManager] fileExistsAtPath:[self.imageSetPathForDocument absolutePathFromDocument] isDirectory:&dir];
}

@end

#pragma RLMCGPoint
@implementation RLMCGPoint
- (instancetype)initWithCGPoint:(CGPoint)point {
    self = [super init];
    if (self) {
        self.CGPointString = NSStringFromCGPoint(point);
    }
    return self;
}

+ (instancetype)pointWithCGPoint:(CGPoint)point {
    return [[self alloc] initWithCGPoint:point];
}
@end
