//
// Created by BLACKGENE on 15. 10. 2..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STQueueManager.h"
#import "STDefine.h"


@implementation STQueueManager {
    dispatch_queue_t initializeQueue;
    dispatch_queue_t initializeBackgroundQueue;
    dispatch_queue_t afterCaptureProcessingQueue;
    dispatch_queue_t ioWriteQueue;
    dispatch_queue_t ioWriteQueueHigh;
    dispatch_queue_t ioReadQueue;
    dispatch_queue_t uiqueue;
}

+ (STQueueManager *)sharedQueue {
    static STQueueManager *_instance;
    BlockOnce(^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (dispatch_queue_t)starting {
    BlockOnce(^{
        initializeQueue = dispatch_queue_create("com.stells.app.start", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(initializeQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    });
    return initializeQueue;
}

- (dispatch_queue_t)startingBackground {
    BlockOnce(^{
        initializeBackgroundQueue = dispatch_queue_create("com.stells.app.startBackground", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(initializeBackgroundQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    });
    return initializeQueue;
}

- (dispatch_queue_t)uiProcessing {
    BlockOnce(^{
        uiqueue = dispatch_queue_create("com.stells.ui.processing", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(uiqueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    });
    return uiqueue;
}

- (dispatch_queue_t)writingIO {
    BlockOnce(^{
        ioWriteQueue = dispatch_queue_create("com.stells.io.write", DISPATCH_QUEUE_CONCURRENT);
        dispatch_set_target_queue(ioWriteQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    });
    return ioWriteQueue;
}

- (dispatch_queue_t)writingIOHigh {
    BlockOnce(^{
        ioWriteQueueHigh = dispatch_queue_create("com.stells.io.writehigh", DISPATCH_QUEUE_CONCURRENT);
        dispatch_set_target_queue(ioWriteQueueHigh, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    });
    return ioWriteQueueHigh;
}

- (dispatch_queue_t)readingIO {
    BlockOnce(^{
        ioReadQueue = dispatch_queue_create("com.stells.io.read", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(ioReadQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    });
    return ioReadQueue;
}

- (dispatch_queue_t)afterCaptureProcessing {
    BlockOnce(^{
        afterCaptureProcessingQueue = dispatch_queue_create("com.stells.capture.after_processing", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(afterCaptureProcessingQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
    });
    return afterCaptureProcessingQueue;
}
@end