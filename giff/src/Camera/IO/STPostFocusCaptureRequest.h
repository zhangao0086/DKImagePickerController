//
// Created by BLACKGENE on 4/23/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STAnimatableCaptureRequest.h"


@interface STPostFocusCaptureRequest : STAnimatableCaptureRequest
@property(nonatomic, assign) NSUInteger indexOfFocusPointsOfInterestSet;
@property(nonatomic, readonly) CGPoint defaultFocusPointsOfInterest;

@property(nonatomic, assign) NSArray * focusPointsOfInterestSet;
@property(nonatomic, readonly) NSArray * focusPointsInOutputSize;
@property(nonatomic, assign) CGSize outputSizeForFocusPoints;

+ (CaptureOutputSizePreset)restrictCaptureOutputSizePresetByPostFocusMode:(STPostFocusMode)mode targetPreset:(CaptureOutputSizePreset)preset circulate:(BOOL)circulate;
@end