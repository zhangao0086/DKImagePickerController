//
// Created by BLACKGENE on 2014. 8. 3..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Photos/Photos.h>
#import "STItem.h"
#import "GPUImage.h"
#import "STElieCamera.h"

@class STFilterItem;
@class STEditorResult;
@class STEditorCommand;
@class STOrientationItem;
@class STCapturedImage;
@class STCapturedImageSet;

@interface STPhotoItem : STItem
//custom image
//TODO: deprecated - 이 3개를 STCapturedImageSet 으로 통합
@property (nonatomic, readwrite) NSURL *sourceForFullResolutionFromURL;
@property (nonatomic, readwrite) NSURL *sourceForFullScreenFromURL;
@property (nonatomic, readwrite) NSURL *sourceForPreviewFromURL;
//captured image
@property (nonatomic, readonly) STCapturedImageSet *sourceForCapturedImageSet;
@property (nonatomic, assign) NSUInteger assigningIndexFromCapturedImageSet;
//photos
@property (nonatomic, readonly) PHAsset *sourceForAsset;
//common properties
@property (nonatomic, readonly) UIImage *previewImage;
@property (nonatomic, readonly) CGSize pixelSizeOfPreviewImage;
@property (nonatomic, readonly) NSString *imageId;
@property (nonatomic, readonly) GPUImagePicture * imageAsGPUImagePicture;
@property (nonatomic, readwrite) STOrientationItem *orientationOriginated;
@property (nonatomic, readonly, getter=isDark) BOOL dark;
//TODO: 비디오 뿐만 아니라 뭔가 이미지 자체가 아니라 대표이미지로 대채할 필요가 있는 아이템이라는 의미로 이름변경
@property (nonatomic, readonly) BOOL sourceAssetIsVideo;

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL marked;
@property (nonatomic, assign) BOOL blanked;
@property (nonatomic, assign) STPhotoItemOrigin origin;
@property (nonatomic, readwrite) NSDictionary * metadataFromCamera;
@property (nonatomic, readonly) NSDate * lastTouchedDate;

@property (nonatomic, readonly, getter=isEdited) BOOL edited;
@property (nonatomic, readonly) BOOL isFilterApplied;
@property (nonatomic, readwrite) STFilterItem *currentFilterItem;
@property (nonatomic, assign) BOOL isModifiedByTool;
@property (nonatomic, readwrite) STEditorResult *toolResult;
@property (nonatomic, readwrite) STEditorCommand *lastToolCommand;

@property (nonatomic, assign) BOOL needsEnhance;

- (instancetype)initWithCapturedImageSet:(STCapturedImageSet *)sourceForCapturedImageSet;

+ (instancetype)itemWithCapturedImageSet:(STCapturedImageSet *)sourceForCapturedImageSet;

- (instancetype)initWithAsset:(PHAsset *)sourceForAsset;

+ (instancetype)itemWithAsset:(PHAsset *)sourceForAsset;

+ (PHAssetResourceType)primaryAssetResourceTypeByPhotoItem:(STPhotoItem *)photoItem;

- (PHAssetMediaSubtype)mediaSubtypesForAsset;

- (void)loadPreviewImage;

- (void)loadPreviewImageWithCurrentEdited;

- (UIImage *)loadFullScreenImage;

- (NSData *)loadFullScreenData;

- (UIImage *)loadFullResolutionImage;

- (NSData *)loadFullResolutionData;

- (void)disposePreviewImage;

+ (UIImage *)createBlankImage:(CGSize)size;

+ (STPhotoItemOrigin)originFromCameraMode:(STCameraMode)mode;

+ (void)savePhotosOrigin:(NSString *)identifier origin:(STPhotoItemOrigin)origin;

+ (STPhotoItemOrigin)photosOrigin:(NSString *)identifier;

+ (NSArray *)photoIdentifiersByOrigin:(STPhotoItemOrigin)origin;

+ (void)clearPhotosOrigins;

- (void)initializePreviewImage:(UIImage *)image;

- (void)clearCurrentEditedAndReloadPreviewImage;

- (void)clearToolEdited;

- (void)destroyGPUImagePicture;

- (CGSize)sourceAssetSizeThatFits:(CGSize)size;

@end