//
// Created by BLACKGENE on 8/23/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STGPUImageOutputComposeItem.h"

@class STRasterizingImageSourceItem;

@interface STGPUImageOutputComposeItem (Utils)
+ (instancetype)itemForComposerMask:(STRasterizingImageSourceItem *)imageSourceItem size:(CGSize)imageSize;
@end