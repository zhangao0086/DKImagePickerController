//
// Created by BLACKGENE on 15. 4. 17..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STExporter.h"

@interface STExporter (Handle)
- (void)registDispatchSuccessWhenEnterBackground;

- (void)unregistDispatchSuccessWhenEnterBackground;

- (void)dispatchStartProcessing;

- (void)dispatchStopProcessing;
@end