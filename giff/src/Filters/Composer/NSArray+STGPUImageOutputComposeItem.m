//
// Created by BLACKGENE on 8/23/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "NSArray+STGPUImageOutputComposeItem.h"
#import "STGPUImageOutputComposeItem.h"


@implementation NSArray (STGPUImageOutputComposeItem)

- (NSArray *)composeItemsByCategory:(STGPUImageOutputComposeItemCategory)category{
    NSMutableArray * composers = [NSMutableArray arrayWithCapacity:self.count];
    for(STGPUImageOutputComposeItem * sourceImageComposeItem in self){
        if(sourceImageComposeItem.category == category){
            [composers addObject:sourceImageComposeItem];
        }
    }
    return composers;
}

@end