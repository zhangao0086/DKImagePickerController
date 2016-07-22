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
            _supportedPresets = [@(CaptureOutputSizePreset_count) st_intArray];
        }
    }
    return _supportedPresets;
}

- (CGFloat)captureOutputPixelSizeForCurrentPreset {
    return [self.class CaptureOutputSizePresetsPixelSize:self.captureOutputSizePreset];
}

+ (CGFloat)CaptureOutputSizePresetsPixelSize:(CaptureOutputSizePreset)preset {
    switch(preset){
        case CaptureOutputSizePreset4K:
            return STElieCameraCurrentImageMaxSidePixelSize_FullDimension;
        case CaptureOutputSizePresetLarge:
            return CaptureOutputPixelDimension3072_3K;
        case CaptureOutputSizePresetMedium:
            return CaptureOutputPixelDimension2048_2K;
        default:
            return STElieCameraCurrentImageMaxSidePixelSize_OptimalFullScreen;
    }
}

@end