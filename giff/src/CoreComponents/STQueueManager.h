//
// Created by BLACKGENE on 15. 10. 2..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface STQueueManager : NSObject
+ (STQueueManager *)sharedQueue;

- (dispatch_queue_t)starting;

- (dispatch_queue_t)startingBackground;

- (dispatch_queue_t)afterCaptureProcessing;

- (dispatch_queue_t)uiProcessing;

- (dispatch_queue_t)writingIO;

- (dispatch_queue_t)writingIOHigh;

- (dispatch_queue_t)readingIO;
@end