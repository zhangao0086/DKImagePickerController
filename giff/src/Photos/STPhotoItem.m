//
// Created by BLACKGENE on 2014. 8. 3..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <BlocksKit/NSArray+BlocksKit.h>
#import "STPhotoItem.h"
#import "STFilter.h"
#import "UIImage+STUtil.h"
#import "STEditorResult.h"
#import "STEditorCommand.h"
#import "STExporter.h"
#import "STExporter+IO.h"
#import "NSObject+STUtil.h"
#import "NSString+STUtil.h"
#import "NSArray+STUtil.h"
#import "STCapturedImage.h"
#import "STCapturedImageSet.h"
#import "STCapturedImageSetProtected.h"
#import "PHAsset+STUtil.h"

@implementation STPhotoItem {
    GPUImagePicture * _imageAsGPUImagePicture;
    NSUInteger _imageIsDarkFlag;
    PHAsset * _sourceForAsset;

    UIImage * _previewImage;
}

#pragma mark Source
- (instancetype)initWithAsset:(PHAsset *)sourceForAsset{
    self = [super init];
    if (self) {
        _sourceForAsset = sourceForAsset;
        _lastTouchedDate = _sourceForAsset.modificationDate;
    }
    return self;
}

- (instancetype)initWithCapturedImageSet:(STCapturedImageSet *)sourceForCapturedImageSet {
    self = [super init];
    if (self) {
        _sourceForCapturedImageSet = sourceForCapturedImageSet;
    }

    return self;
}

+ (instancetype)itemWithCapturedImageSet:(STCapturedImageSet *)sourceForCapturedImageSet {
    return [[self alloc] initWithCapturedImageSet:sourceForCapturedImageSet];
}


+ (instancetype)itemWithAsset:(PHAsset *)sourceForAsset {
    return [[self alloc] initWithAsset:sourceForAsset];
}

- (void)setSourceForPreviewFromURL:(NSURL *)sourceForPreviewFromURL {
    _sourceForPreviewFromURL = sourceForPreviewFromURL;

    @try {
        _lastTouchedDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:[_sourceForPreviewFromURL path] error:nil] fileModificationDate];
    }@finally {}
}

#pragma mark CapturedImageStorage

- (void)setAssigningIndexFromCapturedImageSet:(NSUInteger)assigningIndexFromCapturedImageSet {
    NSParameterAssert(_sourceForCapturedImageSet);
    if(!_sourceForCapturedImageSet){
        return;
    }

    _assigningIndexFromCapturedImageSet = assigningIndexFromCapturedImageSet;
    
    STCapturedImage * image = [self.sourceForCapturedImageSet.images st_objectOrNilAtIndex:_assigningIndexFromCapturedImageSet];
    NSAssert(image, @"not found image of given index");
    self.sourceForCapturedImageSet.indexOfDefaultImage = assigningIndexFromCapturedImageSet;
    [self loadPreviewImage];
}

#pragma mark Sources Attributes
+ (PHAssetResourceType)primaryAssetResourceTypeByPhotoItem:(STPhotoItem *)photoItem{
    switch (photoItem.origin){
        case STPhotoItemOriginAssetVideo:
            return PHAssetResourceTypeVideo;

        case STPhotoItemOriginAssetLivePhoto:
            return PHAssetResourceTypePairedVideo;

        default:
            return PHAssetResourceTypePhoto;
    }
}

- (PHAssetMediaSubtype)mediaSubtypesForAsset {
    if(self.sourceForAsset){
        return self.sourceForAsset.mediaSubtypes;
    }
    return PHAssetMediaSubtypeNone;
}

- (PHAssetMediaType)mediaTypeForAsset {
    if(self.sourceForAsset){
        return self.sourceForAsset.mediaType;
    }
    return PHAssetMediaTypeUnknown;
}

- (CGSize)sourceAssetSizeThatFits:(CGSize)size{
    return CGSizeMake([[self sourceForAsset] pixelWidth]*(size.height/[[self sourceForAsset] pixelHeight]),size.height);
}

