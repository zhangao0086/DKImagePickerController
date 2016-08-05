//
// Created by BLACKGENE on 2015. 2. 3..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STElieCamera.h"
#import "STPhotoItem.h"
#import "STItem.h"

@class STFilterItem;
@class STCaptureResponse;

typedef void(^STCaptureResponseHandler)(STCaptureResponse * result);
typedef NS_ENUM(NSInteger, AfterCaptureProcessingPriority){
    AfterCaptureProcessingPriorityDefault,
    AfterCaptureProcessingPriorityIdle,
    AfterCaptureProcessingPriorityLow,
    AfterCaptureProcessingPriorityHigh,
    AfterCaptureProcessingPriorityFirst
};

typedef NS_ENUM(NSInteger, CaptureOutputPixelSizePreset) {
    CaptureOutputPixelSizePresetSmall,
    CaptureOutputPixelSizePresetMedium,
    CaptureOutputPixelSizePresetLarge,
    CaptureOutputPixelSizePreset4K,
    CaptureOutputPixelSizePreset_count
};

/*
https://en.wikipedia.org/wiki/List_of_common_resolutions
Size * 3/4
 */
typedef NS_ENUM(NSInteger, CaptureOutputPixelSize) {
    CaptureOutputPixelSize640 = 640,
    CaptureOutputPixelSize800 = 800,
    CaptureOutputPixelSize1024 = 1024,
    CaptureOutputPixelSize1280 = 1280,
    CaptureOutputPixelSize1440_HDV = 1440,
    CaptureOutputPixelSize1920_HD = 1920,
    CaptureOutputPixelSize2048_2K = 2048,
    CaptureOutputPixelSize2480 = 2480,
    CaptureOutputPixelSize3072_3K = 3072,
    CaptureOutputPixelSize3840_4K = 3840
};

@interface STCaptureRequest : STItem

@property (copy) STCaptureResponseHandler responseHandler;

@property (nonatomic, readonly) NSString * uid;
@property (nonatomic, assign) CGRect faceRect;
@property (nonatomic, assign) CGRect faceRectBounds;
@property (nonatomic, assign) AfterCaptureProcessingPriority afterCaptureProcessingPriority;

@property (nonatomic, assign) CGSize captureOutputAspectFillRatio;

@property (nonatomic, assign) CaptureOutputPixelSizePreset captureOutputPixelSizePreset;
@property (nonatomic, assign) CGFloat captureOutputPixelSize;
@property (nonatomic, readwrite) GPUImageOutput <GPUImageInput> * needsFilter;
@property (nonatomic, readwrite) STOrientationItem * needsOrientationItem;
@property (nonatomic, assign) STPhotoItemOrigin origin;

@property (nonatomic, assign) BOOL privacyRestriction;
@property (nonatomic, readwrite) NSDictionary * geoTagMedataData;
@property (nonatomic, assign) BOOL autoEnhanceEnabled;
@property (nonatomic, assign) BOOL tiltShiftEnabled;
@property (nonatomic, assign) BOOL cropAsCenterSquare;

- (void)dispose;

+ (instancetype)requestWithNeedsFilter:(GPUImageOutput <GPUImageInput> *)needsFilter;

+ (instancetype)requestWithResultBlock:(STCaptureResponseHandler)block;

+ (instancetype)request;

+ (NSArray *)supportedPresets;

+ (CGFloat)captureOutputPixelSizeFromPreset:(CaptureOutputPixelSizePreset)preset;

@end