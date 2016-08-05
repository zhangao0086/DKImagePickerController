//
// Created by BLACKGENE on 2015. 2. 3..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STCaptureRequest.h"
#import "NSObject+STUtil.h"
#import "STCaptureResponse.h"
#import "NSNumber+STUtil.h"

@implementation STCaptureRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        _uid = self.st_uid;
    }
    return self;
}

- (void)dealloc {
    [self dispose];
}

- (void)dispose{
    _uid = nil;
    self.needsFilter = nil;
    self.needsOrientationItem = nil;
    self.responseHandler = nil;
}

+ (instancetype)requestWithNeedsFilter:(GPUImageOutput <GPUImageInput> *)needsFilter {
    STCaptureRequest *p = [self request];
    p.needsFilter = needsFilter;
    return p;
}

+ (instancetype)requestWithResultBlock:(STCaptureResponseHandler)block; {
    STCaptureRequest *p = [self request];
    p.responseHandler = block;
    return p;
}

+ (instancetype)request {
    return [[self alloc] init];
}

#pragma mark Capture Pixel Size
+ (NSArray *)supportedPresets{
    static NSArray * _supportedPresets;
    @synchronized (self) {
        if(!_supportedPresets){
            _supportedPresets = [@(CaptureOutputPixelSizePreset_count) st_intArray];
        }
    }
    return _supportedPresets;
}

- (void)setCaptureOutputPixelSizePreset:(CaptureOutputPixelSizePreset)captureOutputPixelSizePreset {
    _captureOutputPixelSize = [self.class captureOutputPixelSizeFromPreset:captureOutputPixelSizePreset];
}

+ (CGFloat)captureOutputPixelSizeFromPreset:(CaptureOutputPixelSizePreset)preset {
    switch(preset){
        case CaptureOutputPixelSizePreset4K:
            return CaptureOutputPixelSizeConstFullDimension;
        case CaptureOutputPixelSizePresetLarge:
            return CaptureOutputPixelSize3072_3K;
        case CaptureOutputPixelSizePresetMedium:
            return CaptureOutputPixelSize2048_2K;
        default:
            return CaptureOutputPixelSizeConstOptimalFullScreen;
    }
}

@end