#pragma mark Core Image Providers
- (void)loadPreviewImage {
    UIImage * loadedImage = nil;

    if(self.blanked){
        Weaks
        loadedImage = [self st_cachedImage:@"stphotoitem.blankimage" useDisk:YES init:^UIImage * {
            return [Wself.class createBlankImage:CGSizeByScale([STElieCamera.sharedInstance preferredOutputScreenSize], .5)];
        }];

    }else if(self.sourceForAsset){
        PHImageRequestOptions * options = [PHImageRequestOptions alloc];
//        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.synchronous = YES;

        __block UIImage * resultImage = nil;
        [[PHImageManager defaultManager] requestImageForAsset:self.sourceForAsset
                                                   targetSize:CGSizeByScale([UIScreen mainScreen].bounds.size, .5)
                                                  contentMode:PHImageContentModeAspectFit
                                                      options:options
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
            resultImage = result;
        }];
        loadedImage = resultImage;

    }else if(self.sourceForPreviewFromURL){
        loadedImage = [UIImage imageWithContentsOfFile:self.sourceForPreviewFromURL.path];

    }else if(self.sourceForCapturedImageSet){
        if([self.sourceForCapturedImageSet defaultImage].thumbnailUrl){
            loadedImage = [UIImage imageWithContentsOfFile:[self.sourceForCapturedImageSet defaultImage].thumbnailUrl.path];
        }
        if(!loadedImage){
            loadedImage = [self.sourceForCapturedImageSet.defaultImage UIImage];
        }
    }

    [self _setPreviewImage:loadedImage];
}


- (UIImage *)loadFullScreenImage {
    UIImage * fullscreenImage = nil;
    if(_sourceForAsset){

        if([STApp isCurrentScreenScaleMemorySafe]){
            fullscreenImage = [_sourceForAsset fullScreenImage];

        }else{
            CGSize fullScreenImageSize = CGSizeMakeToFitScreenAsRasterByMinScale(
                    self.sourceForAsset.pixelWidth,
                    self.sourceForAsset.pixelHeight,
                    TwiceMaxScreenScale(),
                    ![STApp isCurrentScreenScaleMemorySafe]
            );

            //FIXME : possible to fire a crash when apply a filter. if stability of image filter processing is higher than now, appliy this.
            PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            options.synchronous = YES;
            __block UIImage * resultImage = nil;
            [[PHImageManager defaultManager] requestImageForAsset:self.sourceForAsset targetSize:fullScreenImageSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
                resultImage = result;
            }];
            fullscreenImage = resultImage;
        }
    }else if(_sourceForFullScreenFromURL){
        fullscreenImage = [UIImage imageWithContentsOfFile:_sourceForFullScreenFromURL.path];
        if(!fullscreenImage){
            fullscreenImage = self.previewImage;
        }
    }else if(_sourceForCapturedImageSet){
        fullscreenImage = [self.sourceForCapturedImageSet.defaultImage UIImage];
        if(!fullscreenImage){
            fullscreenImage = self.previewImage;
        }
    }

    return fullscreenImage;
}

- (NSData *)loadFullScreenData {
    if(_sourceForAsset){
        //TODO: huh,,, fast way to full screen DATA??
        return UIImageJPEGRepresentation([self loadFullScreenImage], .8);

    }else if(_sourceForFullScreenFromURL){
        NSData * data = [NSData dataWithContentsOfFile:_sourceForFullScreenFromURL.path];
        if(!data || !data.length){
            data = [self loadFullResolutionData];
        }
        return data;
    }else if(_sourceForCapturedImageSet){
        NSData * data = _sourceForCapturedImageSet.defaultImage.NSData;
        if(!data || !data.length){
            data = [self loadFullResolutionData];
        }
        return data;
    }

    return nil;
}

- (UIImage *)loadFullResolutionImage {
    if(_sourceForAsset){
        return [_sourceForAsset fullResolutionImage];

    }else if(_sourceForFullResolutionFromURL){
        return [UIImage imageWithContentsOfFile:_sourceForFullResolutionFromURL.path];

    }else if(_sourceForCapturedImageSet){
        return _sourceForCapturedImageSet.defaultImage.UIImage;
    }

    return nil;
}

- (NSData *)loadFullResolutionData; {
    if(_sourceForAsset){
        return [_sourceForAsset fullResolutionData];

    }else if(_sourceForFullResolutionFromURL){
        return [NSData dataWithContentsOfURL:_sourceForFullResolutionFromURL];

    }else if(_sourceForCapturedImageSet){
        return _sourceForCapturedImageSet.defaultImage.NSData;
    }
    return nil;
}

#pragma mark Load/Set Preview Image
- (UIImage *)previewImage; {
    if(_previewImage){
        return _previewImage;
    }

    [self loadPreviewImage];

    return _previewImage;
}

- (void)disposePreviewImage{
    [self _setPreviewImage:nil];
}

- (void)_setPreviewImage:(UIImage *)image; {
    @synchronized (self) {
        _previewImage = image;
    }
}

