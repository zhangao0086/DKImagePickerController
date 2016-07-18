//
// Created by BLACKGENE on 2015. 11. 19..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DirectoryWatcher.h"
#import "TABFileMonitor.h"

@class STCaptureRequest;

@interface STCaptureProcessor : NSObject <DirectoryWatcherDelegate, TABFileMonitorDelegate>

@property(atomic, assign) BOOL watchingStarted;
@property(atomic, readonly) BOOL processing;

+ (STCaptureProcessor *)sharedProcessor;

- (void)clean;

- (void)startWatching;

- (void)stopWatching;

- (void)requestData:(NSData *)capturedImageData request:(STCaptureRequest *)request;
@end