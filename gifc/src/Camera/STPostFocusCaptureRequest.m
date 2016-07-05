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

#pragma mark Definition Of Restrict CaptureOutputSizePreset
+ (CaptureOutputSizePreset)restrictCaptureOutputSizePresetByPostFocusMode:(STPostFocusMode)mode targetPreset:(CaptureOutputSizePreset)preset circulate:(BOOL)circulate {
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
                    preset = (CaptureOutputSizePreset) [[supportedPresets st_objectOrNilAtIndex:targetIndex] integerValue];
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