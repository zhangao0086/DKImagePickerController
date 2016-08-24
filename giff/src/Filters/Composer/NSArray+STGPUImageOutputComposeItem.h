//
// Created by BLACKGENE on 8/23/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STGPUImageOutputComposeItem.h"

@interface NSArray (STGPUImageOutputComposeItem)
- (NSArray<STGPUImageOutputComposeItem *> *)composeItemsByCategory:(STGPUImageOutputComposeItemCategory)category;

- (NSArray<STGPUImageOutputComposeItem *> *)concatOtherComposers:(NSArray<STGPUImageOutputComposeItem *> *)otherComposers blender:(GPUImageTwoInputFilter *)filter orderByMix:(BOOL)orderByMix;
@end