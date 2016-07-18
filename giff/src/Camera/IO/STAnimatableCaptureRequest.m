//
// Created by BLACKGENE on 2016. 4. 15..
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAnimatableCaptureRequest.h"


@implementation STAnimatableCaptureRequest {

}

- (void)dispose {
    self.progressHandler = nil;
    [super dispose];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _maxDuration = 1.5;
        _framesPerSecond = 10;
        [self updateDefaultsValues];
    }
    return self;
}

- (void)setFramesPerSecond:(NSUInteger)framesPerSecond {
    NSAssert(framesPerSecond>0, @"framesPerSecond must be higher than 0");
    _framesPerSecond = framesPerSecond;
    [self updateDefaultsValues];
}

- (void)setMaxDuration:(NSTimeInterval)maxDuration {
    NSAssert(maxDuration>0, @"maxDuration must be higher than 0");
    _maxDuration = maxDuration;
    [self updateDefaultsValues];
}

- (void)setFrameCount:(NSUInteger)frameCount {
    NSAssert(frameCount>0,@"frame count must be higer than 0.");
    _frameCount = frameCount;
}

- (void)updateDefaultsValues{
    if(!self.frameCount){
        self.frameCount = (NSUInteger) (_framesPerSecond * _maxDuration);
    }

    if(!_frameCaptureInterval){
        _frameCaptureInterval = 1/(_frameCount/_maxDuration);
    }
}

+ (CGFloat)CaptureOutputSizePresetsPixelSize:(CaptureOutputSizePreset)preset {
    switch(preset){
        case CaptureOutputSizePresetLarge:
            return CaptureOutputPixelDimension1024;
        case CaptureOutputSizePresetMedium:
            return CaptureOutputPixelDimension800;
        case CaptureOutputSizePresetSmall:
            return CaptureOutputPixelDimension640;
        default:
            NSAssert(NO, @"Not supported presets at this request");
            return [self CaptureOutputSizePresetsPixelSize:CaptureOutputSizePresetSmall];
    }
}
@end