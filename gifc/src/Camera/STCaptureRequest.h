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

typedef NS_ENUM(NSInteger, CaptureOutputSizePreset) {
    CaptureOutputSizePresetSmall,
    CaptureOutputSizePresetMedium,
    CaptureOutputSizePresetLarge,
    CaptureOutputSizePreset4K,
    CaptureOutputSizePreset_count
};

/*
https://en.wikipedia.org/wiki/List_of_common_resolutions
Size * 3/4
 */
typedef NS_ENUM(NSInteger, CaptureOutputPixelDimension) {
    CaptureOutputPixelDimension1024 = 1024,
    CaptureOutputPixelDimension1280 = 1280,
    CaptureOutputPixelDimension1440_HDV = 1440,
    CaptureOutputPixelDimension1920_HD = 1920,
    CaptureOutputPixelDimension2048_2K = 2048,
    CaptureOutputPixelDimension2480 = 2480,
    CaptureOutputPixelDimension3072_3K = 3072,
    CaptureOutputPixelDimension3840_4K = 3840
};

@interface STCaptureRequest : STItem

@property (copy) STCaptureResponseHandler responseHandler;

@property (nonatomic, readonly) NSString * uid;
@property (nonatomic, assign) CGRect faceRect;
@property (nonatomic, assign) CGRect faceRectBounds;
@property (nonatomic, assign) AfterCaptureProcessingPriority afterCaptureProcessingPriority;
@property (nonatomic, assign) CaptureOutputSizePreset captureOutputSizePreset;
@property (nonatomic, readonly) CGFloat captureOutputPixelSizeForCurrentPreset;
@property (nonatomic, readwrite) STFilterItem * needsFilterItem;
@property (nonatomic, readwrite) STOrientationItem * needsOrientationItem;
@property (nonatomic, assign) STPhotoItemOrigin origin;

@property (nonatomic, assign) BOOL privacyRestriction;
@property (nonatomic, readwrite) NSDictionary * geoTagMedataData;
@property (nonatomic, assign) BOOL autoEnhanceEnabled;
@property (nonatomic, assign) BOOL tiltShiftEnabled;

- (void)dispose;

+ (instancetype)requestWithNeedsFilterItem:(STFilterItem *)needsFilterItem;

+ (instancetype)requestWithResultBlock:(STCaptureResponseHandler)block;

+ (instancetype)request;

+ (NSArray *)supportedPresets;

- (GPUImageOutput <GPUImageInput> *)createOutput;
@end