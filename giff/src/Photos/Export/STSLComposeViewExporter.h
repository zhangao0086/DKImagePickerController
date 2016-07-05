//
// Created by BLACKGENE on 2015. 2. 16..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STExporter.h"
#import "STExporterAsyncPreparing.h"

@import Social;

@interface STSLComposeViewExporter : STExporter{
@protected
    SLComposeViewController *_controller;
}

@property (nonatomic, readonly) NSString * SLServiceType;

+ (void)precheckSLServiceAvailables;
@end