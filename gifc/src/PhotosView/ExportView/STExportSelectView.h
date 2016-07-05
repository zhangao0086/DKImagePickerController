//
// Created by BLACKGENE on 5/9/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCGridViewDelegate.h"

@class STExporter;


@interface STExportSelectView : STUIView <SCGridViewDelegate>
@property (nonatomic, readwrite) NSArray<NSValue *> *exporterTypes;

@end