- (CGSize)pixelSizeOfPreviewImage {
    if(_sourceForAsset){
        if(self.sourceForAsset.pixelWidth){
            return CGSizeMake(self.sourceForAsset.pixelWidth,self.sourceForAsset.pixelHeight);
        }else{
            return self.previewImage.size;
        }

    }else if(_sourceForFullResolutionFromURL){
        return self.previewImage.size;

    }else if(_sourceForCapturedImageSet){
        return _sourceForCapturedImageSet.defaultImage.pixelSize;

    }else{
        return self.previewImage.size;
    }
}

#pragma mark Live Photo / Video
- (void)loadLivePhoto{
    if(![STApp isLivePhotoCompatible]){
        return;
    }

    NSArray * resources = [PHAssetResource assetResourcesForAsset:self.sourceForAsset];
    [resources bk_each:^(PHAssetResource * resource) {
        ii(resource.type);
        oo(resource.originalFilename);
    }];

    PHAssetResource * resource = [resources firstObject];

    [[PHAssetResourceManager defaultManager] writeDataForAssetResource:[resources firstObject] toFile:[resource.originalFilename URLForTemp] options:nil completionHandler:^(NSError *error) {
        oo(error);
    }];

//    PHLivePhotoRequestOptions *livePhotoOptions = [[PHLivePhotoRequestOptions alloc] init];
//    livePhotoOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
//    livePhotoOptions.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
//        // this block is in NOT main thread.
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//        });
//    };
//
//    [[PHImageManager defaultManager] requestLivePhotoForAsset:self.sourceForAsset targetSize:size contentMode:PHImageContentModeDefault options:livePhotoOptions resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
//        if (!livePhoto) {
//            return;
//        }
//
//        if([info[PHImageCancelledKey] boolValue] || [info[PHImageErrorKey] boolValue]){
//
//        }
//
//        if (![info[PHImageResultIsDegradedKey] boolValue]) {
//
//        }
//    }];

//    [NSGIF optimalGIFfromURL:photoItem.fullResolutionURL loopCount:0 completion:^(NSURL *GifURL) {
//        oo(GifURL);
//    }];

    //create live photo
//    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
//        //These types should be inferred from your files
//
//        //PHAssetResourceCreationOptions *photoOptions = [[PHAssetResourceCreationOptions alloc] init];
//        //photoOptions.uniformTypeIdentifier = @"public.jpeg";
//
//        //PHAssetResourceCreationOptions *videoOptions = [[PHAssetResourceCreationOptions alloc] init];
//        //videoOptions.uniformTypeIdentifier = @"com.apple.quicktime-movie";
//
//        [request addResourceWithType:PHAssetResourceTypePhoto fileURL:photoURL options:nil /*photoOptions*/];
//        [request addResourceWithType:PHAssetResourceTypePairedVideo fileURL:videoURL options:nil /*videoOptions*/];
//    }];

    //get PHLivePhoto
//    PHLivePhotoRequestOptions *livePhotoOptions = [[PHLivePhotoRequestOptions alloc] init];
//    livePhotoOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
//    livePhotoOptions.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
//        // this block is in NOT main thread.
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//        });
//    };
//
//    [[PHImageManager defaultManager] requestLivePhotoForAsset:self.asset targetSize:size contentMode:PHImageContentModeDefault options:livePhotoOptions resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
//        if (!livePhoto) {
//            return;
//        }
//
//        if([info[PHImageCancelledKey] boolValue] || [info[PHImageErrorKey] boolValue]){
//
//        }
//
//        if (![info[PHImageResultIsDegradedKey] boolValue]) {
//
//        }
//    }];

    //live photo url
//    PHAssetResourceManager.defaultManager().writeDataForAssetResource(assetRes,
//            toFile: fileURL, options: nil, completionHandler:
//    {
//        // Video file has been written to path specified via fileURL
//    }
//
}

#pragma mark Helper

- (BOOL)isDark {
    if(_imageIsDarkFlag==0){
        _imageIsDarkFlag = [self.previewImage isDarkImage:.6] ? 2 : 1;
    }
    return _imageIsDarkFlag==2;
}

- (void)setBlanked:(BOOL)blanked; {
    _blanked = blanked;
    if(blanked){
        self.selected = NO;
        self.origin = STPhotoItemOriginUndefined;
        _lastTouchedDate = nil;
    }
}

- (NSString *)imageId; {
    if(_sourceForAsset){
        return _sourceForAsset.localIdentifier;
    }else if(_sourceForPreviewFromURL){
        return [_sourceForPreviewFromURL lastPathComponent];
    }else if(_sourceForCapturedImageSet){
        return _sourceForCapturedImageSet.defaultImage.uuid;
    }

    return [@(self.index) stringValue];
}

+ (UIImage *)createBlankImage:(CGSize)size {
    return [UIImage imageAsColor:[STStandardUI blankBackgroundColor] withSize:size];
}

