//
// Created by BLACKGENE on 6/20/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "PHImageRequestOptions+STUtil.h"


@implementation PHImageRequestOptions (STUtil)

+ (PHImageRequestOptions *)synchronousOptions {
    static PHImageRequestOptions *_instance = nil;
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
            _instance.synchronous = YES;
        }
    }
    return _instance;
}

+ (PHImageRequestOptions *)fullResolutionOptions:(BOOL)synchronous {
    PHImageRequestOptions* options = synchronous ? [self synchronousOptions] :PHImageRequestOptions.new;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    return options;
}

+ (PHImageRequestOptions *)fullScreenOptions:(BOOL)synchronous {
    PHImageRequestOptions* options = synchronous ? [self synchronousOptions] :PHImageRequestOptions.new;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    return options;
}

@end