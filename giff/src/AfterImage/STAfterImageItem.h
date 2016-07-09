//
// Created by BLACKGENE on 7/8/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"
#import "STRLMFileWritable.h"
#import "RLMCapturedImage.h"

@class STAfterImageLayerItem;

@interface STAfterImageItem : NSDictionary
@property (nonatomic, assign) NSString * uuid;
@property (nonatomic, readwrite) NSArray<STAfterImageLayerItem *> * layers;
@end