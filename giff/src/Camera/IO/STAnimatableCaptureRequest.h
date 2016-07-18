//
// Created by BLACKGENE on 2016. 4. 15..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCaptureRequest.h"

typedef void (^ STAnimatableCaptureRequestProgressHandler)(double progress, NSUInteger offset, NSUInteger length, BOOL *__nullable stop);
@interface STAnimatableCaptureRequest : STCaptureRequest

/* optional. But low memory + high I/O load.
 * defaults to NO. if YES, Result as Images.
 */
@property(nonatomic, assign) BOOL needsLoadAnimatableImagesToMemory;

/* optional.
 * Defaults is to 3. unit is seconds */
@property(nonatomic, assign) NSTimeInterval maxDuration;

/* optional but important.
 * Defaults to 8.
 * number of frames in seconds (FPS)
 * This option will affect gif file size, memory usage and processing speed. */
@property(nonatomic, assign) NSUInteger framesPerSecond;

/* 1/framesPerSecond
 * unit is seconds
 */
@property(nonatomic, assign) NSTimeInterval frameCaptureInterval;

/* optional but important
 * Defaults is to not set.
 * This option will affect gif file size.
 * How far along the video track we want to move, in seconds. It will automatically assign from duration of video and framesPerSecond. */
@property(nonatomic, assign) NSUInteger frameCount;

/* Defaults to 1. frameCount = (framesPerSecond * maxDuration) / frameSpeedRatio */
@property(nonatomic, assign) CGFloat frameResolution;

/* optional.
 * Defaults to 0,
 * the number of times the GIF will repeat. which means repeat infinitely. */
@property(nonatomic, assign) NSUInteger loopCount;


@property(nonatomic, assign) BOOL autoReverseFrames;

/*
 * progress
 */
@property (nonatomic, copy, nullable) STAnimatableCaptureRequestProgressHandler progressHandler;

@end