#pragma mark Edited
- (BOOL)isEdited{
    return self.isFilterApplied || self.isModifiedByTool || self.needsEnhance;
}

- (void)clearToolEdited; {
    self.toolResult = nil;
    self.lastToolCommand = nil;
}

- (void)loadPreviewImageWithCurrentEdited {
    NSAssert(_currentFilterItem, @"must be assigned _currentFilter before called.");

    [self loadPreviewImage];

    [self _setPreviewImage:[STExporter buildImage:self inputImage:self.previewImage enhance:self.needsEnhance]];
}

- (void)clearCurrentEditedAndReloadPreviewImage {
    if(self.isFilterApplied){
        self.currentFilterItem = nil;
    }

    if(self.isModifiedByTool){
        self.toolResult = nil;
    }

    self.needsEnhance = NO;

    [self loadPreviewImage];
}

- (BOOL)isFilterApplied; {
    return self.currentFilterItem!=nil && STFilterSourceCLUT==self.currentFilterItem.source;
}


- (void)loadPreviewImageAsFullScreenSized {
    [self _setPreviewImage:[self loadFullScreenImage]];
}

- (void)initializePreviewImage:(UIImage *)image{
    [self _setPreviewImage:image];
}

#pragma mark GPUImage
- (void)destroyGPUImagePicture{
    if(_imageAsGPUImagePicture){
        if([_imageAsGPUImagePicture targets]){
            [_imageAsGPUImagePicture removeAllTargets];
        }
        _imageAsGPUImagePicture = nil;
    }
}

#pragma mark Origin
+ (STPhotoItemOrigin)originFromCameraMode:(STCameraMode)mode{
    switch (mode){
        case STCameraModeElie:
        case STCameraModeManualWithElie:
            return STPhotoItemOriginElie;

        case STCameraModeManual:
        case STCameraModeManualQuick:
            return STPhotoItemOriginManualCamera;

        default:
            return STPhotoItemOriginUndefined;
    }
}

NSString * const PhotosOriginPersistantKey = @"STPhotosOriginKey";
+ (void)savePhotosOrigin:(NSString *)identifier origin:(STPhotoItemOrigin)origin{
    NSParameterAssert(identifier);
    NSString * key = identifier;
    if(key){
        NSDictionary * originsDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:PhotosOriginPersistantKey];
        NSMutableDictionary * origins = originsDict ? [originsDict mutableCopy] : [NSMutableDictionary dictionary];
        origins[key] = @(origin);
        [[NSUserDefaults standardUserDefaults] setValue:origins forKey:PhotosOriginPersistantKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (STPhotoItemOrigin)photosOrigin:(NSString *)identifier {
    NSDictionary * dictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:PhotosOriginPersistantKey];
    return dictionary && [dictionary hasKey:identifier] ? (STPhotoItemOrigin)[dictionary[identifier] integerValue] : STPhotoItemOriginUndefined;
}

+ (NSArray *)photoIdentifiersByOrigin:(STPhotoItemOrigin)origin{
    NSDictionary * dictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:PhotosOriginPersistantKey];
    return [dictionary allKeysForObject:@(origin)];
}

+ (void)clearPhotosOrigins{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PhotosOriginPersistantKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (STPhotoItemOrigin)origin {
    if(_origin == STPhotoItemOriginUndefined){
        // 1st : from Setting._photosOrigins
        _origin = [self.class photosOrigin:[self imageId]];

        // 2nd : if it has not found, fetch from file format
        if(_origin == STPhotoItemOriginUndefined){

            if(self.sourceForAsset){
                if (self.mediaTypeForAsset == PHAssetMediaTypeVideo) {
                    return (_origin = STPhotoItemOriginAssetVideo);

                }else if (self.mediaSubtypesForAsset & PHAssetMediaSubtypePhotoLive){
                    return (_origin = STPhotoItemOriginAssetLivePhoto);
                }
            }else if(self.sourceForCapturedImageSet){

                switch(self.sourceForCapturedImageSet.type){
                    case STCapturedImageSetTypeAnimatable:
                        _origin = STPhotoItemOriginAnimatable;
                        break;
                    case STCapturedImageSetTypePostFocus:
                        _origin = STPhotoItemOriginPostFocus;
                        break;
                }

            }
        }
    }
    return _origin;
}

#pragma mark Modify from Tool

- (BOOL)isModifiedByTool; {
    return self.toolResult && self.toolResult.modified;
}

- (void)dealloc; {
    [self disposePreviewImage];
    self.toolResult = nil;
    [self destroyGPUImagePicture];
}

@end