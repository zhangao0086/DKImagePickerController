//
// Created by BLACKGENE on 4/23/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STPostFocusCaptureRequest.h"
#import "NSArray+STUtil.h"


@implementation STPostFocusCaptureRequest {

}

- (void)setIndexOfFocusPointsOfInterestSet:(NSUInteger)indexOfFocusPointsOfInterestSet {
    BOOL hasIndex = [self.focusPointsOfInterestSet st_objectOrNilAtIndex:indexOfFocusPointsOfInterestSet] != nil;
    NSAssert(hasIndex,@"setFocusPointsOfInterestSet first.");
    if(hasIndex){
        _indexOfFocusPointsOfInterestSet = indexOfFocusPointsOfInterestSet;
    }else{
        _indexOfFocusPointsOfInterestSet = 0;
    }
}

- (void)setFocusPointsOfInterestSet:(NSArray *)focusPointsOfInterestSet {
    NSAssert(self.outputSizeForFocusPoints.width>0 && self.outputSizeForFocusPoints.height>0, @"set valid outputSizeForFocusPoint first.");
    _focusPointsOfInterestSet = focusPointsOfInterestSet;

    CGSize size = self.outputSizeForFocusPoints;
    _focusPointsInOutputSize = [_focusPointsOfInterestSet mapWithIndex:^id(id object, NSInteger index) {
        CGPoint p = [object CGPointValue];
        return [NSValue valueWithCGPoint:CGPointMake(size.width*p.x,size.height*p.y)];
    }];
}

- (CGPoint)defaultFocusPointsOfInterest {
    return [[self.focusPointsOfInterestSet st_objectOrNilAtIndex:self.indexOfFocusPointsOfInterestSet] CGPointValue];
}

#pragma mark Capture Output Presets
+ (NSArray *)supportedPresets{
    static NSArray * _supportedPresets;
    @synchronized (self) {
        if(!_supportedPresets){
            switch ([STApp deviceModelFamily]){
                case STDeviceModelFamilyNotHandled:
                    _supportedPresets = @[
                            @(CaptureOutputPixelSizePresetSmall),
                            @(CaptureOutputPixelSizePresetLarge)
                    ];
                    break;

                case STDeviceModelFamilyIPadPro:
                case STDeviceModelFamilyIPhone6s:
                case STDeviceModelFamilyIPhoneSE:
                case STDeviceModelFamilyUpComming:
                    _supportedPresets = @[
                            @(CaptureOutputPixelSizePresetSmall),
                            @(CaptureOutputPixelSizePresetMedium),
                            @(CaptureOutputPixelSizePresetLarge),
                            @(CaptureOutputPixelSizePreset4K)
                    ];
                    break;

                default:
                    _supportedPresets = @[
                            @(CaptureOutputPixelSizePresetSmall),
                            @(CaptureOutputPixelSizePresetMedium),
                            @(CaptureOutputPixelSizePresetLarge)
                    ];
                    break;
            }
        }
    }
    return _supportedPresets;
}

+ (CGFloat)captureOutputPixelSizeFromPreset:(CaptureOutputPixelSizePreset)preset {
    switch ([STApp deviceModelFamily]){
        case STDeviceModelFamilyNotHandled:
            switch(preset){
                case CaptureOutputPixelSizePresetLarge:
                    return CaptureOutputPixelSize1920_HD;
                default:
                    return CaptureOutputPixelSize1024;
            }
        case STDeviceModelFamilyIPadPro:
        case STDeviceModelFamilyIPhone6s:
        case STDeviceModelFamilyIPhoneSE:
        case STDeviceModelFamilyUpComming:
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
        case STDeviceModelFamilyIPhone6:
        case STDeviceModelFamilyCurrentIPad:
            switch(preset){
                case CaptureOutputPixelSizePresetLarge:
                    return CaptureOutputPixelSize3072_3K;
                case CaptureOutputPixelSizePresetMedium:
                    return CaptureOutputPixelSize1920_HD;
                default:
                    return CaptureOutputPixelSize1280;
            }
        default:
            switch(preset){
                case CaptureOutputPixelSizePresetLarge:
                    return CaptureOutputPixelSize2480;
                case CaptureOutputPixelSizePresetMedium:
                    return CaptureOutputPixelSize1920_HD;
                default:
                    return CaptureOutputPixelSize1280;
            }
    }
}

#pragma mark Definition Of Restrict CaptureOutputPixelSizePreset
+ (CaptureOutputPixelSizePreset)restrictCaptureOutputPixelSizePresetByPostFocusMode:(STPostFocusMode)mode targetPreset:(CaptureOutputPixelSizePreset)preset circulate:(BOOL)circulate {
    NSArray * const supportedPresets = [self supportedPresets];

    switch ([STApp deviceModelFamily]) {
        case STDeviceModelFamilyIPadPro:
        case STDeviceModelFamilyIPhone6s:
        case STDeviceModelFamilyIPhoneSE:
        case STDeviceModelFamilyUpComming:
            break;

        default:
            switch(mode){
                case STPostFocusMode5Points:
                case STPostFocusModeVertical3Points:{
                    NSUInteger targetIndex = [supportedPresets indexOfObject:@(preset)];
                    NSUInteger const maxSupportedTargetIndex = supportedPresets.count-2;
                    if(targetIndex > maxSupportedTargetIndex){
                        targetIndex = circulate ? 0 : maxSupportedTargetIndex;
                    }
                    // 2nd last preset.
                    preset = (CaptureOutputPixelSizePreset) [[supportedPresets st_objectOrNilAtIndex:targetIndex] integerValue];
                }
                    break;

                default:
                    break;
            }
            break;
    }

    return preset;
}
@end